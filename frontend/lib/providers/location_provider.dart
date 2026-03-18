import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../constants.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  Timer? _trackingTimer;
  bool _isTracking = false;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;

  final String baseUrl = ApiConstants.baseUrl;

  Future<String> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'service_disabled';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'permission_denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'permission_permanently_denied';
    }

    return 'granted';
  }

  Future<String> startTracking(UserModel user) async {
    if (_isTracking) return 'already_tracking';

    // Step 1: Check & request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return 'permission_permanently_denied';
    }
    if (permission == LocationPermission.denied) {
      return 'permission_denied';
    }

    // Step 2: Check GPS — request service directly if turned off
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Use the 'location' package to request service enablement via system popup
      loc.Location locationService = loc.Location();
      serviceEnabled = await locationService.requestService();

      if (!serviceEnabled) {
        // Fallback or retry loop if requestService returns false immediately or user cancels
        // Poll every 1 second for a short duration while waiting for service to be enabled
        for (int i = 0; i < 5; i++) {
          await Future.delayed(const Duration(seconds: 1));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (serviceEnabled) break;
        }
      }

      if (!serviceEnabled) {
        return 'service_disabled';
      }
    }

    // Step 3: Start tracking
    _isTracking = true;
    notifyListeners();

    debugPrint('Starting location tracking for user: ${user.username}');
    _updateLocation(user);

    // Periodic update every 5 minutes
    _trackingTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      debugPrint('Periodic location update triggered');
      _updateLocation(user);
    });
    
    return 'success';
  }

  void stopTracking() {
    _trackingTimer?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  Future<void> _updateLocation(UserModel user) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      _currentPosition = position;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl/locations/update_location/'),
        headers: {
          'Authorization': 'Token ${user.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );
      
      debugPrint('Location updated: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Location update error body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Location update error: $e');
    }
  }

  Future<Map<String, dynamic>?> getStudentLocation(UserModel user, int studentProfileId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/locations/?student=$studentProfileId'),
        headers: {'Authorization': 'Token ${user.token}'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.first;
        }
      }
    } catch (e) {
      debugPrint('Get student location error: $e');
    }
    return null;
  }

  Future<void> openSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
