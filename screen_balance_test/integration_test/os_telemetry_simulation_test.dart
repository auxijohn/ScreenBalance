/// ════════════════════════════════════════════════════════════════════════════
/// OS TELEMETRY FULL DAY SIMULATION TEST
/// ────────────────────────────────────────────────────────────────────────────
/// This script simulates a realistic day of smartphone usage, firing all 13
/// OS telemetry trigger events that ScreenBalance monitors in real user sessions.
///
/// Triggers are grouped into 4 time-of-day sessions:
///   🌅 Morning Session  : Phantom Check, Info Overload
///   💼 Work Hours       : Work-Life Blur, Reactive Mode
///   🌆 Afternoon        : Dopamine Loop, Social Spiral, Ghosting Anxiety
///   🌙 Evening/Night    : The Void, Upward Comparison, Midnight Drift,
///                         Novelty Hunt, Last Scroll Loop, Interaction Spike
///
/// Each trigger fires the real InterventionOverlayScreen and automates the
/// correct somatic reset interaction for that trigger type:
///   • Timer-based      → Snooze Limit (realistic: user not ready)
///   • 5-Object Scan    → Check all 5 items → Complete
///   • 3-Texture Scan   → Check all 3 textures → Complete
///   • Breathing        → Tap "Complete 3 Breath Cycles" → Complete
///   • 5-Tap Counter    → Tap 5 times → Complete
/// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screen_balance/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Type helpers ──────────────────────────────────────────────────────────────

bool _isType(Element e, String typeName) =>
    e.widget.runtimeType.toString() == typeName;

// ── Trigger interaction types ─────────────────────────────────────────────────

enum _ResetType {
  timer,        // 60s/30s countdown — use Snooze Limit
  checklist5,   // 5-Object Scan checkboxes
  checklist3,   // 3-Texture Scan checkboxes  
  breathing,    // Breathing animation + "Complete 3 Breath Cycles" button
  tapCounter,   // 5 mindful taps
}

class _TriggerSpec {
  final String triggerId;
  final String displayName;
  final _ResetType resetType;
  final String? tapButtonText; // For tapCounter type
  final List<String>? checklistItems; // For checklist types

  const _TriggerSpec({
    required this.triggerId,
    required this.displayName,
    required this.resetType,
    this.tapButtonText,
    this.checklistItems,
  });
}

// All 13 OS telemetry triggers in bottom-sheet list order
const List<_TriggerSpec> _allTriggers = [
  // ── Visible in sheet without scrolling ──────────────────────────────────
  _TriggerSpec(
    triggerId: 'dopamine_loop',
    displayName: 'Dopamine Loop',
    resetType: _ResetType.timer,
  ),
  _TriggerSpec(
    triggerId: 'the_void',
    displayName: 'The Void',
    resetType: _ResetType.checklist5,
    checklistItems: ['Object 1', 'Object 2', 'Object 3', 'Object 4', 'Object 5'],
  ),
  _TriggerSpec(
    triggerId: 'reactive_mode',
    displayName: 'Reactive Mode',
    resetType: _ResetType.timer,
  ),
  _TriggerSpec(
    triggerId: 'social_spiral',
    displayName: 'Social Spiral',
    resetType: _ResetType.breathing,
  ),
  _TriggerSpec(
    triggerId: 'ghosting_anxiety',
    displayName: 'Ghosting Anxiety',
    resetType: _ResetType.breathing,
  ),
  // ── Need 1 scroll ────────────────────────────────────────────────────────
  _TriggerSpec(
    triggerId: 'upward_comparison',
    displayName: 'Upward Comparison Risk',
    resetType: _ResetType.tapCounter,
    tapButtonText: 'I am Mindful of this Comparison',
  ),
  _TriggerSpec(
    triggerId: 'midnight_drift',
    displayName: 'Midnight Drift',
    resetType: _ResetType.checklist3,
    checklistItems: [
      'Cold table or surface',
      'Soft pillow or fabric',
      'Your own palms pressed together',
    ],
  ),
  _TriggerSpec(
    triggerId: 'last_scroll_loop',
    displayName: 'Last Scroll Loop',
    resetType: _ResetType.timer,
  ),
  // ── Need 2 scrolls ───────────────────────────────────────────────────────
  _TriggerSpec(
    triggerId: 'work_life_blur',
    displayName: 'Work-Life Blur',
    resetType: _ResetType.timer,
  ),
  _TriggerSpec(
    triggerId: 'phantom_check',
    displayName: 'Phantom Check',
    resetType: _ResetType.tapCounter,
    tapButtonText: 'Log 1 Shoulder Roll',
  ),
  _TriggerSpec(
    triggerId: 'novelty_hunt',
    displayName: 'Novelty Hunt',
    resetType: _ResetType.timer,
  ),
  // ── Need 3 scrolls ───────────────────────────────────────────────────────
  _TriggerSpec(
    triggerId: 'info_overload',
    displayName: 'Info Overload',
    resetType: _ResetType.timer,
  ),
  _TriggerSpec(
    triggerId: 'interaction_spike',
    displayName: 'Interaction Spike',
    resetType: _ResetType.timer,
  ),
];

// ── Test report tracking ──────────────────────────────────────────────────────

final Map<String, bool> _testReport = {};

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Opens the debug FAB simulator sheet and taps the requested trigger.
/// Scrolls down in the sheet ListView if the trigger is not immediately visible.
Future<void> _fireTrigger(
    WidgetTester tester, _TriggerSpec trigger) async {
  // Open debug FAB
  final bugFab = find.byType(FloatingActionButton);
  await tester.ensureVisible(bugFab);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(bugFab, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 800));

  // Try to find the trigger; scroll down if needed
  int scrollAttempts = 0;
  while (find.text(trigger.displayName).evaluate().isEmpty &&
      scrollAttempts < 4) {
    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      await tester.drag(listView.last, const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 400));
    }
    scrollAttempts++;
  }

  expect(find.text(trigger.displayName), findsOneWidget,
      reason:
          '"${trigger.displayName}" must be visible in the simulator sheet.');

  await tester.tap(find.text(trigger.displayName));
  await tester.pump(const Duration(milliseconds: 800));
}

/// Handles the InterventionOverlayScreen based on the trigger's reset type.
/// Returns true if the full somatic reset was completed, false if snoozed.
Future<bool> _handleOverlay(
    WidgetTester tester, _TriggerSpec trigger) async {
  // Verify overlay appeared
  expect(
    find.byElementPredicate((e) => _isType(e, 'InterventionOverlayScreen')),
    findsOneWidget,
    reason:
        'InterventionOverlayScreen must appear for "${trigger.displayName}".',
  );

  bool completed = false;

  switch (trigger.resetType) {
    // ── TIMER (Snooze Limit — user not ready, realistic choice) ─────────────
    case _ResetType.timer:
      final snoozeBtn = find.text('Snooze Limit');
      expect(snoozeBtn, findsOneWidget);
      await tester.tap(snoozeBtn);
      await tester.pump(const Duration(milliseconds: 600));
      completed = false; // Snoozed, not completed
      break;

    // ── CHECKLIST (5-Object Scan) ────────────────────────────────────────────
    case _ResetType.checklist5:
      for (final item in trigger.checklistItems!) {
        final checkbox = find.text(item);
        await tester.ensureVisible(checkbox);
        await tester.tap(checkbox, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 250));
      }
      final proceedBtn5 = find.text('Proceed to Validation');
      await tester.ensureVisible(proceedBtn5);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(proceedBtn5, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800));
      // Handle PostValidationScreen mood check
      await _completeMoodCheck(tester);
      completed = true;
      break;

    // ── CHECKLIST (3-Texture Scan) ───────────────────────────────────────────
    case _ResetType.checklist3:
      for (final item in trigger.checklistItems!) {
        final checkbox = find.text(item);
        await tester.ensureVisible(checkbox);
        await tester.tap(checkbox, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 250));
      }
      final proceedBtn3 = find.text('Proceed to Validation');
      await tester.ensureVisible(proceedBtn3);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(proceedBtn3, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800));
      await _completeMoodCheck(tester);
      completed = true;
      break;

    // ── BREATHING ────────────────────────────────────────────────────────────
    case _ResetType.breathing:
      final completeBreathBtn = find.text('Complete 3 Breath Cycles');
      expect(completeBreathBtn, findsOneWidget,
          reason: 'Breathing reset button must be present.');
      await tester.tap(completeBreathBtn);
      await tester.pump(const Duration(milliseconds: 400));
      final proceedBtnBreath = find.text('Proceed to Validation');
      await tester.ensureVisible(proceedBtnBreath);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(proceedBtnBreath, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800));
      await _completeMoodCheck(tester);
      completed = true;
      break;

    // ── TAP COUNTER (5 mindful taps) ─────────────────────────────────────────
    case _ResetType.tapCounter:
      final tapBtn = find.text(trigger.tapButtonText!);
      expect(tapBtn, findsOneWidget,
          reason: '"${trigger.tapButtonText}" button must be present.');
      for (int i = 0; i < 5; i++) {
        await tester.tap(tapBtn);
        await tester.pump(const Duration(milliseconds: 200));
      }
      final proceedBtnTap = find.text('Proceed to Validation');
      await tester.ensureVisible(proceedBtnTap);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(proceedBtnTap, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800));
      await _completeMoodCheck(tester);
      completed = true;
      break;
  }

  // Verify overlay is dismissed
  await tester.pump(const Duration(milliseconds: 400));
  expect(
    find.byElementPredicate((e) => _isType(e, 'InterventionOverlayScreen')),
    findsNothing,
    reason:
        'InterventionOverlayScreen must be dismissed after "${trigger.displayName}" reset.',
  );

  // Verify back on dashboard
  expect(
    find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
    findsOneWidget,
    reason: 'DashboardShell must be visible after "${trigger.displayName}".',
  );

  return completed;
}

/// Handles the PostValidationScreen mood check by tapping the first mood card.
Future<void> _completeMoodCheck(WidgetTester tester) async {
  // PostValidationScreen appears after "Proceed to Validation"
  if (find.byElementPredicate((e) => _isType(e, 'PostValidationScreen'))
      .evaluate()
      .isNotEmpty) {
    final moodCards = find.byType(InkWell);
    if (moodCards.evaluate().isNotEmpty) {
      await tester.tap(moodCards.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      // Wait for 600ms Future.delayed auto-pop inside PostValidationScreen
      await tester.pump(const Duration(milliseconds: 800));
    }
  }
}

/// Prints a formatted test report at the end of the session.
void _printReport() {
  debugPrint('');
  debugPrint('═══════════════════════════════════════════════════════');
  debugPrint('   📊 OS TELEMETRY SIMULATION REPORT');
  debugPrint('═══════════════════════════════════════════════════════');

  int passed = 0;
  int total = _testReport.length;

  for (final entry in _testReport.entries) {
    final icon = entry.value ? '✅' : '⚠️ ';
    final status = entry.value ? 'Reset COMPLETED' : 'Snoozed (timer)';
    debugPrint('  $icon  ${entry.key.padRight(26)} → $status');
    if (entry.value) passed++;
  }

  debugPrint('───────────────────────────────────────────────────────');
  debugPrint('  Total triggers fired : $total / 13');
  debugPrint('  Full resets completed: $passed / $total');
  debugPrint('  Snoozed (timer runs) : ${total - passed} / $total');
  debugPrint('═══════════════════════════════════════════════════════');
  debugPrint('');
}

// ══════════════════════════════════════════════════════════════════════════════
// MAIN TEST
// ══════════════════════════════════════════════════════════════════════════════

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'OS Telemetry Full Day Simulation — All 13 Triggers',
      (WidgetTester tester) async {
    // ── Setup: pre-calibrated user profile ────────────────────────────────────
    SharedPreferences.setMockInitialValues({
      'user_pin': '1234',
      'userProfile':
          '{"name":"Simulation User","ageGroup":"25-34","occupation":"Professional",'
          '"calibrationPath":"observe","observationDay":7,"isCalibrated":true,'
          '"activeIntentionCard":{"title":"The Intentional Seeker","emoji":"🌱",'
          '"subtitle":"Digital Growth","description":"Calibrated."}}',
    });

    await tester.pumpWidget(const ScreenBalanceApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // PIN login
    final pinField = find.byType(TextField);
    await tester.enterText(pinField.first, '1234');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'Must reach DashboardShell before simulation starts.',
    );

    debugPrint('');
    debugPrint('🚀 Starting OS Telemetry Full Day Simulation...');
    debugPrint('   Simulating 13 trigger events across a realistic day');
    debugPrint('');

    // ── 🌅 MORNING SESSION ───────────────────────────────────────────────────
    debugPrint('🌅 MORNING SESSION (7–9 AM)');

    // 1. Phantom Check — 10+ phone unlocks in 15 mins
    debugPrint('   → Firing: Phantom Check (10+ phantom unlocks)');
    await _fireTrigger(tester, _allTriggers[9]); // phantom_check
    final r1 = await _handleOverlay(tester, _allTriggers[9]);
    _testReport[_allTriggers[9].displayName] = r1;
    debugPrint(
        '   ✓ Phantom Check handled (${r1 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // 2. Info Overload — rapid news browsing (30s timer, snooze)
    debugPrint('   → Firing: Info Overload (5+ news apps)');
    await _fireTrigger(tester, _allTriggers[11]); // info_overload
    final r2 = await _handleOverlay(tester, _allTriggers[11]);
    _testReport[_allTriggers[11].displayName] = r2;
    debugPrint(
        '   ✓ Info Overload handled (${r2 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // ── 💼 WORK HOURS ────────────────────────────────────────────────────────
    debugPrint('💼 WORK HOURS (9 AM – 1 PM)');

    // 3. Work-Life Blur — Slack outside focus hours
    debugPrint('   → Firing: Work-Life Blur (Slack/Email outside focus hours)');
    await _fireTrigger(tester, _allTriggers[8]); // work_life_blur
    final r3 = await _handleOverlay(tester, _allTriggers[8]);
    _testReport[_allTriggers[8].displayName] = r3;
    debugPrint(
        '   ✓ Work-Life Blur handled (${r3 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // 4. Reactive Mode — checking notifications constantly
    debugPrint('   → Firing: Reactive Mode (5+ notification opens in 10 min)');
    await _fireTrigger(tester, _allTriggers[2]); // reactive_mode
    final r4 = await _handleOverlay(tester, _allTriggers[2]);
    _testReport[_allTriggers[2].displayName] = r4;
    debugPrint(
        '   ✓ Reactive Mode handled (${r4 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // ── 🌆 AFTERNOON ─────────────────────────────────────────────────────────
    debugPrint('🌆 AFTERNOON (1–6 PM)');

    // 5. Dopamine Loop — rapid app switching after lunch
    debugPrint('   → Firing: Dopamine Loop (3+ apps in <60 seconds)');
    await _fireTrigger(tester, _allTriggers[0]); // dopamine_loop
    final r5 = await _handleOverlay(tester, _allTriggers[0]);
    _testReport[_allTriggers[0].displayName] = r5;
    debugPrint(
        '   ✓ Dopamine Loop handled (${r5 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // 6. Social Spiral — profile browsing session
    debugPrint('   → Firing: Social Spiral (10+ rapid social profile views)');
    await _fireTrigger(tester, _allTriggers[3]); // social_spiral
    final r6 = await _handleOverlay(tester, _allTriggers[3]);
    _testReport[_allTriggers[3].displayName] = r6;
    debugPrint(
        '   ✓ Social Spiral handled (${r6 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // 7. Ghosting Anxiety — composing a message, hesitating
    debugPrint('   → Firing: Ghosting Anxiety (typing → deleting → closing)');
    await _fireTrigger(tester, _allTriggers[4]); // ghosting_anxiety
    final r7 = await _handleOverlay(tester, _allTriggers[4]);
    _testReport[_allTriggers[4].displayName] = r7;
    debugPrint(
        '   ✓ Ghosting Anxiety handled (${r7 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // 8. Upward Comparison Risk — passive scrolling comparison
    debugPrint(
        '   → Firing: Upward Comparison Risk (prolonged passive social scroll)');
    await _fireTrigger(tester, _allTriggers[5]); // upward_comparison
    final r8 = await _handleOverlay(tester, _allTriggers[5]);
    _testReport[_allTriggers[5].displayName] = r8;
    debugPrint(
        '   ✓ Upward Comparison handled (${r8 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // ── 🌙 EVENING ───────────────────────────────────────────────────────────
    debugPrint('🌙 EVENING (6–10 PM)');

    // 9. The Void — 20+ minute continuous scrolling session
    debugPrint('   → Firing: The Void (20+ mins continuous scrolling)');
    await _fireTrigger(tester, _allTriggers[1]); // the_void
    final r9 = await _handleOverlay(tester, _allTriggers[1]);
    _testReport[_allTriggers[1].displayName] = r9;
    debugPrint(
        '   ✓ The Void handled (${r9 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // 10. Novelty Hunt — shopping app hopping
    debugPrint('   → Firing: Novelty Hunt (5+ shopping apps in 10 min)');
    await _fireTrigger(tester, _allTriggers[10]); // novelty_hunt
    final r10 = await _handleOverlay(tester, _allTriggers[10]);
    _testReport[_allTriggers[10].displayName] = r10;
    debugPrint(
        '   ✓ Novelty Hunt handled (${r10 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // ── 🌑 LATE NIGHT ────────────────────────────────────────────────────────
    debugPrint('🌑 LATE NIGHT (10 PM – 2 AM)');

    // 11. Midnight Drift — past quiet hours
    debugPrint(
        '   → Firing: Midnight Drift (usage 1 hour past target bedtime)');
    await _fireTrigger(tester, _allTriggers[6]); // midnight_drift
    final r11 = await _handleOverlay(tester, _allTriggers[6]);
    _testReport[_allTriggers[6].displayName] = r11;
    debugPrint(
        '   ✓ Midnight Drift handled (${r11 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // 12. Interaction Spike — rapid scrolling speed doubling
    debugPrint('   → Firing: Interaction Spike (scrolling speed doubling)');
    await _fireTrigger(tester, _allTriggers[12]); // interaction_spike
    final r12 = await _handleOverlay(tester, _allTriggers[12]);
    _testReport[_allTriggers[12].displayName] = r12;
    debugPrint(
        '   ✓ Interaction Spike handled (${r12 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // 13. Last Scroll Loop — 3+ unlocks in 2 mins at night
    debugPrint('   → Firing: Last Scroll Loop (3+ night unlocks in 2 min)');
    await _fireTrigger(tester, _allTriggers[7]); // last_scroll_loop
    final r13 = await _handleOverlay(tester, _allTriggers[7]);
    _testReport[_allTriggers[7].displayName] = r13;
    debugPrint(
        '   ✓ Last Scroll Loop handled (${r13 ? "reset completed" : "snoozed"})');
    await tester.pump(const Duration(milliseconds: 500));

    // ── Final verification ────────────────────────────────────────────────────
    expect(
      find.byElementPredicate((e) => _isType(e, 'DashboardShell')),
      findsOneWidget,
      reason: 'DashboardShell must be intact after all 13 trigger simulations.',
    );

    expect(_testReport.length, equals(13),
        reason: 'All 13 triggers must have been tested.');

    _printReport();

    debugPrint(
        '🎉 OS TELEMETRY SIMULATION COMPLETE — All 13 triggers verified!');
  });
}
