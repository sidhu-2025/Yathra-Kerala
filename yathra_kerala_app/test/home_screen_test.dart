import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yathra_kerala_app/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen builds and renders without exception', (WidgetTester tester) async {
    final mockUser = {
      'id': 6,
      'username': 'user1',
      'name': 'Abhijith K',
      'role': 'user',
      'email': 'user1@example.com',
      'phone': '9847001122',
      'vehicle_no': 'KL-13-AB-8429',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(currentUser: mockUser),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
