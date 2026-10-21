import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yathra_kerala_app/screens/auth_screen.dart';

void main() {
  testWidgets('AuthScreen renders without overflow on passenger and driver tabs', (WidgetTester tester) async {
    // Standard phone screen size
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(isRoot: true, initialRole: 'user'),
      ),
    );

    // Verify Passenger Sign In is visible
    expect(find.text('Sign In as Passenger'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);

    // Switch to Driver tab
    await tester.tap(find.text('Bus Driver'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In as Driver'), findsOneWidget);

    // Toggle to Sign Up
    await tester.tap(find.text('Sign Up as Driver'));
    await tester.pumpAndSettle();
    expect(find.text('Already have an account? '), findsOneWidget);
    
    // Explicitly verify the mandatory vehicle number field is visible on Driver Sign Up
    expect(find.text('Bus / Vehicle Number * (Mandatory)'), findsOneWidget);

    // Switch back to Passenger tab
    await tester.tap(find.text('User / Passenger'));
    await tester.pumpAndSettle();
  });
}
