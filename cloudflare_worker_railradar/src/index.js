/**
 * Cloudflare Worker: Secure RailRadar Live Train Tracking Proxy
 * 
 * Free-tier serverless backend for Indian Railways live train status tracking.
 * - Keeps RAILRADAR_API_KEY securely on the server (never exposed to client).
 * - Validates five-digit Indian train numbers (e.g. 12081, 20631, 16308).
 * - Implements edge caching (120s TTL) to stay well within free tier rate limits.
 * - Safely handles upstream rate limits, missing coordinates, and CORS.
 */

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Requested-With",
  "Access-Control-Max-Age": "86400",
};

export default {
  async fetch(request, env, ctx) {
    // 1. Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: CORS_HEADERS,
      });
    }

    // 2. Only allow GET requests
    if (request.method !== "GET") {
      return jsonResponse(
        { success: false, error: "Method not allowed. Use GET." },
        405
      );
    }

    const url = new URL(request.url);
    const pathname = url.pathname;

    // 3. Health check route
    if (pathname === "/" || pathname === "/health") {
      return jsonResponse({
        status: "ok",
        service: "RailRadar Secure Proxy (Yathra Kerala)",
        version: "1.0.0",
        configured: Boolean(env.RAILRADAR_API_KEY),
        supportedRoutes: [
          "/api/trains/{trainNumber}/live",
          "/v1/trains/{trainNumber}/live"
        ]
      }, 200);
    }

    // 4. Match train live status route: /api/trains/:trainNo/live or /v1/trains/:trainNo/live
    const match = pathname.match(/^\/(?:api|v1)\/trains\/([A-Za-z0-9_-]+)\/live$/);
    if (!match) {
      return jsonResponse(
        {
          success: false,
          error: "Endpoint not found. Expected format: GET /api/trains/{5-digit-trainNumber}/live"
        },
        404
      );
    }

    const trainNo = match[1].replace(/^TRAIN-?/i, "").trim();

    // 5. Strict 5-digit train number validation (Indian Railways standard)
    if (!/^\d{5}$/.test(trainNo)) {
      return jsonResponse(
        {
          success: false,
          error: `Invalid train number '${trainNo}'. Indian Railways train numbers must be exactly 5 digits (e.g. 12081, 20631, 16308).`
        },
        400
      );
    }

    // 6. Check for server secret
    const apiKey = env.RAILRADAR_API_KEY ? env.RAILRADAR_API_KEY.trim() : null;
    if (!apiKey) {
      return jsonResponse(
        {
          success: false,
          error: "Server configuration error: RAILRADAR_API_KEY is not configured on this Cloudflare Worker. Set it using 'wrangler secret put RAILRADAR_API_KEY'."
        },
        500
      );
    }

    // 7. Edge caching check using Cloudflare Cache API
    const cache = caches.default;
    const cacheKey = new Request(url.toString(), request);
    const cachedResponse = await cache.match(cacheKey);

    if (cachedResponse) {
      const responseWithCors = new Response(cachedResponse.body, cachedResponse);
      for (const [k, v] of Object.entries(CORS_HEADERS)) {
        responseWithCors.headers.set(k, v);
      }
      responseWithCors.headers.set("X-Cache", "HIT-CLOUDFLARE-EDGE");
      return responseWithCors;
    }

    // 8. Call upstream RailRadar API
    const upstreamUrl = `https://api.railradar.in/v1/trains/${trainNo}/live`;

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 8000); // 8-second upstream timeout

      const upstreamResp = await fetch(upstreamUrl, {
        method: "GET",
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Accept": "application/json",
          "User-Agent": "YathraKerala-TrainTracker/1.0 (Cloudflare Worker)",
        },
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      // Handle upstream non-200 responses
      if (upstreamResp.status === 401 || upstreamResp.status === 403) {
        return jsonResponse(
          {
            success: false,
            error: "RailRadar API authentication failed. Please verify your RAILRADAR_API_KEY secret."
          },
          502
        );
      }

      if (upstreamResp.status === 429) {
        return jsonResponse(
          {
            success: false,
            error: "RailRadar rate limit exceeded. Please wait a moment before refreshing."
          },
          429
        );
      }

      if (upstreamResp.status === 404) {
        return jsonResponse(
          {
            success: false,
            error: `Train #${trainNo} not found or not currently active today in RailRadar system.`
          },
          404
        );
      }

      if (!upstreamResp.ok) {
        return jsonResponse(
          {
            success: false,
            error: `RailRadar upstream service responded with HTTP status ${upstreamResp.status}.`
          },
          502
        );
      }

      const rawJson = await upstreamResp.json();
      const rawData = (rawJson && (rawJson.data || rawJson)) || {};

      // Parse and validate live GPS coordinates
      let validLat = null;
      let validLng = null;

      const rawLat = rawData.latitude ?? rawData.lat ?? (rawData.coordinates && rawData.coordinates.latitude);
      const rawLng = rawData.longitude ?? rawData.lng ?? rawData.lon ?? (rawData.coordinates && rawData.coordinates.longitude);

      if (rawLat !== null && rawLat !== undefined && rawLng !== null && rawLng !== undefined) {
        const parsedLat = parseFloat(rawLat);
        const parsedLng = parseFloat(rawLng);
        if (Number.isFinite(parsedLat) && Number.isFinite(parsedLng) &&
            parsedLat >= -90 && parsedLat <= 90 &&
            parsedLng >= -180 && parsedLng <= 180 &&
            !(parsedLat === 0 && parsedLng === 0)) {
          validLat = parseFloat(parsedLat.toFixed(5));
          validLng = parseFloat(parsedLng.toFixed(5));
        }
      }

      // Parse station progression
      const currStn = rawData.current_station || rawData.currentStation || rawData.current_stop || "In Transit";
      const currStnName = typeof currStn === "object" ? (currStn.name || currStn.station_name || currStn.code || "In Transit") : String(currStn);
      const currStnCode = typeof currStn === "object" ? (currStn.code || currStn.station_code || "") : "";

      const nextStn = rawData.next_station || rawData.nextStation || rawData.nextHalt || rawData.next_stop || "Upcoming Station";
      const nextStnName = typeof nextStn === "object" ? (nextStn.name || nextStn.station_name || nextStn.code || "Upcoming Station") : String(nextStn);
      const nextStnCode = typeof nextStn === "object" ? (nextStn.code || nextStn.station_code || "") : "";

      const prevStn = rawData.previous_station || rawData.previousStation || rawData.last_stop;
      const prevStnName = prevStn ? (typeof prevStn === "object" ? (prevStn.name || prevStn.station_name || prevStn.code || "") : String(prevStn)) : null;

      const delayMins = parseInt(rawData.delay_minutes ?? rawData.delayMinutes ?? rawData.delay ?? 0, 10) || 0;
      const currStatus = rawData.current_status || rawData.status || (delayMins === 0 ? "ON TIME" : `DELAYED ${delayMins} MINS`);
      const lastUpdated = rawData.last_updated_at || rawData.last_updated || rawData.lastUpdatedAt || new Date().toISOString();

      // Parse route polyline coordinates if available
      let routePolyline = [];
      if (Array.isArray(rawData.polyline)) {
        for (const pt of rawData.polyline) {
          if (Array.isArray(pt) && pt.length >= 2) {
            const pLat = parseFloat(pt[0]);
            const pLng = parseFloat(pt[1]);
            if (Number.isFinite(pLat) && Number.isFinite(pLng)) {
              routePolyline.push([pLat, pLng]);
            }
          }
        }
      }

      // Build standardized, secure response
      const standardizedResponse = {
        success: true,
        source: "RailRadar Live API",
        cached_at: new Date().toISOString(),
        data: {
          train_number: trainNo,
          train_name: rawData.train_name || rawData.trainName || rawData.name || `Train #${trainNo}`,
          current_status: currStatus,
          delay_minutes: delayMins,
          has_gps: Boolean(validLat !== null && validLng !== null),
          latitude: validLat,
          longitude: validLng,
          current_station: currStnName,
          current_station_code: currStnCode,
          next_station: nextStnName,
          next_station_code: nextStnCode,
          previous_station: prevStnName,
          platform: String(rawData.platform || (typeof currStn === "object" && currStn.platform) || "--"),
          scheduled_departure: rawData.scheduled_departure || (typeof currStn === "object" && currStn.scheduled_departure) || null,
          actual_departure: rawData.actual_departure || (typeof currStn === "object" && currStn.actual_departure) || null,
          scheduled_arrival: rawData.scheduled_arrival || (typeof currStn === "object" && currStn.scheduled_arrival) || null,
          actual_arrival: rawData.actual_arrival || (typeof currStn === "object" && currStn.actual_arrival) || null,
          last_updated_at: String(lastUpdated),
          polyline: routePolyline,
          route: Array.isArray(rawData.route) ? rawData.route : []
        }
      };

      // 120-second edge cache headers to protect upstream RailRadar free tier quotas
      const response = new Response(JSON.stringify(standardizedResponse), {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Cache-Control": "public, max-age=120, s-maxage=120",
          "X-Cache": "MISS",
          ...CORS_HEADERS,
        },
      });

      // Save to Cloudflare edge cache asynchronously
      ctx.waitUntil(cache.put(cacheKey, response.clone()));

      return response;

    } catch (err) {
      if (err.name === "AbortError") {
        return jsonResponse(
          { success: false, error: "RailRadar upstream server timed out. Please try again." },
          504
        );
      }
      return jsonResponse(
        { success: false, error: `Proxy network error: ${err.message}` },
        500
      );
    }
  },
};

function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...CORS_HEADERS,
    },
  });
}
