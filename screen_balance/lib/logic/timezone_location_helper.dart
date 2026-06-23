import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';

class TimezoneLocationHelper {
  // A rough approximation of latitudes based on UTC offset blocks
  // Since timezones are primarily longitudinal, latitudes vary wildly.
  // We'll use a very generalized approach mapping the first part of IANA names
  // to approximate central latitudes. 
  static double getApproximateLatitude(String timezoneName) {
    timezoneName = timezoneName.toLowerCase();
    
    // Northern Hemisphere
    if (timezoneName.startsWith('europe/')) return 48.0; // Central Europe
    if (timezoneName.startsWith('america/')) {
      if (timezoneName.contains('argentina') || timezoneName.contains('sao_paulo') || timezoneName.contains('buenos_aires') || timezoneName.contains('santiago')) {
        return -30.0; // South America
      }
      return 38.0; // North America average
    }
    if (timezoneName.startsWith('asia/')) {
      if (timezoneName.contains('jakarta') || timezoneName.contains('singapore') || timezoneName.contains('kuala_lumpur')) {
        return 1.0; // Near equator
      }
      return 25.0; // Asia average (India/China/Middle East)
    }
    
    // Southern Hemisphere
    if (timezoneName.startsWith('australia/')) return -25.0;
    if (timezoneName.startsWith('africa/')) {
      if (timezoneName.contains('johannesburg')) return -26.0;
      return 0.0; // Central Africa
    }
    
    // Pacific
    if (timezoneName.startsWith('pacific/')) return -10.0;

    return 35.0; // Generic fallback
  }

  static double getApproximateLongitude(Duration offset) {
    // 1 hour offset = 15 degrees of longitude
    // UTC offset gives us a direct approximate longitude
    return (offset.inMinutes / 60.0) * 15.0;
  }

  static Future<Map<String, TimeOfDay>> getTodaySunriseSunset() async {
    try {
      final String currentTimeZone = (await FlutterTimezone.getLocalTimezone()).identifier;
      final now = DateTime.now();
      final offset = now.timeZoneOffset;

      final lat = getApproximateLatitude(currentTimeZone);
      final lng = getApproximateLongitude(offset);

      var sunriseSunset = getSunriseSunset(
          lat, 
          lng, 
          Duration(minutes: offset.inMinutes), 
          now
      );

      return {
        'sunrise': TimeOfDay(hour: sunriseSunset.sunrise.hour, minute: sunriseSunset.sunrise.minute),
        'sunset': TimeOfDay(hour: sunriseSunset.sunset.hour, minute: sunriseSunset.sunset.minute),
      };
    } catch (e) {
      debugPrint("Error calculating sunrise/sunset: $e");
      // Fallback
      return {
        'sunrise': const TimeOfDay(hour: 6, minute: 0),
        'sunset': const TimeOfDay(hour: 18, minute: 0),
      };
    }
  }
}
