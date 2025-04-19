enum AdvisorySeverity { high, medium, low }

enum AdvisoryType { storm, flood, wind, heat, cold }

class WeatherAdvisory {
  final String message;
  final AdvisorySeverity severity;
  final AdvisoryType type;
  final DateTime timestamp;

  WeatherAdvisory({
    required this.message,
    required this.severity,
    required this.type,
    required this.timestamp,
  });

  factory WeatherAdvisory.fromJson(Map<String, dynamic> json) {
    return WeatherAdvisory(
      message: json['message'] as String,
      severity: _parseSeverity(json['severity'] as String),
      type: _parseType(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static AdvisorySeverity _parseSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AdvisorySeverity.high;
      case 'medium':
        return AdvisorySeverity.medium;
      case 'low':
        return AdvisorySeverity.low;
      default:
        return AdvisorySeverity.medium;
    }
  }

  static AdvisoryType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'storm':
        return AdvisoryType.storm;
      case 'flood':
        return AdvisoryType.flood;
      case 'wind':
        return AdvisoryType.wind;
      case 'heat':
        return AdvisoryType.heat;
      case 'cold':
        return AdvisoryType.cold;
      default:
        return AdvisoryType.storm;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'severity': severity.toString().split('.').last,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 