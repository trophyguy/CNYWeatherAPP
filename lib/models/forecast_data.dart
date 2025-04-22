import 'package:flutter/foundation.dart';

class ForecastPeriod {
  final String name;  // e.g., "Today", "Tonight", "Tomorrow"
  final String shortName;  // e.g., "Tue", "Tue Nite"
  final String condition;  // e.g., "Scattered Snow Showers"
  final double temperature;  // High or Low temperature
  final bool isNight;  // To determine which icon set to use
  final String iconName;  // e.g., "sn" for snow
  final int popPercent;  // Probability of precipitation
  final String windSpeed;  // e.g., "14"
  final String windDirection;  // e.g., "W"
  final String detailedForecast;  // Full forecast text

  ForecastPeriod({
    required this.name,
    required this.shortName,
    required this.condition,
    required this.temperature,
    required this.isNight,
    required this.iconName,
    required this.popPercent,
    required this.windSpeed,
    required this.windDirection,
    required this.detailedForecast,
  });

  factory ForecastPeriod.fromJson(Map<String, dynamic> json) {
    return ForecastPeriod(
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      condition: json['condition'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      isNight: json['isNight'] ?? false,
      iconName: json['iconName'] ?? 'skc',  // Default to clear sky
      popPercent: json['popPercent'] ?? 0,
      windSpeed: json['windSpeed'] ?? '',
      windDirection: json['windDirection'] ?? '',
      detailedForecast: json['detailedForecast'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortName': shortName,
      'condition': condition,
      'temperature': temperature,
      'isNight': isNight,
      'iconName': iconName,
      'popPercent': popPercent,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'detailedForecast': detailedForecast,
    };
  }
} 