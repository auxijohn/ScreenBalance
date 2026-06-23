import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_balance/main.dart';
import 'package:screen_balance/screens/calibration_confirmation_screen.dart';
import 'package:screen_balance/screens/boundary_config_screen.dart';
import 'package:screen_balance/screens/profile_card_screen.dart';
import 'package:screen_balance/models/boundary_settings.dart';
import 'package:screen_balance/models/user_profile.dart';
import 'package:screen_balance/logic/intervention_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads welcome screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pumpAndSettle();

    // Verify that the title text is present.
    expect(find.text('ScreenBalance'), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText().contains('People pick up their phone without any reason'),
      ),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Signup form navigation to CalibrationConfirmationScreen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    // Mock accessibility permission method channel
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.screenbalance.tracker/commands'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isAccessibilityServiceEnabled') {
          return true;
        }
        return null;
      },
    );

    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pumpAndSettle();

    // Tap "Skip" button to go to final quote
    final skipButton = find.text('Skip');
    expect(skipButton, findsOneWidget);
    await tester.tap(skipButton);
    await tester.pumpAndSettle();

    // Tap "Unlock Screen Balance →"
    final unlockButton = find.text('Unlock Screen Balance →');
    expect(unlockButton, findsOneWidget);
    await tester.tap(unlockButton);
    await tester.pumpAndSettle();

    // Fill out form fields
    await tester.enterText(find.byType(TextFormField).first, 'John');
    await tester.enterText(find.byType(TextFormField).last, '1234');
    
    // Ensure the button is visible before tapping
    final registerButton = find.text('Continue to Onboarding');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    
    // Pump multiple frames to allow the navigation transition to complete
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify that we navigated to CalibrationConfirmationScreen
    expect(find.byType(CalibrationConfirmationScreen), findsOneWidget);
    expect(find.text('Calibration Setup'), findsOneWidget);
  });

  test('BoundarySettings.clearFromStorage clears all boundary keys from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({
      'targetBedtime': '23:00',
      'focusStartTime': '09:00',
      'focusEndTime': '17:00',
      'morningBufferMinutes': 45,
      'accountabilityContacts': ['Alice (123)'],
      'customApps': ['com.test.app'],
      'categorizedApps': '{"Utility": ["com.test.app"]}',
      'user_pin': '1234',
    });

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('targetBedtime'), isTrue);
    expect(prefs.containsKey('user_pin'), isTrue);

    await BoundarySettings.clearFromStorage();

    expect(prefs.containsKey('targetBedtime'), isFalse);
    expect(prefs.containsKey('focusStartTime'), isFalse);
    expect(prefs.containsKey('focusEndTime'), isFalse);
    expect(prefs.containsKey('morningBufferMinutes'), isFalse);
    expect(prefs.containsKey('accountabilityContacts'), isFalse);
    expect(prefs.containsKey('customApps'), isFalse);
    expect(prefs.containsKey('categorizedApps'), isFalse);
    expect(prefs.containsKey('user_pin'), isTrue);
  });

  testWidgets('IdentityTransformationDialog renders correct 5-word phrases and titles', (WidgetTester tester) async {
    final transformation = {
      'before': 'Restless scroller fighting midnight fatigue',
      'after': 'Deep sleeper restoring sleep rhythms',
      'type': 'Sleep',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IdentityTransformationDialog(transformation: transformation),
        ),
      ),
    );

    expect(find.text('SLEEP QUIET SHIFT'), findsOneWidget);
    expect(find.text('Restless scroller fighting midnight fatigue'), findsOneWidget);
    expect(find.text('Deep sleeper restoring sleep rhythms'), findsOneWidget);
    expect(find.text('CURRENT STATE'), findsOneWidget);
    expect(find.text('EVOLVED SELF'), findsOneWidget);
    expect(find.text('Apply Shift'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  test('InterventionEngine mindfulness score calculations work correctly', () {
    final engine = InterventionEngine();
    
    // Test base healthy state (0 unlocks, 0 interventions)
    engine.unlockCountToday = 0;
    engine.behavioralHistory.clear();
    expect(engine.getDigitalMindfulnessScore(), equals(100));
    expect(engine.getMindfulnessPhrase(100)['title'], equals('Zen Master'));

    // Test moderate state (15 unlocks -> 10 unlocks are free, 5 subtract 2 points each = 90)
    engine.unlockCountToday = 15;
    expect(engine.getDigitalMindfulnessScore(), equals(90));
    expect(engine.getMindfulnessPhrase(90)['title'], equals('Zen Practitioner'));

    // Test low state (20 unlocks -> -20 points, plus 2 interventions today -> -10 points = 70 score)
    engine.unlockCountToday = 20;
    engine.logEvent("Intervention Triggered", "some_trigger");
    engine.logEvent("Intervention Triggered", "another_trigger");
    expect(engine.getDigitalMindfulnessScore(), equals(70));
    expect(engine.getMindfulnessPhrase(70)['title'], equals('Seeking Balance'));
  });

  testWidgets('ProfileCardScreen renders Digital Mindfulness Score card', (WidgetTester tester) async {
    final mockProfile = UserProfile(
      name: 'Test User',
      isCalibrated: true,
    );

    // Set some stats on InterventionEngine
    InterventionEngine().unlockCountToday = 8;
    InterventionEngine().behavioralHistory.clear();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileCardScreen(
            profile: mockProfile,
            onProfileUpdated: () {},
            onLogout: () {},
          ),
        ),
      ),
    );

    // Verify presence of mindfulness score title
    expect(find.text('DIGITAL MINDFULNESS SCORE'), findsOneWidget);
    // Score is rendered via SolarEclipsePainter CustomPaint, other texts are standard text widgets
    expect(find.text('ZEN MASTER'), findsOneWidget);
    expect(find.text('Daily Unlocks'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });
}

