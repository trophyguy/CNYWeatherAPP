import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';

class CacheService {
  late SharedPreferences _prefs;
  static const String _weatherDataKey = 'weather_data';
  static const String _lastUpdateKey = 'last_update';
  static const Duration _cacheDuration = Duration(minutes: 5);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> cacheWeatherData(Map<String, dynamic> data) async {
    if (!_prefs.containsKey(_lastUpdateKey)) {
      await init();
    }
    await _prefs.setString(_weatherDataKey, data.toString());
    await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>?> getCachedWeatherData() async {
    if (!_prefs.containsKey(_lastUpdateKey)) {
      await init();
    }
    final lastUpdate = _prefs.getString(_lastUpdateKey);
    if (lastUpdate == null) return null;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    if (DateTime.now().difference(lastUpdateTime) > _cacheDuration) {
      return null;
    }

    final cachedData = _prefs.getString(_weatherDataKey);
    if (cachedData == null) return null;

    try {
      // Parse the cached data string back into a Map
      return Map<String, dynamic>.from(eval(cachedData));
    } catch (e) {
      return null;
    }
  }

  // Helper function to safely evaluate the cached data string
  dynamic eval(String str) {
    return str
        .replaceAll('{', '{"')
        .replaceAll(': ', '": "')
        .replaceAll(', ', '", "')
        .replaceAll('}', '"}');
  }

  DateTime? getLastUpdateTime() {
    final String? timeStr = _prefs.getString(_lastUpdateKey);
    if (timeStr == null) return null;
    
    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      print('Error parsing last update time: $e');
      return null;
    }
  }

  bool isCacheStale() {
    final lastUpdate = getLastUpdateTime();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inMinutes > 5;
  }

  Future<void> saveWeatherData(String data) async {
    await _prefs.setString('weather_data', data);
  }

  Future<String?> getWeatherData() async {
    return _prefs.getString('weather_data');
  }
} 