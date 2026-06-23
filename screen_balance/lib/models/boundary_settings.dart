import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/timezone_location_helper.dart';

class BoundarySettings {
  TimeOfDay? targetBedtime;
  TimeOfDay? focusStartTime;
  TimeOfDay? focusEndTime;
  int morningBufferMinutes;
  bool syncFocusWithSun;

  final Map<String, List<String>> categorizedApps;
  List<String> accountabilityContacts;
  List<String> customApps;

  BoundarySettings({
    this.targetBedtime,
    this.focusStartTime,
    this.focusEndTime,
    this.morningBufferMinutes = 30,
    this.syncFocusWithSun = false,
    Map<String, List<String>>? categorizedApps,
    List<String>? accountabilityContacts,
    List<String>? customApps,
  })  : categorizedApps = categorizedApps ??
            {
              'Utility': [],
              'Social': [],
              'Emotional Distraction': [],
              'Productivity': [],
              'Entertainment': [],
            },
        accountabilityContacts = accountabilityContacts ?? [],
        customApps = customApps ?? [];

  static Future<BoundarySettings> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    
    final bedtimeStr = prefs.getString('targetBedtime');
    final focusStartStr = prefs.getString('focusStartTime');
    final focusEndStr = prefs.getString('focusEndTime');
    final buffer = prefs.getInt('morningBufferMinutes') ?? 30;
    final syncSun = prefs.getBool('syncFocusWithSun') ?? false;
    
    final contacts = (prefs.getStringList('accountabilityContacts') ?? []).toList();
    final customAppsList = (prefs.getStringList('customApps') ?? []).toList();

    final categorizedStr = prefs.getString('categorizedApps');
    Map<String, List<String>> catApps = {
      'Utility': [],
      'Social': [],
      'Emotional Distraction': [],
      'Productivity': [],
      'Entertainment': [],
    };

    if (categorizedStr != null) {
      try {
        final decoded = json.decode(categorizedStr) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          if (catApps.containsKey(key)) {
            catApps[key] = List<String>.from(value);
          }
        });
      } catch (e) {
        debugPrint("Error parsing categorizedApps: $e");
      }
    }

    return BoundarySettings(
      targetBedtime: _stringToTime(bedtimeStr),
      focusStartTime: _stringToTime(focusStartStr),
      focusEndTime: _stringToTime(focusEndStr),
      morningBufferMinutes: buffer,
      syncFocusWithSun: syncSun,
      categorizedApps: catApps,
      accountabilityContacts: contacts,
      customApps: customAppsList,
    );
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('targetBedtime', _timeToString(targetBedtime) ?? '');
    await prefs.setString('focusStartTime', _timeToString(focusStartTime) ?? '');
    await prefs.setString('focusEndTime', _timeToString(focusEndTime) ?? '');
    await prefs.setInt('morningBufferMinutes', morningBufferMinutes);
    await prefs.setBool('syncFocusWithSun', syncFocusWithSun);
    await prefs.setStringList('accountabilityContacts', accountabilityContacts);
    await prefs.setStringList('customApps', customApps);
    await prefs.setString('categorizedApps', json.encode(categorizedApps));
  }

  Future<TimeOfDay?> getEffectiveFocusStartTime() async {
    if (syncFocusWithSun) {
      final sunTimes = await TimezoneLocationHelper.getTodaySunriseSunset();
      return sunTimes['sunrise'];
    }
    return focusStartTime;
  }

  Future<TimeOfDay?> getEffectiveFocusEndTime() async {
    if (syncFocusWithSun) {
      final sunTimes = await TimezoneLocationHelper.getTodaySunriseSunset();
      return sunTimes['sunset'];
    }
    return focusEndTime;
  }

  static Future<void> clearFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('targetBedtime');
    await prefs.remove('focusStartTime');
    await prefs.remove('focusEndTime');
    await prefs.remove('morningBufferMinutes');
    await prefs.remove('syncFocusWithSun');
    await prefs.remove('accountabilityContacts');
    await prefs.remove('customApps');
    await prefs.remove('categorizedApps');
  }

  static String? _timeToString(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay? _stringToTime(String? str) {
    if (str == null || str.isEmpty) return null;
    final parts = str.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
