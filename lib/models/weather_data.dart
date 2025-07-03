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
  final String date;
  final bool isNight;
  final String updateTime;
  final String windDirectionText;
  final String iconName;

  // Temperature/Humidity
  final double temperature;
  final double tempNoDecimal;
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
  final double tempChangeHour;
  final double humidity;
  final double dewPoint;
  final double windChill;
  final double heatIndex;

  // Air Quality
  final double? aqi;
  final String? aqiDescription;

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
  final double possibleDaylight;
  final DateTime moonrise;
  final DateTime moonset;
  final double moonPhase;
  final String moonPhaseName;

  // Weather condition
  final String condition;

  WeatherData({
    required this.lastUpdatedTime,
    required this.lastUpdatedDate,
    required this.date,
    required this.isNight,
    required this.updateTime,
    required this.windDirectionText,
    required this.iconName,
    required this.temperature,
    required this.tempNoDecimal,
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
    required this.tempChangeHour,
    required this.humidity,
    required this.dewPoint,
    required this.windChill,
    required this.heatIndex,
    required this.aqi,
    required this.aqiDescription,
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
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      lastUpdatedTime: json['lastUpdatedTime'] as String? ?? '',
      lastUpdatedDate: json['lastUpdatedDate'] as String? ?? '',
      date: json['date'] as String? ?? '',
      isNight: json['isNight'] as bool? ?? false,
      updateTime: json['updateTime'] as String? ?? '',
      windDirectionText: json['windDirectionText'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'skc',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      tempNoDecimal: (json['tempNoDecimal'] as num?)?.toDouble() ?? 0,
      maxTemp: (json['maxTemp'] as num?)?.toDouble() ?? 0,
      maxTempTime: json['maxTempTime'] as String? ?? '',
      minTemp: (json['minTemp'] as num?)?.toDouble() ?? 0,
      minTempTime: json['minTempTime'] as String? ?? '',
      maxTempLastYear: (json['maxTempLastYear'] as num?)?.toDouble() ?? 0,
      minTempLastYear: (json['minTempLastYear'] as num?)?.toDouble() ?? 0,
      maxTempRecord: (json['maxTempRecord'] as num?)?.toDouble() ?? 0,
      minTempRecord: (json['minTempRecord'] as num?)?.toDouble() ?? 0,
      maxTempAverage: (json['maxTempAverage'] as num?)?.toDouble() ?? 0,
      minTempAverage: (json['minTempAverage'] as num?)?.toDouble() ?? 0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 0,
      tempChangeHour: (json['tempChangeHour'] as num?)?.toDouble() ?? 0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0,
      dewPoint: (json['dewPoint'] as num?)?.toDouble() ?? 0,
      windChill: (json['windChill'] as num?)?.toDouble() ?? 0,
      heatIndex: (json['heatIndex'] as num?)?.toDouble() ?? 0,
      aqi: (json['aqi'] as num?)?.toDouble(),
      aqiDescription: json['aqiDescription'] as String?,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      windGust: (json['windGust'] as num?)?.toDouble() ?? 0,
      maxGust: (json['maxGust'] as num?)?.toDouble() ?? 0,
      maxGustTime: json['maxGustTime'] as String? ?? '',
      windDirection: json['windDirection'] as String? ?? '',
      windDirectionDegrees: json['windDirectionDegrees'] as int? ?? 0,
      avgWind10Min: (json['avgWind10Min'] as num?)?.toDouble() ?? 0,
      monthlyHighWindGust: (json['monthlyHighWindGust'] as num?)?.toDouble() ?? 0,
      beaufortScale: json['beaufortScale'] as String? ?? '',
      beaufortText: json['beaufortText'] as String? ?? '',
      pressure: (json['pressure'] as num?)?.toDouble() ?? 0,
      pressureTrend: json['pressureTrend'] as String? ?? '',
      pressureTrend3Hour: json['pressureTrend3Hour'] as String? ?? '',
      forecastText: json['forecastText'] as String? ?? '',
      dailyRain: (json['dailyRain'] as num?)?.toDouble() ?? 0,
      yesterdayRain: (json['yesterdayRain'] as num?)?.toDouble() ?? 0,
      monthlyRain: (json['monthlyRain'] as num?)?.toDouble() ?? 0,
      yearlyRain: (json['yearlyRain'] as num?)?.toDouble() ?? 0,
      daysWithNoRain: json['daysWithNoRain'] as int? ?? 0,
      daysWithRain: json['daysWithRain'] as int? ?? 0,
      currentRainRate: (json['currentRainRate'] as num?)?.toDouble() ?? 0,
      maxRainRate: (json['maxRainRate'] as num?)?.toDouble() ?? 0,
      maxRainRateTime: json['maxRainRateTime'] as String? ?? '',
      solarRadiation: (json['solarRadiation'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0,
      highSolar: (json['highSolar'] as num?)?.toDouble() ?? 0,
      highUV: (json['highUV'] as num?)?.toDouble() ?? 0,
      highSolarTime: json['highSolarTime'] as String? ?? '',
      highUVTime: json['highUVTime'] as String? ?? '',
      burnTime: json['burnTime'] as int? ?? 0,
      snowSeason: (json['snowSeason'] as num?)?.toDouble() ?? 0,
      snowMonth: (json['snowMonth'] as num?)?.toDouble() ?? 0,
      snowToday: (json['snowToday'] as num?)?.toDouble() ?? 0,
      snowYesterday: (json['snowYesterday'] as num?)?.toDouble() ?? 0,
      snowHeight: (json['snowHeight'] as num?)?.toDouble() ?? 0,
      snowDepth: (json['snowDepth'] as num?)?.toDouble() ?? 0,
      snowDaysThisMonth: json['snowDaysThisMonth'] as int? ?? 0,
      snowDaysThisYear: json['snowDaysThisYear'] as int? ?? 0,
      advisories: (json['advisories'] as List<dynamic>?)
          ?.map((e) => WeatherAdvisory.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      maxTempYesterday: (json['maxTempYesterday'] as num?)?.toDouble() ?? 0,
      minTempYesterday: (json['minTempYesterday'] as num?)?.toDouble() ?? 0,
      forecast: (json['forecast'] as List<dynamic>?)
          ?.map((e) => ForecastPeriod.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      alerts: (json['alerts'] as List<dynamic>?)
          ?.map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      sunrise: json['sunrise'] != null ? DateTime.parse(json['sunrise'].toString()) : DateTime.now(),
      sunset: json['sunset'] != null ? DateTime.parse(json['sunset'].toString()) : DateTime.now(),
      daylightChange: json['daylightChange'] != null ? Duration(seconds: json['daylightChange']) : Duration.zero,
      possibleDaylight: (json['possibleDaylight'] as num?)?.toDouble() ?? 0,
      moonrise: json['moonrise'] != null ? DateTime.parse(json['moonrise'].toString()) : DateTime.now(),
      moonset: json['moonset'] != null ? DateTime.parse(json['moonset'].toString()) : DateTime.now(),
      moonPhase: (json['moonPhase'] as num?)?.toDouble() ?? 0,
      moonPhaseName: json['moonPhaseName'] as String? ?? '',
      condition: json['condition'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdatedTime': lastUpdatedTime,
      'lastUpdatedDate': lastUpdatedDate,
      'date': date,
      'isNight': isNight,
      'updateTime': updateTime,
      'windDirectionText': windDirectionText,
      'iconName': iconName,
      'temperature': temperature,
      'tempNoDecimal': tempNoDecimal,
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
      'tempChangeHour': tempChangeHour,
      'humidity': humidity,
      'dewPoint': dewPoint,
      'windChill': windChill,
      'heatIndex': heatIndex,
      'aqi': aqi,
      'aqiDescription': aqiDescription,
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
      'condition': condition,
    };
  }

  WeatherData copyWith({
    String? lastUpdatedTime,
    String? lastUpdatedDate,
    String? date,
    bool? isNight,
    String? updateTime,
    String? windDirectionText,
    String? iconName,
    double? temperature,
    double? tempNoDecimal,
    double? maxTemp,
    String? maxTempTime,
    double? minTemp,
    String? minTempTime,
    double? maxTempLastYear,
    double? minTempLastYear,
    double? maxTempRecord,
    double? minTempRecord,
    double? maxTempAverage,
    double? minTempAverage,
    double? feelsLike,
    double? tempChangeHour,
    double? humidity,
    double? dewPoint,
    double? windChill,
    double? heatIndex,
    double? aqi,
    String? aqiDescription,
    double? windSpeed,
    double? windGust,
    double? maxGust,
    String? maxGustTime,
    String? windDirection,
    int? windDirectionDegrees,
    double? avgWind10Min,
    double? monthlyHighWindGust,
    String? beaufortScale,
    String? beaufortText,
    double? pressure,
    String? pressureTrend,
    String? pressureTrend3Hour,
    String? forecastText,
    double? dailyRain,
    double? yesterdayRain,
    double? monthlyRain,
    double? yearlyRain,
    int? daysWithNoRain,
    int? daysWithRain,
    double? currentRainRate,
    double? maxRainRate,
    String? maxRainRateTime,
    double? solarRadiation,
    double? uvIndex,
    double? highSolar,
    double? highUV,
    String? highSolarTime,
    String? highUVTime,
    int? burnTime,
    double? snowSeason,
    double? snowMonth,
    double? snowToday,
    double? snowYesterday,
    double? snowHeight,
    double? snowDepth,
    int? snowDaysThisMonth,
    int? snowDaysThisYear,
    List<WeatherAdvisory>? advisories,
    double? maxTempYesterday,
    double? minTempYesterday,
    List<ForecastPeriod>? forecast,
    List<WeatherAlert>? alerts,
    DateTime? sunrise,
    DateTime? sunset,
    Duration? daylightChange,
    double? possibleDaylight,
    DateTime? moonrise,
    DateTime? moonset,
    double? moonPhase,
    String? moonPhaseName,
    String? condition,
  }) {
    return WeatherData(
      lastUpdatedTime: lastUpdatedTime ?? this.lastUpdatedTime,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      date: date ?? this.date,
      isNight: isNight ?? this.isNight,
      updateTime: updateTime ?? this.updateTime,
      windDirectionText: windDirectionText ?? this.windDirectionText,
      iconName: iconName ?? this.iconName,
      temperature: temperature ?? this.temperature,
      tempNoDecimal: tempNoDecimal ?? this.tempNoDecimal,
      maxTemp: maxTemp ?? this.maxTemp,
      maxTempTime: maxTempTime ?? this.maxTempTime,
      minTemp: minTemp ?? this.minTemp,
      minTempTime: minTempTime ?? this.minTempTime,
      maxTempLastYear: maxTempLastYear ?? this.maxTempLastYear,
      minTempLastYear: minTempLastYear ?? this.minTempLastYear,
      maxTempRecord: maxTempRecord ?? this.maxTempRecord,
      minTempRecord: minTempRecord ?? this.minTempRecord,
      maxTempAverage: maxTempAverage ?? this.maxTempAverage,
      minTempAverage: minTempAverage ?? this.minTempAverage,
      feelsLike: feelsLike ?? this.feelsLike,
      tempChangeHour: tempChangeHour ?? this.tempChangeHour,
      humidity: humidity ?? this.humidity,
      dewPoint: dewPoint ?? this.dewPoint,
      windChill: windChill ?? this.windChill,
      heatIndex: heatIndex ?? this.heatIndex,
      aqi: aqi ?? this.aqi,
      aqiDescription: aqiDescription ?? this.aqiDescription,
      windSpeed: windSpeed ?? this.windSpeed,
      windGust: windGust ?? this.windGust,
      maxGust: maxGust ?? this.maxGust,
      maxGustTime: maxGustTime ?? this.maxGustTime,
      windDirection: windDirection ?? this.windDirection,
      windDirectionDegrees: windDirectionDegrees ?? this.windDirectionDegrees,
      avgWind10Min: avgWind10Min ?? this.avgWind10Min,
      monthlyHighWindGust: monthlyHighWindGust ?? this.monthlyHighWindGust,
      beaufortScale: beaufortScale ?? this.beaufortScale,
      beaufortText: beaufortText ?? this.beaufortText,
      pressure: pressure ?? this.pressure,
      pressureTrend: pressureTrend ?? this.pressureTrend,
      pressureTrend3Hour: pressureTrend3Hour ?? this.pressureTrend3Hour,
      forecastText: forecastText ?? this.forecastText,
      dailyRain: dailyRain ?? this.dailyRain,
      yesterdayRain: yesterdayRain ?? this.yesterdayRain,
      monthlyRain: monthlyRain ?? this.monthlyRain,
      yearlyRain: yearlyRain ?? this.yearlyRain,
      daysWithNoRain: daysWithNoRain ?? this.daysWithNoRain,
      daysWithRain: daysWithRain ?? this.daysWithRain,
      currentRainRate: currentRainRate ?? this.currentRainRate,
      maxRainRate: maxRainRate ?? this.maxRainRate,
      maxRainRateTime: maxRainRateTime ?? this.maxRainRateTime,
      solarRadiation: solarRadiation ?? this.solarRadiation,
      uvIndex: uvIndex ?? this.uvIndex,
      highSolar: highSolar ?? this.highSolar,
      highUV: highUV ?? this.highUV,
      highSolarTime: highSolarTime ?? this.highSolarTime,
      highUVTime: highUVTime ?? this.highUVTime,
      burnTime: burnTime ?? this.burnTime,
      snowSeason: snowSeason ?? this.snowSeason,
      snowMonth: snowMonth ?? this.snowMonth,
      snowToday: snowToday ?? this.snowToday,
      snowYesterday: snowYesterday ?? this.snowYesterday,
      snowHeight: snowHeight ?? this.snowHeight,
      snowDepth: snowDepth ?? this.snowDepth,
      snowDaysThisMonth: snowDaysThisMonth ?? this.snowDaysThisMonth,
      snowDaysThisYear: snowDaysThisYear ?? this.snowDaysThisYear,
      advisories: advisories ?? this.advisories,
      maxTempYesterday: maxTempYesterday ?? this.maxTempYesterday,
      minTempYesterday: minTempYesterday ?? this.minTempYesterday,
      forecast: forecast ?? this.forecast,
      alerts: alerts ?? this.alerts,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      daylightChange: daylightChange ?? this.daylightChange,
      possibleDaylight: possibleDaylight ?? this.possibleDaylight,
      moonrise: moonrise ?? this.moonrise,
      moonset: moonset ?? this.moonset,
      moonPhase: moonPhase ?? this.moonPhase,
      moonPhaseName: moonPhaseName ?? this.moonPhaseName,
      condition: condition ?? this.condition,
    );
  }
} 