class WeatherAlert {
  final String event;
  final String severity;
  final String area;
  final String description;
  final String effective;
  final String issued;
  final String? expires;

  WeatherAlert({
    required this.event,
    required this.severity,
    required this.area,
    required this.description,
    required this.effective,
    required this.issued,
    this.expires,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      event: json['event'] ?? '',
      severity: json['severity'] ?? '',
      area: json['areaDesc'] ?? '',
      description: json['description'] ?? '',
      effective: json['effective'] ?? '',
      issued: json['sent'] ?? '',
      expires: json['expires'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'severity': severity,
      'areaDesc': area,
      'description': description,
      'effective': effective,
      'sent': issued,
      'expires': expires,
    };
  }
} 