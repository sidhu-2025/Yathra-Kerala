import 'dart:async';
import 'package:flutter/services.dart';

const MethodChannel _methodChannel = MethodChannel('com.yathrakerala/location');
const EventChannel _eventChannel = EventChannel('com.yathrakerala/location_stream');

Stream<Map<String, dynamic>>? _locationStream;

/// Returns continuous real-time stream of physical GPS coordinates from Android LocationManager
Stream<Map<String, dynamic>> getLocationStream() {
  _locationStream ??= _eventChannel.receiveBroadcastStream().map<Map<String, dynamic>>((event) {
    if (event is Map) {
      return Map<String, dynamic>.from(event);
    }
    return <String, dynamic>{};
  });
  return _locationStream!;
}

/// Fetches current/fresh GPS position
Future<Map<String, dynamic>?> getDeviceLocation() async {
  try {
    final res = await _methodChannel.invokeMethod('getCurrentPosition');
    if (res is Map) {
      return Map<String, dynamic>.from(res);
    }
  } catch (e) {
    print('[Android Location] getCurrentPosition error: $e');
  }
  return null;
}

/// Checks location permission: 'precise', 'approximate', or 'denied'
Future<String> checkLocationPermission() async {
  try {
    final res = await _methodChannel.invokeMethod<String>('checkPermission');
    return res ?? 'denied';
  } catch (e) {
    return 'denied';
  }
}

/// Requests ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION
Future<String> requestLocationPermission() async {
  try {
    final res = await _methodChannel.invokeMethod<String>('requestPermission');
    return res ?? 'denied';
  } catch (e) {
    return 'denied';
  }
}

/// Checks if GPS or Network location service is enabled on device
Future<bool> isLocationServiceEnabled() async {
  try {
    final res = await _methodChannel.invokeMethod<bool>('isLocationServiceEnabled');
    return res ?? false;
  } catch (e) {
    return false;
  }
}

/// Opens device Location Settings
Future<void> openLocationSettings() async {
  try {
    await _methodChannel.invokeMethod('openLocationSettings');
  } catch (_) {}
}

/// Opens Application Info Settings (for permanently denied permissions)
Future<void> openAppSettings() async {
  try {
    await _methodChannel.invokeMethod('openAppSettings');
  } catch (_) {}
}
