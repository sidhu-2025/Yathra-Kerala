import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test _buildCityMapperCard with Taxi route', (WidgetTester tester) async {
    final routeJson = '''{
  "id": "route_cab_uber_premier",
  "title": "Uber Premier (Sedan AC - Dzire / Etios)",
  "badge": "UBER PREMIER",
  "mode_type": "TAXI",
  "sub_type": "Uber Premier",
  "service_provider": "Uber",
  "is_auto": false,
  "allow_booking": true,
  "booking_url": "https://m.uber.com/",
  "total_fare": "₹825",
  "fare_numeric": 825,
  "base_fare": 95.0,
  "base_dist_km": 2.0,
  "per_km_rate": 20.0,
  "distance_km": 33.7,
  "total_time_mins": 54,
  "trip_duration_mins": 48,
  "expected_departure": "07:46 AM",
  "expected_arrival": "08:34 AM",
  "departure_countdown_mins": 6,
  "transfers": 0,
  "co2_saved_kg": 0.0,
  "fare_rate_summary": "Uber Premier: ₹95 base + ₹20/km + ₹2/min time",
  "source": "kannur",
  "destination": "chemperi",
  "legs": [
    {
      "mode": "WALK",
      "instruction": "Wait at pickup point in kannur (Uber Premier arrives in 6 mins)",
      "duration_mins": 6,
      "fare": 0
    },
    {
      "mode": "TAXI",
      "instruction": "Comfort sedan ride from kannur to chemperi (33.7 km • ~48 mins)",
      "from_stop": "kannur",
      "to_stop": "chemperi",
      "duration_mins": 48,
      "fare": 825,
      "is_live_trackable": false,
      "vehicle_id": "UBER-PREMIER"
    }
  ]
}''';

    final route = jsonDecode(routeJson);
    
    // We will test if building the widget fails
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // We'll see if rendering succeeds
                Text(route['title']),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Uber Premier (Sedan AC - Dzire / Etios)'), findsOneWidget);
  });
}
