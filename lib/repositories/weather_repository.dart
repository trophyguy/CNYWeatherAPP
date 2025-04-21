import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../services/cache_service.dart';
import '../services/openweather_service.dart';
import 'package:flutter/foundation.dart';

class WeatherRepository {
  final CacheService _cacheService;
  final OpenWeatherService _openWeatherService;
  static const String _testTagsUrl = 'https://cnyweather.com/testtags.php?sce=view';
  // static const String _clientRawUrl = 'https://cnyweather.com/clientraw.txt';
  static const double _stationLat = 43.2105; // Rome, NY latitude
  static const double _stationLon = -75.4557; // Rome, NY longitude
  static const String _baseUrl = 'https://cnyweather.com/testtags.php?sce=view';

  WeatherRepository(this._cacheService, this._openWeatherService);

  Future<WeatherData> getWeatherData() async {
    try {
      // Try to get cached data first
      final cachedData = await _cacheService.getCachedWeatherData();
      if (cachedData != null) {
        return WeatherData.fromJson(cachedData);
      }

      // If no cached data or cache is stale, fetch fresh data
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );
      if (response.statusCode == 200) {
        // Convert bytes to string, replacing any invalid UTF-8 sequences
        final cleanedBody = String.fromCharCodes(
          response.bodyBytes.where((byte) => byte < 128)
        );
        
        // Get AQI data from OpenWeatherMap
        double aqiValue = 0.0;
        try {
          final aqiData = await _openWeatherService.getAirQuality(_stationLat, _stationLon);
          debugPrint('AQI Data: $aqiData');
          aqiValue = aqiData['aqi']?.toDouble() ?? 0.0;
          debugPrint('AQI Value: $aqiValue');
        } catch (e) {
          debugPrint('Warning: Failed to fetch AQI data: $e');
          // Continue with default AQI value
        }
        
        final data = _parseTestTags(cleanedBody, aqiValue);
        await _cacheService.cacheWeatherData(data.toJson());
        return data;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  // TODO: Implement quick update functionality
  Future<Map<String, dynamic>> getQuickUpdate() async {
    // Temporarily return empty map until clientraw.txt implementation is complete
    return {
      'temperature': 0.0,
      'humidity': 0.0,
      'windSpeed': 0.0,
      'windDirection': '',
      'pressure': 0.0,
    };
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

  WeatherData _parseTestTags(String html, double aqiValue) {
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
    
    // Debug: Print all variables
    debugPrint('\nAll variables found:');
    variables.forEach((key, value) {
      debugPrint('$key = $value');
    });
    
    // Debug: Print pressure and dew point values
    debugPrint('\nPressure and Dew Point values:');
    debugPrint('Raw barometer value: ${variables['barometer']}');
    debugPrint('Raw dewpoint value: ${variables['dewpt']}');
    
    // Debug: Print temperature-related variables
    debugPrint('\nTemperature-related variables:');
    variables.forEach((key, value) {
      if (key.toLowerCase().contains('temp') || 
          key.toLowerCase().contains('lastyear') || 
          key.toLowerCase().contains('record') || 
          key.toLowerCase().contains('average')) {
        debugPrint('$key = $value');
      }
    });
    
    // Debug: Print the first few lines of raw data
    debugPrint('\nFirst few lines of raw data:');
    final firstFewLines = html.split('\n').take(50).join('\n');
    debugPrint(firstFewLines);
    
    debugPrint('Parsed values from test tags:');
    debugPrint('Raw tempnodp value: ${variables['tempnodp']}');
    
    // Clean and convert temperature values
    final tempnodp = double.tryParse(variables['tempnodp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final feelsLike = double.tryParse(variables['feelslike']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final maxTemp = double.tryParse(variables['maxtemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final minTemp = double.tryParse(variables['mintemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final maxTempYesterday = double.tryParse(variables['maxtempyest']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final minTempYesterday = double.tryParse(variables['mintempyest']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final maxTempLastYear = double.tryParse(variables['maxtempyrago']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final minTempLastYear = double.tryParse(variables['mintempyrago']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final maxTempRecord = double.tryParse(variables['maxtemp4today']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final minTempRecord = double.tryParse(variables['mintemp4today']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final maxTempAverage = double.tryParse(variables['maxtempfordaytimeofyearfromyourdata']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    final minTempAverage = double.tryParse(variables['mintempfordaytimeofyearfromyourdata']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;
    
    // Debug prints for all temperature values
    debugPrint('\nDebug - Temperature Values:');
    debugPrint('Last Year:');
    debugPrint('  Raw maxtempyrago: ${variables['maxtempyrago']}');
    debugPrint('  Raw mintempyrago: ${variables['mintempyrago']}');
    debugPrint('  Parsed maxTempLastYear: $maxTempLastYear');
    debugPrint('  Parsed minTempLastYear: $minTempLastYear');
    
    debugPrint('\nRecord:');
    debugPrint('  Raw maxtemp4today: ${variables['maxtemp4today']}');
    debugPrint('  Raw mintemp4today: ${variables['mintemp4today']}');
    debugPrint('  Parsed maxTempRecord: $maxTempRecord');
    debugPrint('  Parsed minTempRecord: $minTempRecord');
    
    debugPrint('\nAverage:');
    debugPrint('  Raw maxtempfordaytimeofyearfromyourdata: ${variables['maxtempfordaytimeofyearfromyourdata']}');
    debugPrint('  Raw mintempfordaytimeofyearfromyourdata: ${variables['mintempfordaytimeofyearfromyourdata']}');
    debugPrint('  Parsed maxTempAverage: $maxTempAverage');
    debugPrint('  Parsed minTempAverage: $minTempAverage');

    debugPrint('\n=== Temperature Values ===');
    debugPrint('Current Temperature: $tempnodp°F');
    debugPrint('Feels Like: $feelsLike°F');
    debugPrint('\nToday:');
    debugPrint('  High: $maxTemp°F');
    debugPrint('  Low: $minTemp°F');
    debugPrint('\nYesterday:');
    debugPrint('  High: $maxTempYesterday°F');
    debugPrint('  Low: $minTempYesterday°F');
    debugPrint('\nLast Year:');
    debugPrint('  High: $maxTempLastYear°F');
    debugPrint('  Low: $minTempLastYear°F');
    debugPrint('\nRecords:');
    debugPrint('  High: $maxTempRecord°F');
    debugPrint('  Low: $minTempRecord°F');
    debugPrint('\nAverages:');
    debugPrint('  High: $maxTempAverage°F');
    debugPrint('  Low: $minTempAverage°F');
    debugPrint('========================\n');

    // Debug prints for last year temperatures
    debugPrint('\nDebug - Last Year Temperatures:');
    debugPrint('Raw maxtempyrago: ${variables['maxtempyrago']}');
    debugPrint('Raw mintempyrago: ${variables['mintempyrago']}');
    debugPrint('Parsed maxTempLastYear: $maxTempLastYear');
    debugPrint('Parsed minTempLastYear: $minTempLastYear');

    final double uvIndex = double.tryParse(variables['uvindex']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0;

    return WeatherData(
      lastUpdatedTime: variables['time'] ?? '',
      lastUpdatedDate: variables['date'] ?? '',
      temperature: tempnodp,
      tempNoDecimal: tempnodp,
      humidity: double.tryParse(variables['humidity']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      dewPoint: double.tryParse(variables['dewpt']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxTemp: maxTemp,
      maxTempTime: variables['maxtemptime'] ?? '',
      minTemp: minTemp,
      minTempTime: variables['mintemptime'] ?? '',
      maxTempLastYear: maxTempLastYear,
      minTempLastYear: minTempLastYear,
      maxTempRecord: maxTempRecord,
      minTempRecord: minTempRecord,
      maxTempAverage: maxTempAverage,
      minTempAverage: minTempAverage,
      feelsLike: feelsLike,
      heatIndex: double.tryParse(variables['heatindex']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      windChill: double.tryParse(variables['windchill']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      humidex: double.tryParse(variables['humidex']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      apparentTemp: double.tryParse(variables['apparenttemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      apparentSolarTemp: double.tryParse(variables['apparentsolartemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      tempChangeHour: double.tryParse(variables['tempchangehour']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      aqi: aqiValue,
      windSpeed: double.tryParse(variables['windspeed']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      windGust: double.tryParse(variables['windgust']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxGust: double.tryParse(variables['maxgust']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxGustTime: variables['maxgusttime'] ?? '',
      windDirection: variables['winddirection'] ?? '',
      windDirectionDegrees: int.tryParse(variables['winddirectiondegrees']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      avgWind10Min: double.tryParse(variables['avgwind10min']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      beaufortScale: variables['beaufortscale'] ?? '',
      beaufortText: variables['beauforttext'] ?? '',
      pressure: double.tryParse(variables['baro']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      pressureTrend: variables['pressuretrendname'] ?? '',
      pressureTrend3Hour: variables['pressuretrend3hour'] ?? '',
      forecastText: variables['forecasttext'] ?? '',
      dailyRain: double.tryParse(variables['dailyrain']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      monthlyRain: double.tryParse(variables['monthlyrain']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      yearlyRain: double.tryParse(variables['yearlyrain']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      daysWithNoRain: int.tryParse(variables['dayswithnorain']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      daysWithRain: int.tryParse(variables['dayswithrain']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0,
      currentRainRate: double.tryParse(variables['currentrainrate']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxRainRate: double.tryParse(variables['maxrainrate']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxRainRateTime: variables['maxrainratetime'] ?? '',
      solarRadiation: double.tryParse(variables['solarradiation']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      uvIndex: uvIndex,
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
      maxTempYesterday: maxTempYesterday,
      minTempYesterday: minTempYesterday,
    );
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
        debugPrint(decodedBody.substring(0, min(1000, decodedBody.length)));
        
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
          final weatherData = _parseTestTags(decodedBody, 0.0);
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
} 