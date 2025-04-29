import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'forecast_data.dart';
import 'weather_alert.dart';
import 'package:flutter/material.dart';

class WeatherAdvisory {
  final String type;
  final String severity;
  final String title;
  final String description;
  final DateTime timestamp;

  WeatherAdvisory({
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory WeatherAdvisory.fromJson(Map<String, dynamic> json) {
    return WeatherAdvisory(
      type: json['type']?.toString() ?? 'unknown',
      severity: json['severity']?.toString() ?? 'low',
      title: json['title']?.toString() ?? 'Weather Advisory',
      description: json['description']?.toString() ?? 'No details available',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class WeatherData {
  // Time/Date
  final String lastUpdatedTime;
  final String lastUpdatedDate;
  final bool isNight;
  final String condition;
  final String iconName;

  // Temperature/Humidity
  final double temperature;
  final double tempNoDecimal;
  final double humidity;
  final double dewPoint;
  final double maxTemp;
  final String maxTempTime;
  final double minTemp;
  final String minTempTime;
  final double maxTempLastYear;
  final double minTempLastYear;
  final double maxTempRecord;
  final double minTempRecord;
  final double maxTempAverage;
  final double minTempAverage;
  final double feelsLike;
  final double heatIndex;
  final double windChill;
  final double humidex;
  final double apparentTemp;
  final double apparentSolarTemp;
  final double tempChangeHour;

  // Air Quality
  final double aqi;
  
  // Get AQI color based on value
  Color get aqiColor {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.red.shade900;
  }
  
  // Wind
  final double windSpeed;
  final double windGust;
  final double maxGust;
  final String maxGustTime;
  final String windDirection;
  final int windDirectionDegrees;
  final double avgWind10Min;
  final double monthlyHighWindGust;
  final String beaufortScale;
  final String beaufortText;

  // Barometer
  final double pressure;
  final String pressureTrend;
  final String pressureTrend3Hour;
  final String forecastText;

  // Rain
  final double dailyRain;
  final double yesterdayRain;
  final double monthlyRain;
  final double yearlyRain;
  final int daysWithNoRain;
  final int daysWithRain;
  final double currentRainRate;
  final double maxRainRate;
  final String maxRainRateTime;

  // Solar/UV
  final double solarRadiation;
  final double uvIndex;
  final double highSolar;
  final double highUV;
  final String highSolarTime;
  final String highUVTime;
  final int burnTime;

  // Snow
  final double snowSeason;
  final double snowMonth;
  final double snowToday;
  final double snowYesterday;
  final double snowHeight;
  final double snowDepth;
  final int snowDaysThisMonth;
  final int snowDaysThisYear;

  // Advisories
  final List<WeatherAdvisory> advisories;

  // New fields
  final double maxTempYesterday;
  final double minTempYesterday;

  // Forecast data
  final List<ForecastPeriod> forecast;

  // Alerts
  final List<WeatherAlert> alerts;

  // Sun and Moon data
  final DateTime sunrise;
  final DateTime sunset;
  final Duration daylightChange;
  final double possibleDaylight;  // Total hours of possible daylight
  final DateTime moonrise;
  final DateTime moonset;
  final double moonPhase;  // 0 to 1
  final String moonPhaseName;

  WeatherData({
    required this.lastUpdatedTime,
    required this.lastUpdatedDate,
    required this.isNight,
    required this.condition,
    required this.iconName,
    required this.temperature,
    required this.tempNoDecimal,
    required this.humidity,
    required this.dewPoint,
    required this.maxTemp,
    required this.maxTempTime,
    required this.minTemp,
    required this.minTempTime,
    required this.maxTempLastYear,
    required this.minTempLastYear,
    required this.maxTempRecord,
    required this.minTempRecord,
    required this.maxTempAverage,
    required this.minTempAverage,
    required this.feelsLike,
    required this.heatIndex,
    required this.windChill,
    required this.humidex,
    required this.apparentTemp,
    required this.apparentSolarTemp,
    required this.tempChangeHour,
    required this.aqi,
    required this.windSpeed,
    required this.windGust,
    required this.maxGust,
    required this.maxGustTime,
    required this.windDirection,
    required this.windDirectionDegrees,
    required this.avgWind10Min,
    required this.monthlyHighWindGust,
    required this.beaufortScale,
    required this.beaufortText,
    required this.pressure,
    required this.pressureTrend,
    required this.pressureTrend3Hour,
    required this.forecastText,
    required this.dailyRain,
    required this.yesterdayRain,
    required this.monthlyRain,
    required this.yearlyRain,
    required this.daysWithNoRain,
    required this.daysWithRain,
    required this.currentRainRate,
    required this.maxRainRate,
    required this.maxRainRateTime,
    required this.solarRadiation,
    required this.uvIndex,
    required this.highSolar,
    required this.highUV,
    required this.highSolarTime,
    required this.highUVTime,
    required this.burnTime,
    required this.snowSeason,
    required this.snowMonth,
    required this.snowToday,
    required this.snowYesterday,
    required this.snowHeight,
    required this.snowDepth,
    required this.snowDaysThisMonth,
    required this.snowDaysThisYear,
    required this.advisories,
    required this.maxTempYesterday,
    required this.minTempYesterday,
    required this.forecast,
    required this.alerts,
    required this.sunrise,
    required this.sunset,
    required this.daylightChange,
    required this.possibleDaylight,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonPhaseName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      lastUpdatedTime: json['lastUpdatedTime'] ?? '',
      lastUpdatedDate: json['lastUpdatedDate'] ?? '',
      isNight: json['isNight'] ?? false,
      condition: json['condition'] ?? '',
      iconName: json['iconName'] ?? 'skc',  // Default to clear sky
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      tempNoDecimal: (json['tempNoDecimal'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      dewPoint: (json['dewPoint'] ?? 0.0).toDouble(),
      maxTemp: (json['maxTemp'] ?? 0.0).toDouble(),
      maxTempTime: json['maxTempTime'] ?? '',
      minTemp: (json['minTemp'] ?? 0.0).toDouble(),
      minTempTime: json['minTempTime'] ?? '',
      maxTempLastYear: (json['maxTempLastYear'] ?? 0.0).toDouble(),
      minTempLastYear: (json['minTempLastYear'] ?? 0.0).toDouble(),
      maxTempRecord: (json['maxTempRecord'] ?? 0.0).toDouble(),
      minTempRecord: (json['minTempRecord'] ?? 0.0).toDouble(),
      maxTempAverage: (json['maxTempAverage'] ?? 0.0).toDouble(),
      minTempAverage: (json['minTempAverage'] ?? 0.0).toDouble(),
      feelsLike: (json['feelsLike'] ?? 0.0).toDouble(),
      heatIndex: (json['heatIndex'] ?? 0.0).toDouble(),
      windChill: (json['windChill'] ?? 0.0).toDouble(),
      humidex: (json['humidex'] ?? 0.0).toDouble(),
      apparentTemp: (json['apparentTemp'] ?? 0.0).toDouble(),
      apparentSolarTemp: (json['apparentSolarTemp'] ?? 0.0).toDouble(),
      tempChangeHour: (json['tempChangeHour'] ?? 0.0).toDouble(),
      aqi: (json['aqi'] ?? 0.0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      windGust: (json['windGust'] ?? 0.0).toDouble(),
      maxGust: (json['maxGust'] ?? 0.0).toDouble(),
      maxGustTime: json['maxGustTime'] ?? '',
      windDirection: json['windDirection'] ?? '',
      windDirectionDegrees: json['windDirectionDegrees'] ?? 0,
      avgWind10Min: (json['avgWind10Min'] ?? 0.0).toDouble(),
      monthlyHighWindGust: (json['monthlyHighWindGust'] ?? 0.0).toDouble(),
      beaufortScale: json['beaufortScale'] ?? '',
      beaufortText: json['beaufortText'] ?? '',
      pressure: (json['pressure'] ?? 0.0).toDouble(),
      pressureTrend: json['pressureTrend'] ?? '',
      pressureTrend3Hour: json['pressureTrend3Hour'] ?? '',
      forecastText: json['forecastText'] ?? '',
      dailyRain: (json['dailyRain'] ?? 0.0).toDouble(),
      yesterdayRain: (json['yesterdayRain'] ?? 0.0).toDouble(),
      monthlyRain: (json['monthlyRain'] ?? 0.0).toDouble(),
      yearlyRain: (json['yearlyRain'] ?? 0.0).toDouble(),
      daysWithNoRain: json['daysWithNoRain'] ?? 0,
      daysWithRain: json['daysWithRain'] ?? 0,
      currentRainRate: (json['currentRainRate'] ?? 0.0).toDouble(),
      maxRainRate: (json['maxRainRate'] ?? 0.0).toDouble(),
      maxRainRateTime: json['maxRainRateTime'] ?? '',
      solarRadiation: (json['solarRadiation'] ?? 0.0).toDouble(),
      uvIndex: (json['uvIndex'] ?? 0.0).toDouble(),
      highSolar: (json['highSolar'] ?? 0.0).toDouble(),
      highUV: (json['highUV'] ?? 0.0).toDouble(),
      highSolarTime: json['highSolarTime'] ?? '',
      highUVTime: json['highUVTime'] ?? '',
      burnTime: json['burnTime'] ?? 0,
      snowSeason: (json['snowSeason'] ?? 0.0).toDouble(),
      snowMonth: (json['snowMonth'] ?? 0.0).toDouble(),
      snowToday: (json['snowToday'] ?? 0.0).toDouble(),
      snowYesterday: (json['snowYesterday'] ?? 0.0).toDouble(),
      snowHeight: (json['snowHeight'] ?? 0.0).toDouble(),
      snowDepth: (json['snowDepth'] ?? 0.0).toDouble(),
      snowDaysThisMonth: json['snowDaysThisMonth'] ?? 0,
      snowDaysThisYear: json['snowDaysThisYear'] ?? 0,
      advisories: (json['advisories'] as List<dynamic>?)
          ?.map((e) => WeatherAdvisory.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      maxTempYesterday: (json['maxTempYesterday'] ?? 0.0).toDouble(),
      minTempYesterday: (json['minTempYesterday'] ?? 0.0).toDouble(),
      forecast: (json['forecast'] as List<dynamic>?)
          ?.map((e) => ForecastPeriod.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      alerts: (json['alerts'] as List<dynamic>?)
          ?.map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      sunrise: json['sunrise'] != null ? DateTime.parse(json['sunrise'].toString()) : DateTime.now(),
      sunset: json['sunset'] != null ? DateTime.parse(json['sunset'].toString()) : DateTime.now(),
      daylightChange: json['daylightChange'] != null ? Duration(seconds: json['daylightChange']) : Duration.zero,
      possibleDaylight: (json['possibleDaylight'] ?? 0.0).toDouble(),
      moonrise: json['moonrise'] != null ? DateTime.parse(json['moonrise'].toString()) : DateTime.now(),
      moonset: json['moonset'] != null ? DateTime.parse(json['moonset'].toString()) : DateTime.now(),
      moonPhase: (json['moonPhase'] ?? 0.0).toDouble(),
      moonPhaseName: json['moonPhaseName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdatedTime': lastUpdatedTime,
      'lastUpdatedDate': lastUpdatedDate,
      'isNight': isNight,
      'condition': condition,
      'iconName': iconName,
      'temperature': temperature,
      'tempNoDecimal': tempNoDecimal,
      'humidity': humidity,
      'dewPoint': dewPoint,
      'maxTemp': maxTemp,
      'maxTempTime': maxTempTime,
      'minTemp': minTemp,
      'minTempTime': minTempTime,
      'maxTempLastYear': maxTempLastYear,
      'minTempLastYear': minTempLastYear,
      'maxTempRecord': maxTempRecord,
      'minTempRecord': minTempRecord,
      'maxTempAverage': maxTempAverage,
      'minTempAverage': minTempAverage,
      'feelsLike': feelsLike,
      'heatIndex': heatIndex,
      'windChill': windChill,
      'humidex': humidex,
      'apparentTemp': apparentTemp,
      'apparentSolarTemp': apparentSolarTemp,
      'tempChangeHour': tempChangeHour,
      'aqi': aqi,
      'windSpeed': windSpeed,
      'windGust': windGust,
      'maxGust': maxGust,
      'maxGustTime': maxGustTime,
      'windDirection': windDirection,
      'windDirectionDegrees': windDirectionDegrees,
      'avgWind10Min': avgWind10Min,
      'monthlyHighWindGust': monthlyHighWindGust,
      'beaufortScale': beaufortScale,
      'beaufortText': beaufortText,
      'pressure': pressure,
      'pressureTrend': pressureTrend,
      'pressureTrend3Hour': pressureTrend3Hour,
      'forecastText': forecastText,
      'dailyRain': dailyRain,
      'yesterdayRain': yesterdayRain,
      'monthlyRain': monthlyRain,
      'yearlyRain': yearlyRain,
      'daysWithNoRain': daysWithNoRain,
      'daysWithRain': daysWithRain,
      'currentRainRate': currentRainRate,
      'maxRainRate': maxRainRate,
      'maxRainRateTime': maxRainRateTime,
      'solarRadiation': solarRadiation,
      'uvIndex': uvIndex,
      'highSolar': highSolar,
      'highUV': highUV,
      'highSolarTime': highSolarTime,
      'highUVTime': highUVTime,
      'burnTime': burnTime,
      'snowSeason': snowSeason,
      'snowMonth': snowMonth,
      'snowToday': snowToday,
      'snowYesterday': snowYesterday,
      'snowHeight': snowHeight,
      'snowDepth': snowDepth,
      'snowDaysThisMonth': snowDaysThisMonth,
      'snowDaysThisYear': snowDaysThisYear,
      'advisories': advisories.map((e) => e.toJson()).toList(),
      'maxTempYesterday': maxTempYesterday,
      'minTempYesterday': minTempYesterday,
      'forecast': forecast.map((e) => e.toJson()).toList(),
      'alerts': alerts.map((e) => e.toJson()).toList(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'daylightChange': daylightChange.inSeconds,
      'possibleDaylight': possibleDaylight,
      'moonrise': moonrise.toIso8601String(),
      'moonset': moonset.toIso8601String(),
      'moonPhase': moonPhase,
      'moonPhaseName': moonPhaseName,
    };
  }
} 