import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screen_balance/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper: match widget by runtime type name string (avoids library-duplication issues)
bool _isType(Element e, String typeName) =>
    e.widget.runtimeType.toString() == typeName;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Scenario 7: App Profile Reset & Returning PIN Validation Test',
      (WidgetTester tester) async {
    // ── 1. Set up a returning (calibrated) user ───────────────────────────────
    SharedPreferences.setMockInitialValues({
      'user_pin': '1234',
      'userProfile':
          '{"name":"Returning User","ageGroup":"18-24","occupation":"Student",'
          '"calibrationPath":"observe","observationDay":7,"isCalibrated":true,'
          '"activeIntentionCard":{"title":"The Intentional Seeker","emoji":"🌱",'
          '"subtitle":"Digital Growth","description":"Calibrated."}}',
    });

    // ── 2. Launch the app ─────────────────────────────────────────────────────
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // Returning user skips Welcome → goes straight to PIN login screen
    expect(find.text('Welcome Back, Returning User'), findsOneWidget,
        reason: 'Returning user should see the PIN login screen directly.');
    expect(find.text('Enter PIN to access your dashboard.'), findsOneWidget);

    // ── 3. Enter incorrect PIN (3 chars won't auto-submit; add a wrong 4th char) ─
    // enterText fires onChanged. A 4-char wrong PIN will auto-submit and show error.
    final pinField = find.byType(TextField);
    await tester.enterText(pinField.first, '9999');
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Invalid PIN code. Please try again.'), findsOneWidget,
        reason: 'Error message should appear for a wrong PIN.');

    // ── 4. Clear field and enter correct PIN ─────────────────────────────────
    // enterText with '1234' (4 chars) auto-submits via onChanged
    await tester.enterText(pinField.first, '1234');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // Verify user reaches the Dashboard
    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'Correct PIN should unlock and navigate to DashboardShell.',
    );

    // ── 5. Tap the logout/reset button ───────────────────────────────────────
    // The logout button is an IconButton with tooltip "Logout & Reset Profile"
    // in the ProfileCardScreen (default tab 0).
    final logoutBtn = find.byTooltip('Logout & Reset Profile');

    // Scroll down if the logout button isn't immediately visible
    if (logoutBtn.evaluate().isEmpty) {
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 400));
      }
    }

    expect(logoutBtn, findsOneWidget,
        reason:
            'Logout & Reset Profile button should be visible in profile tab.');

    await tester.tap(logoutBtn);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));

    // ── 6. After logout: app shows WelcomeScreen (pin was cleared) ───────────
    expect(
      find.byElementPredicate((e) => _isType(e, 'WelcomeScreen')),
      findsOneWidget,
      reason:
          'After profile reset, WelcomeScreen should appear since pin was cleared.',
    );

    debugPrint(
        '✅ Scenario 7 PASSED: Returning user login, incorrect PIN, correct PIN unlock, and profile reset all verified.');
  });
}
