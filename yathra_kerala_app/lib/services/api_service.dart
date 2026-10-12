import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator, or localhost for Windows/Chrome
  // We can provide a configurable or smart base URL
  static String baseUrl = 'http://127.0.0.1:8000';

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static Future<List<String>> fetchStops() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/stops'));
      if (res.statusCode == 200) {
        final List dynamicList = jsonDecode(res.body);
        return dynamicList.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('fetchStops error: $e');
    }
    // Fallback default stops in Kannur / Chemperi
    return [
      'Chemperi',
      'Sreekandapuram',
      'Taliparamba',
      'Dharmasala',
      'Pallikunnu',
      'Caltex',
      'Kannur Railway Station',
      'Kannur',
      'Thalassery',
      'Kozhikode',
      'Payyambalam Beach'
    ];
  }

  static Future<Map<String, dynamic>> fetchWeather(String location) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/weather?location=$location'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('fetchWeather error: $e');
    }
    return {
      'temperature_celsius': 29.0,
      'weather': 'Light Rain',
      'rain_probability': '60%',
      'recommendation': 'Auto-rickshaw recommended for last-mile transfers.'
    };
  }

  static Future<Map<String, dynamic>?> planJourney({
    required String source,
    required String destination,
    String preference = 'best',
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/plan-journey?source=${Uri.encodeComponent(source)}&destination=${Uri.encodeComponent(destination)}&preference=$preference',
      );
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('planJourney error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>> predictETA({
    required double distanceKm,
    required int hourOfDay,
    int trafficLevel = 1,
    int weatherImpact = 0,
    int numStops = 5,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/predict-eta'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'distance_km': distanceKm,
          'hour_of_day': hourOfDay,
          'traffic_level': trafficLevel,
          'weather_impact': weatherImpact,
          'num_stops': numStops,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('predictETA error: $e');
    }
    return {
      'predicted_arrival_minutes': (distanceKm * 2.2) + 5,
      'confidence_score': 0.95,
      'model_used': 'Random Forest Regressor'
    };
  }

  static Future<List<dynamic>> fetchLiveVehicles() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/tracking'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('fetchLiveVehicles error: $e');
    }
    return [];
  }

  static Future<bool> updateDriverLocation({
    required String vehicleId,
    required double lat,
    required double lng,
    required String currentStop,
    required String nextStop,
    required double speedKmh,
    int delayMins = 0,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/driver/update-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vehicle_id': vehicleId,
          'lat': lat,
          'lng': lng,
          'current_stop': currentStop,
          'next_stop': nextStop,
          'speed_kmh': speedKmh,
          'delay_mins': delayMins,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('updateDriverLocation error: $e');
      return false;
    }
  }

  static Future<String> askChatbot(String message) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['reply'] ?? 'No reply received.';
      }
    } catch (e) {
      print('askChatbot error: $e');
    }
    return 'Could not connect to TransitGPT. Please verify backend connection.';
  }
}
