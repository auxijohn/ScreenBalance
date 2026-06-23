import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screen_balance/main.dart';
import 'package:screen_balance/screens/welcome_screen.dart';
import 'package:screen_balance/screens/calibration_confirmation_screen.dart';
import 'package:screen_balance/screens/quiz_screen.dart';
import 'package:screen_balance/screens/dashboard_shell.dart';
import 'package:screen_balance/screens/profile_card_screen.dart';
import 'package:screen_balance/models/quiz_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scenario 1 & 2 & 3: Onboarding and Quiz Calibration Test', (WidgetTester tester) async {
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

    // Verify Welcome Screen
    expect(find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'WelcomeScreen'), findsOneWidget);

    // Skip welcome screen
    final skipBtn = find.text('Skip');
    await tester.tap(skipBtn);
    await tester.pump(const Duration(milliseconds: 800));
    
    final unlockBtn = find.text('Unlock Screen Balance →');
    await tester.tap(unlockBtn);
    await tester.pump(const Duration(milliseconds: 800));

    // Fill registration details
    await tester.enterText(find.byType(TextFormField).first, 'Quiz User');
    await tester.enterText(find.byType(TextFormField).last, '9876');
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    await tester.pump(const Duration(milliseconds: 800));

    // Submit form
    final continueBtn = find.text('Continue to Onboarding');
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pump(const Duration(milliseconds: 1200));

    // Verify Calibration Confirmation page
    expect(find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'CalibrationConfirmationScreen'), findsOneWidget);

    // Tap "Take Instant Quiz (3 mins)" path card to proceed immediately
    final beginQuizBtn = find.text('Take Instant Quiz (3 mins)');
    await tester.ensureVisible(beginQuizBtn);
    await tester.tap(beginQuizBtn);
    
    // Pump multiple times to allow async navigation and state updates to process
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    final quizScreenFinder = find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'QuizScreen');

    // We should now be in the QuizScreen
    expect(quizScreenFinder, findsOneWidget);

    // Answer 10 questions sequentially
    for (int i = 0; i < 10; i++) {
      print('DEBUG: Answering quiz question index i = $i');
      expect(quizScreenFinder, findsOneWidget);
      
      // Get the text of the first option of the current question
      final optionText = QuizData.questions[i].options[0].text;
      final optionCard = find.ancestor(
        of: find.text(optionText),
        matching: find.byType(InkWell),
      );
      
      await tester.tap(optionCard);
      // Wait for the 350ms transition timer inside quiz_screen.dart
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump(const Duration(milliseconds: 450));
    }

    // Verify landing on Dashboard
    expect(find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'DashboardShell'), findsOneWidget);
    expect(find.byElementPredicate((e) => e.widget.runtimeType.toString() == 'ProfileCardScreen'), findsOneWidget);
    final nameTextFinder = find.text('Quiz User');
    expect(nameTextFinder, findsOneWidget);

    // Ensure name is scrolled into view before tapping
    await tester.ensureVisible(nameTextFinder);
    await tester.pump(const Duration(milliseconds: 800));

    // Tap user name to open details dialog
    await tester.tap(nameTextFinder);
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('Interactive Quiz'), findsOneWidget);

    // Close the dialog
    final closeBtn = find.text('Close');
    await tester.tap(closeBtn);
    await tester.pump(const Duration(milliseconds: 800));
  });
}
