import 'dart:async';
import '../models/weather_alert.dart';
import '../models/forecast_data.dart';

abstract class NWSServiceBase {
  Stream<List<WeatherAlert>> get alertsStream;
  Future<List<WeatherAlert>> getAlerts();
  Future<List<WeatherAlert>> fetchAlerts();
  Future<List<ForecastPeriod>> getForecast();
  Future<String> getHazardousWeatherOutlook();
  Future<void> initialize();
  Future<void> cleanup();
} 