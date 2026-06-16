/// ════════════════════════════════════════════════════════════════════════════
/// REAL OS TELEMETRY SIMULATION TEST
/// ────────────────────────────────────────────────────────────────────────────
/// This test does NOT use the debug FAB or simulateTrigger().
///
/// Instead it injects events directly into NativeTracker.appOpenStream — the
/// same StreamController that the real Android NativeTracker EventChannel feeds.
///
///   Real Android OS → EventChannel → NativeTracker.appOpenStream → Engine
///   This test       →               NativeTracker.appOpenStream → Engine
///
/// The InterventionEngine's real detection logic fires the triggers naturally,
/// exactly as it would during actual mobile usage.
///
/// Supported real-detection triggers (via processAppOpen / processDeviceUnlock):
///   ✅ Dopamine Loop     — 3+ different apps opened in < 60 seconds
///   ✅ Reactive Mode     — 5+ app opens in 10 minutes (spaced > 60s apart)
///   ✅ Info Overload     — 5+ Social apps in 15 mins (after Reactive Mode fires)
///   ✅ Phantom Check     — 10+ device unlocks in 15 minutes
///   ✅ Work-Life Blur    — Productivity app opened outside focus hours
///   ✅ Midnight Drift    — Social/Entertainment app opened past target bedtime
///   ✅ Last Scroll Loop  — 3+ unlocks in 2 minutes past bedtime
///
/// Note: social_spiral, ghosting_anxiety, upward_comparison, the_void,
/// and interaction_spike have no real OS detection — they are only in the
/// debug simulator because they require ML/NLP analysis (typing patterns,
/// scroll velocity, etc.) that goes beyond basic UsageStats counters.
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

// ── Type helpers ──────────────────────────────────────────────────────────────

bool _isType(Element e, String typeName) =>
    e.widget.runtimeType.toString() == typeName;

// ── Real package name catalogue (used on emulator) ───────────────────────────
// These are the package names that the real Android NativeTracker would send.

const _socialApps = [
  'com.instagram.android',
  'com.twitter.android',
  'com.facebook.katana',
  'com.reddit.frontpage',
  'com.snapchat.android',
  'com.tiktok.android',
];

const _entertainmentApps = [
  'com.netflix.mediaclient',
  'com.amazon.avod.thirdpartyclient',
  'com.ebay.mobile',
  'com.amazon.mShop.android.shopping',
  'com.etsy.android',
];

const _productivityApps = [
  'com.slack.a',
  'com.microsoft.teams',
  'com.google.android.gm',
  'com.notion.id',
];

// ── Test report ───────────────────────────────────────────────────────────────

final Map<String, String> _report = {};

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Inject a raw app package name into the NativeTracker stream.
/// This is exactly what Android OS sends through the EventChannel.
Future<void> _openApp(WidgetTester tester, String packageName,
    {String label = ''}) async {
  debugPrint(
      '   📱 App Open Event → $packageName ${label.isNotEmpty ? "($label)" : ""}');
  NativeTracker.appOpenStream.add(packageName);
  await tester.pump(const Duration(milliseconds: 400));
}

/// Inject DEVICE_UNLOCK event — same as user pressing power + swipe.
Future<void> _unlock(WidgetTester tester) async {
  NativeTracker.appOpenStream.add('DEVICE_UNLOCK');
  await tester.pump(const Duration(milliseconds: 300));
}

/// Inject DEVICE_LOCK event — same as user pressing power button.
Future<void> _lock(WidgetTester tester) async {
  NativeTracker.appOpenStream.add('DEVICE_LOCK');
  await tester.pump(const Duration(milliseconds: 200));
}

/// Wait for the InterventionOverlayScreen to appear, then handle it:
/// - Snooze if timer-based (user not ready)
/// - Complete if actionable (checklist, breathing, tap-counter)
Future<void> _handleOverlay(WidgetTester tester, String triggerName,
    {bool snooze = false}) async {
  // Give stream + setState time to build the overlay
  await tester.pump(const Duration(milliseconds: 600));

  final overlayFinder =
      find.byElementPredicate((e) => _isType(e, 'InterventionOverlayScreen'));
  expect(overlayFinder, findsOneWidget,
      reason: 'InterventionOverlayScreen must appear for "$triggerName".');

  if (snooze) {
    // User acknowledges but isn't ready — snooze (timer still running)
    final snoozeBtn = find.text('Snooze Limit');
    expect(snoozeBtn, findsOneWidget);
    await tester.tap(snoozeBtn);
    await tester.pump(const Duration(milliseconds: 600));
    _report[triggerName] = '⚠️  Overlay shown — Snoozed (timer-based)';
  } else {
    // Snooze is still the safe default for real-detection triggers in test
    final snoozeBtn = find.text('Snooze Limit');
    if (snoozeBtn.evaluate().isNotEmpty) {
      await tester.tap(snoozeBtn);
      await tester.pump(const Duration(milliseconds: 600));
    }
    _report[triggerName] = '⚠️  Overlay shown — Snoozed';
  }

  // Verify overlay dismissed and dashboard is back
  expect(
    find.byElementPredicate((e) => _isType(e, 'InterventionOverlayScreen')),
    findsNothing,
    reason: 'Overlay must be dismissed after handling "$triggerName".',
  );
  expect(
    find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
    findsOneWidget,
    reason: 'DashboardShell must be visible after "$triggerName" overlay.',
  );
}

void _printReport() {
  debugPrint('');
  debugPrint('═══════════════════════════════════════════════════════════════');
  debugPrint('   📊 REAL OS TELEMETRY SIMULATION REPORT');
  debugPrint('   (All triggers fired via NativeTracker.appOpenStream)');
  debugPrint('═══════════════════════════════════════════════════════════════');
  for (final entry in _report.entries) {
    debugPrint('   ${entry.key.padRight(26)} → ${entry.value}');
  }
  debugPrint('───────────────────────────────────────────────────────────────');
  debugPrint('   Total triggers verified: ${_report.length}');
  debugPrint('═══════════════════════════════════════════════════════════════');
}

// ══════════════════════════════════════════════════════════════════════════════
// MAIN TEST
// ══════════════════════════════════════════════════════════════════════════════

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Real OS Telemetry — All Detection-Based Triggers',
      (WidgetTester tester) async {
    // Mock the device_apps MethodChannel to prevent native querying hangs on modern emulators
    const channel = MethodChannel('g123k/device_apps');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (methodCall) async {
      if (methodCall.method.startsWith('getInstalledApps')) {
        return [];
      }
      return null;
    });

    // ── Setup ─────────────────────────────────────────────────────────────────
    // Pre-seed SharedPreferences with:
    //   • A calibrated user profile (skips onboarding)
    //   • App category mappings (Social, Entertainment, Productivity)
    //   • Boundary settings (bedtime 23:00, focus 09:00-17:00)
    SharedPreferences.setMockInitialValues({
      'user_pin': '1234',
      'userProfile':
          '{"name":"OS Test User","ageGroup":"25-34","occupation":"Professional",'
          '"calibrationPath":"observe","observationDay":7,"isCalibrated":true,'
          '"activeIntentionCard":{"title":"The Intentional Seeker","emoji":"🌱",'
          '"subtitle":"Digital Growth","description":"Calibrated."}}',
      'targetBedtime': '23:00',
      'focusStartTime': '09:00',
      'focusEndTime': '17:00',
      'morningBufferMinutes': 30,
      'categorizedApps': json.encode({
        'Social': _socialApps,
        'Entertainment': _entertainmentApps,
        'Productivity': _productivityApps,
        'Emotional Distraction': ['com.tinder', 'com.bumble.app'],
        'Utility': [
          'com.google.android.calculator',
          'com.android.chrome',
          'com.android.settings',
        ],
      }),
    });

    // Launch app and log in
    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    final pinField = find.byType(TextField);
    await tester.enterText(pinField.first, '1234');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'Must be on DashboardShell before simulation starts.',
    );

    debugPrint('');
    debugPrint('🚀 Real OS Telemetry Simulation Starting...');
    debugPrint('   Injecting raw app-open & device events into NativeTracker');
    debugPrint('');

    // ══════════════════════════════════════════════════════════════════════════
    // 🌅 MORNING (simulated: 09:15 AM, inside focus hours, after buffer)
    // ══════════════════════════════════════════════════════════════════════════
    debugPrint('🌅 MORNING SESSION (09:15 AM)');
    InterventionEngine().setSimulatedTime(
        DateTime(2026, 6, 12, 9, 15)); // 9:15 AM — inside focus hours

    // ── TRIGGER 1: Dopamine Loop ───────────────────────────────────────────
    // Real event: User switches between 3 social apps within 60 seconds.
    // Detection: _recentAppOpens.length >= 3 within 60 seconds.
    debugPrint('');
    debugPrint('   🔵 Simulating: Rapid app switching (Dopamine Loop)');
    debugPrint('      Real behavior: Instagram → Twitter → Reddit in 60s');
    await _openApp(tester, _socialApps[0], label: 'Instagram');
    await _openApp(tester, _socialApps[1], label: 'Twitter');
    await _openApp(tester, _socialApps[2], label: 'Facebook'); // 3rd → fires!

    await _handleOverlay(tester, 'Dopamine Loop', snooze: true);
    debugPrint('   ✅ Dopamine Loop triggered by real app-switching pattern');

    // ── TRIGGER 2: Phantom Check ───────────────────────────────────────────
    // Real event: User unlocks phone 10+ times in 15 minutes checking for nothing.
    // Detection: _recentUnlocks.length >= 10 within 15 minutes.
    debugPrint('');
    debugPrint('   🔵 Simulating: Compulsive unlocking (Phantom Check)');
    debugPrint('      Real behavior: 10 device unlocks in 15 minutes');
    for (int i = 1; i <= 10; i++) {
      await _unlock(tester);
      await _lock(tester);
      debugPrint('      Unlock/Lock #$i');
    }

    await _handleOverlay(tester, 'Phantom Check', snooze: true);
    debugPrint('   ✅ Phantom Check triggered by repeated unlock pattern');

    // ══════════════════════════════════════════════════════════════════════════
    // 💼 WORK HOURS (simulated: 6:30 PM — OUTSIDE focus hours 09:00-17:00)
    // ══════════════════════════════════════════════════════════════════════════
    debugPrint('');
    debugPrint('💼 AFTER-WORK (06:30 PM — outside focus hours)');
    InterventionEngine()
        .setSimulatedTime(DateTime(2026, 6, 12, 18, 30)); // 6:30 PM

    // ── TRIGGER 3: Work-Life Blur ──────────────────────────────────────────
    // Real event: User opens Slack at 6:30 PM, outside their 09:00-17:00 focus zone.
    // Detection: category == 'Productivity' AND outside focusStartTime-focusEndTime.
    debugPrint('');
    debugPrint('   🔵 Simulating: Opening Slack after hours (Work-Life Blur)');
    debugPrint('      Real behavior: Slack opened at 6:30 PM, focus ends at 5 PM');
    await _openApp(tester, _productivityApps[0], label: 'Slack @ 6:30 PM');

    await _handleOverlay(tester, 'Work-Life Blur', snooze: true);
    debugPrint('   ✅ Work-Life Blur triggered by Productivity app outside focus hours');

    // ── TRIGGER 4: Reactive Mode ───────────────────────────────────────────
    // Real event: 5 different apps opened in 10 minutes (each > 60s apart).
    // Detection: _openedAppsInTenMins.length >= 5.
    // Note: apps are spaced 70s apart to prevent Dopamine Loop (which fires at 3 in 60s).
    debugPrint('');
    debugPrint('   🔵 Simulating: Notification-reactive browsing (Reactive Mode)');
    debugPrint('      Real behavior: 5 apps in 10 min, each opened 70s apart');

    final baseTime = DateTime(2026, 6, 12, 18, 35);
    for (int i = 0; i < 5; i++) {
      // Advance simulated time by 70s between each open (avoids Dopamine Loop's 60s window)
      InterventionEngine()
          .setSimulatedTime(baseTime.add(Duration(seconds: i * 70)));
      await _openApp(tester, _socialApps[i % _socialApps.length],
          label: 'Open #${i + 1} at +${i * 70}s');
    }

    await _handleOverlay(tester, 'Reactive Mode', snooze: true);
    debugPrint('   ✅ Reactive Mode triggered by notification-reactive app opening');

    // ── TRIGGER 5: Info Overload ───────────────────────────────────────────
    // Real event: After Reactive Mode cleared _openedAppsInTenMins,
    // one more Social app open fills _newsAppOpens to 5 → Info Overload fires.
    // Detection: _newsAppOpens.length >= 5 within 15 minutes.
    // State: _newsAppOpens = [4 from Reactive Mode phase] + this 1 = 5.
    debugPrint('');
    debugPrint('   🔵 Simulating: News/social information overload (Info Overload)');
    debugPrint('      Real behavior: 6th social app opens — _newsAppOpens reaches 5');
    InterventionEngine()
        .setSimulatedTime(baseTime.add(const Duration(seconds: 360)));
    await _openApp(tester, _socialApps[3], label: 'Reddit (6th Social)');

    await _handleOverlay(tester, 'Info Overload', snooze: true);
    debugPrint('   ✅ Info Overload triggered by sustained social news browsing');

    // ══════════════════════════════════════════════════════════════════════════
    // 🌙 LATE NIGHT (simulated: 11:30 PM — past 23:00 bedtime)
    // ══════════════════════════════════════════════════════════════════════════
    debugPrint('');
    debugPrint('🌙 LATE NIGHT (11:30 PM — past 11:00 PM bedtime)');
    InterventionEngine()
        .setSimulatedTime(DateTime(2026, 6, 12, 23, 30)); // 11:30 PM

    // ── TRIGGER 6: Midnight Drift ──────────────────────────────────────────
    // Real event: User opens Instagram at 11:30 PM, past their 11:00 PM bedtime.
    // Detection: _isPastBedtime() == true AND category == 'Social' or 'Entertainment'.
    debugPrint('');
    debugPrint('   🔵 Simulating: Late-night social scroll (Midnight Drift)');
    debugPrint('      Real behavior: Instagram opened at 11:30 PM, bedtime 11:00 PM');
    await _openApp(tester, _socialApps[0], label: 'Instagram @ 11:30 PM');

    await _handleOverlay(tester, 'Midnight Drift', snooze: true);
    debugPrint('   ✅ Midnight Drift triggered by social app past bedtime');

    // ── TRIGGER 7: Last Scroll Loop ────────────────────────────────────────
    // Real event: User keeps unlocking the phone 3 times in 2 minutes while
    //             trying to put it down late at night.
    // Detection: Past bedtime AND _recentUnlocks within 2 minutes >= 3.
    debugPrint('');
    debugPrint('   🔵 Simulating: "One last check" loop (Last Scroll Loop)');
    debugPrint('      Real behavior: 3 unlocks in 2 minutes past bedtime');
    InterventionEngine()
        .setSimulatedTime(DateTime(2026, 6, 12, 23, 45)); // 11:45 PM
    for (int i = 1; i <= 3; i++) {
      await _unlock(tester);
      await _lock(tester);
      debugPrint('      Night Unlock/Lock #$i');
    }

    await _handleOverlay(tester, 'Last Scroll Loop', snooze: true);
    debugPrint('   ✅ Last Scroll Loop triggered by repeated late-night unlocking');

    // ── Final state check ─────────────────────────────────────────────────────
    // Reset simulated time back to real time
    InterventionEngine().setSimulatedTime(null);

    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'DashboardShell must be intact after all OS telemetry tests.',
    );

    expect(_report.length, greaterThanOrEqualTo(7),
        reason: 'All 7 real-detection triggers must have been tested.');

    _printReport();

    debugPrint('');
    debugPrint('🎉 REAL OS TELEMETRY SIMULATION COMPLETE!');
    debugPrint('');
    debugPrint('   Note: The following triggers have no real OS detection');
    debugPrint('   (they require ML/NLP/scroll-velocity analysis beyond');
    debugPrint('   Android UsageStats counters, so only exist in the debug');
    debugPrint('   FAB simulator):');
    debugPrint('   • The Void         (scroll duration monitoring)');
    debugPrint('   • Social Spiral    (profile-view pattern recognition)');
    debugPrint('   • Ghosting Anxiety (typing + delete + close pattern)');
    debugPrint('   • Upward Comparison (passive social content analysis)');
    debugPrint('   • Interaction Spike (scroll velocity measurement)');
  });
}
