import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/weather_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer' as developer;

class CacheService {
  late SharedPreferences _prefs;
  static const String _weatherDataKey = 'weather_data';
  static const String _lastUpdateKey = 'last_update';
  static const String _aqiDataKey = 'aqi_data';
  static const String _aqiLastUpdateKey = 'aqi_last_update';
  static const String _forecastDataKey = 'forecast_data';
  static const String _forecastLastUpdateKey = 'forecast_last_update';
  static const String _alertsDataKey = 'alerts_data';
  static const String _alertsLastUpdateKey = 'alerts_last_update';
  static const String _testTagsDataKey = 'testtags_data';
  static const Duration _cacheDuration = Duration(minutes: 15);
  static const Duration _aqiCacheDuration = Duration(minutes: 30);
  static const Duration _forecastCacheDuration = Duration(hours: 6);
  static const Duration _alertsCacheDuration = Duration(minutes: 15);

  CacheService();

  Future<void> init() async {
    developer.log('=== WEATHER_PERF: CacheService init called ===', name: 'CacheService');
    try {
      _prefs = await SharedPreferences.getInstance();
      developer.log('=== WEATHER_PERF: SharedPreferences initialized ===', name: 'CacheService');
      await populateWithDefaultIfEmpty();
    } catch (e) {
      developer.log('Error initializing CacheService: $e', name: 'CacheService');
      rethrow;
    }
  }

  Future<void> populateWithDefaultIfEmpty() async {
    developer.log('=== WEATHER_PERF: populateWithDefaultIfEmpty called ===', name: 'CacheService');
    try {
      // Check if we already have cached data
      final cachedData = await getWeatherData();
      if (cachedData != null) {
        developer.log('=== WEATHER_PERF: Found data in cache ===', name: 'CacheService');
        return;
      }

      developer.log('=== WEATHER_PERF: No cached testtags data found ===', name: 'CacheService');
      
      // Load default testtags data from assets
      final defaultData = await rootBundle.loadString('assets/default_testtags.txt');
      if (defaultData.isNotEmpty) {
        developer.log('=== WEATHER_PERF: Loading default testtags data ===', name: 'CacheService');
        await saveWeatherData(defaultData);
        
        // Verify the data was saved
        final savedData = await getWeatherData();
        if (savedData != null) {
          developer.log('=== WEATHER_PERF: Successfully saved default data ===', name: 'CacheService');
        } else {
          developer.log('=== WEATHER_PERF: Failed to save default data ===', name: 'CacheService');
        }
      } else {
        developer.log('=== WEATHER_PERF: Default testtags data is empty ===', name: 'CacheService');
      }
    } catch (e) {
      developer.log('Error populating cache: $e', name: 'CacheService');
    }
  }

  Future<void> saveWeatherData(String data) async {
    try {
      await _prefs.setString(_weatherDataKey, data);
      await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      developer.log('=== WEATHER_PERF: Saved weather data to cache ===', name: 'CacheService');
    } catch (e) {
      developer.log('Error saving weather data: $e', name: 'CacheService');
    }
  }

  Future<String?> getWeatherData() async {
    try {
      final data = _prefs.getString(_weatherDataKey);
      if (data != null) {
        developer.log('=== WEATHER_PERF: Found data in cache ===', name: 'CacheService');
      }
      return data;
    } catch (e) {
      developer.log('Error getting cached weather data: $e', name: 'CacheService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCachedWeatherData() async {
    try {
      final data = _prefs.getString(_weatherDataKey);
      if (data == null) return null;
      return json.decode(data);
    } catch (e) {
      developer.log('Error getting cached weather data: $e', name: 'CacheService');
      return null;
    }
  }

  Future<void> cacheForecastData(List<dynamic> forecastData) async {
    try {
      await _prefs.setString(_forecastDataKey, json.encode(forecastData));
      await _prefs.setString(_forecastLastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      developer.log('Error caching forecast data: $e', name: 'CacheService');
    }
  }

  Future<List<dynamic>?> getCachedForecastData() async {
    try {
      final data = _prefs.getString(_forecastDataKey);
      return data != null ? json.decode(data) : null;
    } catch (e) {
      developer.log('Error getting cached forecast data: $e', name: 'CacheService');
      return null;
    }
  }

  Future<void> cacheAQIData(Map<String, dynamic> aqiData) async {
    try {
      await _prefs.setString(_aqiDataKey, json.encode(aqiData));
      await _prefs.setString(_aqiLastUpdateKey, DateTime.now().toIso8601String());
      developer.log('=== WEATHER_PERF: Saved AQI data to cache ===', name: 'CacheService');
    } catch (e) {
      developer.log('Error saving AQI data: $e', name: 'CacheService');
    }
  }

  Future<Map<String, dynamic>?> getCachedAQIData() async {
    try {
      final lastUpdate = _prefs.getString(_aqiLastUpdateKey);
      if (lastUpdate == null) return null;

      final lastUpdateTime = DateTime.parse(lastUpdate);
      if (DateTime.now().difference(lastUpdateTime) > _aqiCacheDuration) {
        return null;
      }

      final cachedData = _prefs.getString(_aqiDataKey);
      if (cachedData == null) return null;

      return json.decode(cachedData) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error getting cached AQI data: $e', name: 'CacheService');
      return null;
    }
  }

  bool isAQICacheStale() {
    final lastUpdate = _prefs.getString(_aqiLastUpdateKey);
    if (lastUpdate == null) return true;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    return DateTime.now().difference(lastUpdateTime) > _aqiCacheDuration;
  }

  Future<void> clearCache() async {
    try {
      await _prefs.remove(_weatherDataKey);
      await _prefs.remove(_forecastDataKey);
      await _prefs.remove(_aqiDataKey);
      await _prefs.remove(_testTagsDataKey);
    } catch (e) {
      developer.log('Error clearing cache: $e', name: 'CacheService');
    }
  }

  DateTime? getLastUpdateTime() {
    final String? timeStr = _prefs.getString(_lastUpdateKey);
    if (timeStr == null) return null;
    
    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      developer.log('Error parsing last update time: $e', name: 'CacheService');
      return null;
    }
  }

  bool isCacheStale() {
    final lastUpdate = getLastUpdateTime();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference > _cacheDuration;
  }

  Future<List<WeatherAlert>?> getCachedAlerts() async {
    if (!_prefs.containsKey(_alertsLastUpdateKey)) {
      await init();
    }
    final lastUpdate = _prefs.getString(_alertsLastUpdateKey);
    if (lastUpdate == null) return null;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    if (DateTime.now().difference(lastUpdateTime) > _alertsCacheDuration) {
      return null;
    }

    final cachedData = _prefs.getString(_alertsDataKey);
    if (cachedData == null) return null;

    try {
      final List<dynamic> alertsJson = json.decode(cachedData);
      return alertsJson.map((json) => WeatherAlert.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error parsing cached alerts: $e', name: 'CacheService');
      return null;
    }
  }

  Future<void> cacheAlerts(List<WeatherAlert> alerts) async {
    if (!_prefs.containsKey(_alertsLastUpdateKey)) {
      await init();
    }
    final alertsJson = alerts.map((alert) => {
      'id': alert.id,
      'event': alert.event,
      'severity': alert.severity,
      'urgency': alert.urgency,
      'certainty': alert.certainty,
      'areaDesc': alert.area,
      'description': alert.description,
      'effective': alert.effective,
      'expires': alert.expires,
      'instruction': alert.instruction,
      'status': alert.status,
      'scope': alert.scope,
      'messageType': alert.msgType,
      'sent': alert.issued,
      'backgroundColor': alert.backgroundColor,
      'textColor': alert.textColor,
    }).toList();
    
    await _prefs.setString(_alertsDataKey, json.encode(alertsJson));
    await _prefs.setString(_alertsLastUpdateKey, DateTime.now().toIso8601String());
  }
} 