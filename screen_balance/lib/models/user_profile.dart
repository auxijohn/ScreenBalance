import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String name;
  String ageGroup;
  String occupation;
  Map<String, String> activeIntentionCard;

  UserProfile({
    required this.name,
    this.ageGroup = '18-24',
    this.occupation = 'Student',
    this.activeIntentionCard = const {
      'title': 'The Intentional Seeker',
      'emoji': '🌱',
      'subtitle': 'Digital Growth',
      'description': 'You are looking to build healthier boundaries. We will build a customized system to protect your peace and focus.'
    },
  });

  static Future<UserProfile?> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('userProfile');
    if (profileStr == null || profileStr.isEmpty) return null;

    try {
      final decoded = json.decode(profileStr) as Map<String, dynamic>;
      return UserProfile(
        name: decoded['name'] ?? '',
        ageGroup: decoded['ageGroup'] ?? '18-24',
        occupation: decoded['occupation'] ?? 'Student',
        activeIntentionCard: Map<String, String>.from(decoded['activeIntentionCard'] ?? {}),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'name': name,
      'ageGroup': ageGroup,
      'occupation': occupation,
      'activeIntentionCard': activeIntentionCard,
    };
    await prefs.setString('userProfile', json.encode(data));
  }
}
