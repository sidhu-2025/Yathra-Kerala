# Cloudflare Worker: RailRadar Train Tracking Backend (₹0 Free Tier)

This Cloudflare Worker acts as a secure serverless proxy between your **Yathra Kerala** Flutter app and the **RailRadar API** (`https://api.railradar.in/v1/trains/{trainNumber}/live`).

## Key Security & Architectural Features
1. **Zero Key Exposure**: `RAILRADAR_API_KEY` is saved solely as an encrypted Cloudflare server-side secret. It is **never** embedded in Flutter code, APK files, or source control.
2. **Indian Railways Train Number Validation**: Rejects invalid inputs before contacting upstream RailRadar (`^\d{5}$`).
3. **Smart Edge Caching (120s TTL)**: Repeated requests for the same train number are served directly from Cloudflare's global edge network without consuming upstream RailRadar quota or hitting rate limits.
4. **CORS Safe**: Fully supports cross-origin requests from Flutter Web, Android, and iOS.
5. **Zero Cost (₹0)**: Runs entirely within Cloudflare's Workers Free tier (100,000 requests/day, 10ms CPU per request).

---

## 5-Minute Free Tier Deployment Guide

### Prerequisites
- Node.js (v18 or newer) installed.
- Free account on [Cloudflare](https://dash.cloudflare.com/sign-up) (no credit card required).

### Step 1: Open Terminal in Worker Directory
```bash
cd c:\Users\Asus\OneDrive\Desktop\program\PROJECT\cloudflare_worker_railradar
```

### Step 2: Login to Cloudflare
```bash
npx wrangler login
```
*(This opens a browser tab. Click "Authorize" to connect your free Cloudflare account).*

### Step 3: Set Your RailRadar API Key Secret
Run:
```bash
npx wrangler secret put RAILRADAR_API_KEY
```
When prompted, paste your RailRadar API Key and press Enter.

### Step 4: Deploy the Worker
```bash
npx wrangler deploy
```
Wrangler will output your live worker URL, for example:
```
Published railradar-proxy (0.42 sec)
  https://railradar-proxy.<your-subdomain>.workers.dev
```

### Step 5: Verify the Deployment
Run a curl command or open the URL in your browser:
```bash
# 1. Health check:
curl https://railradar-proxy.<your-subdomain>.workers.dev/health

# 2. Live train track test:
curl https://railradar-proxy.<your-subdomain>.workers.dev/api/trains/12081/live
```

---

## Testing Scenarios

| Scenario | Request | Expected Result |
| :--- | :--- | :--- |
| **Valid Train Search** | `GET /api/trains/12081/live` | HTTP 200 with JSON: status, delay, stations, and GPS coordinates (if broadcasting) |
| **Invalid Train Number** | `GET /api/trains/999/live` | HTTP 400 with `Invalid train number '999'. Indian Railways train numbers must be exactly 5 digits.` |
| **Non-existent Train** | `GET /api/trains/00000/live` | HTTP 404 with `Train #00000 not found or not currently active today in RailRadar system.` |
| **Missing Secret** | `GET /api/trains/12081/live` (before `secret put`) | HTTP 500 with instruction to set secret |
| **Rate Limit / Quota** | Repeated queries within 2 min | Cached at edge (`X-Cache: HIT-CLOUDFLARE-EDGE`), preventing upstream quota consumption |
