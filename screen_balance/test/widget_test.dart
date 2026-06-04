import 'package:flutter_test/flutter_test.dart';
import 'package:screen_balance/main.dart';

void main() {
  testWidgets('App loads welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScreenBalanceApp());

    // Verify that the title text is present.
    expect(find.text('ScreenBalance'), findsWidgets);
  });
}
