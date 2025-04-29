// **************************************************************************
// * WARNING: DO NOT MODIFY THIS FILE WITHOUT EXPLICIT APPROVAL                *
// * Changes to this file should be properly reviewed and authorized          *
// * Version: 1.1.0                                                          *
// **************************************************************************

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/weather_alert.dart';
import '../services/cache_service.dart';
import '../services/openweather_service.dart';
import '../services/nws_service.dart';
import '../services/purple_air_service.dart';
import 'package:flutter/foundation.dart';

class WeatherRepository {
  final CacheService _cacheService;
  final OpenWeatherService _openWeatherService;
  final NWSService _nwsService;
  final PurpleAirService _purpleAirService;
  static const String _testTagsUrl = 'https://cnyweather.com/testtags.php?sce=view';
  // static const String _clientRawUrl = 'https://cnyweather.com/clientraw.txt';
  static const double _stationLat = 43.2105; // Rome, NY latitude
  static const double _stationLon = -75.4557; // Rome, NY longitude
  static const String _baseUrl = 'https://cnyweather.com/testtags.php?sce=view';

  WeatherRepository(this._cacheService, this._openWeatherService, this._purpleAirService) 
      : _nwsService = NWSService();

  Future<WeatherData> getWeatherData() async {
    try {
      // Check for cached forecast first
      List<ForecastPeriod>? cachedForecast = await _cacheService.getCachedForecastData();
      List<ForecastPeriod> forecastData = cachedForecast ?? await _nwsService.getForecast();
      
      // If we had to fetch new forecast data, cache it
      if (cachedForecast == null) {
        await _cacheService.cacheForecastData(forecastData);
      }

      // Get AQI data from Purple Air, using cache if available
      Map<String, dynamic> aqiData;
      final cachedAQIData = await _cacheService.getCachedAQIData();
      if (cachedAQIData != null) {
        aqiData = cachedAQIData;
        debugPrint('=== Purple Air AQI Data ===');
        debugPrint('Using cached AQI data');
        debugPrint('AQI Value: ${aqiData['aqi']}');
        debugPrint('Last Update: ${aqiData['lastUpdate']}');
      } else {
        debugPrint('=== Purple Air AQI Data ===');
        debugPrint('Fetching fresh AQI data from Purple Air');
        aqiData = await _purpleAirService.getAQIData();
        debugPrint('AQI Value: ${aqiData['aqi']}');
        debugPrint('Last Update: ${DateTime.now()}');
        await _cacheService.cacheAQIData(aqiData);
        debugPrint('Cached new AQI data');
      }
      
      // Always fetch fresh data first
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        // Convert bytes to string, replacing any invalid UTF-8 sequences
        final cleanedBody = String.fromCharCodes(
          response.bodyBytes.where((byte) => byte < 128)
        );

        // Debug print the raw response
        debugPrint('\n=== Raw TestTags Response ===');
        debugPrint(cleanedBody);

        // Parse testtags data
        final weatherData = _parseTestTags(cleanedBody);

        // Create new WeatherData with forecast and AQI data
        final updatedWeatherData = WeatherData(
          lastUpdatedTime: weatherData.lastUpdatedTime,
          lastUpdatedDate: weatherData.lastUpdatedDate,
          isNight: weatherData.isNight,
          condition: weatherData.condition,
          iconName: weatherData.iconName,
          temperature: weatherData.temperature,
          tempNoDecimal: weatherData.tempNoDecimal,
          humidity: weatherData.humidity,
          dewPoint: weatherData.dewPoint,
          maxTemp: weatherData.maxTemp,
          maxTempTime: weatherData.maxTempTime,
          minTemp: weatherData.minTemp,
          minTempTime: weatherData.minTempTime,
          maxTempLastYear: weatherData.maxTempLastYear,
          minTempLastYear: weatherData.minTempLastYear,
          maxTempRecord: weatherData.maxTempRecord,
          minTempRecord: weatherData.minTempRecord,
          maxTempAverage: weatherData.maxTempAverage,
          minTempAverage: weatherData.minTempAverage,
          feelsLike: weatherData.feelsLike,
          heatIndex: weatherData.heatIndex,
          windChill: weatherData.windChill,
          humidex: weatherData.humidex,
          apparentTemp: weatherData.apparentTemp,
          apparentSolarTemp: weatherData.apparentSolarTemp,
          tempChangeHour: weatherData.tempChangeHour,
          aqi: aqiData['aqi'].toDouble(),
          windSpeed: weatherData.windSpeed,
          windGust: weatherData.windGust,
          maxGust: weatherData.maxGust,
          maxGustTime: weatherData.maxGustTime,
          windDirection: weatherData.windDirection,
          windDirectionDegrees: weatherData.windDirectionDegrees,
          avgWind10Min: weatherData.avgWind10Min,
          monthlyHighWindGust: weatherData.monthlyHighWindGust,
          beaufortScale: weatherData.beaufortScale,
          beaufortText: weatherData.beaufortText,
          pressure: weatherData.pressure,
          pressureTrend: weatherData.pressureTrend,
          pressureTrend3Hour: weatherData.pressureTrend3Hour,
          forecastText: weatherData.forecastText,
          dailyRain: weatherData.dailyRain,
          yesterdayRain: weatherData.yesterdayRain,
          monthlyRain: weatherData.monthlyRain,
          yearlyRain: weatherData.yearlyRain,
          daysWithNoRain: weatherData.daysWithNoRain,
          daysWithRain: weatherData.daysWithRain,
          currentRainRate: weatherData.currentRainRate,
          maxRainRate: weatherData.maxRainRate,
          maxRainRateTime: weatherData.maxRainRateTime,
          solarRadiation: weatherData.solarRadiation,
          uvIndex: weatherData.uvIndex,
          highSolar: weatherData.highSolar,
          highUV: weatherData.highUV,
          highSolarTime: weatherData.highSolarTime,
          highUVTime: weatherData.highUVTime,
          burnTime: weatherData.burnTime,
          snowSeason: weatherData.snowSeason,
          snowMonth: weatherData.snowMonth,
          snowToday: weatherData.snowToday,
          snowYesterday: weatherData.snowYesterday,
          snowHeight: weatherData.snowHeight,
          snowDepth: weatherData.snowDepth,
          snowDaysThisMonth: weatherData.snowDaysThisMonth,
          snowDaysThisYear: weatherData.snowDaysThisYear,
          advisories: weatherData.advisories,
          maxTempYesterday: weatherData.maxTempYesterday,
          minTempYesterday: weatherData.minTempYesterday,
          forecast: forecastData,
          alerts: weatherData.alerts,
          sunrise: weatherData.sunrise,
          sunset: weatherData.sunset,
          daylightChange: weatherData.daylightChange,
          possibleDaylight: weatherData.possibleDaylight,
          moonrise: weatherData.moonrise,
          moonset: weatherData.moonset,
          moonPhase: weatherData.moonPhase,
          moonPhaseName: weatherData.moonPhaseName,
        );

        // Cache the new data (without forecast since it's cached separately)
        final weatherDataJson = updatedWeatherData.toJson();
        weatherDataJson.remove('forecast'); // Remove forecast from main cache
        await _cacheService.cacheWeatherData(weatherDataJson);
        
        return updatedWeatherData;
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in getWeatherData: $e');
      
      // Try to get cached data
      try {
        final cachedDataStr = await _cacheService.getWeatherData();
        if (cachedDataStr != null) {
          return WeatherData.fromJson(json.decode(cachedDataStr));
        }
      } catch (cacheError) {
        developer.log('Error getting cached data: $cacheError');
      }
      
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getQuickUpdate() async {
    try {
      debugPrint('Fetching quick update data...');
      // Use the correct URL for clientraw.txt
      final response = await http.get(
        Uri.parse('https://cnyweather.com/weather/clientraw.txt'),
        headers: {'Accept-Charset': 'utf-8'},
      );
      
      debugPrint('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final rawBody = String.fromCharCodes(response.bodyBytes);
        debugPrint('\n=== Completely Raw Response ===');
        debugPrint(rawBody);
        
        final cleanedBody = String.fromCharCodes(
          response.bodyBytes.where((byte) => byte < 128)
        );
        
        debugPrint('\n=== Cleaned Response ===');
        debugPrint(cleanedBody);
        
        final parts = cleanedBody.split(' ');
        debugPrint('\n=== First 10 Fields ===');
        for (int i = 0; i < math.min(10, parts.length); i++) {
          debugPrint('Field[$i]: "${parts[i]}"');
        }
        
        if (parts.length >= 10) {
          // Field indices from clientraw.txt documentation:
          // [0] = Data header (12345)
          // [1] = Average wind speed
          // [2] = Current wind speed
          // [3] = Wind direction
          // [4] = Outside temperature
          // [5] = Relative humidity
          // [6] = Barometer
          // [7] = Daily rain
          
          final temp = double.tryParse(parts[4]) ?? 0.0;
          final windSpeed = double.tryParse(parts[2]) ?? 0.0;
          final windDir = parts[3];
          final humidity = double.tryParse(parts[5]) ?? 0.0;
          final pressureMB = double.tryParse(parts[6]) ?? 0.0;
          final rainfall = double.tryParse(parts[7]) ?? 0.0;
          
          debugPrint('\n=== Direct Field Values ===');
          debugPrint('Field[4] (Temperature) raw value: "${parts[4]}"');
          debugPrint('Parsed temperature: $temp°C');
          
          final result = {
            'temperature': temp,
            'humidity': humidity.clamp(0.0, 100.0),
            'windSpeed': windSpeed,
            'windDirection': windDir,
            'pressure': pressureMB,
            'rainfall': rainfall,
          };
          
          debugPrint('\n=== Final Result ===');
          result.forEach((key, value) {
            debugPrint('$key: $value (${value.runtimeType})');
          });
          
          return result;
        } else {
          debugPrint('Not enough data parts in clientraw.txt');
          debugPrint('Total parts found: ${parts.length}');
        }
      }
      
      debugPrint('Falling back to cached data...');
      // If we can't get fresh data, return the last known values from cache
      final cachedData = await _cacheService.getCachedWeatherData();
      if (cachedData != null) {
        final weatherData = WeatherData.fromJson(cachedData);
        return {
          'temperature': weatherData.temperature,
          'humidity': weatherData.humidity,
          'windSpeed': weatherData.windSpeed,
          'windDirection': weatherData.windDirection,
          'pressure': weatherData.pressure,
          'rainfall': weatherData.dailyRain,
        };
      }
      
      // If all else fails, return zeros
      return {
        'temperature': 0.0,
        'humidity': 0.0,
        'windSpeed': 0.0,
        'windDirection': '',
        'pressure': 0.0,
        'rainfall': 0.0,
      };
    } catch (e) {
      debugPrint('Error in quick update: $e');
      // Try to get cached data as fallback
      final cachedData = await _cacheService.getCachedWeatherData();
      if (cachedData != null) {
        final weatherData = WeatherData.fromJson(cachedData);
        return {
          'temperature': weatherData.temperature,
          'humidity': weatherData.humidity,
          'windSpeed': weatherData.windSpeed,
          'windDirection': weatherData.windDirection,
          'pressure': weatherData.pressure,
          'rainfall': weatherData.dailyRain,
        };
      }
      return {
        'temperature': 0.0,
        'humidity': 0.0,
        'windSpeed': 0.0,
        'windDirection': '',
        'pressure': 0.0,
        'rainfall': 0.0,
      };
    }
  }

  // Map<String, dynamic> _parseQuickUpdate(String html) {
  //   // TODO: Implement clientraw.txt parsing logic
  //   // This will parse the quick update data into a map of values
  //   final Map<String, dynamic> values = {};
  //   final parts = html.split(' ');
    
  //   // Map the parts to their corresponding values
  //   // This mapping will need to be adjusted based on the actual clientraw.txt format
  //   if (parts.length >= 10) {
  //     values['temperature'] = double.tryParse(parts[4]) ?? 0.0;
  //     values['humidity'] = double.tryParse(parts[5]) ?? 0.0;
  //     values['windSpeed'] = double.tryParse(parts[1]) ?? 0.0;
  //     values['windDirection'] = parts[2];
  //     values['pressure'] = double.tryParse(parts[6]) ?? 0.0;
  //     values['rainfall'] = double.tryParse(parts[7]) ?? 0.0;
  //   }
    
  //   return values;
  // }

  String _getShortMoonPhaseName(String fullName) {
    // Convert full moon phase names to shorter versions
    final Map<String, String> shortNames = {
      'New Moon': 'New',
      'Waxing Crescent': 'Wax Cres',
      'First Quarter': '1st Qtr',
      'Waxing Gibbous': 'Wax Gib',
      'Full Moon': 'Full',
      'Waning Gibbous': 'Wan Gib',
      'Last Quarter': 'Last Qtr',
      'Waning Crescent': 'Wan Cres',
    };
    
    return shortNames[fullName] ?? fullName;
  }

  WeatherData _parseTestTags(String html) {
    final Map<String, String> variables = {};
    // First try with double quotes
    final doubleQuotePattern = RegExp(r'\$(\w+)\s*=\s*"([^"]*)"\s*;');
    // Then try with single quotes
    final singleQuotePattern = RegExp(r"\$(\w+)\s*=\s*'([^']*)'\s*;");
    
    // Try both patterns
    for (final match in doubleQuotePattern.allMatches(html)) {
      final key = match.group(1)!;
      final value = match.group(2)!;
      variables[key] = value;
    }
    
    for (final match in singleQuotePattern.allMatches(html)) {
      final key = match.group(1)!;
      final value = match.group(2)!;
      variables[key] = value;
    }
    
    // Debug prints for all variables
    debugPrint('\n=== All Variables Debug ===');
    variables.forEach((key, value) {
      debugPrint('$key: $value');
    });
    
    // Get the update time from testtags using the correct variable names
    final lastUpdatedTime = variables['time'] ?? DateTime.now().toString();
    final lastUpdatedDate = variables['date'] ?? DateTime.now().toString();
    
    // Debug prints for update time
    debugPrint('\n=== Update Time Debug ===');
    debugPrint('Raw time: ${variables['time']}');
    debugPrint('Raw date: ${variables['date']}');
    debugPrint('Using lastUpdatedTime: $lastUpdatedTime');
    debugPrint('Using lastUpdatedDate: $lastUpdatedDate');
    debugPrint('Current system time: ${DateTime.now()}');
    
    // Clean and convert values
    final humidity = double.tryParse(variables['humidity']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final pressure = double.tryParse(variables['barometer']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? 
                                   variables['baro']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? 
                                   variables['pressure']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;

    // Parse sun and moon times
    final now = DateTime.now();
    final sunrise = _parseDateTime(variables['sunrise'] ?? '', now);
    final sunset = _parseDateTime(variables['sunset'] ?? '', now);
    final moonrise = _parseDateTime(variables['moonrise'] ?? '', now);
    final moonset = _parseDateTime(variables['moonset'] ?? '', now);
    final moonPhaseName = _getShortMoonPhaseName(variables['moonphasename'] ?? '');
    
    // Parse possible daylight hours
    final possibleDaylightStr = variables['hoursofpossibledaylight'] ?? '0:00';
    final parts = possibleDaylightStr.split(':');
    final hours = double.tryParse(parts[0]) ?? 0.0;
    final minutes = double.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0.0;
    final possibleDaylight = hours + (minutes / 60.0);
    
    // Calculate daylight change
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final todaySunrise = sunrise;
    final todaySunset = sunset;
    final tomorrowSunrise = _parseDateTime(variables['sunrise'] ?? '', tomorrow);
    final tomorrowSunset = _parseDateTime(variables['sunset'] ?? '', tomorrow);
    
    // Parse change in day length from testtags
    final changeInDayStr = variables['changeinday'] ?? '00:00:00';
    final changeParts = changeInDayStr.split(':');
    final changeHours = int.tryParse(changeParts[0]) ?? 0;
    final changeMinutes = int.tryParse(changeParts[1]) ?? 0;
    final changeSeconds = int.tryParse(changeParts[2]) ?? 0;
    final daylightChange = Duration(
      hours: changeHours,
      minutes: changeMinutes,
      seconds: changeSeconds,
    );

    // Calculate moon phase (if available in testtags)
    final moonPhase = double.tryParse(variables['moonphase']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    
    return WeatherData(
      lastUpdatedTime: lastUpdatedTime,
      lastUpdatedDate: lastUpdatedDate,
      isNight: false,
      condition: 'Fair',
      iconName: _getIconName(false, 'Fair'),
      temperature: double.tryParse(variables['tempnodp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      tempNoDecimal: double.tryParse(variables['tempnodp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      humidity: humidity,
      dewPoint: double.tryParse(variables['dewpt']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxTemp: double.tryParse(variables['maxtemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxTempTime: variables['maxtemptime'] ?? '',
      minTemp: double.tryParse(variables['mintemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      minTempTime: variables['mintemptime'] ?? '',
      maxTempLastYear: double.tryParse(variables['maxtempyrago']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      minTempLastYear: double.tryParse(variables['mintempyrago']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxTempRecord: double.tryParse(variables['maxtemp4today']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      minTempRecord: double.tryParse(variables['mintemp4today']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxTempAverage: double.tryParse(variables['maxtempfordaytimeofyearfromyourdata']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      minTempAverage: double.tryParse(variables['mintempfordaytimeofyearfromyourdata']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      feelsLike: double.tryParse(variables['feelslike']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      heatIndex: double.tryParse(variables['heatindex']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      windChill: double.tryParse(variables['windchill']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      humidex: double.tryParse(variables['humidex']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      apparentTemp: double.tryParse(variables['apparenttemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      apparentSolarTemp: double.tryParse(variables['apparentsolartemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      tempChangeHour: double.tryParse(variables['tempchangehour']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      aqi: 0.0, // AQI will be set from Purple Air data
      windSpeed: double.tryParse(variables['avgspd']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      windGust: double.tryParse(variables['gstspd']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxGust: double.tryParse(variables['maxgst']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxGustTime: variables['maxgusttime'] ?? '',
      windDirection: variables['dirlabel'] ?? '',
      windDirectionDegrees: int.tryParse(variables['winddirectiondegrees']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      avgWind10Min: double.tryParse(variables['avgwind10min']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      monthlyHighWindGust: double.tryParse(variables['mrecordwindgust']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      beaufortScale: variables['beaufortscale'] ?? '',
      beaufortText: variables['beauforttext'] ?? '',
      pressure: pressure,
      pressureTrend: variables['pressuretrendname'] ?? '',
      pressureTrend3Hour: variables['pressuretrend3hour'] ?? '',
      forecastText: variables['forecasttext'] ?? '',
      dailyRain: double.tryParse(variables['dayrn']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      yesterdayRain: double.tryParse(variables['yesterdayrain']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      monthlyRain: double.tryParse(variables['monthrn']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      yearlyRain: double.tryParse(variables['yearrn']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      daysWithNoRain: int.tryParse(variables['dayswithnorain']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      daysWithRain: int.tryParse(variables['dayswithrain']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      currentRainRate: double.tryParse(variables['currentrainrate']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxRainRate: double.tryParse(variables['maxrainrate']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxRainRateTime: variables['maxrainratetime'] ?? '',
      solarRadiation: double.tryParse(variables['solarradiation']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      uvIndex: double.tryParse(variables['VPuv']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      highSolar: double.tryParse(variables['highsolar']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      highUV: double.tryParse(variables['highuv']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      highSolarTime: variables['highsolartime'] ?? '',
      highUVTime: variables['highuvtime'] ?? '',
      burnTime: int.tryParse(variables['burntime']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      snowSeason: double.tryParse(variables['snowseason']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      snowMonth: double.tryParse(variables['snowmonth']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      snowToday: double.tryParse(variables['snowtoday']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      snowYesterday: double.tryParse(variables['snowyesterday']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      snowHeight: double.tryParse(variables['snowheight']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      snowDepth: double.tryParse(variables['snowdepth']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      snowDaysThisMonth: int.tryParse(variables['snowdaysthismonth']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      snowDaysThisYear: int.tryParse(variables['snowdaysthisyear']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      advisories: [],
      maxTempYesterday: double.tryParse(variables['maxtempyest']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      minTempYesterday: double.tryParse(variables['mintempyest']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      forecast: [],
      alerts: [],
      sunrise: sunrise,
      sunset: sunset,
      daylightChange: daylightChange,
      possibleDaylight: possibleDaylight,
      moonrise: moonrise,
      moonset: moonset,
      moonPhase: moonPhase,
      moonPhaseName: moonPhaseName,
    );
  }

  DateTime _parseDateTime(String timeStr, DateTime referenceDate) {
    try {
      // Try to parse time in various formats
      final cleanTime = timeStr.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = cleanTime.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return DateTime(
          referenceDate.year,
          referenceDate.month,
          referenceDate.day,
          hour,
          minute,
        );
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }
    return referenceDate;
  }

  Future<void> testParsing() async {
    try {
      debugPrint('Testing testtags.php parsing...');
      final response = await http.get(
        Uri.parse(_testTagsUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );
      
      if (response.statusCode == 200) {
        debugPrint('Successfully fetched testtags.php data');
        debugPrint('Response headers: ${response.headers}');
        debugPrint('Response body length: ${response.bodyBytes.length}');
        
        // Convert bytes to string, replacing any invalid UTF-8 sequences
        final decodedBody = String.fromCharCodes(
          response.bodyBytes.where((byte) => byte < 128)
        );
        
        debugPrint('\nFirst 1000 characters of cleaned response:');
        debugPrint(decodedBody.substring(0, math.min(1000, decodedBody.length)));
        
        // Extract and show key variables we're interested in
        final lines = decodedBody.split('\n');
        debugPrint('\nKey variables found:');
        for (var line in lines) {
          line = line.trim();
          if (line.startsWith('\$') && (
              line.contains('temperature') ||
              line.contains('humidity') ||
              line.contains('avgspd') ||
              line.contains('dirlabel') ||
              line.contains('baro') ||
              line.contains('currentrainratehr')
          )) {
            debugPrint(line);
          }
        }
        
        try {
          final weatherData = _parseTestTags(decodedBody);
          debugPrint('\nParsing test completed successfully!');
        } catch (e) {
          debugPrint('Error parsing testtags data: $e');
          debugPrint('Error occurred at: ${e.toString()}');
        }
      } else {
        debugPrint('Failed to fetch testtags.php data. Status code: ${response.statusCode}');
        debugPrint('Response headers: ${response.headers}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error testing parsing: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  String _getIconName(bool isNight, String condition) {
    // Convert condition to lowercase for case-insensitive matching
    final lowerCondition = condition.toLowerCase();
    
    // Map NWS forecast text to icon names
    if (lowerCondition.contains('snow') || lowerCondition.contains('flurries')) {
      return isNight ? 'nsn' : 'sn';
    } else if (lowerCondition.contains('rain') && lowerCondition.contains('snow')) {
      return isNight ? 'nra_sn' : 'ra_sn';
    } else if (lowerCondition.contains('freezing rain') && lowerCondition.contains('snow')) {
      return isNight ? 'nfzra_sn' : 'fzra_sn';
    } else if (lowerCondition.contains('freezing rain')) {
      return isNight ? 'nfzra' : 'fzra';
    } else if (lowerCondition.contains('rain') && lowerCondition.contains('ice')) {
      return isNight ? 'nraip' : 'raip';
    } else if (lowerCondition.contains('ice')) {
      return isNight ? 'nip' : 'ip';
    } else if (lowerCondition.contains('rain')) {
      return isNight ? 'nra' : 'ra';
    } else if (lowerCondition.contains('showers')) {
      return isNight ? 'nshra' : 'shra';
    } else if (lowerCondition.contains('thunderstorm')) {
      return isNight ? 'ntsra' : 'tsra';
    } else if (lowerCondition.contains('overcast') || lowerCondition.contains('cloudy')) {
      return isNight ? 'novc' : 'ovc';
    } else if (lowerCondition.contains('broken')) {
      return isNight ? 'nbkn' : 'bkn';
    } else if (lowerCondition.contains('scattered') || lowerCondition.contains('partly')) {
      return isNight ? 'nsct' : 'sct';
    } else if (lowerCondition.contains('few') || lowerCondition.contains('fair') || lowerCondition.contains('mostly clear')) {
      return isNight ? 'nfew' : 'few';
    } else if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
      return isNight ? 'nskc' : 'skc';
    } else if (lowerCondition.contains('fog')) {
      return isNight ? 'nfg' : 'fg';
    } else if (lowerCondition.contains('haze')) {
      return 'hz';
    } else if (lowerCondition.contains('hot')) {
      return 'hot';
    } else if (lowerCondition.contains('cold')) {
      return isNight ? 'ncold' : 'cold';
    } else if (lowerCondition.contains('blizzard')) {
      return isNight ? 'nblizzard' : 'blizzard';
    }
    
    // Default to clear sky
    return isNight ? 'nskc' : 'skc';
  }
} 