import '../models/quiz_data.dart';

class QuizEngine {
  final Map<String, int> _scores = {
    "The Morning Scroller": 0,
    "The Evening Escapist": 0,
    "The Midday Slumper": 0,
    "The Task Avoidant": 0,
    "The Phantom Checker": 0,
    "The Notification Reactive": 0,
    "The Doomscroller": 0,
    "The Social Comparer": 0,
    "None": 0,
  };

  void recordAnswer(Option option) {
    if (_scores.containsKey(option.archetypeScore)) {
      _scores[option.archetypeScore] = _scores[option.archetypeScore]! + 1;
    }
  }

  String getTopArchetypeKey() {
    String topArchetype = "The Morning Scroller"; // Default
    int maxScore = 0;

    _scores.forEach((key, value) {
      if (key != "None" && value > maxScore) {
        maxScore = value;
        topArchetype = key;
      }
    });

    return topArchetype;
  }

  Map<String, String> getArchetypeDetails() {
    String key = getTopArchetypeKey();

    switch (key) {
      case "The Morning Scroller":
        return {
          "emoji": "🌅",
          "title": "The Morning Scroller",
          "subtitle": "Reactive Start",
          "description": "You tend to reach for your phone before your feet hit the floor. We'll work on building a mindful morning buffer to start your day with intention."
        };
      case "The Evening Escapist":
        return {
          "emoji": "🌙",
          "title": "The Evening Escapist",
          "subtitle": "Revenge Bedtime Procrastination",
          "description": "You use late-night scrolling to reclaim personal time. We'll help you build a staged digital sunset so you get the rest you deserve."
        };
      case "The Midday Slumper":
        return {
          "emoji": "☕",
          "title": "The Midday Slumper",
          "subtitle": "Circadian Energy Crash",
          "description": "You seek fast dopamine hits when your energy dips in the afternoon. We'll find better, more restorative ways to recharge your brain."
        };
      case "The Task Avoidant":
        return {
          "emoji": "🏃",
          "title": "The Task Avoidant",
          "subtitle": "Avoidance Coping",
          "description": "App-switching has become your escape from friction or boredom. We'll help you build focus endurance and sit with discomfort."
        };
      case "The Phantom Checker":
        return {
          "emoji": "👻",
          "title": "The Phantom Checker",
          "subtitle": "Unconscious Habit Loop",
          "description": "Muscle memory drives your screen unlocks even when there's no notification. We'll introduce gentle friction to break this automatic loop."
        };
      case "The Notification Reactive":
        return {
          "emoji": "🔔",
          "title": "The Notification Reactive",
          "subtitle": "Stimulus Reactivity",
          "description": "External pings dictate your attention. We'll help you build robust boundaries so you can decide when you are available."
        };
      case "The Doomscroller":
        return {
          "emoji": "🌀",
          "title": "The Doomscroller",
          "subtitle": "Anxiety-Seeking",
          "description": "You get caught in endless, often negative feeds as a way to process anxiety. We'll help you recognize the void before you fall in."
        };
      case "The Social Comparer":
        return {
          "emoji": "⚖️",
          "title": "The Social Comparer",
          "subtitle": "Emotional Dysregulation & FOMO",
          "description": "Curated feeds trigger comparison and drain your energy. We'll help you shift from reactive consumption to intentional connection."
        };
      default:
        return {
          "emoji": "🌱",
          "title": "The Intentional Seeker",
          "subtitle": "Digital Growth",
          "description": "You are looking to build healthier boundaries. We will build a customized system to protect your peace and focus."
        };
    }
  }
}
