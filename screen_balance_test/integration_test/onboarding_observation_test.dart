import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Mock MethodChannels
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

    // 1. Initialize mock SharedPreferences for clean state
    SharedPreferences.setMockInitialValues({});

    // 2. Launch the app and settle
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify Welcome Screen renders
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // Skip welcome screen
    final skipBtn = find.text('Skip');
    await tester.tap(skipBtn);
    await tester.pump(const Duration(milliseconds: 800));
    
    final unlockBtn = find.text('Unlock Screen Balance →');
    await tester.tap(unlockBtn);
    await tester.pump(const Duration(milliseconds: 800));

    // Verify Registration Form
    print('DEBUG: Verifying registration form text');
    expect(find.text('Create Login Profile'), findsOneWidget);

    // Fill registration details
    print('DEBUG: Entering text in registration form');
    await tester.enterText(find.byType(TextFormField).first, 'Observation User');
    await tester.enterText(find.byType(TextFormField).last, '4321');
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    await tester.pump(const Duration(milliseconds: 800));

    // Submit form
    print('DEBUG: Tapping Continue to Onboarding');
    final continueBtn = find.text('Continue to Onboarding');
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pump(const Duration(milliseconds: 1200));

    // Verify Calibration Confirmation page
    print('DEBUG: Verifying CalibrationConfirmationScreen');
    expect(find.byType(CalibrationConfirmationScreen), findsOneWidget);

    // Scroll page down to bring bottom options into view
    print('DEBUG: Dragging scrollable');
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -450));
    await tester.pump(const Duration(milliseconds: 800));

    // Select "7-Day Background Calibration" path - should navigate immediately!
    print('DEBUG: Selecting 7-Day Background Calibration');
    final calibrationOption = find.text('7-Day Background Calibration');
    await tester.ensureVisible(calibrationOption);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(calibrationOption);
    
    // Settle async navigation
    print('DEBUG: Settling async navigation');
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Verify landing on Dashboard in uncalibrated state
    print('DEBUG: Verifying landing on DashboardShell');
    expect(find.byType(DashboardShell), findsOneWidget);
    expect(find.byType(ProfileCardScreen), findsOneWidget);
    expect(find.text('Calibration Active'), findsOneWidget);

    // Simulate passive observation progress from Day 1 to Day 7
    print('DEBUG: Simulating passive observation days 1 to 6');
    for (int i = 1; i <= 6; i++) {
      final simulateBtn = find.text('Simulate Next Day');
      await tester.ensureVisible(simulateBtn);
      await tester.tap(simulateBtn);
      await tester.pump(const Duration(milliseconds: 800));
    }

    // Reveal final intervention card on Day 7 to complete calibration
    print('DEBUG: Revealing final intervention card on Day 7');
    final revealCardBtn = find.text('Reveal Intervention Card');
    await tester.ensureVisible(revealCardBtn);
    await tester.tap(revealCardBtn);
    await tester.pump(const Duration(milliseconds: 1200));

    // Now the profile is fully calibrated!
    print('DEBUG: Verifying calibrated profile');
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
