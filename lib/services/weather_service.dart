import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../repositories/weather_repository.dart';
import '../services/cache_service.dart';

class WeatherService extends ChangeNotifier {
  final WeatherRepository _repository;
  final CacheService _cacheService;
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  Timer? _updateTimer;
  static const _updateInterval = Duration(minutes: 5);

  WeatherService(this._repository, this._cacheService) {
    _init();
    _startUpdateTimer();
  }

  Future<void> _init() async {
    await _cacheService.init();
    await fetchWeatherData();
  }

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    // Full update every 5 minutes
    _updateTimer = Timer.periodic(_updateInterval, (_) => fetchWeatherData());
  }

  Future<void> fetchWeatherData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to get cached data first
      final cachedData = await _cacheService.getCachedWeatherData();
      if (cachedData != null) {
        _weatherData = WeatherData.fromJson(cachedData);
        notifyListeners();
      }

      // Fetch fresh data
      final freshData = await _repository.getWeatherData();
      _weatherData = freshData;
      await _cacheService.cacheWeatherData(freshData.toJson());
    } catch (e) {
      _error = 'Failed to fetch weather data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
} 