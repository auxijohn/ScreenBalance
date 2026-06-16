import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screen_balance/main.dart';
import 'package:screen_balance/logic/intervention_engine.dart';
import 'package:screen_balance/logic/native_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _isType(Element e, String typeName) =>
    e.widget.runtimeType.toString() == typeName;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper to set up mocks for each testWidgets
  void setupMocks(WidgetTester tester) {
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
  }

  testWidgets('Test 1: Lock and Unlock Count Test', (WidgetTester tester) async {
    setupMocks(tester);

    // Seed Mock SharedPreferences with a calibrated user profile
    SharedPreferences.setMockInitialValues({
      'user_pin': '1234',
      'userProfile':
          '{"name":"Interaction User","ageGroup":"25-34","occupation":"Professional",'
          '"calibrationPath":"observe","observationDay":7,"isCalibrated":true,'
          '"activeIntentionCard":{"title":"The Intentional Seeker","emoji":"🌱",'
          '"subtitle":"Digital Growth","description":"Calibrated."}}',
      'categorizedApps': json.encode({
        'Social': ['com.instagram.android', 'com.twitter.android', 'com.facebook.katana'],
        'Entertainment': ['com.netflix.mediaclient'],
        'Productivity': ['com.slack.a'],
      }),
    });

    // Launch app
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // Enter PIN
    final pinField = find.byType(TextField);
    expect(pinField, findsOneWidget);
    await tester.enterText(pinField.first, '1234');
    await tester.pump(const Duration(milliseconds: 800));

    // Verify on DashboardShell
    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'Should navigate to Dashboard after PIN entry.',
    );

    // Reset the count just to be clean
    final engine = InterventionEngine();
    engine.unlockCountToday = 0;
    engine.behavioralHistory.clear();

    debugPrint('🔓 Simulating: Lock and unlock device 5 times');

    // Lock and unlock 5 times
    for (int i = 1; i <= 5; i++) {
      debugPrint('   Cycle #$i: Sending DEVICE_LOCK & DEVICE_UNLOCK');
      NativeTracker.appOpenStream.add('DEVICE_LOCK');
      await tester.pump(const Duration(milliseconds: 200));
      NativeTracker.appOpenStream.add('DEVICE_UNLOCK');
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Allow UI to rebuild and update the counter
    await tester.pump(const Duration(milliseconds: 600));

    // Locate the 'Daily Unlocks' telemetry card parent Column to safely assert value '5'
    final dailyUnlocksColumn = find.ancestor(
      of: find.text('Daily Unlocks'),
      matching: find.byType(Column),
    ).first;
    
    final valueText = find.descendant(
      of: dailyUnlocksColumn,
      matching: find.text('5'),
    );

    expect(valueText, findsOneWidget, reason: 'Daily Unlocks count on the dashboard should reactively update to 5.');
    debugPrint('✅ Test 1 Passed: Lock/unlock counts correctly tracked and updated reactively.');
  });

  testWidgets('Test 2: Trigger Dopamine Loop', (WidgetTester tester) async {
    setupMocks(tester);

    // Seed Mock SharedPreferences with a calibrated user profile
    SharedPreferences.setMockInitialValues({
      'user_pin': '1234',
      'userProfile':
          '{"name":"Interaction User","ageGroup":"25-34","occupation":"Professional",'
          '"calibrationPath":"observe","observationDay":7,"isCalibrated":true,'
          '"activeIntentionCard":{"title":"The Intentional Seeker","emoji":"🌱",'
          '"subtitle":"Digital Growth","description":"Calibrated."}}',
      'categorizedApps': json.encode({
        'Social': ['com.instagram.android', 'com.twitter.android', 'com.facebook.katana'],
        'Entertainment': ['com.netflix.mediaclient'],
        'Productivity': ['com.slack.a'],
      }),
    });

    // Launch app
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // Enter PIN
    final pinField = find.byType(TextField);
    expect(pinField, findsOneWidget);
    await tester.enterText(pinField.first, '1234');
    await tester.pump(const Duration(milliseconds: 800));

    // Verify on DashboardShell
    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'Should navigate to Dashboard after PIN entry.',
    );

    debugPrint('⏳ Pausing 2 seconds on the Dashboard...');
    await Future.delayed(const Duration(seconds: 2));
    await tester.pump();

    debugPrint('📱 Simulating: Rapid switching of 3 different social apps (Instagram -> Twitter -> Facebook)');

    // Open Instagram
    NativeTracker.appOpenStream.add('com.instagram.android');
    await tester.pump(const Duration(milliseconds: 400));

    // Open Twitter
    NativeTracker.appOpenStream.add('com.twitter.android');
    await tester.pump(const Duration(milliseconds: 400));

    // Open Facebook -> triggers Dopamine Loop
    NativeTracker.appOpenStream.add('com.facebook.katana');
    await tester.pump(const Duration(milliseconds: 400));

    // Allow overlay to build
    await tester.pump(const Duration(milliseconds: 600));

    // Verify that the InterventionOverlayScreen is visible and contains Dopamine Loop
    final overlayFinder = find.byElementPredicate((e) => _isType(e, 'InterventionOverlayScreen'));
    expect(overlayFinder, findsOneWidget, reason: 'Dopamine Loop intervention overlay should appear.');
    expect(find.text('Dopamine Loop'), findsOneWidget, reason: 'Intervention title "Dopamine Loop" should be displayed.');

    debugPrint('⏳ Pausing 5 seconds to let you view the triggered Dopamine Loop overlay...');
    await Future.delayed(const Duration(seconds: 5));
    await tester.pump();

    debugPrint('🛑 Intervention overlay detected. Dismissing by clicking "Snooze Limit"...');

    // Tap Snooze Limit
    final snoozeBtn = find.text('Snooze Limit');
    expect(snoozeBtn, findsOneWidget);
    await tester.tap(snoozeBtn);
    await tester.pump(const Duration(milliseconds: 600));

    // Verify we returned to the DashboardShell
    expect(overlayFinder, findsNothing, reason: 'Intervention overlay should be dismissed.');
    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'Should be back on DashboardShell.',
    );

    debugPrint('⏳ Pausing 2 seconds to view the Dashboard again...');
    await Future.delayed(const Duration(seconds: 2));
    await tester.pump();

    debugPrint('✅ Test 2 Passed: Dopamine Loop triggered and dismissed successfully.');
  });
}
