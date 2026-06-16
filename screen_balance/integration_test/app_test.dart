import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screen_balance/main.dart';
import 'package:screen_balance/screens/welcome_screen.dart';
import 'package:screen_balance/screens/auth_screen.dart';
import 'package:screen_balance/screens/calibration_confirmation_screen.dart';
import 'package:screen_balance/screens/quiz_screen.dart';
import 'package:screen_balance/screens/dashboard_shell.dart';
import 'package:screen_balance/screens/profile_card_screen.dart';
import 'package:screen_balance/screens/boundary_config_screen.dart';
import 'package:screen_balance/screens/insights_dashboard_screen.dart';
import 'package:screen_balance/screens/intervention_overlay_screen.dart';
import 'package:screen_balance/screens/tranquility_success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ScreenBalance Full User Onboarding and Operations Integration Test', (WidgetTester tester) async {
    // 1. Initialize mock SharedPreferences for clean state
    SharedPreferences.setMockInitialValues({});

    // 2. Launch the app and settle the initial splash/loading transition
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    // ==========================================================
    // Scenario 1: Welcome Screen & Privacy Notice
    // ==========================================================
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('The Dopamine Loop'), findsOneWidget);
    expect(find.text('Privacy & Offline Guarantee'), findsOneWidget);

    // Tap "Privacy & Offline Guarantee" to verify the bottom sheet opens
    final privacyBtn = find.text('Privacy & Offline Guarantee');
    await tester.tap(privacyBtn);
    await tester.pumpAndSettle();
    expect(find.text('Privacy & Offline Data'), findsOneWidget);
    expect(find.text('Strictly Offline Architecture'), findsOneWidget);

    // Close the privacy sheet
    final closePrivacyBtn = find.text('Acknowledge & Close');
    await tester.tap(closePrivacyBtn);
    await tester.pumpAndSettle();

    // Tap "Next Step" to transition to second slide
    final nextBtn = find.text('Next Step');
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();
    expect(find.text('Calm Conscious Resets'), findsOneWidget);

    // Tap "Next Step" again to transition to third slide
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();
    expect(find.text('Reclaim Your Focus'), findsOneWidget);

    // Click "Get Started" to proceed to Registration Form
    final getStartedBtn = find.text('Get Started');
    await tester.tap(getStartedBtn);
    await tester.pumpAndSettle();

    // ==========================================================
    // Scenario 2: Signup Form Validations & Submissions
    // ==========================================================
    expect(find.text('Create Local Profile'), findsOneWidget);

    // Submit empty registration form to trigger validation
    final continueToOnboardingBtn = find.text('Continue to Onboarding');
    await tester.ensureVisible(continueToOnboardingBtn);
    await tester.tap(continueToOnboardingBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a name'), findsOneWidget);

    // Fill valid registration details
    await tester.enterText(find.byType(TextFormField).first, 'John Doe');
    await tester.enterText(find.byType(TextFormField).last, '1234'); // 4-digit PIN
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    await tester.pumpAndSettle();

    // Submit and verify transition to Calibration Confirmation page
    await tester.tap(continueToOnboardingBtn);
    await tester.pumpAndSettle();
    expect(find.byType(CalibrationConfirmationScreen), findsOneWidget);

    // ==========================================================
    // Scenario 3: Calibration Settings & Consent Requirements (7-Day Calibration Path)
    // ==========================================================
    expect(find.text('Calibration Setup'), findsOneWidget);

    // Scroll page down to bring bottom options into view
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -450));
    await tester.pumpAndSettle();

    // Try to proceed without authorization checkbox consent
    final initializeBtn = find.text('Initialize & Begin Quiz');
    await tester.ensureVisible(initializeBtn);
    await tester.tap(initializeBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please check the authorization consent box to proceed.'), findsOneWidget);

    // Approve consent checkbox
    final consentCheckbox = find.byType(CheckboxListTile);
    await tester.ensureVisible(consentCheckbox);
    await tester.tap(consentCheckbox);
    await tester.pumpAndSettle();

    // Select "7-Day Background Calibration" path (bypass quiz)
    final calibrationOption = find.text('7-Day Background Calibration');
    await tester.ensureVisible(calibrationOption);
    await tester.tap(calibrationOption);
    await tester.pumpAndSettle();

    // Tap "Initialize & Start Calibration" to proceed
    final startCalibrationBtn = find.text('Initialize & Start Calibration');
    await tester.ensureVisible(startCalibrationBtn);
    await tester.tap(startCalibrationBtn);
    await tester.pumpAndSettle();

    // ==========================================================
    // Scenario 5: Dashboard Screen Navigation & Views
    // ==========================================================
    expect(find.byType(DashboardShell), findsOneWidget);
    expect(find.byType(ProfileCardScreen), findsOneWidget);

    // Complete passive calibration if we are in observation path
    final revealCardBtn = find.text('Reveal Intervention Card');
    if (revealCardBtn.evaluate().isNotEmpty) {
      await tester.tap(revealCardBtn);
      await tester.pumpAndSettle();
    }

    expect(find.text('John Doe'), findsOneWidget);

    // Switch to boundaries tab
    final boundariesTab = find.text('Boundaries');
    await tester.tap(boundariesTab);
    await tester.pumpAndSettle();
    expect(find.byType(BoundaryConfigScreen), findsOneWidget);

    // Switch to insights tab
    final insightsTab = find.text('Insights');
    await tester.tap(insightsTab);
    await tester.pumpAndSettle();
    expect(find.byType(InsightsDashboardScreen), findsOneWidget);

    // ==========================================================
    // Scenario 6: Changing Boundaries, Adding Partner & Saving
    // ==========================================================
    // Switch back to boundaries configuration page
    await tester.tap(boundariesTab);
    await tester.pumpAndSettle();

    // Tap Bedtime Goal list tile (opens TimePicker, cancel to test dismissal)
    final bedtimeGoalTile = find.text('Bedtime Goal');
    await tester.tap(bedtimeGoalTile);
    await tester.pumpAndSettle();
    
    final cancelBtn = find.text('CANCEL');
    if (cancelBtn.evaluate().isNotEmpty) {
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();
    }

    // Expand and configure Accountability Partners section
    final partnersExpansionTile = find.text('Accountability Partners');
    await tester.tap(partnersExpansionTile);
    await tester.pumpAndSettle();

    // Enter accountability partner name and details
    final partnerNameInput = find.byType(TextField).at(0);
    final partnerContactInput = find.byType(TextField).at(1);
    await tester.enterText(partnerNameInput, 'Sarah');
    await tester.enterText(partnerContactInput, 'sarah@test.com');
    await tester.pumpAndSettle();

    // Tap Add Partner button
    final addPartnerBtn = find.text('Add Partner');
    await tester.tap(addPartnerBtn);
    await tester.pumpAndSettle();

    // Verify accountability partner item rendered on screen
    expect(find.text('Sarah (sarah@test.com)'), findsOneWidget);

    // Toggle app list picker
    final addAppButton = find.text('Add App');
    await tester.tap(addAppButton);
    await tester.pumpAndSettle();

    // Handle conditional dialog view depending on test host setup
    final fallbackDialogTitle = find.text('Add Application');
    if (fallbackDialogTitle.evaluate().isNotEmpty) {
      final notionPresetChip = find.text('Notion');
      await tester.tap(notionPresetChip);
      await tester.pumpAndSettle();
    } else {
      final closeAndroidSheetBtn = find.byIcon(Icons.close);
      if (closeAndroidSheetBtn.evaluate().isNotEmpty) {
        await tester.tap(closeAndroidSheetBtn);
        await tester.pumpAndSettle();
      }
    }

    // Tap Save & Apply Limits button to launch Identity Transformation
    final saveLimitsBtn = find.text('Save & Apply Limits');
    await tester.ensureVisible(saveLimitsBtn);
    await tester.tap(saveLimitsBtn);
    await tester.pumpAndSettle();

    // Verify Dynamic Identity Dialog
    expect(find.byType(IdentityTransformationDialog), findsOneWidget);
    expect(find.text('CURRENT STATE'), findsOneWidget);
    expect(find.text('EVOLVED SELF'), findsOneWidget);

    // Apply the shift and proceed to Success Screen
    final applyShiftBtn = find.text('Apply Shift');
    await tester.tap(applyShiftBtn);
    await tester.pumpAndSettle();

    expect(find.byType(TranquilitySuccessScreen), findsOneWidget);
    expect(find.text('Tranquility Calibrated'), findsOneWidget);

    // Return to Wellness tab
    final returnBtn = find.text('Return to Wellness');
    await tester.tap(returnBtn);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileCardScreen), findsOneWidget);

    // ==========================================================
    // Scenario 7: Telemetry Trigger Simulator & Overlay Interventions
    // ==========================================================
    // Open Simulator Dashboard bottom sheet via bug FAB
    final bugFab = find.byType(FloatingActionButton);
    await tester.tap(bugFab);
    await tester.pumpAndSettle();

    // Choose "Dopamine Loop" raw OS telemetry trigger
    final dopamineLoopOption = find.text('Dopamine Loop');
    await tester.tap(dopamineLoopOption);
    await tester.pumpAndSettle();

    // Verify somatic reset intervention overlay loads
    expect(find.byType(InterventionOverlayScreen), findsOneWidget);
    expect(find.text('Dopamine Loop'), findsOneWidget);

    // Dismiss the overlay via Somatic Reset Completed action
    final completeResetBtn = find.text('Complete Somatic Reset');
    await tester.tap(completeResetBtn);
    await tester.pumpAndSettle();

    // Verify we are returned back to normal dashboard
    expect(find.byType(InterventionOverlayScreen), findsNothing);
    expect(find.byType(DashboardShell), findsOneWidget);

    // ==========================================================
    // Scenario 8: App Logout Reset & Returning Login Flow (PIN)
    // ==========================================================
    // Tap logout/reset profile button
    final logoutBtn = find.byTooltip('Logout & Reset Profile');
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    // Verify returned to fresh welcome screen state
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // Walkthrough welcome slides to get to registration
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'John Doe');
    await tester.enterText(find.byType(TextFormField).last, '1234'); // PIN
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to Onboarding'));
    await tester.pumpAndSettle();

    // Scroll page down to bring bottom options into view
    final scrollable2 = find.byType(Scrollable).first;
    await tester.drag(scrollable2, const Offset(0, -350));
    await tester.pumpAndSettle();

    // Consent and choose "7-Day Background Calibration" path
    final consentCheckboxList = find.byType(CheckboxListTile);
    await tester.ensureVisible(consentCheckboxList);
    await tester.tap(consentCheckboxList);
    await tester.pumpAndSettle();
    
    final calibrationOption2 = find.text('7-Day Background Calibration');
    await tester.ensureVisible(calibrationOption2);
    await tester.tap(calibrationOption2);
    await tester.pumpAndSettle();
    
    final startCalibrationBtn2 = find.text('Initialize & Start Calibration');
    await tester.ensureVisible(startCalibrationBtn2);
    await tester.tap(startCalibrationBtn2);
    await tester.pumpAndSettle();

    expect(find.byType(DashboardShell), findsOneWidget);

    // Simulated Restart: Load app again with SharedPreferences already containing data
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify returning user sees PIN screen
    expect(find.text('Welcome Back, John Doe'), findsOneWidget);
    expect(find.text('Enter PIN to access your dashboard.'), findsOneWidget);

    // Attempt login with incorrect PIN
    final pinInput = find.byType(TextField);
    await tester.enterText(pinInput, '9999');
    await tester.pumpAndSettle();
    expect(find.text('Invalid PIN code. Please try again.'), findsOneWidget);

    // Complete login with correct PIN
    await tester.enterText(pinInput, '1234');
    await tester.pumpAndSettle();

    // Verify unlocked and returned to main dashboard
    expect(find.byType(DashboardShell), findsOneWidget);
  });
}
