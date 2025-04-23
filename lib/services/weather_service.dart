import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../models/weather_alert.dart';
import '../repositories/weather_repository.dart';
import '../services/cache_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService extends ChangeNotifier {
  final WeatherRepository _repository;
  final CacheService _cacheService;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  Timer? _updateTimer;
  static const _updateInterval = Duration(minutes: 5);

  WeatherService(this._repository, this._cacheService) {
    _init();
    _startUpdateTimer();
    _initializeNotifications();
  }

  Future<void> _init() async {
    await _cacheService.init();
    await fetchWeatherData();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(initSettings);
  }

  Future<void> _checkAndNotifyAlerts(List<WeatherAlert> newAlerts) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    
    if (!notificationsEnabled) return;

    final oldAlerts = _weatherData?.alerts ?? [];
    final newAlertIds = newAlerts.map((a) => '${a.event}-${a.area}-${a.effective}').toSet();
    final oldAlertIds = oldAlerts.map((a) => '${a.event}-${a.area}-${a.effective}').toSet();
    
    // Find alerts that are new (not in old alerts)
    final alertsToNotify = newAlerts.where((alert) {
      final alertId = '${alert.event}-${alert.area}-${alert.effective}';
      return !oldAlertIds.contains(alertId);
    }).toList();

    if (alertsToNotify.isEmpty) return;

    const androidSettings = AndroidNotificationDetails(
      'weather_alerts',
      'Weather Alerts',
      channelDescription: 'Notifications for weather alerts in your area',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosSettings = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidSettings, iOS: iosSettings);

    for (var i = 0; i < alertsToNotify.length; i++) {
      final alert = alertsToNotify[i];
      await _notifications.show(
        i,
        '${alert.severity.toUpperCase()}: ${alert.event}',
        '${alert.area}\n${alert.description}',
        details,
      );
    }
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
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _repository.getWeatherData();
      
      // Check for new alerts before updating weather data
      if (data.alerts.isNotEmpty) {
        await _checkAndNotifyAlerts(data.alerts);
      }

      _weatherData = WeatherData(
        lastUpdatedTime: data.lastUpdatedTime,
        lastUpdatedDate: data.lastUpdatedDate,
        isNight: data.isNight,
        condition: data.condition,
        iconName: data.iconName,
        temperature: data.temperature,
        tempNoDecimal: data.tempNoDecimal,
        humidity: data.humidity,
        dewPoint: data.dewPoint,
        maxTemp: data.maxTemp,
        maxTempTime: data.maxTempTime,
        minTemp: data.minTemp,
        minTempTime: data.minTempTime,
        maxTempLastYear: data.maxTempLastYear,
        minTempLastYear: data.minTempLastYear,
        maxTempRecord: data.maxTempRecord,
        minTempRecord: data.minTempRecord,
        maxTempAverage: data.maxTempAverage,
        minTempAverage: data.minTempAverage,
        feelsLike: data.feelsLike,
        heatIndex: data.heatIndex,
        windChill: data.windChill,
        humidex: data.humidex,
        apparentTemp: data.apparentTemp,
        apparentSolarTemp: data.apparentSolarTemp,
        tempChangeHour: data.tempChangeHour,
        aqi: data.aqi,
        windSpeed: data.windSpeed,
        windGust: data.windGust,
        maxGust: data.maxGust,
        maxGustTime: data.maxGustTime,
        windDirection: data.windDirection,
        windDirectionDegrees: data.windDirectionDegrees,
        avgWind10Min: data.avgWind10Min,
        monthlyHighWindGust: data.monthlyHighWindGust,
        beaufortScale: data.beaufortScale,
        beaufortText: data.beaufortText,
        pressure: data.pressure,
        pressureTrend: data.pressureTrend,
        pressureTrend3Hour: data.pressureTrend3Hour,
        forecastText: data.forecastText,
        dailyRain: data.dailyRain,
        yesterdayRain: data.yesterdayRain,
        monthlyRain: data.monthlyRain,
        yearlyRain: data.yearlyRain,
        daysWithNoRain: data.daysWithNoRain,
        daysWithRain: data.daysWithRain,
        currentRainRate: data.currentRainRate,
        maxRainRate: data.maxRainRate,
        maxRainRateTime: data.maxRainRateTime,
        solarRadiation: data.solarRadiation,
        uvIndex: data.uvIndex,
        highSolar: data.highSolar,
        highUV: data.highUV,
        highSolarTime: data.highSolarTime,
        highUVTime: data.highUVTime,
        burnTime: data.burnTime,
        snowSeason: data.snowSeason,
        snowMonth: data.snowMonth,
        snowToday: data.snowToday,
        snowYesterday: data.snowYesterday,
        snowHeight: data.snowHeight,
        snowDepth: data.snowDepth,
        snowDaysThisMonth: data.snowDaysThisMonth,
        snowDaysThisYear: data.snowDaysThisYear,
        advisories: data.advisories,
        maxTempYesterday: data.maxTempYesterday,
        minTempYesterday: data.minTempYesterday,
        forecast: data.forecast,
        alerts: data.alerts,
        sunrise: data.sunrise,
        sunset: data.sunset,
        daylightChange: data.daylightChange,
        possibleDaylight: data.possibleDaylight,
        moonrise: data.moonrise,
        moonset: data.moonset,
        moonPhase: data.moonPhase,
        moonPhaseName: data.moonPhaseName,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
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