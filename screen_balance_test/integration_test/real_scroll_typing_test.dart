/// ════════════════════════════════════════════════════════════════════════════
/// REAL SCROLL & TYPING SIMULATION TEST
/// ────────────────────────────────────────────────────────────────────────────
/// This test injects advanced telemetry events (SCROLL, TEXT_CHANGE, CONTENT_CHANGE)
/// directly into the EventChannel stream, verifying the real-time detection
/// logic for the 5 advanced triggers:
///   ✅ The Void
///   ✅ Interaction Spike
///   ✅ Social Spiral
///   ✅ Upward Comparison Risk
///   ✅ Ghosting Anxiety
/// ════════════════════════════════════════════════════════════════════════════

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

final Map<String, String> _report = {};

/// Inject a raw event string into the stream
Future<void> _injectEvent(WidgetTester tester, String event) async {
  debugPrint('   📱 Telemetry Event → $event');
  NativeTracker.appOpenStream.add(event);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Dismiss the overlay and record it
Future<void> _handleOverlay(WidgetTester tester, String triggerName) async {
  await tester.pump(const Duration(milliseconds: 600));

  final overlayFinder =
      find.byElementPredicate((e) => _isType(e, 'InterventionOverlayScreen'));
  expect(overlayFinder, findsOneWidget,
      reason: 'InterventionOverlayScreen must appear for "$triggerName".');

  // Tap "Snooze Limit" if present to dismiss
  final snoozeBtn = find.text('Snooze Limit');
  if (snoozeBtn.evaluate().isNotEmpty) {
    await tester.tap(snoozeBtn);
    await tester.pump(const Duration(milliseconds: 600));
  } else {
    // Fallback: check objects if scan checklist is shown
    for (int i = 1; i <= 5; i++) {
      final checkbox = find.text('Object $i');
      if (checkbox.evaluate().isNotEmpty) {
        await tester.tap(checkbox);
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    final proceedBtn = find.text('Proceed to Validation');
    if (proceedBtn.evaluate().isNotEmpty) {
      await tester.tap(proceedBtn);
      await tester.pump(const Duration(milliseconds: 600));
      final mood = find.byType(InkWell);
      if (mood.evaluate().isNotEmpty) {
        await tester.tap(mood.first);
        await tester.pump(const Duration(milliseconds: 800));
      }
    }
  }

  expect(
    find.byElementPredicate((e) => _isType(e, 'InterventionOverlayScreen')),
    findsNothing,
    reason: 'Overlay must be dismissed after handling "$triggerName".',
  );
  _report[triggerName] = '✅ Verified (Fired & Handled)';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Real Scroll & Typing Telemetry Triggers',
      (WidgetTester tester) async {
    // ── Mock platform channel to avoid hangs ──────────────────────────────────
    const channel = MethodChannel('g123k/device_apps');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (methodCall) async {
      if (methodCall.method.startsWith('getInstalledApps')) {
        return [];
      }
      return null;
    });

    // Mock Commands MethodChannel to return true for Accessibility Service check
    const cmdChannel = MethodChannel('com.screenbalance.tracker/commands');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(cmdChannel, (methodCall) async {
      if (methodCall.method == 'isAccessibilityServiceEnabled') {
        return true;
      }
      return null;
    });

    // ── Setup pre-calibrated user profile ─────────────────────────────────────
    SharedPreferences.setMockInitialValues({
      'user_pin': '1234',
      'userProfile':
          '{"name":"Scroll User","ageGroup":"25-34","occupation":"Developer",'
          '"calibrationPath":"observe","observationDay":7,"isCalibrated":true,'
          '"activeIntentionCard":{"title":"The Intentional Seeker","emoji":"🌱",'
          '"subtitle":"Digital Growth","description":"Calibrated."}}',
      'categorizedApps': json.encode({
        'Social': ['com.instagram.android', 'com.twitter.android'],
        'Entertainment': ['com.netflix.mediaclient'],
        'Productivity': ['com.slack.a'],
      }),
    });

    // Launch app and log in
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    final pinField = find.byType(TextField);
    await tester.enterText(pinField.first, '1234');
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'Must unlock to Dashboard.',
    );

    // Set simulated time to allow test checks
    final baseTime = DateTime(2026, 6, 15, 12, 0);
    InterventionEngine().setSimulatedTime(baseTime);

    // ── 1. TRIGGER: The Void ─────────────────────────────────────────────────
    // Fires when continuous scroll counts reach 3 in simulated environment
    debugPrint('\n🚀 Simulating: Continuous scrolling in Instagram (The Void)...');
    await _injectEvent(tester, 'SCROLL:com.instagram.android');
    await _injectEvent(tester, 'SCROLL:com.instagram.android');
    await _injectEvent(tester, 'SCROLL:com.instagram.android'); // 3rd scroll triggers it!

    await _handleOverlay(tester, 'The Void');

    // ── 2. TRIGGER: Interaction Spike ────────────────────────────────────────
    // Fires when rate of scrolls doubles in a 5s window (older scrolls >= 2, newer scrolls >= 2 * older)
    debugPrint('\n🚀 Simulating: Rapid speed increase (Interaction Spike)...');
    // older scrolls at baseTime
    InterventionEngine().setSimulatedTime(baseTime.add(const Duration(seconds: 1)));
    await _injectEvent(tester, 'SCROLL:com.instagram.android');
    await _injectEvent(tester, 'SCROLL:com.instagram.android');
    
    // newer scrolls at baseTime + 3s
    InterventionEngine().setSimulatedTime(baseTime.add(const Duration(seconds: 4)));
    await _injectEvent(tester, 'SCROLL:com.instagram.android');
    await _injectEvent(tester, 'SCROLL:com.instagram.android');
    await _injectEvent(tester, 'SCROLL:com.instagram.android');
    await _injectEvent(tester, 'SCROLL:com.instagram.android'); // doubles rate -> triggers!

    await _handleOverlay(tester, 'Interaction Spike');

    // ── 3. TRIGGER: Social Spiral ────────────────────────────────────────────
    // Fires when screen switches (CONTENT_CHANGE) >= 4 in simulated time
    debugPrint('\n🚀 Simulating: Profile browsing loop (Social Spiral)...');
    InterventionEngine().setSimulatedTime(baseTime.add(const Duration(minutes: 5)));
    await _injectEvent(tester, 'CONTENT_CHANGE:com.instagram.android');
    await _injectEvent(tester, 'CONTENT_CHANGE:com.instagram.android');
    await _injectEvent(tester, 'CONTENT_CHANGE:com.instagram.android');
    await _injectEvent(tester, 'CONTENT_CHANGE:com.instagram.android'); // 4th content change triggers!

    await _handleOverlay(tester, 'Social Spiral');

    // ── 4. TRIGGER: Upward Comparison ────────────────────────────────────────
    // Fires when scrolls >= 15 with no active typing (typed chars == 0) in social app
    debugPrint('\n🚀 Simulating: Passive social media scroll (Upward Comparison)...');
    InterventionEngine().setSimulatedTime(baseTime.add(const Duration(minutes: 10)));
    for (int i = 0; i < 15; i++) {
      await _injectEvent(tester, 'SCROLL:com.instagram.android');
    }

    await _handleOverlay(tester, 'Upward Comparison Risk');

    // ── 5. TRIGGER: Ghosting Anxiety ─────────────────────────────────────────
    // Fires when user typed > 30 chars, deleted all, and closed app (opened launcher)
    debugPrint('\n🚀 Simulating: Typing hesitancy and quick exit (Ghosting Anxiety)...');
    InterventionEngine().setSimulatedTime(baseTime.add(const Duration(minutes: 15)));
    // Type 35 chars
    await _injectEvent(tester, 'TEXT_CHANGE:com.instagram.android:35:0');
    // Delete 35 chars
    await _injectEvent(tester, 'TEXT_CHANGE:com.instagram.android:0:35');
    // Exit app (open launcher)
    await _injectEvent(tester, 'com.android.launcher3'); // triggers!

    await _handleOverlay(tester, 'Ghosting Anxiety');

    // Clean up time override
    InterventionEngine().setSimulatedTime(null);

    // Final Report
    debugPrint('\n═══════════════════════════════════════════════════════════════');
    debugPrint('   📊 ADVANCED TELEMETRY INTERVENTIONS REPORT');
    debugPrint('═══════════════════════════════════════════════════════════════');
    for (final entry in _report.entries) {
      debugPrint('   ${entry.key.padRight(26)} → ${entry.value}');
    }
    debugPrint('═══════════════════════════════════════════════════════════════\n');
  });
}
