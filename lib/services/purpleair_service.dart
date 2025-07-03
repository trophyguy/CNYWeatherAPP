import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PurpleAirService {
  final String _apiKey;
  final String _sensorId;
  static const String _baseUrl = 'https://api.purpleair.com/v1/sensors';
  static const String _lastUpdateKey = 'purpleair_last_update';
  static const Duration _cacheDuration = Duration(hours: 1);
  late SharedPreferences _prefs;

  PurpleAirService(this._apiKey, this._sensorId) {
    developer.log('Initializing PurpleAirService with sensor ID: $_sensorId', name: 'PurpleAirService');
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      developer.log('SharedPreferences initialized successfully', name: 'PurpleAirService');
      // Try to fetch initial data
      await getAirQuality();
    } catch (e) {
      developer.log('Error initializing SharedPreferences: $e', name: 'PurpleAirService');
      // Don't rethrow, as this is initialization
    }
  }

  Future<Map<String, dynamic>> getAirQuality() async {
    try {
      developer.log('Starting getAirQuality()', name: 'PurpleAirService');
      
      // Check if we have valid API key and sensor ID
      if (_apiKey.isEmpty || _sensorId.isEmpty) {
        developer.log('API key or sensor ID is empty', name: 'PurpleAirService');
        return _getUnavailableResponse();
      }

      // Try to get cached data first
      final cachedData = await _getCachedData();
      if (cachedData != null) {
        developer.log('Using cached AQI data: ${cachedData['aqi']}', name: 'PurpleAirService');
        return cachedData;
      }

      developer.log('No valid cache, fetching fresh data...', name: 'PurpleAirService');
      developer.log('API Key: ${_apiKey.substring(0, 4)}...', name: 'PurpleAirService');
      developer.log('Sensor ID: $_sensorId', name: 'PurpleAirService');

      final url = 'https://api.purpleair.com/v1/sensors/$_sensorId?api_key=$_apiKey';
      developer.log('Making API request to: $url', name: 'PurpleAirService');

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          developer.log('API request timed out', name: 'PurpleAirService');
          throw TimeoutException('Request timed out');
        },
      );

      developer.log('API Response Status: ${response.statusCode}', name: 'PurpleAirService');
      developer.log('API Response Body: ${response.body}', name: 'PurpleAirService');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['sensor'] == null) {
          developer.log('No sensor data in response', name: 'PurpleAirService');
          return _getUnavailableResponse();
        }

        // Get PM2.5 from the 10-minute average in stats
        final pm25 = data['sensor']['stats']?['pm2.5_10minute']?.toDouble() ?? 0.0;
        developer.log('Raw PM2.5 value (10min avg): $pm25', name: 'PurpleAirService');

        if (pm25 <= 0) {
          developer.log('Invalid PM2.5 value: $pm25', name: 'PurpleAirService');
          return _getUnavailableResponse();
        }

        final aqi = _calculateAQI(pm25);
        developer.log('Calculated AQI: $aqi', name: 'PurpleAirService');

        final result = {
          'aqi': aqi,
          'aqiDescription': _getAQIDescription(aqi),
          'pm25': pm25,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Cache the result
        await _cacheData(result);
        developer.log('Cached new AQI data', name: 'PurpleAirService');

        return result;
      } else {
        developer.log('API request failed with status: ${response.statusCode}', name: 'PurpleAirService');
        return _getUnavailableResponse();
      }
    } catch (e) {
      developer.log('Error in getAirQuality(): $e', name: 'PurpleAirService');
      return _getUnavailableResponse();
    }
  }

  Future<Map<String, dynamic>?> _getCachedData() async {
    try {
      final lastUpdateStr = _prefs.getString(_lastUpdateKey);
      if (lastUpdateStr == null) return null;

      final lastUpdate = DateTime.parse(lastUpdateStr);
      if (DateTime.now().difference(lastUpdate) > _cacheDuration) {
        return null;
      }

      final cachedData = _prefs.getString('purpleair_data');
      if (cachedData == null) return null;

      return json.decode(cachedData) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error getting cached PurpleAir data: $e', name: 'PurpleAirService');
      return null;
    }
  }

  Future<void> _cacheData(Map<String, dynamic> data) async {
    try {
      await _prefs.setString('purpleair_data', json.encode(data));
      await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      developer.log('Error caching PurpleAir data: $e', name: 'PurpleAirService');
    }
  }

  double _calculateAQI(double pm25) {
    // EPA's NowCast algorithm for PM2.5
    if (pm25 <= 0) {
      developer.log('PM2.5 value is 0 or negative, returning 0 AQI', name: 'PurpleAirService');
      return 0;
    }
    
    double aqi;
    // EPA's AQI breakpoints for PM2.5
    if (pm25 <= 12.0) {
      aqi = _linearScale(pm25, 0, 12.0, 0, 50);
    } else if (pm25 <= 35.4) {
      aqi = _linearScale(pm25, 12.1, 35.4, 51, 100);
    } else if (pm25 <= 55.4) {
      aqi = _linearScale(pm25, 35.5, 55.4, 101, 150);
    } else if (pm25 <= 150.4) {
      aqi = _linearScale(pm25, 55.5, 150.4, 151, 200);
    } else if (pm25 <= 250.4) {
      aqi = _linearScale(pm25, 150.5, 250.4, 201, 300);
    } else if (pm25 <= 350.4) {
      aqi = _linearScale(pm25, 250.5, 350.4, 301, 400);
    } else if (pm25 <= 500.4) {
      aqi = _linearScale(pm25, 350.5, 500.4, 401, 500);
    } else {
      aqi = 500;
    }
    
    developer.log('Calculated AQI for PM2.5 $pm25: $aqi', name: 'PurpleAirService');
    return aqi;
  }

  double _linearScale(double value, double inMin, double inMax, double outMin, double outMax) {
    return ((value - inMin) * (outMax - outMin) / (inMax - inMin)) + outMin;
  }

  String _getAQIDescription(double aqi) {
    developer.log('Getting AQI description for value: $aqi', name: 'PurpleAirService');
    if (aqi <= 50) {
      developer.log('AQI $aqi is Good', name: 'PurpleAirService');
      return 'Good';
    }
    if (aqi <= 100) {
      developer.log('AQI $aqi is Moderate', name: 'PurpleAirService');
      return 'Moderate';
    }
    if (aqi <= 150) {
      developer.log('AQI $aqi is Unhealthy for Sensitive Groups', name: 'PurpleAirService');
      return 'Unhealthy for Sensitive Groups';
    }
    if (aqi <= 200) {
      developer.log('AQI $aqi is Unhealthy', name: 'PurpleAirService');
      return 'Unhealthy';
    }
    if (aqi <= 300) {
      developer.log('AQI $aqi is Very Unhealthy', name: 'PurpleAirService');
      return 'Very Unhealthy';
    }
    if (aqi <= 500) {
      developer.log('AQI $aqi is Hazardous', name: 'PurpleAirService');
      return 'Hazardous';
    }
    developer.log('AQI $aqi is Hazardous (above 500)', name: 'PurpleAirService');
    return 'Hazardous';
  }

  Map<String, dynamic> _getUnavailableResponse() {
    return {
      'aqi': 0.0,
      'aqiDescription': 'Unavailable',
      'pm25': 0.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
} 