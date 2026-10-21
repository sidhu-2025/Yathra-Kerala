import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yathra_kerala_app/screens/driver_screen.dart';

void main() {
  testWidgets('DriverScreen renders clean portal without Arrived or speed controls', (WidgetTester tester) async {
    final mockDriver = {
      'id': 8,
      'username': 'driver1',
      'name': 'Ramesh Driver',
      'role': 'driver',
      'vehicle_no': 'KL-13-AB-8429',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: DriverScreen(driverUser: mockDriver),
      ),
    );

    // Verify driver details are displayed
    expect(find.text('Driver Portal'), findsOneWidget);
    expect(find.text('Ramesh Driver'), findsOneWidget);
    expect(find.text('KL-13-AB-8429'), findsOneWidget);
    expect(find.text('TURN ON LOCATION'), findsOneWidget);

    // Ensure unwanted controls are NOT present
    expect(find.text('Arrived'), findsNothing);
    expect(find.text('Live Trip Controls'), findsNothing);
    expect(find.text('Current Speed: 45 km/h'), findsNothing);
    expect(find.text('Delay: 5 mins'), findsNothing);

    // Toggle location ON
    await tester.tap(find.text('TURN ON LOCATION'));
    await tester.pump();

    // Verify it changed to TURN OFF LOCATION
    expect(find.text('TURN OFF LOCATION'), findsOneWidget);
  });
}
