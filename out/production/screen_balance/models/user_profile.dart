import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String name;
  String ageGroup;
  String occupation;
  Map<String, String> activeIntentionCard;
  String calibrationPath; // 'quiz' or 'observe'
  int observationDay; // 1 to 7
  bool isCalibrated; // whether profile has active archetype

  UserProfile({
    required this.name,
    this.ageGroup = '18-24',
    this.occupation = 'Student',
    this.calibrationPath = 'quiz',
    this.observationDay = 1,
    this.isCalibrated = false,
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
        calibrationPath: decoded['calibrationPath'] ?? 'quiz',
        observationDay: decoded['observationDay'] ?? 1,
        isCalibrated: decoded['isCalibrated'] ?? false,
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
      'calibrationPath': calibrationPath,
      'observationDay': observationDay,
      'isCalibrated': isCalibrated,
      'activeIntentionCard': activeIntentionCard,
    };
    await prefs.setString('userProfile', json.encode(data));
  }
}
