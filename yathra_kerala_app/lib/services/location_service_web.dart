import 'dart:async';
import 'dart:html' as html;

StreamController<Map<String, dynamic>>? _webStreamController;
StreamSubscription<html.Geoposition>? _watchSub;

/// Continuous high-accuracy location stream via HTML5 navigator.geolocation.watchPosition
Stream<Map<String, dynamic>> getLocationStream() {
  if (_webStreamController == null || _webStreamController!.isClosed) {
    _webStreamController = StreamController<Map<String, dynamic>>.broadcast(
      onListen: () {
        try {
          final geo = html.window.navigator.geolocation;
          _watchSub = geo.watchPosition(
            enableHighAccuracy: true,
            timeout: const Duration(seconds: 15),
            maximumAge: Duration.zero,
          ).listen((pos) {
            try {
              final coords = pos.coords;
              if (coords != null) {
                final double lat = (coords.latitude ?? 0.0).toDouble();
                final double lng = (coords.longitude ?? 0.0).toDouble();
                final double speed = coords.speed != null ? coords.speed!.toDouble() * 3.6 : 0.0;
                final double accuracy = coords.accuracy != null ? coords.accuracy!.toDouble() : 0.0;
                final double bearing = coords.heading != null ? coords.heading!.toDouble() : 0.0;
                _webStreamController?.add({
                  'lat': lat,
                  'lng': lng,
                  'speed': speed,
                  'accuracy': accuracy,
                  'bearing': bearing,
                  'provider': 'web-gps',
                });
              }
            } catch (_) {}
          }, onError: (_) {});
        } catch (_) {}
      },
      onCancel: () {
        _watchSub?.cancel();
        _watchSub = null;
      },
    );
  }
  return _webStreamController!.stream;
}

/// Fetches the logged-in device's physical GPS coordinates
Future<Map<String, dynamic>?> getDeviceLocation() async {
  try {
    final geo = html.window.navigator.geolocation;
    final pos = await geo.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 15),
      maximumAge: Duration.zero,
    );
    final coords = pos.coords;
    if (coords != null) {
      final double lat = (coords.latitude ?? 0.0).toDouble();
      final double lng = (coords.longitude ?? 0.0).toDouble();
      final double speed = coords.speed != null ? coords.speed!.toDouble() * 3.6 : 0.0;
      final double accuracy = coords.accuracy != null ? coords.accuracy!.toDouble() : 0.0;
      return {
        'lat': lat,
        'lng': lng,
        'speed': speed,
        'accuracy': accuracy,
        'provider': 'web-gps',
      };
    }
  } catch (_) {}
  return null;
}
