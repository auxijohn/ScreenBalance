import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screen_balance/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper: match widget by runtime type name string (avoids library-duplication issues)
bool _isType(Element e, String typeName) =>
    e.widget.runtimeType.toString() == typeName;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scenario 6: Telemetry Simulator & Somatic Reset Test',
      (WidgetTester tester) async {
    // Mock the device_apps MethodChannel to prevent native querying hangs on modern emulators
    const channel = MethodChannel('g123k/device_apps');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (methodCall) async {
      if (methodCall.method.startsWith('getInstalledApps')) {
        return [];
      }
      return null;
    });

    const cmdChannel = MethodChannel('com.screenbalance.tracker/commands');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(cmdChannel, (methodCall) async {
      if (methodCall.method == 'isAccessibilityServiceEnabled') {
        return true;
      }
      return null;
    });

    // ── 1. Pre-calibrate a profile so we skip onboarding ──────────────────────
    SharedPreferences.setMockInitialValues({
      'user_pin': '1234',
      'userProfile':
          '{"name":"Telemetry User","ageGroup":"18-24","occupation":"Student",'
          '"calibrationPath":"observe","observationDay":7,"isCalibrated":true,'
          '"activeIntentionCard":{"title":"The Intentional Seeker","emoji":"🌱",'
          '"subtitle":"Digital Growth","description":"Calibrated."}}',
    });

    // ── 2. Launch app ──────────────────────────────────────────────────────────
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // Skip WelcomeScreen if present
    if (find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'WelcomeScreen').evaluate().isNotEmpty) {
      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.tap(find.text('Unlock Screen Balance →'));
      await tester.pump(const Duration(milliseconds: 800));
    }

    // Returning user sees PIN screen directly
    expect(find.text('Welcome Back, Telemetry User'), findsOneWidget,
        reason: 'Should land on PIN login screen for calibrated user.');

    // enterText fires onChanged; 4-char input auto-submits via onChanged
    final pinField = find.byType(TextField);
    await tester.enterText(pinField.first, '1234');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Dashboard loaded
    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'DashboardShell should be visible after successful PIN entry.',
    );

    // ── 3. Open the debug Simulator FAB ───────────────────────────────────────
    final bugFab = find.byType(FloatingActionButton);
    await tester.ensureVisible(bugFab);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(bugFab, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 400));

    // Confirm sheet opened — "Dopamine Loop" is always the first visible trigger
    expect(find.text('Dopamine Loop'), findsOneWidget,
        reason: 'Simulator bottom sheet should list Dopamine Loop trigger.');

    // ── 4. Trigger "The Void" (2nd item, always visible in sheet) ─────────────
    // "The Void" uses a 5-checkbox checklist — all checkable instantly.
    expect(find.text('The Void'), findsOneWidget,
        reason: 'The Void trigger should be visible in the bottom sheet.');
    await tester.tap(find.text('The Void'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 400));

    // InterventionOverlayScreen should appear
    expect(
      find.byElementPredicate((e) => _isType(e, 'InterventionOverlayScreen')),
      findsOneWidget,
      reason: 'InterventionOverlayScreen should appear after trigger.',
    );
    expect(find.text('The Void'), findsOneWidget,
        reason: 'Overlay should display "The Void" trigger title.');

    // ── 5. Complete the somatic reset (check all 5 objects) ───────────────────
    // The Void shows CheckboxListTile items: "Object 1" through "Object 5"
    for (int i = 1; i <= 5; i++) {
      final checkboxItem = find.text('Object $i');
      expect(checkboxItem, findsOneWidget,
          reason: 'Checklist item "Object $i" should be present.');
      await tester.tap(checkboxItem);
      await tester.pump(const Duration(milliseconds: 200));
    }

    // "Proceed to Validation" button should now be enabled (all 5 checked)
    final proceedBtn = find.text('Proceed to Validation');
    expect(proceedBtn, findsOneWidget,
        reason:
            'Proceed to Validation should appear after checking all 5 objects.');

    await tester.tap(proceedBtn);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 400));

    // ── 6. PostValidationScreen appears for mood check ────────────────────────
    // After reset completes, InterventionOverlayScreen is gone and
    // PostValidationScreen is pushed onto the Navigator.
    expect(
      find.byElementPredicate((e) => _isType(e, 'PostValidationScreen')),
      findsOneWidget,
      reason: 'PostValidationScreen should appear for mood validation.',
    );
    expect(find.text('Which image aligns with your state?'), findsOneWidget,
        reason: 'Mood check prompt should be visible.');

    // ── 7. Navigate back from PostValidationScreen ─────────────────────────
    // The mood cards are pure CustomPaint canvases (no text labels).
    // Tap the first InkWell (first mood option) to trigger auto-pop.
    final moodCards = find.byType(InkWell);
    expect(moodCards, findsWidgets,
        reason: 'Mood option InkWell cards should be present.');
    await tester.tap(moodCards.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    // Wait for the 600ms Future.delayed auto-pop inside PostValidationScreen
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 400));

    // ── 8. Back on Dashboard ──────────────────────────────────────────────────
    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'DashboardShell should be visible after PostValidationScreen auto-pops.',
    );

    debugPrint(
        '✅ Scenario 6 PASSED: Telemetry trigger "The Void", somatic reset, and mood validation all completed successfully.');
  });
}
