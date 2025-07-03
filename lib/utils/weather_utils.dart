import 'package:flutter/foundation.dart';

class WeatherUtils {
  static String getIconName(bool isNight, String condition) {
    // Convert condition to lowercase for case-insensitive matching
    final lowerCondition = condition.trim().toLowerCase();
    
    // Debug print
    debugPrint('Getting icon for condition: $lowerCondition (isNight: $isNight)');
    
    // Map NWS forecast text to icon names
    String iconName;
    
    if (lowerCondition.contains('few') || lowerCondition.contains('fair') || lowerCondition.contains('mostly clear')) {
      iconName = isNight ? 'nfew' : 'few';
    } else if (lowerCondition.contains('snow') || lowerCondition.contains('flurries')) {
      iconName = isNight ? 'nsn' : 'sn';
    } else if (lowerCondition.contains('rain') && lowerCondition.contains('snow')) {
      iconName = isNight ? 'nra_sn' : 'ra_sn';
    } else if (lowerCondition.contains('freezing rain') && lowerCondition.contains('snow')) {
      iconName = isNight ? 'nfzra_sn' : 'fzra_sn';
    } else if (lowerCondition.contains('freezing rain')) {
      iconName = isNight ? 'nfzra' : 'fzra';
    } else if (lowerCondition.contains('rain') && lowerCondition.contains('ice')) {
      iconName = isNight ? 'nraip' : 'raip';
    } else if (lowerCondition.contains('ice')) {
      iconName = isNight ? 'nip' : 'ip';
    } else if (lowerCondition.contains('rain') || lowerCondition.contains('shower')) {
      iconName = isNight ? 'nshra' : 'shra';
    } else if (lowerCondition.contains('thunder') || lowerCondition.contains('tstorm')) {
      iconName = isNight ? 'ntsra' : 'tsra';
    } else if (lowerCondition.contains('overcast') || lowerCondition.contains('cloudy')) {
      iconName = isNight ? 'novc' : 'ovc';
    } else if (lowerCondition.contains('broken')) {
      iconName = isNight ? 'nbkn' : 'bkn';
    } else if (lowerCondition.contains('scattered') || lowerCondition.contains('partly')) {
      iconName = isNight ? 'nsct' : 'sct';
    } else if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
      iconName = isNight ? 'nfew' : 'few';
    } else if (lowerCondition.contains('fog') || lowerCondition.contains('mist')) {
      iconName = isNight ? 'nfg' : 'fg';
    } else if (lowerCondition.contains('haze') || lowerCondition.contains('smoke')) {
      iconName = 'hz';
    } else if (lowerCondition.contains('hot')) {
      iconName = 'hot';
    } else if (lowerCondition.contains('cold')) {
      iconName = isNight ? 'ncold' : 'cold';
    } else if (lowerCondition.contains('blizzard')) {
      iconName = isNight ? 'nblizzard' : 'blizzard';
    } else {
      // Default to few clouds instead of clear sky
      iconName = isNight ? 'nfew' : 'few';
    }
    
    // Debug print for selected icon
    debugPrint('Selected weather icon: $iconName');
    
    return iconName;
  }

  static bool isNightTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        return hour < 6 || hour >= 18;  // Consider night time between 6 PM and 6 AM
      }
    } catch (e) {
      debugPrint('Error parsing time for night check: $e');
    }
    return false;
  }

  static DateTime parseTimeString(String timeStr) {
    try {
      final now = DateTime.now();
      final parts = timeStr.toLowerCase().split(' ');
      if (parts.length == 2) {
        final timeParts = parts[0].split(':');
        if (timeParts.length == 2) {
          var hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final isPM = parts[1] == 'pm';
          
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          
          return DateTime(now.year, now.month, now.day, hour, minute);
        }
      }
    } catch (e) {
      debugPrint('Error parsing time string: $timeStr - $e');
    }
    return DateTime.now();
  }

  static Duration parseDuration(String durationStr) {
    try {
      final parts = durationStr.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return Duration(hours: hours, minutes: minutes, seconds: seconds);
      }
    } catch (e) {
      debugPrint('Error parsing duration string: $durationStr - $e');
    }
    return const Duration();
  }
} 