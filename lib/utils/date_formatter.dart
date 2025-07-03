import 'package:intl/intl.dart';

class DateFormatter {
  static String formatAlertDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      // If less than 24 hours ago, show relative time
      if (difference.inHours < 24) {
        if (difference.inMinutes < 60) {
          return '${difference.inMinutes} minutes ago';
        } else {
          return '${difference.inHours} hours ago';
        }
      }
      
      // Otherwise show date and time
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatExpirationDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }
} 