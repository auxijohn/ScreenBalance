import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screen_balance/main.dart';
import 'package:screen_balance/screens/dashboard_shell.dart';
import 'package:screen_balance/screens/boundary_config_screen.dart';
import 'package:screen_balance/screens/profile_card_screen.dart';
import 'package:screen_balance/screens/tranquility_success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scenario 5 & 6: Boundaries Settings and Identity Evolution Test', (WidgetTester tester) async {
    // Mock the device_apps MethodChannel to prevent native querying hangs on modern emulators
    const channel = MethodChannel('g123k/device_apps');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (methodCall) async {
      print('DEBUG: MethodChannel call on g123k/device_apps: ${methodCall.method}');
      if (methodCall.method.startsWith('getInstalledApps')) {
        return [];
      }
      return null;
    });

    // 1. Initialize mock SharedPreferences with pre-calibrated profile to bypass onboarding
    SharedPreferences.setMockInitialValues({
      'user_pin': '1234',
      'userProfile': '{"name":"Boundaries User","ageGroup":"18-24","occupation":"Student","calibrationPath":"observe","observationDay":7,"isCalibrated":true,"activeIntentionCard":{"title":"The Intentional Seeker","emoji":"🌱","subtitle":"Digital Growth","description":"Your profile has been calibrated."}}'
    });

    // 2. Launch the app and settle
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 1000));

    print('DEBUG: Before login - Active screens in tree:');
    print('WelcomeScreen: ${find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'WelcomeScreen').evaluate().isNotEmpty}');
    print('AuthScreen (main): ${find.text('Welcome Back, Boundaries User').evaluate().isNotEmpty}');
    print('TextField count: ${find.byType(TextField).evaluate().length}');

    // Enter PIN to log in
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump(const Duration(milliseconds: 1200));
    
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    print('DEBUG: After login - Active screens in tree:');
    print('WelcomeScreen: ${find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'WelcomeScreen').evaluate().isNotEmpty}');
    print('DashboardShell: ${find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'DashboardShell').evaluate().isNotEmpty}');

    // Verify it loads dashboard and shows the user profile directly
    expect(find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'DashboardShell'), findsOneWidget);
    expect(find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'ProfileCardScreen'), findsOneWidget);
    expect(find.text('Boundaries User'), findsOneWidget);

    // Switch to boundaries tab
    final boundariesTab = find.ancestor(
      of: find.byIcon(Icons.phonelink_lock),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(boundariesTab);
    await tester.pump(const Duration(milliseconds: 1200));

    // Verify boundaries tab is selected (only selected tab shows its label)
    if (find.text('Boundaries').evaluate().isEmpty) {
      print('DEBUG: Tab not switched, tapping icon directly...');
      await tester.tap(find.byIcon(Icons.phonelink_lock));
      await tester.pump(const Duration(milliseconds: 1200));
    }

    print('DEBUG: Active tab text checks:');
    print('   Wellness: ${find.text('Wellness').evaluate().isNotEmpty}');
    print('   Boundaries: ${find.text('Boundaries').evaluate().isNotEmpty}');
    print('   Insights: ${find.text('Insights').evaluate().isNotEmpty}');

    // Wait for the config screen loading indicator to disappear
    int waitCount = 0;
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty && waitCount < 20) {
      print('DEBUG: Waiting for CircularProgressIndicator to disappear... ($waitCount)');
      await tester.pump(const Duration(milliseconds: 500));
      waitCount++;
    }

    // Double check that the tile is present
    final schedulesTileFound = find.text('Schedules & Sleep Quiet').evaluate().isNotEmpty;
    print('DEBUG: Schedules & Sleep Quiet tile found: $schedulesTileFound');
    if (!schedulesTileFound) {
      print('DEBUG: Printing all texts in tree:');
      for (final element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        print('   Text widget: "${widget.data}"');
      }
    }
    expect(find.text('Schedules & Sleep Quiet'), findsOneWidget, 
        reason: 'Schedules & Sleep Quiet tile must be visible after loading.');

    // Expand Schedules & Sleep Quiet section
    final schedulesTile = find.text('Schedules & Sleep Quiet');
    print('DEBUG: Tapping schedulesTile...');
    await tester.tap(schedulesTile);
    print('DEBUG: Tapping schedulesTile done, pumping...');
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Pump after schedulesTile done.');

    // Expand and configure Accountability Partners section
    final scrollable = find.byType(Scrollable).first;
    final partnersExpansionTile = find.text('Accountability Partners');
    print('DEBUG: Ensuring visible: Accountability Partners...');
    await tester.ensureVisible(partnersExpansionTile);
    print('DEBUG: Ensuring visible done, pumping...');
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Tapping Accountability Partners...');
    await tester.tap(partnersExpansionTile);
    print('DEBUG: Tapping Accountability Partners done, pumping...');
    await tester.pump(const Duration(milliseconds: 1000));
    print('DEBUG: Pump after Accountability Partners done.');

    // Enter accountability partner name and contact
    final partnerNameInput = find.byType(TextField).at(0);
    final partnerContactInput = find.byType(TextField).at(1);
    print('DEBUG: Ensuring visible: partnerNameInput...');
    await tester.ensureVisible(partnerNameInput);
    print('DEBUG: Ensuring visible partnerNameInput done, pumping...');
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Entering text for partnerNameInput...');
    await tester.enterText(partnerNameInput, 'Sarah');
    print('DEBUG: Entering text done.');
    
    print('DEBUG: Ensuring visible: partnerContactInput...');
    await tester.ensureVisible(partnerContactInput);
    print('DEBUG: Ensuring visible partnerContactInput done, pumping...');
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Entering text for partnerContactInput...');
    await tester.enterText(partnerContactInput, 'sarah@test.com');
    print('DEBUG: Entering text done, closing keyboard...');
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Closed keyboard.');

    // Tap Add Partner button
    final addPartnerBtn = find.text('Add Partner');
    print('DEBUG: Ensuring visible: Add Partner...');
    await tester.ensureVisible(addPartnerBtn);
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Tapping Add Partner...');
    await tester.tap(addPartnerBtn);
    print('DEBUG: Pumping after tapping Add Partner...');
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Tapping Add Partner done.');

    // Verify accountability partner item rendered on screen
    expect(find.text('Sarah (sarah@test.com)'), findsOneWidget);
    print('DEBUG: Verified Sarah (sarah@test.com) is rendered.');

    // Toggle app list picker
    final addAppButton = find.text('Add App');
    print('DEBUG: Ensuring visible: Add App...');
    await tester.ensureVisible(addAppButton);
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Tapping Add App...');
    await tester.tap(addAppButton);
    print('DEBUG: Pumping after tapping Add App...');
    await tester.pump(const Duration(milliseconds: 1000));
    print('DEBUG: Tapping Add App done.');

    // Handle fallback application dialog
    final fallbackDialogTitle = find.text('Add Application');
    if (fallbackDialogTitle.evaluate().isNotEmpty) {
      print('DEBUG: Handling fallback dialog title "Add Application"...');
      final notionPresetChip = find.text('Notion');
      await tester.tap(notionPresetChip);
      await tester.pump(const Duration(milliseconds: 800));
      print('DEBUG: Tapped Notion chip and pumped.');
    } else {
      print('DEBUG: Finding closeBtn (Icons.close)...');
      final closeBtn = find.byIcon(Icons.close);
      if (closeBtn.evaluate().isNotEmpty) {
        print('DEBUG: closeBtn found, tapping...');
        await tester.tap(closeBtn);
        await tester.pump(const Duration(milliseconds: 800));
        print('DEBUG: Tapped closeBtn and pumped.');
      } else {
        print('DEBUG: closeBtn NOT found.');
      }
    }

    // Tap Save & Apply Limits button to launch Identity Transformation
    final saveLimitsBtn = find.text('Save & Apply Limits');
    print('DEBUG: Ensuring visible: Save & Apply Limits...');
    await tester.ensureVisible(saveLimitsBtn);
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Tapping Save & Apply Limits...');
    await tester.tap(saveLimitsBtn);
    print('DEBUG: Pumping after Save & Apply Limits...');
    await tester.pump(const Duration(milliseconds: 1200));
    print('DEBUG: Tapped Save & Apply Limits.');

    // Verify Dynamic Identity Dialog
    expect(find.text('CURRENT STATE'), findsOneWidget);
    expect(find.text('EVOLVED SELF'), findsOneWidget);
    print('DEBUG: Verified identity dialog states.');

    // Apply the shift and proceed to Success Screen
    final applyShiftBtn = find.text('Apply Shift');
    print('DEBUG: Tapping Apply Shift...');
    await tester.tap(applyShiftBtn);
    await tester.pump(const Duration(milliseconds: 1200));
    print('DEBUG: Tapped Apply Shift.');

    expect(find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'TranquilitySuccessScreen'), findsOneWidget);
    expect(find.text('Boundaries Committed.'), findsOneWidget);
    print('DEBUG: Verified Success Screen.');

    // Close the app/test
    final closeAppBtn = find.text('Close the App');
    print('DEBUG: Tapping Close the App...');
    await tester.tap(closeAppBtn);
    await tester.pump(const Duration(milliseconds: 800));
    print('DEBUG: Test complete!');
  });
}
