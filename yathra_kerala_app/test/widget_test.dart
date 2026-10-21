import 'package:flutter_test/flutter_test.dart';
import 'package:yathra_kerala_app/main.dart';
import 'package:yathra_kerala_app/screens/auth_screen.dart';

void main() {
  testWidgets('App smoke test: YathraKeralaApp loads AuthScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const YathraKeralaApp());
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
