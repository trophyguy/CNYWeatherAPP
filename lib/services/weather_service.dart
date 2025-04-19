import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../repositories/weather_repository.dart';
import '../services/cache_service.dart';

class WeatherService with ChangeNotifier {
  final WeatherRepository _weatherRepository;
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

  WeatherService(this._weatherRepository, this._cacheService) {
    fetchWeatherData();
    _startUpdateTimers();
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _weatherData = await _weatherRepository.getWeatherData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadQuickUpdate() async {
    try {
      final quickUpdate = await _weatherRepository.getQuickUpdate();
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