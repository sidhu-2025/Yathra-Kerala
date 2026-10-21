import 'package:latlong2/latlong.dart';

/// Strongly-typed, null-safe data model for Indian Railways Live Tracking data
/// compliant with RailRadar API schema and Cloudflare Worker proxy responses.
class TrainLiveStatus {
  final String trainNumber;
  final String trainName;
  final String currentStatus;
  final int delayMinutes;
  final bool hasGps;
  final double? latitude;
  final double? longitude;
  final String currentStation;
  final String currentStationCode;
  final String nextStation;
  final String nextStationCode;
  final String? previousStation;
  final String platform;
  final String? scheduledDeparture;
  final String? actualDeparture;
  final String? scheduledArrival;
  final String? actualArrival;
  final String lastUpdatedAt;
  final List<LatLng> routePolyline;
  final List<TrainRouteStation> routeStations;

  const TrainLiveStatus({
    required this.trainNumber,
    required this.trainName,
    required this.currentStatus,
    required this.delayMinutes,
    required this.hasGps,
    this.latitude,
    this.longitude,
    required this.currentStation,
    required this.currentStationCode,
    required this.nextStation,
    required this.nextStationCode,
    this.previousStation,
    required this.platform,
    this.scheduledDeparture,
    this.actualDeparture,
    this.scheduledArrival,
    this.actualArrival,
    required this.lastUpdatedAt,
    required this.routePolyline,
    required this.routeStations,
  });

  /// Check whether genuine finite non-zero coordinates are present
  bool get hasValidCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      !latitude!.isNaN &&
      !longitude!.isNaN &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180 &&
      !(latitude! == 0.0 && longitude! == 0.0);

  LatLng? get position => hasValidCoordinates ? LatLng(latitude!, longitude!) : null;

  bool get isDelayed => delayMinutes > 0;

  /// Check if the update is older than 30 minutes
  bool get isStale {
    try {
      final dt = DateTime.tryParse(lastUpdatedAt);
      if (dt != null) {
        return DateTime.now().difference(dt.toLocal()).inMinutes > 30;
      }
    } catch (_) {}
    return false;
  }

  /// Human-readable time ago
  String get timeAgoDescription {
    try {
      final dt = DateTime.tryParse(lastUpdatedAt);
      if (dt != null) {
        final diff = DateTime.now().difference(dt.toLocal());
        if (diff.inSeconds < 60) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes % 60}m ago';
        return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return lastUpdatedAt;
  }

  factory TrainLiveStatus.fromJson(Map<String, dynamic> raw) {
    // Unnest if envelope is { "success": true, "data": { ... } }
    final Map<String, dynamic> data =
        raw.containsKey('data') && raw['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(raw['data'])
            : raw;

    final String tNo = (data['train_number'] ?? data['trainNo'] ?? data['number'] ?? '').toString();
    final String tName = (data['train_name'] ?? data['trainName'] ?? data['name'] ?? 'Express').toString();

    // Coordinates extraction
    double? parsedLat;
    double? parsedLng;
    final rawLat = data['latitude'] ?? data['lat'];
    final rawLng = data['longitude'] ?? data['lng'] ?? data['lon'];
    if (rawLat != null && rawLng != null) {
      final l1 = double.tryParse(rawLat.toString());
      final l2 = double.tryParse(rawLng.toString());
      if (l1 != null && l2 != null && l1.isFinite && l2.isFinite) {
        parsedLat = l1;
        parsedLng = l2;
      }
    }

    // Delay & Status
    int delay = 0;
    final rawDelay = data['delay_minutes'] ?? data['delayMinutes'] ?? data['delay'];
    if (rawDelay != null) {
      delay = int.tryParse(rawDelay.toString()) ?? 0;
    }

    final String status = (data['current_status'] ?? data['status'] ?? (delay > 0 ? 'DELAYED $delay MINS' : 'ON TIME')).toString();

    // Stations
    String currStn = 'In Transit';
    String currStnCode = '';
    if (data['current_station'] is Map) {
      currStn = data['current_station']['name'] ?? data['current_station']['station_name'] ?? 'In Transit';
      currStnCode = data['current_station']['code'] ?? '';
    } else if (data['current_station'] != null) {
      currStn = data['current_station'].toString();
      currStnCode = (data['current_station_code'] ?? '').toString();
    }

    String nextStn = 'Upcoming Station';
    String nextStnCode = '';
    if (data['next_station'] is Map) {
      nextStn = data['next_station']['name'] ?? data['next_station']['station_name'] ?? 'Upcoming Station';
      nextStnCode = data['next_station']['code'] ?? '';
    } else if (data['next_station'] != null) {
      nextStn = data['next_station'].toString();
      nextStnCode = (data['next_station_code'] ?? '').toString();
    }

    String? prevStn;
    if (data['previous_station'] is Map) {
      prevStn = data['previous_station']['name'] ?? data['previous_station']['station_name'];
    } else if (data['previous_station'] != null) {
      prevStn = data['previous_station'].toString();
    }

    // Polyline
    final List<LatLng> polylineList = [];
    if (data['polyline'] is List) {
      for (final pt in data['polyline']) {
        if (pt is List && pt.length >= 2) {
          final pLat = double.tryParse(pt[0].toString());
          final pLng = double.tryParse(pt[1].toString());
          if (pLat != null && pLng != null && pLat.isFinite && pLng.isFinite) {
            polylineList.add(LatLng(pLat, pLng));
          }
        }
      }
    }

    // Route stations
    final List<TrainRouteStation> routeStationsList = [];
    final dynamic rawStops = data['route'] ?? data['stops'];
    if (rawStops is List) {
      for (final item in rawStops) {
        if (item is Map<String, dynamic>) {
          routeStationsList.add(TrainRouteStation.fromJson(item));
        } else if (item is Map) {
          routeStationsList.add(TrainRouteStation.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return TrainLiveStatus(
      trainNumber: tNo,
      trainName: tName,
      currentStatus: status,
      delayMinutes: delay,
      hasGps: data['has_gps'] == true || (parsedLat != null && parsedLng != null),
      latitude: parsedLat,
      longitude: parsedLng,
      currentStation: currStn,
      currentStationCode: currStnCode,
      nextStation: nextStn,
      nextStationCode: nextStnCode,
      previousStation: prevStn,
      platform: (data['platform'] ?? '--').toString(),
      scheduledDeparture: data['scheduled_departure']?.toString(),
      actualDeparture: data['actual_departure']?.toString(),
      scheduledArrival: data['scheduled_arrival']?.toString(),
      actualArrival: data['actual_arrival']?.toString(),
      lastUpdatedAt: (data['last_updated_at'] ?? data['last_updated'] ?? DateTime.now().toIso8601String()).toString(),
      routePolyline: polylineList,
      routeStations: routeStationsList,
    );
  }
}

/// Intermediate station stop along train route
class TrainRouteStation {
  final String stationCode;
  final String stationName;
  final String? scheduledArrival;
  final String? actualArrival;
  final String? scheduledDeparture;
  final String? actualDeparture;
  final String? platform;
  final bool isHalt;
  final double? distanceKm;
  final LatLng? coordinates;

  const TrainRouteStation({
    required this.stationCode,
    required this.stationName,
    this.scheduledArrival,
    this.actualArrival,
    this.scheduledDeparture,
    this.actualDeparture,
    this.platform,
    this.isHalt = true,
    this.distanceKm,
    this.coordinates,
  });

  factory TrainRouteStation.fromJson(Map<String, dynamic> json) {
    LatLng? coords;
    final lat = double.tryParse((json['latitude'] ?? json['lat'] ?? '').toString());
    final lng = double.tryParse((json['longitude'] ?? json['lng'] ?? json['lon'] ?? '').toString());
    if (lat != null && lng != null && lat.isFinite && lng.isFinite) {
      coords = LatLng(lat, lng);
    }

    return TrainRouteStation(
      stationCode: (json['station_code'] ?? json['code'] ?? '').toString(),
      stationName: (json['station_name'] ?? json['name'] ?? json['code'] ?? '').toString(),
      scheduledArrival: (json['scheduled_arrival'] ?? json['arr'])?.toString(),
      actualArrival: (json['actual_arrival'] ?? json['act_arr'])?.toString(),
      scheduledDeparture: (json['scheduled_departure'] ?? json['dep'])?.toString(),
      actualDeparture: (json['actual_departure'] ?? json['act_dep'])?.toString(),
      platform: (json['platform'] ?? json['pf'])?.toString(),
      isHalt: json['is_halt'] != false,
      distanceKm: double.tryParse((json['distance_km'] ?? json['distance'] ?? '').toString()),
      coordinates: coords,
    );
  }
}
