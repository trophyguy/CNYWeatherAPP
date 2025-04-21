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
  Timer? _quickUpdateTimer;
  Timer? _debounceTimer;
  static const _updateInterval = Duration(minutes: 5);
  static const _quickUpdateInterval = Duration(seconds: 30);
  static const _debounceInterval = Duration(milliseconds: 500);

  WeatherService(this._repository, this._cacheService) {
    _init();
    _startUpdateTimers();
  }

  Future<void> _init() async {
    await _cacheService.init();
    await fetchWeatherData();
  }

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _startUpdateTimers() {
    _updateTimer?.cancel();
    _quickUpdateTimer?.cancel();

    // Full update every 5 minutes
    _updateTimer = Timer.periodic(_updateInterval, (_) => fetchWeatherData());

    // Quick update every 30 seconds with debounce
    _quickUpdateTimer = Timer.periodic(_quickUpdateInterval, (_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceInterval, _loadQuickUpdate);
    });
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

  Future<void> _loadQuickUpdate() async {
    try {
      final quickUpdate = await _repository.getQuickUpdate();
      if (_weatherData != null) {
        // Update only the fields that change frequently
        final changes = {
          'temperature': quickUpdate['temperature'] as double? ?? _weatherData!.temperature,
          'humidity': quickUpdate['humidity'] as double? ?? _weatherData!.humidity,
          'windSpeed': quickUpdate['windSpeed'] as double? ?? _weatherData!.windSpeed,
          'windDirection': quickUpdate['windDirection'] as String? ?? _weatherData!.windDirection,
          'pressure': quickUpdate['pressure'] as double? ?? _weatherData!.pressure,
        };
        
        _weatherData = _weatherData!.copyWith(changes);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Quick update failed: $e');
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _quickUpdateTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
} 