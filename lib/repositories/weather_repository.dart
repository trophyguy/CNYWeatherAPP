import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../services/cache_service.dart';
import 'package:flutter/foundation.dart';

class WeatherRepository {
  final CacheService _cacheService;
  static const String _testTagsUrl = 'https://cnyweather.com/testtags.php?sce=view';
  static const String _clientRawUrl = 'https://cnyweather.com/clientraw.txt';

  WeatherRepository(this._cacheService);

  Future<WeatherData> getWeatherData() async {
    try {
      // First try to get the testtags data
      final response = await http.get(
        Uri.parse(_testTagsUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );
      
      if (response.statusCode == 200) {
        // Convert bytes to string, replacing any invalid UTF-8 sequences
        final cleanedBody = String.fromCharCodes(
          response.bodyBytes.where((byte) => byte < 128)
        );
        
        // Debug: Print the first few lines of raw data
        debugPrint('\nFirst few lines of raw data:');
        final firstFewLines = cleanedBody.split('\n').take(10).join('\n');
        debugPrint(firstFewLines);
        
        final data = _parseTestTags(cleanedBody);
        await _cacheService.cacheWeatherData(data);
        return data;
      }
      throw Exception('Failed to fetch testtags data');
    } catch (e) {
      // If testtags fails, try to get cached data
      final cachedData = _cacheService.getCachedWeatherData();
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Failed to fetch weather data and no cached data available');
    }
  }

  Future<Map<String, dynamic>> getQuickUpdate() async {
    try {
      final response = await http.get(Uri.parse(_clientRawUrl));
      if (response.statusCode == 200) {
        return _parseClientRaw(response.body);
      }
      throw Exception('Failed to fetch quick update data');
    } catch (e) {
      throw Exception('Failed to fetch quick update data: $e');
    }
  }

  WeatherData _parseTestTags(String data) {
    final Map<String, String> variables = {};
    final lines = data.split('\n');
    
    // Define the variables we're interested in
    final keyVariables = {
      'temperature', 'tempnodp', 'humidity', 'dewpt',
      'maxtemp', 'maxtempt', 'mintemp', 'mintempt',
      'feelslike', 'heati', 'windch', 'humidexfaren',
      'apparenttemp', 'apparentsolartemp',
      'avgspd', 'gstspd', 'maxgst', 'maxgstt',
      'dirdeg', 'dirlabel', 'avwindlastimediate10',
      'beaufortnum', 'bftspeedtext',
      'baro', 'pressuretrendname', 'pressuretrendname3hour',
      'vpforecasttext',
      'dayrn', 'monthrn', 'yearrn',
      'currentrainratehr', 'maxrainrate', 'maxrainratetime',
      'VPsolar', 'VPuv', 'highsolar', 'highuv',
      'highsolartime', 'highuvtime', 'burntime',
      'snowseasonin', 'snowmonthin', 'snowtodayin',
      'snowyesterday', 'snowheight', 'snownowin',
      'snowdaysthismonth', 'snowdaysthisyear',
      'dayswithnorain', 'dayswithrain',
      'time', 'date'
    };
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || !line.startsWith('\$')) continue;
      
      // Remove comments and clean up the line
      line = line.replaceAll(RegExp(r'//.*$'), '')
                .replaceAll(RegExp(r'/\*.*?\*/'), '')
                .replaceAll(RegExp(r'#.*$'), '')
                .trim();
      
      final parts = line.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim().substring(1);
        if (keyVariables.contains(key)) {
          var value = parts[1].trim();
          // Handle quotes and semicolon
          if (value.startsWith('\'') || value.startsWith('"')) {
            value = value.substring(1);
          }
          if (value.endsWith('\'') || value.endsWith('"')) {
            value = value.substring(0, value.length - 1);
          }
          value = value.replaceAll(';', '').trim();
          
          if (value.isNotEmpty) {
            variables[key] = value;
          }
        }
      }
    }

    // Log key parsed values for verification
    debugPrint('\nKey parsed values:');
    debugPrint('Temperature: ${variables['temperature']}');
    debugPrint('TempNoDP raw value: "${variables['tempnodp']}"');
    debugPrint('Feels Like raw value: "${variables['feelslike']}"');
    debugPrint('Time raw value: "${variables['time']}"');
    debugPrint('Date raw value: "${variables['date']}"');
    debugPrint('Humidity: ${variables['humidity']}');
    debugPrint('Wind Speed: ${variables['avgspd']}');
    debugPrint('Wind Direction: ${variables['dirlabel']}');
    debugPrint('Pressure: ${variables['baro']}');
    debugPrint('Rain Rate: ${variables['currentrainratehr']}');

    // Convert the parsed variables into WeatherData
    final rawTempNoDp = variables['tempnodp'] ?? '0';
    debugPrint('Raw tempnodp from variables: "$rawTempNoDp"');
    final cleanedTempNoDp = rawTempNoDp.replaceAll(RegExp(r'[^\d.-]'), '');
    debugPrint('Cleaned tempnodp value: "$cleanedTempNoDp"');
    final tempNoDp = int.tryParse(cleanedTempNoDp)?.toDouble() ?? 0.0;
    debugPrint('Final parsed tempNoDp value: $tempNoDp');

    final rawFeelsLike = variables['feelslike'] ?? '0';
    final cleanedFeelsLike = rawFeelsLike.replaceAll(RegExp(r'[^\d.-]'), '');
    debugPrint('Cleaned feelslike value: "$cleanedFeelsLike"');
    final feelsLike = double.tryParse(cleanedFeelsLike) ?? 0.0;
    debugPrint('Creating WeatherData with feelsLike: $feelsLike');

    final rawTime = variables['time'] ?? '';
    final cleanedTime = rawTime.replaceAll("'", "").replaceAll('"', '').trim();
    final rawDate = variables['date'] ?? '';
    final cleanedDate = rawDate.replaceAll("'", "").replaceAll('"', '').trim();
    debugPrint('Cleaned time value: "$cleanedTime"');
    debugPrint('Cleaned date value: "$cleanedDate"');

    final weatherData = WeatherData(
      // Time/Date
      lastUpdatedTime: cleanedTime,
      lastUpdatedDate: cleanedDate,
      // Temperature/Humidity
      temperature: double.tryParse(variables['temperature']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      tempNoDecimal: tempNoDp,
      humidity: double.tryParse(variables['humidity']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      dewPoint: double.tryParse(variables['dewpt']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxTemp: double.tryParse(variables['maxtemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      maxTempTime: variables['maxtempt'] ?? '',
      minTemp: double.tryParse(variables['mintemp']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
      minTempTime: variables['mintempt'] ?? '',
      feelsLike: feelsLike,
      heatIndex: double.tryParse(variables['heati'] ?? '0') ?? 0.0,
      windChill: double.tryParse(variables['windch'] ?? '0') ?? 0.0,
      humidex: double.tryParse(variables['humidexfaren'] ?? '0') ?? 0.0,
      apparentTemp: double.tryParse(variables['apparenttemp'] ?? '0') ?? 0.0,
      apparentSolarTemp: double.tryParse(variables['apparentsolartemp'] ?? '0') ?? 0.0,

      // Wind
      windSpeed: double.tryParse(variables['avgspd'] ?? '0') ?? 0.0,
      windGust: double.tryParse(variables['gstspd'] ?? '0') ?? 0.0,
      maxGust: double.tryParse(variables['maxgst'] ?? '0') ?? 0.0,
      maxGustTime: variables['maxgstt'] ?? '',
      windDirection: variables['dirlabel'] ?? '',
      windDirectionDegrees: int.tryParse(variables['dirdeg'] ?? '0') ?? 0,
      avgWind10Min: double.tryParse(variables['avwindlastimediate10'] ?? '0') ?? 0.0,
      beaufortScale: variables['beaufortnum'] ?? '',
      beaufortText: variables['bftspeedtext'] ?? '',

      // Barometer
      pressure: double.tryParse(variables['baro'] ?? '0') ?? 0.0,
      pressureTrend: variables['pressuretrendname'] ?? '',
      pressureTrend3Hour: variables['pressuretrendname3hour'] ?? '',
      forecastText: variables['vpforecasttext'] ?? '',

      // Rain
      dailyRain: double.tryParse(variables['dayrn'] ?? '0') ?? 0.0,
      monthlyRain: double.tryParse(variables['monthrn'] ?? '0') ?? 0.0,
      yearlyRain: double.tryParse(variables['yearrn'] ?? '0') ?? 0.0,
      daysWithNoRain: int.tryParse(variables['dayswithnorain'] ?? '0') ?? 0,
      daysWithRain: int.tryParse(variables['dayswithrain'] ?? '0') ?? 0,
      currentRainRate: double.tryParse(variables['currentrainratehr'] ?? '0') ?? 0.0,
      maxRainRate: double.tryParse(variables['maxrainrate'] ?? '0') ?? 0.0,
      maxRainRateTime: variables['maxrainratetime'] ?? '',

      // Solar/UV
      solarRadiation: double.tryParse(variables['VPsolar'] ?? '0') ?? 0.0,
      uvIndex: double.tryParse(variables['VPuv'] ?? '0') ?? 0.0,
      highSolar: double.tryParse(variables['highsolar'] ?? '0') ?? 0.0,
      highUV: double.tryParse(variables['highuv'] ?? '0') ?? 0.0,
      highSolarTime: variables['highsolartime'] ?? '',
      highUVTime: variables['highuvtime'] ?? '',
      burnTime: int.tryParse(variables['burntime'] ?? '0') ?? 0,

      // Snow
      snowSeason: double.tryParse(variables['snowseasonin'] ?? '0') ?? 0.0,
      snowMonth: double.tryParse(variables['snowmonthin'] ?? '0') ?? 0.0,
      snowToday: double.tryParse(variables['snowtodayin'] ?? '0') ?? 0.0,
      snowYesterday: double.tryParse(variables['snowyesterday'] ?? '0') ?? 0.0,
      snowHeight: double.tryParse(variables['snowheight'] ?? '0') ?? 0.0,
      snowDepth: double.tryParse(variables['snownowin'] ?? '0') ?? 0.0,
      snowDaysThisMonth: int.tryParse(variables['snowdaysthismonth'] ?? '0') ?? 0,
      snowDaysThisYear: int.tryParse(variables['snowdaysthisyear'] ?? '0') ?? 0,

      advisories: [], // Advisories will be handled separately
    );

    return weatherData;
  }

  Map<String, dynamic> _parseClientRaw(String data) {
    // TODO: Implement clientraw.txt parsing logic
    // This will parse the quick update data into a map of values
    final Map<String, dynamic> values = {};
    final parts = data.split(' ');
    
    // Map the parts to their corresponding values
    // This mapping will need to be adjusted based on the actual clientraw.txt format
    if (parts.length >= 10) {
      values['temperature'] = double.tryParse(parts[4]) ?? 0.0;
      values['humidity'] = double.tryParse(parts[5]) ?? 0.0;
      values['windSpeed'] = double.tryParse(parts[1]) ?? 0.0;
      values['windDirection'] = parts[2];
      values['pressure'] = double.tryParse(parts[6]) ?? 0.0;
      values['rainfall'] = double.tryParse(parts[7]) ?? 0.0;
    }
    
    return values;
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
} 