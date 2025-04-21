import 'package:flutter/foundation.dart';
import 'dart:convert';

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

  // Wind
  final double windSpeed;
  final double windGust;
  final double maxGust;
  final String maxGustTime;
  final String windDirection;
  final int windDirectionDegrees;
  final double avgWind10Min;
  final String beaufortScale;
  final String beaufortText;

  // Barometer
  final double pressure;
  final String pressureTrend;
  final String pressureTrend3Hour;
  final String forecastText;

  // Rain
  final double dailyRain;
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

  WeatherData({
    required this.lastUpdatedTime,
    required this.lastUpdatedDate,
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
    required this.beaufortScale,
    required this.beaufortText,
    required this.pressure,
    required this.pressureTrend,
    required this.pressureTrend3Hour,
    required this.forecastText,
    required this.dailyRain,
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
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    debugPrint('JSON tempNoDecimal: ${json['tempNoDecimal']}');
    return WeatherData(
      lastUpdatedTime: json['lastUpdatedTime'] ?? '',
      lastUpdatedDate: json['lastUpdatedDate'] ?? '',
      temperature: json['temperature'] ?? 0.0,
      tempNoDecimal: (json['tempNoDecimal'] as num?)?.toDouble() ?? 0.0,
      humidity: json['humidity'] ?? 0.0,
      dewPoint: json['dewPoint'] ?? 0.0,
      maxTemp: json['maxTemp'] ?? 0.0,
      maxTempTime: json['maxTempTime'] ?? '',
      minTemp: json['minTemp'] ?? 0.0,
      minTempTime: json['minTempTime'] ?? '',
      maxTempLastYear: json['maxTempLastYear'] ?? 0.0,
      minTempLastYear: json['minTempLastYear'] ?? 0.0,
      maxTempRecord: json['maxTempRecord'] ?? 0.0,
      minTempRecord: json['minTempRecord'] ?? 0.0,
      maxTempAverage: json['maxTempAverage'] ?? 0.0,
      minTempAverage: json['minTempAverage'] ?? 0.0,
      feelsLike: json['feelsLike'] ?? 0.0,
      heatIndex: json['heatIndex'] ?? 0.0,
      windChill: json['windChill'] ?? 0.0,
      humidex: json['humidex'] ?? 0.0,
      apparentTemp: json['apparentTemp'] ?? 0.0,
      apparentSolarTemp: json['apparentSolarTemp'] ?? 0.0,
      tempChangeHour: json['tempChangeHour'] ?? 0.0,
      aqi: json['aqi'] ?? 0.0,
      windSpeed: json['windSpeed'] ?? 0.0,
      windGust: json['windGust'] ?? 0.0,
      maxGust: json['maxGust'] ?? 0.0,
      maxGustTime: json['maxGustTime'] ?? '',
      windDirection: json['windDirection'] ?? '',
      windDirectionDegrees: json['windDirectionDegrees'] ?? 0,
      avgWind10Min: json['avgWind10Min'] ?? 0.0,
      beaufortScale: json['beaufortScale'] ?? '',
      beaufortText: json['beaufortText'] ?? '',
      pressure: json['pressure'] ?? 0.0,
      pressureTrend: json['pressureTrend'] ?? '',
      pressureTrend3Hour: json['pressureTrend3Hour'] ?? '',
      forecastText: json['forecastText'] ?? '',
      dailyRain: json['dailyRain'] ?? 0.0,
      monthlyRain: json['monthlyRain'] ?? 0.0,
      yearlyRain: json['yearlyRain'] ?? 0.0,
      daysWithNoRain: json['daysWithNoRain'] ?? 0,
      daysWithRain: json['daysWithRain'] ?? 0,
      currentRainRate: json['currentRainRate'] ?? 0.0,
      maxRainRate: json['maxRainRate'] ?? 0.0,
      maxRainRateTime: json['maxRainRateTime'] ?? '',
      solarRadiation: json['solarRadiation'] ?? 0.0,
      uvIndex: json['uvIndex'] ?? 0.0,
      highSolar: json['highSolar'] ?? 0.0,
      highUV: json['highUV'] ?? 0.0,
      highSolarTime: json['highSolarTime'] ?? '',
      highUVTime: json['highUVTime'] ?? '',
      burnTime: json['burnTime'] ?? 0,
      snowSeason: json['snowSeason'] ?? 0.0,
      snowMonth: json['snowMonth'] ?? 0.0,
      snowToday: json['snowToday'] ?? 0.0,
      snowYesterday: json['snowYesterday'] ?? 0.0,
      snowHeight: json['snowHeight'] ?? 0.0,
      snowDepth: json['snowDepth'] ?? 0.0,
      snowDaysThisMonth: json['snowDaysThisMonth'] ?? 0,
      snowDaysThisYear: json['snowDaysThisYear'] ?? 0,
      advisories: (json['advisories'] as List<dynamic>?)
          ?.map((e) => WeatherAdvisory.fromJson(e))
          .toList() ?? [],
      maxTempYesterday: json['maxTempYesterday'] ?? 0.0,
      minTempYesterday: json['minTempYesterday'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdatedTime': lastUpdatedTime,
      'lastUpdatedDate': lastUpdatedDate,
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
      'beaufortScale': beaufortScale,
      'beaufortText': beaufortText,
      'pressure': pressure,
      'pressureTrend': pressureTrend,
      'pressureTrend3Hour': pressureTrend3Hour,
      'forecastText': forecastText,
      'dailyRain': dailyRain,
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
    };
  }

  WeatherData copyWith(Map<String, dynamic> changes) {
    return WeatherData(
      lastUpdatedTime: changes['lastUpdatedTime']?.toString() ?? lastUpdatedTime,
      lastUpdatedDate: changes['lastUpdatedDate']?.toString() ?? lastUpdatedDate,
      temperature: (changes['temperature'] as num?)?.toDouble() ?? temperature,
      tempNoDecimal: (changes['tempNoDecimal'] as num?)?.toDouble() ?? tempNoDecimal,
      humidity: (changes['humidity'] as num?)?.toDouble() ?? humidity,
      dewPoint: (changes['dewPoint'] as num?)?.toDouble() ?? dewPoint,
      maxTemp: (changes['maxTemp'] as num?)?.toDouble() ?? maxTemp,
      maxTempTime: changes['maxTempTime']?.toString() ?? maxTempTime,
      minTemp: (changes['minTemp'] as num?)?.toDouble() ?? minTemp,
      minTempTime: changes['minTempTime']?.toString() ?? minTempTime,
      maxTempLastYear: (changes['maxTempLastYear'] as num?)?.toDouble() ?? maxTempLastYear,
      minTempLastYear: (changes['minTempLastYear'] as num?)?.toDouble() ?? minTempLastYear,
      maxTempRecord: (changes['maxTempRecord'] as num?)?.toDouble() ?? maxTempRecord,
      minTempRecord: (changes['minTempRecord'] as num?)?.toDouble() ?? minTempRecord,
      maxTempAverage: (changes['maxTempAverage'] as num?)?.toDouble() ?? maxTempAverage,
      minTempAverage: (changes['minTempAverage'] as num?)?.toDouble() ?? minTempAverage,
      feelsLike: (changes['feelsLike'] as num?)?.toDouble() ?? feelsLike,
      heatIndex: (changes['heatIndex'] as num?)?.toDouble() ?? heatIndex,
      windChill: (changes['windChill'] as num?)?.toDouble() ?? windChill,
      humidex: (changes['humidex'] as num?)?.toDouble() ?? humidex,
      apparentTemp: (changes['apparentTemp'] as num?)?.toDouble() ?? apparentTemp,
      apparentSolarTemp: (changes['apparentSolarTemp'] as num?)?.toDouble() ?? apparentSolarTemp,
      tempChangeHour: (changes['tempChangeHour'] as num?)?.toDouble() ?? tempChangeHour,
      aqi: (changes['aqi'] as num?)?.toDouble() ?? aqi,
      windSpeed: (changes['windSpeed'] as num?)?.toDouble() ?? windSpeed,
      windGust: (changes['windGust'] as num?)?.toDouble() ?? windGust,
      maxGust: (changes['maxGust'] as num?)?.toDouble() ?? maxGust,
      maxGustTime: changes['maxGustTime']?.toString() ?? maxGustTime,
      windDirection: changes['windDirection']?.toString() ?? windDirection,
      windDirectionDegrees: changes['windDirectionDegrees'] ?? windDirectionDegrees,
      avgWind10Min: (changes['avgWind10Min'] as num?)?.toDouble() ?? avgWind10Min,
      beaufortScale: changes['beaufortScale']?.toString() ?? beaufortScale,
      beaufortText: changes['beaufortText']?.toString() ?? beaufortText,
      pressure: (changes['pressure'] as num?)?.toDouble() ?? pressure,
      pressureTrend: changes['pressureTrend']?.toString() ?? pressureTrend,
      pressureTrend3Hour: changes['pressureTrend3Hour']?.toString() ?? pressureTrend3Hour,
      forecastText: changes['forecastText']?.toString() ?? forecastText,
      dailyRain: (changes['dailyRain'] as num?)?.toDouble() ?? dailyRain,
      monthlyRain: (changes['monthlyRain'] as num?)?.toDouble() ?? monthlyRain,
      yearlyRain: (changes['yearlyRain'] as num?)?.toDouble() ?? yearlyRain,
      daysWithNoRain: changes['daysWithNoRain'] ?? daysWithNoRain,
      daysWithRain: changes['daysWithRain'] ?? daysWithRain,
      currentRainRate: (changes['currentRainRate'] as num?)?.toDouble() ?? currentRainRate,
      maxRainRate: (changes['maxRainRate'] as num?)?.toDouble() ?? maxRainRate,
      maxRainRateTime: changes['maxRainRateTime']?.toString() ?? maxRainRateTime,
      solarRadiation: (changes['solarRadiation'] as num?)?.toDouble() ?? solarRadiation,
      uvIndex: (changes['uvIndex'] as num?)?.toDouble() ?? uvIndex,
      highSolar: (changes['highSolar'] as num?)?.toDouble() ?? highSolar,
      highUV: (changes['highUV'] as num?)?.toDouble() ?? highUV,
      highSolarTime: changes['highSolarTime']?.toString() ?? highSolarTime,
      highUVTime: changes['highUVTime']?.toString() ?? highUVTime,
      burnTime: changes['burnTime'] ?? burnTime,
      snowSeason: (changes['snowSeason'] as num?)?.toDouble() ?? snowSeason,
      snowMonth: (changes['snowMonth'] as num?)?.toDouble() ?? snowMonth,
      snowToday: (changes['snowToday'] as num?)?.toDouble() ?? snowToday,
      snowYesterday: (changes['snowYesterday'] as num?)?.toDouble() ?? snowYesterday,
      snowHeight: (changes['snowHeight'] as num?)?.toDouble() ?? snowHeight,
      snowDepth: (changes['snowDepth'] as num?)?.toDouble() ?? snowDepth,
      snowDaysThisMonth: changes['snowDaysThisMonth'] ?? snowDaysThisMonth,
      snowDaysThisYear: changes['snowDaysThisYear'] ?? snowDaysThisYear,
      advisories: changes['advisories'] != null 
          ? _parseAdvisories(changes['advisories'].toString())
          : advisories,
      maxTempYesterday: (changes['maxTempYesterday'] as num?)?.toDouble() ?? maxTempYesterday,
      minTempYesterday: (changes['minTempYesterday'] as num?)?.toDouble() ?? minTempYesterday,
    );
  }

  static List<WeatherAdvisory> _parseAdvisories(String? advisoriesJson) {
    if (advisoriesJson == null || advisoriesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(advisoriesJson) as List;
      return jsonList
          .map((json) => WeatherAdvisory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error parsing advisories: $e');
      return [];
    }
  }
} 