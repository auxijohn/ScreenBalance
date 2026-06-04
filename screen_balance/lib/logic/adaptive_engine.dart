import 'intervention_engine.dart';
import '../models/user_profile.dart';

class AdaptiveEngine {
  static final AdaptiveEngine _instance = AdaptiveEngine._internal();
  factory AdaptiveEngine() => _instance;
  AdaptiveEngine._internal();

  // Stream to dispatch adaptation alerts to the UI
  final List<String> adaptationAlerts = [];

  Future<void> runWeeklyAdaptation() async {
    final history = InterventionEngine().behavioralHistory;
    final profile = await UserProfile.loadFromStorage();
    if (profile == null) return;

    final String oldArchetype = profile.activeIntentionCard['title'] ?? 'The Intentional Seeker';
    
    // Count specific trigger events in history
    int morningBufferCount = 0;
    int eveningDriftCount = 0;
    int taskAvoidanceCount = 0;
    int phantomCheckCount = 0;
    int doomscrollCount = 0;

    for (var event in history) {
      if (event.detail.contains('morning_buffer')) {
        morningBufferCount++;
      } else if (event.detail.contains('midnight_drift') || event.detail.contains('staged_sunset')) {
        eveningDriftCount++;
      } else if (event.detail.contains('dopamine_loop')) {
        taskAvoidanceCount++;
      } else if (event.detail.contains('phantom_check')) {
        phantomCheckCount++;
      } else if (event.detail.contains('info_overload')) {
        doomscrollCount++;
      }
    }

    String newArchetypeKey = '';
    Map<String, String> newDetails = {};

    // Logic to select new archetype based on highest offense count
    final counts = {
      'Morning Scroller': morningBufferCount,
      'Evening Escapist': eveningDriftCount,
      'Task Avoidant': taskAvoidanceCount,
      'Phantom Checker': phantomCheckCount,
      'Doomscroller': doomscrollCount,
    };

    String highestKey = 'None';
    int maxCount = 0;
    counts.forEach((key, val) {
      if (val > maxCount) {
        maxCount = val;
        highestKey = key;
      }
    });

    if (maxCount >= 2 && highestKey != 'None') {
      newArchetypeKey = highestKey;
    }

    if (newArchetypeKey.isNotEmpty && !oldArchetype.contains(newArchetypeKey)) {
      // Map details
      if (newArchetypeKey == 'Morning Scroller') {
        newDetails = {
          "emoji": "🌅",
          "title": "The Morning Scroller",
          "subtitle": "Adaptive Adjustment",
          "description": "Your actual telemetry shows frequent morning screen access. We have adjusted your baseline to focus on building a mindful morning routine."
        };
      } else if (newArchetypeKey == 'Evening Escapist') {
        newDetails = {
          "emoji": "🌙",
          "title": "The Evening Escapist",
          "subtitle": "Adaptive Adjustment",
          "description": "Your actual telemetry shows midnight device usage. We have adjusted your baseline to strengthen bedtime boundaries and stage your digital sunset."
        };
      } else if (newArchetypeKey == 'Task Avoidant') {
        newDetails = {
          "emoji": "🏃",
          "title": "The Task Avoidant",
          "subtitle": "Adaptive Adjustment",
          "description": "Telemetry shows rapid app switching during work hours. We have adjusted your profile to build friction around productivity apps."
        };
      } else if (newArchetypeKey == 'Phantom Checker') {
        newDetails = {
          "emoji": "👻",
          "title": "The Phantom Checker",
          "subtitle": "Adaptive Adjustment",
          "description": "Telemetry shows frequent muscle-memory unlocking of your screen. We've optimized your profile to break automatic unlock loops."
        };
      } else if (newArchetypeKey == 'Doomscroller') {
        newDetails = {
          "emoji": "🌀",
          "title": "The Doomscroller",
          "subtitle": "Adaptive Adjustment",
          "description": "Telemetry shows rapid news consumption. We have optimized your settings to avoid informational overload."
        };
      }

      if (newDetails.isNotEmpty) {
        profile.activeIntentionCard = newDetails;
        await profile.saveToStorage();
        
        final alertMsg = "Behavioral Shift: Profile transitioned from '$oldArchetype' to '${newDetails['title']}' based on past 7 days telemetry.";
        adaptationAlerts.add(alertMsg);
        InterventionEngine().logEvent("Profile Adaptive Shift", alertMsg);
        
        // Dispatch alert on Event Bus
        InterventionEngine().eventBusStream.add("EVENT_PROFILE_UPDATED:$oldArchetype->${newDetails['title']}");
      }
    }
  }
}
