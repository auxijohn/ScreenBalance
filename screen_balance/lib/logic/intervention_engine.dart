import 'dart:async';
import 'dart:math';
import '../models/boundary_settings.dart';
import 'native_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
class BehavioralEvent {
  final DateTime timestamp;
  final String eventType;
  final String detail;

  BehavioralEvent({
    required this.timestamp,
    required this.eventType,
    required this.detail,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'eventType': eventType,
        'detail': detail,
      };
}

class AppOpenRecord {
  final String packageName;
  final DateTime timestamp;
  AppOpenRecord(this.packageName, this.timestamp);
}

class InterventionEngine {
  static final InterventionEngine _instance = InterventionEngine._internal();
  factory InterventionEngine() => _instance;
  InterventionEngine._internal();

  // Telemetry lists
  final List<AppOpenRecord> _recentAppOpens = [];
  final List<DateTime> _recentUnlocks = [];
  final List<DateTime> _recentLocks = [];
  final List<DateTime> _openedAppsInTenMins = [];
  final List<DateTime> _shoppingAppOpens = [];
  final List<DateTime> _newsAppOpens = [];
  final List<AppOpenRecord> _recentNotifications = [];
  
  // Decoupled Behavioral History datastore
  final List<BehavioralEvent> behavioralHistory = [];
  
  // State variables
  DateTime? _simulatedTimeOverride;
  bool _somaticResetCompletedOverride = false;
  DateTime? _firstMorningUnlockTime;
  int _unlockCountToday = 0;
  String? _lastOpenedPackage;
  DateTime? _lastOpenedTime;

  // App usage tracking map: package name -> cumulative duration spent today
  final Map<String, Duration> _appUsageToday = {};
  DateTime? _lastTrackingDate;

  void _checkAndResetDailyData(DateTime now) {
    if (_lastTrackingDate == null) {
      _lastTrackingDate = now;
      return;
    }
    if (_lastTrackingDate!.year != now.year || 
        _lastTrackingDate!.month != now.month || 
        _lastTrackingDate!.day != now.day) {
      _unlockCountToday = 0;
      _appUsageToday.clear();
      _lastTrackingDate = now;
    }
  }

  void _updateActiveAppDuration() {
    if (_lastOpenedPackage != null && _lastOpenedTime != null) {
      final now = getCurrentTime();
      final duration = now.difference(_lastOpenedTime!);
      _appUsageToday[_lastOpenedPackage!] = (_appUsageToday[_lastOpenedPackage!] ?? Duration.zero) + duration;
      _lastOpenedTime = now;
    }
  }

  String _getFriendlyName(String packageName) {
    final parts = packageName.split('.');
    if (parts.length > 1) {
      for (final part in parts.reversed) {
        if (part != 'android' && part != 'com' && part != 'app' && part != 'messenger') {
          return part[0].toUpperCase() + part.substring(1);
        }
      }
      return parts.last[0].toUpperCase() + parts.last.substring(1);
    }
    return packageName;
  }

  int get unlockCountToday => _unlockCountToday;

  @visibleForTesting
  set unlockCountToday(int value) {
    _unlockCountToday = value;
  }

  int getDigitalMindfulnessScore() {
    int score = 100;
    if (_unlockCountToday > 10) {
      score -= (_unlockCountToday - 10) * 2;
    }

    final now = getCurrentTime();
    final todayInterventionsCount = behavioralHistory.where((event) {
      return event.eventType == "Intervention Triggered" &&
          event.timestamp.year == now.year &&
          event.timestamp.month == now.month &&
          event.timestamp.day == now.day;
    }).length;

    score -= todayInterventionsCount * 5;

    return score.clamp(0, 100);
  }

  Map<String, String> getMindfulnessPhrase(int score) {
    if (score == 100) {
      return {
        'title': 'Zen Master',
        'description': 'Exceptional digital presence. You are fully in control of your screen time.',
        'motivation': 'You are a beacon of digital balance—keep shining!'
      };
    }

    final now = getCurrentTime();
    final todayInterventions = behavioralHistory.where((event) {
      return event.eventType == "Intervention Triggered" &&
          event.timestamp.year == now.year &&
          event.timestamp.month == now.month &&
          event.timestamp.day == now.day;
    }).toList();

    String? lastTriggerId;
    if (todayInterventions.isNotEmpty) {
      final lastEvent = todayInterventions.last;
      final detail = lastEvent.detail;
      if (detail.contains('morning_buffer')) lastTriggerId = 'morning_buffer';
      else if (detail.contains('staged_sunset_t0')) lastTriggerId = 'staged_sunset_t0';
      else if (detail.contains('staged_sunset_t30')) lastTriggerId = 'staged_sunset_t30';
      else if (detail.contains('staged_sunset_t60')) lastTriggerId = 'staged_sunset_t60';
      else if (detail.contains('staged_sunset_t90')) lastTriggerId = 'staged_sunset_t90';
      else if (detail.contains('midnight_drift')) lastTriggerId = 'midnight_drift';
      else if (detail.contains('last_scroll_loop')) lastTriggerId = 'last_scroll_loop';
      else if (detail.contains('work_life_blur')) lastTriggerId = 'work_life_blur';
      else if (detail.contains('dopamine_loop')) lastTriggerId = 'dopamine_loop';
      else if (detail.contains('reactive_mode')) lastTriggerId = 'reactive_mode';
      else if (detail.contains('novelty_hunt')) lastTriggerId = 'novelty_hunt';
      else if (detail.contains('info_overload')) lastTriggerId = 'info_overload';
      else if (detail.contains('interaction_spike')) lastTriggerId = 'interaction_spike';
      else if (detail.contains('the_void')) lastTriggerId = 'the_void';
      else if (detail.contains('ghosting_anxiety')) lastTriggerId = 'ghosting_anxiety';
      else if (detail.contains('phantom_check')) lastTriggerId = 'phantom_check';
      else if (detail.contains('daily_cap_limit')) lastTriggerId = 'daily_cap_limit';
    }

    final Random _rand = Random();
    List<String> _pick(List<String> options) => [options[_rand.nextInt(options.length)]];

    if (lastTriggerId == 'morning_buffer') {
      return {
        'title': 'Buffer Breaker',
        'description': 'Morning phone-free buffer was bypassed. Start your day with intention, not feeds.',
        'motivation': _pick([
          'Breathe first, scroll later—reclaim your morning.',
          'Your attention deserves a gentle morning wake-up.',
          'Try leaving your phone out of reach until after breakfast.'
        ]).first
      };
    } else if (lastTriggerId == 'staged_sunset_t0' ||
               lastTriggerId == 'staged_sunset_t30' ||
               lastTriggerId == 'staged_sunset_t60' ||
               lastTriggerId == 'staged_sunset_t90' ||
               lastTriggerId == 'midnight_drift' ||
               lastTriggerId == 'last_scroll_loop') {
      return {
        'title': 'Midnight Drifter',
        'description': 'Late night screen exposure detected. Protect your wind-down rhythm and sleep hygiene.',
        'motivation': _pick([
          'Sleep restores your focus; let the screen fade now.',
          'Breathe deep and step away from the light.',
          'Your mind deserves a quiet sunset.'
        ]).first
      };
    } else if (lastTriggerId == 'work_life_blur') {
      return {
        'title': 'Work-Life Blurer',
        'description': 'Checking work apps outside focus hours. Protect your recovery time to prevent burnout.',
        'motivation': _pick([
          'Boundaries build stamina; disconnect with pride.',
          'Work is done. Return to the present moment.',
          'Let Future You handle the remaining tasks.'
        ]).first
      };
    } else if (lastTriggerId == 'dopamine_loop') {
      return {
        'title': 'Dopamine Chaser',
        'description': 'Rapid app switching fragments attention and fuels mental fatigue.',
        'motivation': _pick([
          'Breathe and ground your attention in one task.',
          'Slow down; there is no rush to check everything.',
          'Break the loop by placing the phone face down.'
        ]).first
      };
    } else if (lastTriggerId == 'reactive_mode') {
      return {
        'title': 'Ping Responder',
        'description': 'High reactivity to notifications. You are checking apps immediately in response to pings.',
        'motivation': _pick([
          'You control the device, not the other way around.',
          'Let the notifications wait; your focus is precious.',
          'Consider placing your device on Do Not Disturb.'
        ]).first
      };
    } else if (lastTriggerId == 'novelty_hunt') {
      return {
        'title': 'Novelty Hunter',
        'description': 'Frequent entertainment or shopping app opens suggest search for stimulation.',
        'motivation': _pick([
          'Restlessness is normal; sit with it for a moment.',
          'Observe the urge to browse without acting on it.',
          'Swap a digital scroll for a brief physical stretch.'
        ]).first
      };
    } else if (lastTriggerId == 'info_overload') {
      return {
        'title': 'Info Absorber',
        'description': 'High rate of feed checks risks informational overload and comparison stress.',
        'motivation': _pick([
          'Silence the noise and reconnect with your immediate surroundings.',
          'Your mind is full enough; rest your eyes.',
          'Take a deep breath and let the feeds go.'
        ]).first
      };
    } else if (lastTriggerId == 'interaction_spike') {
      return {
        'title': 'Speed Scroller',
        'description': 'Accelerated scrolling detected, signaling nervous system hyper-arousal.',
        'motivation': _pick([
          'Breathe out slowly; let your scrolling finger rest.',
          'Sense your feet on the ground—slow down your pace.',
          'Your nervous system is revving up; take a pause.'
        ]).first
      };
    } else if (lastTriggerId == 'the_void') {
      return {
        'title': 'Void Explorer',
        'description': 'Continuous passive scrolling detected. Reclaim your awareness.',
        'motivation': _pick([
          'Look away from the screen and notice three things around you.',
          'The void has no bottom; choose to step out now.',
          'Bring your attention back to the physical room.'
        ]).first
      };
    } else if (lastTriggerId == 'ghosting_anxiety') {
      return {
        'title': 'Hesitant Communicator',
        'description': 'Repetitive message editing/deletion indicates communication hesitation or anxiety.',
        'motivation': _pick([
          'A pause is okay. You do not need to reply instantly.',
          'Breathe through the social pressure; you are doing fine.',
          'Trust your first draft or step away before sending.'
        ]).first
      };
    } else if (lastTriggerId == 'phantom_check') {
      return {
        'title': 'Phantom Checker',
        'description': 'Frequent unlocks without notifications, driven by muscle-memory habit loops.',
        'motivation': _pick([
          'Recognize the phantom itch and let it pass.',
          'Each pause before unlocking is a victory of awareness.',
          'Try keeping your phone in another room or drawer.'
        ]).first
      };
    } else if (lastTriggerId == 'daily_cap_limit') {
      return {
        'title': 'Mindful Limit Shift',
        'description': 'Daily allowance cap has been exceeded. Take a break to restore your attention spans.',
        'motivation': _pick([
          'Mindful screen limits build focus stamina.',
          'Stepping away now is a victory for your focus.',
          'Rest your mind; tomorrow brings a fresh allowance.'
        ]).first
      };
    }

    // Fallbacks based on score when no matched intervention is found
    if (score >= 90) {
      return {
        'title': 'Zen Practitioner',
        'description': 'Exceptional digital presence. You are fully in control of your screen time.',
        'motivation': _pick([
          'You are a beacon of digital balance—keep shining!',
          'Your focus is crystal clear; let it radiate outward.',
          'Every moment you manage is a victory of mindfulness.'
        ]).first
      };
    } else if (score >= 75) {
      return {
        'title': 'Mindful Practitioner',
        'description': 'Healthy digital boundaries are keeping you grounded and focused.',
        'motivation': _pick([
          'Every mindful step strengthens your focus.',
          'Consistency builds calm; you are on the right path.',
          'Your balanced usage inspires inner peace.'
        ]).first
      };
    } else if (score >= 60) {
      return {
        'title': 'Seeking Balance',
        'description': 'Moderate phone checking. Consider activating focus shields to prevent loops.',
        'motivation': _pick([
          'Balance is a journey—keep progressing.',
          'Small adjustments lead to lasting harmony.',
          'Your effort today seeds tomorrow’s equilibrium.'
        ]).first
      };
    } else if (score >= 40) {
      return {
        'title': 'Reactive Scroller',
        'description': 'High screen reactivity detected. Take brief somatic pauses to break the checking cycle.',
        'motivation': _pick([
          'Pause, breathe, and regain control.',
          'A mindful breath can reset your rhythm.',
          'Take a moment; your mind deserves calm.'
        ]).first
      };
    } else {
      return {
        'title': 'Digital Overload',
        'description': 'Compulsive phone checking. Turn off notifications and rest your eyes.',
        'motivation': _pick([
          'Release the overload—choose calm.',
          'Step back and let tranquility guide you.',
          'Quiet moments restore your digital wellbeing.'
        ]).first
      };
    }
  }

  // Returns a random motivational sentence for the given score
  String getRandomMotivation(int score) {
    final Random _rand = Random();
    List<String> options;
    if (score >= 90) {
      options = [
        'You are a beacon of digital balance—keep shining!',
        'Your focus is crystal clear; let it radiate outward.',
        'Every moment you manage is a victory of mindfulness.',
      ];
    } else if (score >= 75) {
      options = [
        'Every mindful step strengthens your focus.',
        'Consistency builds calm; you are on the right path.',
        'Your balanced usage inspires inner peace.',
      ];
    } else if (score >= 60) {
      options = [
        'Balance is a journey—keep progressing.',
        'Small adjustments lead to lasting harmony.',
        'Your effort today seeds tomorrow’s equilibrium.',
      ];
    } else if (score >= 40) {
      options = [
        'Pause, breathe, and regain control.',
        'A mindful breath can reset your rhythm.',
        'Take a moment; your mind deserves calm.',
      ];
    } else {
      options = [
        'Release the overload—choose calm.',
        'Step back and let tranquility guide you.',
        'Quiet moments restore your digital wellbeing.',
      ];
    }
    return options[_rand.nextInt(options.length)];
  }

  // Stream to tell the UI to show an overlay
  final StreamController<Map<String, String>> interventionStream = StreamController.broadcast();

  // Stream to notify subscribers of profile updates (Module 8/9/10)
  final StreamController<String> eventBusStream = StreamController.broadcast();

  // Telemetry state variables for advanced scroll/text triggers
  final List<DateTime> _recentScrolls = [];
  DateTime? _scrollStartTime;
  DateTime? _lastScrollTime;
  int _ghostingTypedChars = 0;
  int _ghostingDeletedChars = 0;
  String? _lastTextChangeApp;
  final List<DateTime> _recentContentChanges = [];
  StreamSubscription<String>? _appOpenSubscription;

  void startListening() {
    NativeTracker.initialize();
    _appOpenSubscription?.cancel();
    _appOpenSubscription = NativeTracker.appOpenStream.stream.listen((event) {
      if (event == "DEVICE_LOCK") {
        processDeviceLock();
      } else if (event == "DEVICE_UNLOCK") {
        processDeviceUnlock();
      } else if (event.startsWith("SCROLL:")) {
        final packageName = event.substring("SCROLL:".length);
        processScrollEvent(packageName);
      } else if (event.startsWith("TEXT_CHANGE:")) {
        final parts = event.split(":");
        if (parts.length == 4) {
          final packageName = parts[1];
          final added = int.tryParse(parts[2]) ?? 0;
          final deleted = int.tryParse(parts[3]) ?? 0;
          processTextChangeEvent(packageName, added, deleted);
        }
      } else if (event.startsWith("CONTENT_CHANGE:")) {
        final packageName = event.substring("CONTENT_CHANGE:".length);
        processContentChangeEvent(packageName);
      } else if (event.startsWith("NOTIFICATION:")) {
        final packageName = event.substring("NOTIFICATION:".length);
        processNotificationEvent(packageName);
      } else {
        processAppOpen(event);
      }
    });
  }

  void processNotificationEvent(String packageName) {
    final now = getCurrentTime();
    _recentNotifications.add(AppOpenRecord(packageName, now));
    _recentNotifications.removeWhere((record) => now.difference(record.timestamp).inMinutes > 10);
  }

  void processTextChangeEvent(String packageName, int added, int deleted) {
    print("GHOSTING_DEBUG: processTextChangeEvent received $packageName, added: $added, deleted: $deleted");
    if (packageName.contains('systemui') || 
        packageName.contains('launcher') || 
        packageName == 'com.example.screen_balance' ||
        packageName.contains('inputmethod') ||
        packageName.contains('keyboard') ||
        packageName.contains('swiftkey') ||
        packageName.contains('honeyboard')) {
      print("GHOSTING_DEBUG: Ignored text change from $packageName");
      return;
    }
    
    // If the user starts typing in a new app, reset the buffers for the new app
    if (_lastTextChangeApp != null && _lastTextChangeApp != packageName) {
      print("GHOSTING_DEBUG: Switched typing app. Resetting buffers.");
      _ghostingTypedChars = 0;
      _ghostingDeletedChars = 0;
    }
    
    _lastTextChangeApp = packageName;
    _ghostingTypedChars += added;
    _ghostingDeletedChars += deleted;
    print("GHOSTING_DEBUG: App: $_lastTextChangeApp | Typed: $_ghostingTypedChars | Deleted: $_ghostingDeletedChars");
  }

  Future<void> processScrollEvent(String packageName) async {
    final now = getCurrentTime();
    final settings = await BoundarySettings.loadFromStorage();

    String? category;
    settings.categorizedApps.forEach((key, list) {
      if (list.contains(packageName)) {
        category = key;
      }
    });

    if (category == 'Utility') return;

    // ── Interaction Spike ───────────────────────────────────────────────────
    _recentScrolls.add(now);
    _recentScrolls.removeWhere((t) => now.difference(t).inSeconds > 5);

    final olderScrolls = _recentScrolls.where((t) => now.difference(t).inMilliseconds > 2500).length;
    final newerScrolls = _recentScrolls.where((t) => now.difference(t).inMilliseconds <= 2500).length;

    if (olderScrolls >= 2 && newerScrolls >= olderScrolls * 2) {
      _triggerIntervention(
        title: "Interaction Spike",
        message: "Your scrolling speed has increased. This often happens when the nervous system is revving up. Ready to slow down?",
        somaticReset: "The Weighted Reset: Sit down and press your feet firmly into the floor, feeling the support of the ground for 60 seconds.",
        triggerId: "interaction_spike",
      );
      _recentScrolls.clear();
      return;
    }

    // ── The Void ─────────────────────────────────────────────────────────────
    if (_lastScrollTime != null && now.difference(_lastScrollTime!).inSeconds <= 30) {
      _scrollStartTime ??= _lastScrollTime;
      final continuousDuration = now.difference(_scrollStartTime!).inMinutes;

      if (continuousDuration >= 20 || (_simulatedTimeOverride != null && _recentScrolls.length >= 3)) {
        _triggerIntervention(
          title: "The Void",
          message: "You've been scrolling for a while. This can create a 'mental fog.' Let's pull your awareness back to the room.",
          somaticReset: "The 5-Object Scan: Look away from the screen and find 5 objects in the room that are the same color.",
          triggerId: "the_void",
        );
        _scrollStartTime = null;
        _lastScrollTime = null;
        return;
      }
    } else {
      _scrollStartTime = now;
    }
    _lastScrollTime = now;

  }

  Future<void> processContentChangeEvent(String packageName) async {
    final now = getCurrentTime();
    final settings = await BoundarySettings.loadFromStorage();

    final isSocial = settings.categorizedApps['Social']?.contains(packageName) ?? false;
    if (!isSocial) return;

    // ── Social Spiral ───────────────────────────────────────────────────────
    _recentContentChanges.add(now);
    _recentContentChanges.removeWhere((t) => now.difference(t).inMinutes > 2);

    if (_recentContentChanges.length >= 8 || (_simulatedTimeOverride != null && _recentContentChanges.length >= 4)) {
      _triggerIntervention(
        title: "Social Spiral",
        message: "You're looking at a lot of social profiles. This can sometimes trigger subconscious comparison stress. Shall we ground ourselves?",
        somaticReset: "The Heart-Hand Grounding: Place one hand on your heart and one on your belly. Feel your own breath for 30 seconds.",
        triggerId: "social_spiral",
      );
      _recentContentChanges.clear();
    }
  }

  void setSimulatedTime(DateTime? time) {
    _simulatedTimeOverride = time;
  }

  DateTime getCurrentTime() {
    return _simulatedTimeOverride ?? DateTime.now();
  }

  void completeSomaticReset() {
    _somaticResetCompletedOverride = true;
    logEvent("Somatic Reset Completed", "One-time override granted");
    eventBusStream.add("EVENT_INTERVENTION_COMPLETED");
  }

  void clearSomaticOverride() {
    _somaticResetCompletedOverride = false;
  }

  void logEvent(String eventType, String detail) {
    final event = BehavioralEvent(
      timestamp: getCurrentTime(),
      eventType: eventType,
      detail: detail,
    );
    behavioralHistory.add(event);
    if (eventType == "Intervention Triggered") {
      debugPrint("🚨 [Intervention Triggered] $detail");
    }
    eventBusStream.add("EVENT_NEW_LOGGED_EVENT");
  }

  Future<void> processAppOpen(String packageName) async {
    final now = getCurrentTime();
    _checkAndResetDailyData(now);
    _updateActiveAppDuration();
    
    // ── Ghosting Anxiety Check ──────────────────────────────────────────────
    print("GHOSTING_DEBUG: processAppOpen($packageName)");
    if (_lastTextChangeApp != null && packageName != _lastTextChangeApp && !packageName.contains('systemui')) {
      print("GHOSTING_DEBUG: Evaluating ghosting... Typed: $_ghostingTypedChars, Deleted: $_ghostingDeletedChars");
      if (_ghostingTypedChars >= 10 && _ghostingDeletedChars >= (_ghostingTypedChars * 0.8)) {
        print("GHOSTING_DEBUG: Ghosting Anxiety Triggered!");
        _triggerIntervention(
          title: "Ghosting Anxiety",
          message: "It looks like you're hesitating on a message. Overthinking can build social tension. Let's take a breath before deciding.",
          somaticReset: "The 4-7-8 Breath: Inhale for 4s, hold for 7s, exhale for 8s to calm the nervous system.",
          triggerId: "ghosting_anxiety",
        );
      }
      // Reset buffers because we switched away from the app we were typing in
      _ghostingTypedChars = 0;
      _ghostingDeletedChars = 0;
      _lastTextChangeApp = null;
    }

    if (packageName.contains('launcher') || packageName.contains('systemui') || packageName == 'com.example.screen_balance') {
      if (packageName == 'com.example.screen_balance') {
        final isResumed = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
        if (!isResumed) return;
      }
      return;
    }

    bool isNotificationDriven = false;
    for (final notif in _recentNotifications.reversed) {
      if (notif.packageName == packageName && now.difference(notif.timestamp).inMinutes <= 2) {
        isNotificationDriven = true;
        break;
      }
    }

    // Debounce duplicate accessibility events for the same app
    if (!isNotificationDriven && _lastOpenedPackage == packageName && _lastOpenedTime != null) {
      if (now.difference(_lastOpenedTime!).inSeconds < 5) {
        return;
      }
    }
    _lastOpenedPackage = packageName;
    _lastOpenedTime = now;

    final settings = await BoundarySettings.loadFromStorage();

    // Look up category
    String? category;
    settings.categorizedApps.forEach((key, list) {
      if (list.contains(packageName)) {
        category = key;
      }
    });

    // Automatic fallback for popular apps
    if (category == null) {
      final Map<String, String> autoCategories = {
        // Social / Communication
        'com.whatsapp': 'Social',
        'com.instagram.android': 'Social',
        'com.facebook.katana': 'Social',
        'com.twitter.android': 'Social',
        'com.zhiliaoapp.musically': 'Social', // TikTok
        'com.snapchat.android': 'Social',
        'org.telegram.messenger': 'Social',
        'com.discord': 'Social',
        'com.linkedin.android': 'Social',
        'com.reddit.frontpage': 'Social',
        'com.pinterest': 'Social',
        
        // Emotional Distraction (Dating)
        'com.tinder': 'Emotional Distraction',
        'com.bumble.app': 'Emotional Distraction',
        'co.hinge.app': 'Emotional Distraction',
        
        // Productivity / Work
        'com.slack': 'Productivity',
        'com.microsoft.teams': 'Productivity',
        'com.google.android.gm': 'Productivity', // Gmail
        'com.microsoft.office.outlook': 'Productivity',
        'com.google.android.apps.docs': 'Productivity', 
        'com.atlassian.android.jira.core': 'Productivity',
        'com.google.android.apps.meetings': 'Productivity', // Meet
        'us.zoom.videomeetings': 'Productivity',
        'com.asana.app': 'Productivity',

        // Entertainment / Shopping
        'com.google.android.youtube': 'Entertainment',
        'com.netflix.mediaclient': 'Entertainment',
        'tv.twitch.android.app': 'Entertainment',
        'com.spotify.music': 'Entertainment',
        'in.amazon.mShop.android.shopping': 'Entertainment', // Amazon
        'com.flipkart.android': 'Entertainment', // Flipkart
        'com.myntra.android': 'Entertainment', // Myntra
        'com.meesho.supply': 'Entertainment', // Meesho
        'com.ril.ajio': 'Entertainment', // Ajio
        'in.swiggy.android': 'Entertainment', // Swiggy
        'com.application.zomato': 'Entertainment', // Zomato
        'com.grofers.customerapp': 'Entertainment', // Blinkit

        // Utilities
        'com.android.chrome': 'Utility',
        'com.google.android.apps.maps': 'Utility',
        'com.google.android.calendar': 'Utility',
      };
      
      category = autoCategories[packageName];
      
      // If we successfully auto-categorized it, save it
      if (category != null) {
        settings.categorizedApps.putIfAbsent(category!, () => []).add(packageName);
        await settings.saveToStorage();
      }
    }

    // We no longer automatically add apps to `customApps`.
    // This ensures auto-categorized apps (like Netflix when opened) don't clutter 
    // the user's manual "Balanced Applications" list view in the Boundary screen.

    logEvent("App Open", "$packageName (${category ?? 'Uncategorized'})");

    if (category == 'Utility') {
      return;
    }

    // Check One-Time Somatic Bypass
    if (_somaticResetCompletedOverride) {
      _somaticResetCompletedOverride = false; // consume it
      return;
    }

    // ── Capped App / Daily Mindful Allowance Check ───────────────────────────
    final currentUsage = _appUsageToday[packageName] ?? Duration.zero;
    if (category == 'Social' || category == 'Entertainment') {
      final int limitMinutes = category == 'Social' ? 15 : 30;
      if (currentUsage.inMinutes >= limitMinutes) {
        final appName = _getFriendlyName(packageName);
        _triggerIntervention(
          title: "Daily Cap Exceeded",
          message: "You have reached your $limitMinutes-minute daily allowance for $appName. Let's take a mindful pause to step away.",
          somaticReset: "The Horizon View: Stand up and look at the furthest point you can see out a window for 60 seconds to reset your visual system.",
          triggerId: "daily_cap_limit",
        );
        return;
      }
    }

    // 1. Morning Mindfulness Buffer Check
    if (_firstMorningUnlockTime != null && category == 'Social') {
      final diff = now.difference(_firstMorningUnlockTime!).inMinutes;
      if (diff < settings.morningBufferMinutes) {
        _triggerIntervention(
          title: "Morning Mindfulness Buffer",
          message: "You're in your morning phone-free buffer zone. Let's start the day with intention instead of feeds.",
          somaticReset: "Somatic Release: Roll your shoulders back 5 times and take one slow, deep breath with your eyes closed.",
          triggerId: "morning_buffer",
        );
        return;
      }
    }

    // 2. Staged Digital Sunset Checks (relative to targetBedtime)
    if (settings.targetBedtime != null) {
      final bedtime = settings.targetBedtime!;
      final minutesToBedtime = _getMinutesToBedtime(now, bedtime);

      if (minutesToBedtime <= 0) {
        // T-0: Enforce lock, only utility apps allowed
        _triggerIntervention(
          title: "Bedtime Screen Lock",
          message: "It is past your Target Bedtime. Sleep is vital for cognitive repair.",
          somaticReset: "The Darkroom Reset: Put the phone in a drawer, turn off the lights, and sit in silence for 60 seconds.",
          triggerId: "staged_sunset_t0",
        );
        return;
      } else if (minutesToBedtime <= 30) {
        // T-30: Only utility available
        if (category != 'Utility') {
          _triggerIntervention(
            title: "Digital Sunset (T-30 min)",
            message: "Bedtime is in 30 minutes. Let's disconnect now to ease the mind into deep rest.",
            somaticReset: "Tactile Grounding: Put your phone down and touch 3 different textures.",
            triggerId: "staged_sunset_t30",
          );
          return;
        }
      } else if (minutesToBedtime <= 60) {
        // T-60: Block high intensity, apply grayscale
        if (category == 'Social' || category == 'Emotional Distraction' || category == 'Entertainment') {
          _triggerIntervention(
            title: "Digital Sunset (T-60 min)",
            message: "One hour until sleep. Your brain needs to wind down from screen stimulation.",
            somaticReset: "The Horizon View: Look out a window at the furthest point for 60 seconds.",
            triggerId: "staged_sunset_t60",
          );
          return;
        }
      } else if (minutesToBedtime <= 90) {
        // T-90: Block Emotional Distraction
        if (category == 'Emotional Distraction') {
          _triggerIntervention(
            title: "Digital Sunset (T-90 min)",
            message: "Entering the digital sunset. Emotional distraction apps are now offline to protect your sleep quality.",
            somaticReset: "Social Savoring Reframe: Think of one thing you are grateful for today.",
            triggerId: "staged_sunset_t90",
          );
          return;
        }
      }
    }

    // 3. Focus Mode Hours Check
    if (category == 'Productivity') {
      // Removed unused afterText reference; evolved state handled elsewhere
      final start = await settings.getEffectiveFocusStartTime() ?? const TimeOfDay(hour: 9, minute: 0);
      final end = await settings.getEffectiveFocusEndTime() ?? const TimeOfDay(hour: 17, minute: 0);
      if (_isOutsideFocusHours(now, start, end)) {
        _triggerIntervention(
          title: "Work-Life Blur",
          message: "Checking work apps now can prevent your brain from fully decompressing. Is this urgent?",
          somaticReset: "The Physical Boundary: Walk to a different room or stand up and do a full-body stretch.",
          triggerId: "work_life_blur",
        );
        return;
      }
    }

    // 4. Midnight Drift Rule
    if (settings.targetBedtime != null && _isPastBedtime(now, settings.targetBedtime!)) {
      _triggerIntervention(
        title: "Midnight Drift",
        message: "It's past your quiet hour. Late-night light can trick your brain into staying alert when it needs rest.",
        somaticReset: "Tactile Grounding: Put your phone down and touch 3 different textures.",
        triggerId: "midnight_drift",
      );
      return;
    }

    // 5. Dopamine Loop Rule
    _recentAppOpens.add(AppOpenRecord(packageName, now));
    _recentAppOpens.removeWhere((record) => now.difference(record.timestamp).inSeconds > 60);
    
    int maxConsecutiveSwitches = 0;
    int currentChain = 0;
    
    for (int i = 1; i < _recentAppOpens.length; i++) {
      final prev = _recentAppOpens[i - 1];
      final curr = _recentAppOpens[i];
      if (curr.packageName != prev.packageName) {
        if (curr.timestamp.difference(prev.timestamp).inSeconds < 10) {
          currentChain++;
          if (currentChain > maxConsecutiveSwitches) {
            maxConsecutiveSwitches = currentChain;
          }
        } else {
          currentChain = 0; // The chain of rapid switching was broken
        }
      }
    }

    if (maxConsecutiveSwitches >= 4) {
      _triggerIntervention(
        title: "Dopamine Loop",
        message: "You're moving fast between apps. This rapid switching can fragment your focus. Ready for a quick reset?",
        somaticReset: "The Sky Reset: Step outside (or near a window), tilt your face toward the sky, and close your eyes for 60 seconds.",
        triggerId: "dopamine_loop",
      );
      _recentAppOpens.clear();
      return;
    }

    // 6. Reactive Mode

    if (isNotificationDriven) {
      _openedAppsInTenMins.add(now);
      _openedAppsInTenMins.removeWhere((t) => now.difference(t).inMinutes > 30);
      if (_openedAppsInTenMins.length >= 5) {
        _triggerIntervention(
          title: "Reactive Mode",
          message: "You're reacting to pings as they come. This high-alert mode increases cognitive load. Want to take back control?",
          somaticReset: "The Horizon View: Stand up and look at the furthest point you can see out a window for 60 seconds.",
          triggerId: "reactive_mode",
        );
        _openedAppsInTenMins.clear();
        return;
      }
    }

    // 7. Novelty Hunt
    if (category == 'Entertainment') {
      _shoppingAppOpens.add(now);
      _shoppingAppOpens.removeWhere((t) => now.difference(t).inMinutes > 10);
      if (_shoppingAppOpens.length >= 5) {
        _triggerIntervention(
          title: "Novelty Hunt",
          message: "You're searching for something new. This novelty hunt can be a sign of underlying restlessness.",
          somaticReset: "The Sensory Swap: Find a physical object near you and notice its weight and temperature for 60 seconds.",
          triggerId: "novelty_hunt",
        );
        _shoppingAppOpens.clear();
        return;
      }
    }

    // 8. Info Overload
    if (category == 'Social') {
      _newsAppOpens.add(now);
      _newsAppOpens.removeWhere((t) => now.difference(t).inMinutes > 15);
      if (_newsAppOpens.length >= 5) {
        _triggerIntervention(
          title: "Info Overload",
          message: "You're processing a lot of high-intensity info. Let's find some calm.",
          somaticReset: "The Cold Reset: Splash some cold water on your face or hold a cold object for 30 seconds.",
          triggerId: "info_overload",
        );
        _newsAppOpens.clear();
        return;
      }
    }
  }

  Future<void> processDeviceUnlock() async {
    final now = getCurrentTime();
    _checkAndResetDailyData(now);
    _lastOpenedPackage = null;
    _lastOpenedTime = now;
    final settings = await BoundarySettings.loadFromStorage();
    
    _unlockCountToday++;
    logEvent("Device Unlock", "Total today: $_unlockCountToday");

    // Morning check
    if (now.hour >= 5 && now.hour < 11 && _firstMorningUnlockTime == null) {
      _firstMorningUnlockTime = now;
      logEvent("First Morning Unlock", "Recorded at ${now.hour}:${now.minute}");
    }

    _recentUnlocks.add(now);
    _recentUnlocks.removeWhere((timestamp) => now.difference(timestamp).inMinutes > 15);

    // 1. Last Scroll Loop (3+ unlocks in 2 mins at night)
    if (settings.targetBedtime != null && _isPastBedtime(now, settings.targetBedtime!)) {
      final recentTwoMins = _recentUnlocks.where((t) => now.difference(t).inSeconds <= 120).toList();
      if (recentTwoMins.length >= 3) {
        _triggerIntervention(
          title: "Last Scroll Loop",
          message: "You're trying to put the phone away, but the pull is strong. This last scroll loop delays deep rest.",
          somaticReset: "The Darkroom Reset: Put the phone in a drawer, turn off the lights, and sit in silence for 60 seconds.",
          triggerId: "last_scroll_loop",
        );
        _recentUnlocks.clear();
        return;
      }
    }

    // 2. Phantom Check (10+ unlocks in 15 mins)
    if (_recentUnlocks.length >= 10) {
      _triggerIntervention(
        title: "Phantom Check",
        message: "You've checked in 10 times with no alerts. This phantom checking keeps your mind on high-alert.",
        somaticReset: "Somatic Release: Roll your shoulders back 5 times and take one slow, deep breath with your eyes closed.",
        triggerId: "phantom_check",
      );
      _recentUnlocks.clear();
    }
  }

  void processDeviceLock() {
    final now = getCurrentTime();
    _checkAndResetDailyData(now);
    _updateActiveAppDuration();
    _lastOpenedPackage = null;
    _lastOpenedTime = null;
    logEvent("Device Lock", "");
    _recentLocks.add(now);
    _recentLocks.removeWhere((timestamp) => now.difference(timestamp).inMinutes > 15);
  }

  int _getMinutesToBedtime(DateTime now, TimeOfDay bedtime) {
    if (_isPastBedtime(now, bedtime)) {
      return 0;
    }
    
    final bedMinutes = bedtime.hour * 60 + bedtime.minute;
    final currMinutes = now.hour * 60 + now.minute;
    
    int diff = bedMinutes - currMinutes;
    if (diff < 0) {
      diff += 1440;
    }
    return diff;
  }

  bool _isPastBedtime(DateTime time, TimeOfDay bedtime) {
    final bedHour = bedtime.hour;
    final bedMin = bedtime.minute;
    final currHour = time.hour;
    final currMin = time.minute;

    if (bedHour > 5) {
      if (currHour >= bedHour || currHour < 5) {
        if (currHour == bedHour) {
          return currMin >= bedMin;
        }
        return true;
      }
    } else {
      if (currHour >= bedHour && currHour < 5) {
        if (currHour == bedHour) {
          return currMin >= bedMin;
        }
        return true;
      }
    }
    return false;
  }

  bool _isOutsideFocusHours(DateTime time, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes < startMinutes || currentMinutes > endMinutes;
    } else {
      return currentMinutes < startMinutes && currentMinutes > endMinutes;
    }
  }

  void _triggerIntervention({
    required String title,
    required String message,
    required String somaticReset,
    required String triggerId,
  }) {
    logEvent("Intervention Triggered", "$title ($triggerId)");
    eventBusStream.add("EVENT_INTERVENTION_TRIGGERED:$triggerId");
    
    interventionStream.add({
      'title': title,
      'message': message,
      'somaticReset': somaticReset,
      'triggerId': triggerId,
    });
  }

  // Debug simulation method for all 13 triggers
  void simulateTrigger(String triggerId) {
    switch (triggerId) {
      case "dopamine_loop":
        _triggerIntervention(
          title: "Dopamine Loop",
          message: "You're moving fast between apps. This rapid switching can fragment your focus. Ready for a quick reset?",
          somaticReset: "The Sky Reset: Step outside (or near a window), tilt your face toward the sky, and close your eyes for 60 seconds.",
          triggerId: triggerId,
        );
        break;
      case "the_void":
        _triggerIntervention(
          title: "The Void",
          message: "You've been scrolling for a while. This can create a 'mental fog.' Let's pull your awareness back to the room.",
          somaticReset: "The 5-Object Scan: Look away from the screen and find 5 objects in the room that are the same color.",
          triggerId: triggerId,
        );
        break;
      case "reactive_mode":
        _triggerIntervention(
          title: "Reactive Mode",
          message: "You're reacting to pings as they come. This high-alert mode increases cognitive load. Want to take back control?",
          somaticReset: "The Horizon View: Stand up and look at the furthest point you can see out a window for 60 seconds to reset your visual system.",
          triggerId: triggerId,
        );
        break;
      case "social_spiral":
        _triggerIntervention(
          title: "Social Spiral",
          message: "You're looking at a lot of social profiles. This can sometimes trigger subconscious comparison stress. Shall we ground ourselves?",
          somaticReset: "The Heart-Hand Grounding: Place one hand on your heart and one on your belly. Feel your own breath for 30 seconds.",
          triggerId: triggerId,
        );
        break;
      case "ghosting_anxiety":
        _triggerIntervention(
          title: "Ghosting Anxiety",
          message: "It looks like you're hesitating on a message. Overthinking can build social tension. Let's take a breath before deciding.",
          somaticReset: "The 4-7-8 Breath: Inhale for 4s, hold for 7s, exhale for 8s to calm the nervous system.",
          triggerId: triggerId,
        );
        break;

      case "midnight_drift":
        _triggerIntervention(
          title: "Midnight Drift",
          message: "It's past your quiet hour. Late-night light can trick your brain into staying 'alert' when it needs rest.",
          somaticReset: "Tactile Grounding: Put your phone down and touch 3 different textures (e.g., a cold table, a soft pillow, your own palms).",
          triggerId: triggerId,
        );
        break;
      case "last_scroll_loop":
        _triggerIntervention(
          title: "Last Scroll Loop",
          message: "You're trying to put the phone away, but the pull is strong. This 'last scroll' loop delays deep rest.",
          somaticReset: "The Darkroom Reset: Put the phone in a drawer, turn off the lights, and sit in silence for 60 seconds.",
          triggerId: triggerId,
        );
        break;
      case "work_life_blur":
        _triggerIntervention(
          title: "Work-Life Blur",
          message: "Checking work apps now can prevent your brain from fully decompressing. Is this urgent, or can it wait for 'Future You'?",
          somaticReset: "The Physical Boundary: Walk to a different room or stand up and do a full-body stretch to mark the end of 'work mode.'",
          triggerId: triggerId,
        );
        break;
      case "phantom_check":
        _triggerIntervention(
          title: "Phantom Check",
          message: "You've checked in 10 times with no alerts. This 'phantom checking' keeps your mind on high-alert.",
          somaticReset: "Somatic Release: Roll your shoulders back 5 times and take one slow, deep breath with your eyes closed.",
          triggerId: triggerId,
        );
        break;
      case "novelty_hunt":
        _triggerIntervention(
          title: "Novelty Hunt",
          message: "You're searching for something new. This 'novelty hunt' can be a sign of underlying restlessness.",
          somaticReset: "The Sensory Swap: Find a physical object near you (a pen, a stone, a glass) and notice its weight and temperature for 60 seconds.",
          triggerId: triggerId,
        );
        break;
      case "info_overload":
        _triggerIntervention(
          title: "Info Overload",
          message: "You're processing a lot of high-intensity info. This can trigger a 'threat detection' state. Let's find some calm.",
          somaticReset: "The Cold Reset: Splash some cold water on your face or hold a cold object for 30 seconds to calm the Vagus nerve.",
          triggerId: triggerId,
        );
        break;
      case "interaction_spike":
        _triggerIntervention(
          title: "Interaction Spike",
          message: "Your scrolling speed has increased. This often happens when the nervous system is revving up. Ready to slow down?",
          somaticReset: "The Weighted Reset: Sit down and press your feet firmly into the floor, feeling the support of the ground for 60 seconds.",
          triggerId: triggerId,
        );
        break;
      case "daily_cap_limit":
        _triggerIntervention(
          title: "Daily Cap Exceeded",
          message: "You have reached your 15-minute daily allowance for Instagram. Let's take a mindful pause to step away.",
          somaticReset: "The Horizon View: Stand up and look at the furthest point you can see out a window for 60 seconds to reset your visual system.",
          triggerId: triggerId,
        );
        break;
    }
  }
}
