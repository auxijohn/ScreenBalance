import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screen_balance/main.dart';
import 'package:screen_balance/screens/welcome_screen.dart';
import 'package:screen_balance/screens/calibration_confirmation_screen.dart';
import 'package:screen_balance/screens/dashboard_shell.dart';
import 'package:screen_balance/screens/profile_card_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scenario 1 & 3: Onboarding and Passive Observation Path Test', (WidgetTester tester) async {
    // 1. Initialize mock SharedPreferences for clean state
    SharedPreferences.setMockInitialValues({});

    // 2. Launch the app and settle
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify Welcome Screen renders
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('The Dopamine Loop'), findsOneWidget);

    // Tap "Privacy & Offline Guarantee" to verify modal sheet opens
    final privacyBtn = find.text('Privacy & Offline Guarantee');
    await tester.tap(privacyBtn);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Privacy & Offline Data'), findsOneWidget);

    // Close the privacy sheet
    final closePrivacyBtn = find.text('Acknowledge & Close');
    await tester.tap(closePrivacyBtn);
    await tester.pump(const Duration(milliseconds: 800));

    // Step through the slides
    final nextBtn = find.text('Next Step').first;
    await tester.tap(nextBtn);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Calm Conscious Resets'), findsOneWidget);

    await tester.tap(nextBtn);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Reclaim Your Focus'), findsOneWidget);

    // Click "Get Started" to proceed to Registration Form
    final getStartedBtn = find.text('Get Started').first;
    await tester.tap(getStartedBtn);
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify Registration Form
    expect(find.text('Create Local Profile'), findsOneWidget);

    // Fill registration details
    await tester.enterText(find.byType(TextFormField).first, 'Observation User');
    await tester.enterText(find.byType(TextFormField).last, '4321');
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    await tester.pump(const Duration(milliseconds: 800));

    // Submit form
    final continueBtn = find.text('Continue to Onboarding');
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pump(const Duration(milliseconds: 1200));

    // Verify Calibration Confirmation page
    expect(find.byType(CalibrationConfirmationScreen), findsOneWidget);

    // Scroll page down to bring bottom options into view
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -450));
    await tester.pump(const Duration(milliseconds: 800));

    // Check the consent box
    final consentCheckbox = find.byType(CheckboxListTile);
    await tester.ensureVisible(consentCheckbox);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -100));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(consentCheckbox);
    await tester.pump(const Duration(milliseconds: 800));

    // Select "7-Day Background Calibration" path
    final calibrationOption = find.text('7-Day Background Calibration');
    await tester.ensureVisible(calibrationOption);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(calibrationOption);
    await tester.pump(const Duration(milliseconds: 800));

    // Tap "Initialize & Start Calibration" to proceed
    final startCalibrationBtn = find.text('Initialize & Start Calibration');
    await tester.ensureVisible(startCalibrationBtn);
    await tester.tap(startCalibrationBtn);
    await tester.pump(const Duration(milliseconds: 1200));

    // Verify landing on Dashboard in uncalibrated state
    expect(find.byType(DashboardShell), findsOneWidget);
    expect(find.byType(ProfileCardScreen), findsOneWidget);
    expect(find.text('Calibration Active'), findsOneWidget);

    // Simulate passive observation progress from Day 1 to Day 7
    for (int i = 1; i <= 6; i++) {
      final simulateBtn = find.text('Simulate Next Day');
      await tester.ensureVisible(simulateBtn);
      await tester.tap(simulateBtn);
      await tester.pump(const Duration(milliseconds: 800));
    }

    // Reveal final intervention card on Day 7 to complete calibration
    final revealCardBtn = find.text('Reveal Intervention Card');
    await tester.ensureVisible(revealCardBtn);
    await tester.tap(revealCardBtn);
    await tester.pump(const Duration(milliseconds: 1200));

    // Now the profile is fully calibrated!
    final nameTextFinder = find.text('Observation User');
    expect(nameTextFinder, findsOneWidget);

    // Ensure name is scrolled back into view before tapping
    await tester.ensureVisible(nameTextFinder);
    await tester.pump(const Duration(milliseconds: 800));

    // Tap user name to open details dialog
    await tester.tap(nameTextFinder);
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('7-Day Observation'), findsOneWidget);

    // Close the dialog
    final closeBtn = find.text('Close');
    await tester.tap(closeBtn);
    await tester.pump(const Duration(milliseconds: 800));
  });
}
