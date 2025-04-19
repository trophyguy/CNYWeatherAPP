import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';

class CacheService {
  static const String _weatherKey = 'cached_weather_data';
  static const String _lastUpdateKey = 'last_update_time';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> cacheWeatherData(WeatherData data) async {
    await _prefs.setString(_weatherKey, jsonEncode(data.toJson()));
    await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  WeatherData? getCachedWeatherData() {
    final String? cachedData = _prefs.getString(_weatherKey);
    if (cachedData == null) return null;

    try {
      final Map<String, dynamic> jsonData = jsonDecode(cachedData);
      return WeatherData.fromJson(jsonData);
    } catch (e) {
      print('Error reading cached data: $e');
      return null;
    }
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