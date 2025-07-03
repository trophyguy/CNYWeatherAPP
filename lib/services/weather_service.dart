// **************************************************************************
// * WARNING: DO NOT MODIFY THIS FILE WITHOUT EXPLICIT APPROVAL                *
// * Changes to this file should be properly reviewed and authorized          *
// * Version: 1.1.0                                                          *
// **************************************************************************

import 'dart:async';
import 'dart:async'; // Added Timer import
import 'package:flutter/foundation.dart';
import '../models/weather_data.dart';
import '../models/weather_alert.dart';
import '../repositories/weather_repository.dart';
import '../services/cache_service.dart';
import '../services/purpleair_service.dart';
import '../services/nws_service_base.dart';
import '../models/settings.dart';
import 'nws_service_cap.dart';
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as developer;
import 'package:flutter/material.dart';

class WeatherService extends ChangeNotifier {
  final WeatherRepository _repository;
  final CacheService _cacheService;
  final NWSServiceBase _nwsService;
  final PurpleAirService _purpleAirService;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService;
  final Settings _settings;
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  Timer? _timer;
  StreamSubscription<List<WeatherAlert>>? _alertsSubscription;
  static const _testTagUpdateInterval = Duration(minutes: 30);
  static const _quickUpdateInterval = Duration(seconds: 30);
  static const _conditionsIconInterval = Duration(minutes: 5);
  bool _initialLoadComplete = false;
  List<WeatherAlert> _alerts = [];
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(minutes: 5);

  WeatherService(
    this._repository,
    this._cacheService,
    this._settings,
    this._purpleAirService,
    this._notificationService,
  ) : _nwsService = NWSServiceCAP(_notificationService, _settings) {
    print('=== WEATHER_PERF: WeatherService constructor called ===');
    _init();
    
    // Subscribe to NWS alerts stream
    _alertsSubscription = _nwsService.alertsStream.listen((alerts) {
      debugPrint('=== WEATHER_PERF: Received ${alerts.length} alerts from stream ===');
      
      // Update alerts list
      _alerts = alerts;
      
      // Update weather data with new alerts
      if (_weatherData != null) {
        _weatherData = _weatherData!.copyWith(
          alerts: alerts,
        );
        debugPrint('=== WEATHER_PERF: Updated weather data with ${alerts.length} alerts ===');
        notifyListeners();
      } else {
        // If no weather data yet, create it with just the alerts
        final now = DateTime.now();
        _weatherData = WeatherData(
          alerts: alerts,
          forecast: [],
          lastUpdatedTime: now.toString(),
          lastUpdatedDate: now.toString(),
          date: now.toString(),
          isNight: false,
          updateTime: now.toString(),
          windDirectionText: 'N',
          iconName: 'assets/weather_icons/skc.png',
          temperature: 0.0,
          tempNoDecimal: 0.0,
          maxTemp: 0.0,
          maxTempTime: now.toString(),
          minTemp: 0.0,
          minTempTime: now.toString(),
          maxTempLastYear: 0.0,
          minTempLastYear: 0.0,
          maxTempRecord: 0.0,
          minTempRecord: 0.0,
          maxTempAverage: 0.0,
          minTempAverage: 0.0,
          feelsLike: 0.0,
          tempChangeHour: 0.0,
          humidity: 0.0,
          dewPoint: 0.0,
          windChill: 0.0,
          heatIndex: 0.0,
          aqi: 0.0,
          aqiDescription: '',
          windSpeed: 0.0,
          windGust: 0.0,
          maxGust: 0.0,
          maxGustTime: now.toString(),
          windDirection: 'N',
          windDirectionDegrees: 0,
          avgWind10Min: 0.0,
          monthlyHighWindGust: 0.0,
          beaufortScale: '0',
          beaufortText: '',
          pressure: 0.0,
          pressureTrend: '0.0',
          pressureTrend3Hour: '0.0',
          forecastText: '',
          dailyRain: 0.0,
          yesterdayRain: 0.0,
          monthlyRain: 0.0,
          yearlyRain: 0.0,
          daysWithNoRain: 0,
          daysWithRain: 0,
          currentRainRate: 0.0,
          maxRainRate: 0.0,
          maxRainRateTime: now.toString(),
          solarRadiation: 0.0,
          uvIndex: 0.0,
          highSolar: 0.0,
          highUV: 0.0,
          highSolarTime: now.toString(),
          highUVTime: now.toString(),
          burnTime: 0,
          snowSeason: 0.0,
          snowMonth: 0.0,
          snowToday: 0.0,
          snowYesterday: 0.0,
          snowHeight: 0.0,
          snowDepth: 0.0,
          snowDaysThisMonth: 0,
          snowDaysThisYear: 0,
          advisories: [],
          maxTempYesterday: 0.0,
          minTempYesterday: 0.0,
          sunrise: now,
          sunset: now,
          daylightChange: Duration.zero,
          possibleDaylight: 0.0,
          moonrise: now,
          moonset: now,
          moonPhase: 0.0,
          moonPhaseName: '',
          condition: 'Clear',
        );
        debugPrint('=== WEATHER_PERF: Created new weather data with ${alerts.length} alerts ===');
        notifyListeners();
      }
      
      // Check for new alerts and show notifications
      for (final alert in alerts) {
        final oldAlerts = _weatherData?.alerts ?? [];
        final oldAlertIds = oldAlerts.map((a) => a.id).toSet();
        
        if (!oldAlertIds.contains(alert.id)) {
          debugPrint('=== WEATHER_PERF: New alert detected: ${alert.event} ===');
          _notificationService.showAlertNotification(alert);
        }
      }
    });
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    _nwsService.cleanup();
    super.dispose();
  }

  Future<void> _init() async {
    debugPrint('\n=== Starting WeatherService._init() ===');
    try {
      // Initial fetch of weather data and alerts
      await refreshWeatherData();
      
      // Set up periodic updates - combine weather and alerts into one timer
      _timer = Timer.periodic(const Duration(minutes: 5), (_) async {
        await refreshWeatherData();
      });

      // Start quick updates
      _startUpdateTimers();
      
      debugPrint('WeatherService initialization complete');
    } catch (e) {
      debugPrint('Error in WeatherService._init: $e');
    }
  }

  Future<void> _checkAlerts() async {
    debugPrint('\n=== Starting _checkAlerts() ===');
    try {
      final alerts = await _nwsService.getAlerts();
      debugPrint('=== WEATHER_PERF: Fetched ${alerts.length} alerts ===');
      
      // Update weather data with new alerts
      if (_weatherData != null) {
        _weatherData = _weatherData!.copyWith(
          alerts: alerts,
          forecast: _weatherData?.forecast ?? [],
        );
        notifyListeners();
      }
      
      // Check for new alerts and show notifications
      for (final alert in alerts) {
        final oldAlerts = _weatherData?.alerts ?? [];
        final oldAlertIds = oldAlerts.map((a) => a.id).toSet();
        
        if (!oldAlertIds.contains(alert.id)) {
          debugPrint('=== WEATHER_PERF: New alert detected: ${alert.event} ===');
          _notificationService.showAlertNotification(alert);
        }
      }
      
      debugPrint('=== WEATHER_PERF: Alert check complete. Current alerts: ===');
      for (final alert in alerts) {
        debugPrint('- ${alert.event} for ${alert.area}');
      }
    } catch (e) {
      debugPrint('=== WEATHER_PERF: Error checking alerts: $e ===');
      if (_weatherData != null) {
        _weatherData = _weatherData!.copyWith(
          alerts: [],
        );
      }
      notifyListeners();
    }
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

  Future<void> _loadInitialTestTagData() async {
    print('=== WEATHER_PERF: _loadInitialTestTagData called ===');
    try {
      _isLoading = true;
      notifyListeners();
      
      // Load testtag data
      await fetchWeatherData();
      
      // Mark initial load as complete
      _initialLoadComplete = true;
      
      // Start the update timers
      _startUpdateTimers();
    } catch (e) {
      _error = 'Failed to load initial data: $e';
      debugPrint('Error in _loadInitialTestTagData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startUpdateTimers() {
    debugPrint('Starting update timers');
    
    // Start the quick update timer (every 15 seconds)
    Timer.periodic(_quickUpdateInterval, (_) {
      _performQuickUpdate();
    });

    // Start the conditions icon update timer (every 5 minutes)
    Timer.periodic(_conditionsIconInterval, (_) {
      _updateConditionsIcon();
    });

    debugPrint('Update timers started');
  }

  Future<void> _performQuickUpdate() async {
    try {
      final now = DateTime.now();
      final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final formattedTime = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

      final quickUpdateData = await _repository.getQuickUpdate();
      if (quickUpdateData != null) {
        // Debug log the raw data
        debugPrint('Quick Update Raw Data:');
        debugPrint('Temperature: ${quickUpdateData['temperature']}');
        debugPrint('Wind Speed: ${quickUpdateData['windSpeed']}');
        debugPrint('Dew Point: ${quickUpdateData['dewPoint']}');
        debugPrint('UV Index: ${quickUpdateData['uvIndex']}');

        // Only print debug info if values have changed significantly
        if (_weatherData != null) {
          final tempDiff = (quickUpdateData['temperature'] - _weatherData!.temperature).abs();
          final windDiff = (quickUpdateData['windSpeed'] - _weatherData!.windSpeed).abs();
          final dewPointDiff = (quickUpdateData['dewPoint'] - _weatherData!.dewPoint).abs();
          final uvDiff = (quickUpdateData['uvIndex'] - _weatherData!.uvIndex).abs();
          
          if (tempDiff > 0.5 || windDiff > 0.5 || dewPointDiff > 0.5 || uvDiff > 0.5) {
            debugPrint('Quick Update - Significant change detected:');
            debugPrint('Temperature: ${quickUpdateData['temperature']}°F (was: ${_weatherData?.temperature}°F)');
            debugPrint('Wind Speed: ${quickUpdateData['windSpeed']} knots (was: ${_weatherData?.windSpeed} knots)');
            debugPrint('Dew Point: ${quickUpdateData['dewPoint']}°F (was: ${_weatherData?.dewPoint}°F)');
            debugPrint('UV Index: ${quickUpdateData['uvIndex']} (was: ${_weatherData?.uvIndex})');
          }
        }

        // Get fresh AQI data
        double? aqiValue;
        String? aqiDescription;
        try {
          final aqiData = await _purpleAirService.getAirQuality();
          aqiValue = aqiData['aqi']?.toDouble();
          aqiDescription = aqiData['aqiDescription'] as String?;
        } catch (e) {
          debugPrint('Warning: Failed to fetch AQI data: $e');
        }

        // Convert wind direction to compass word
        final windDirectionWord = _getWindDirectionWord(double.parse(quickUpdateData['windDirection'].toString()));

        // Ensure values are within reasonable ranges
        final temperature = quickUpdateData['temperature'] is num ? quickUpdateData['temperature'].toDouble() : _weatherData?.temperature ?? 0.0;
        // Convert wind speed from knots to mph (1 knot = 1.15078 mph)
        final windSpeedKnots = quickUpdateData['windSpeed'] is num ? quickUpdateData['windSpeed'].toDouble() : _weatherData?.windSpeed ?? 0.0;
        final windSpeed = windSpeedKnots * 1.15078; // Convert knots to mph
        // Get dew point (already in Fahrenheit from quick update)
        final dewPoint = quickUpdateData['dewPoint'] is num ? quickUpdateData['dewPoint'].toDouble() : _weatherData?.dewPoint ?? 0.0;
        debugPrint('Dew Point: $dewPoint°F');
        // Convert UV index to whole number
        final uvIndex = quickUpdateData['uvIndex'] is num ? quickUpdateData['uvIndex'].round().toDouble() : _weatherData?.uvIndex ?? 0.0;

        // Convert rain rate from in/hr to in/hr (already in correct units)
        final rainRate = quickUpdateData['rainRate'] is num ? quickUpdateData['rainRate'].toDouble() : 0.0;
        debugPrint('Rain Rate: $rainRate in/hr');

        _weatherData = _weatherData?.copyWith(
          temperature: temperature,
          tempNoDecimal: temperature,
          windSpeed: windSpeed,
          windDirection: windDirectionWord,
          windGust: quickUpdateData['windGust'],
          humidity: quickUpdateData['humidity'],
          pressure: quickUpdateData['pressure'],
          dailyRain: quickUpdateData['dailyRain'],
          currentRainRate: rainRate,  // Use converted rain rate
          solarRadiation: quickUpdateData['solarRadiation'],
          uvIndex: uvIndex,
          dewPoint: dewPoint,
          windChill: quickUpdateData['windChill'],
          heatIndex: quickUpdateData['heatIndex'],
          aqi: aqiValue,
          aqiDescription: aqiDescription,
          updateTime: formattedTime,
          forecast: _weatherData?.forecast ?? [],
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Quick Update Error: $e');
    }
  }

  Future<void> fetchWeatherData() async {
    debugPrint('=== WEATHER_PERF: fetchWeatherData starting ===');
    try {
      // Get fresh alerts
      final alerts = await _nwsService.getAlerts();
      debugPrint('=== WEATHER_PERF: Got ${alerts.length} alerts during fetch ===');
      
      // Get weather data
      final data = await _repository.getWeatherData();
      debugPrint('=== WEATHER_PERF: Weather data fetched successfully ===');
      
      // Update weather data with alerts
      _weatherData = data.copyWith(
        alerts: alerts,
      );
      
      debugPrint('=== WEATHER_PERF: Updated weather data with ${alerts.length} alerts ===');
      notifyListeners();
    } catch (e) {
      debugPrint('=== WEATHER_PERF: Error fetching weather data: $e ===');
      // Handle error appropriately
    }
  }

  Future<void> refreshWeatherData() async {
    debugPrint('\n=== WEATHER_PERF: refreshWeatherData() starting ===');
    if (_isLoading) {
      debugPrint('=== WEATHER_PERF: Already loading, skipping refresh ===');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get fresh alerts directly from NWS service
      final alertsFuture = _nwsService.getAlerts();
      
      // Get other weather data
      final weatherDataFuture = _repository.getWeatherData();
      
      // Wait for both to complete
      final results = await Future.wait([alertsFuture, weatherDataFuture]);
      final alerts = results[0] as List<WeatherAlert>;
      final weatherData = results[1] as WeatherData;
      
      debugPrint('=== WEATHER_PERF: Got ${alerts.length} alerts and weather data ===');
      
      // Update alerts list
      _alerts = alerts;
      
      // Update weather data with new alerts
      _weatherData = weatherData.copyWith(
        alerts: alerts,
      );
      
      debugPrint('=== WEATHER_PERF: Updated weather data with ${alerts.length} alerts ===');
      debugPrint('=== WEATHER_PERF: Current alerts: ===');
      for (final alert in alerts) {
        debugPrint('- ${alert.event} for ${alert.area}');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('=== WEATHER_PERF: Error refreshing weather data: $e ===');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> getHazardousWeatherOutlook() async {
    try {
      return await _nwsService.getHazardousWeatherOutlook();
    } catch (e) {
      debugPrint('Error getting hazardous weather outlook: $e');
      return 'Unable to load Hazardous Weather Outlook';
    }
  }

  Future<void> _updateConditionsIcon() async {
    try {
      if (_weatherData != null) {
        // Get fresh weather data which includes the latest conditions
        final freshData = await _repository.getWeatherData();
        
        // Update the weather data with the fresh conditions
        _weatherData = _weatherData!.copyWith(
          condition: freshData.condition,
          iconName: getConditionIcon(freshData.condition, isNight: freshData.isNight)
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating conditions icon: $e');
    }
  }

  String _extractCurrentCondition(String html) {
    // Remove all whitespace and newlines for easier parsing
    final cleanedHtml = html.replaceAll(RegExp(r'\s+'), '');
    
    // Find the weather report value
    final startIndex = cleanedHtml.indexOf('\$weatherreport=\"') + 15;
    if (startIndex == -1) return 'Fair';
    
    final endIndex = cleanedHtml.indexOf('"', startIndex);
    if (endIndex == -1) return 'Fair';
    
    return cleanedHtml.substring(startIndex, endIndex);
  }

  bool _isNightTime(String html) {
    // Remove all whitespace and newlines for easier parsing
    final cleanedHtml = html.replaceAll(RegExp(r'\s+'), '');
    
    // Find the isnight value
    final startIndex = cleanedHtml.indexOf('\$isnight=\"') + 11;
    if (startIndex == -1) return false;
    
    final endIndex = cleanedHtml.indexOf('"', startIndex);
    if (endIndex == -1) return false;
    
    return cleanedHtml.substring(startIndex, endIndex).toLowerCase() == 'true';
  }

  String getConditionIcon(String condition, {bool isNight = false}) {
    condition = condition.toLowerCase();
    if (!isNight) {
      switch (condition) {
        case 'clear':
        case 'sunny':
          return 'assets/weather_icons/skc.png';
        case 'few clouds':
          return 'assets/weather_icons/few.png';
        case 'partly cloudy':
          return 'assets/weather_icons/sct.png';
        case 'mostly cloudy':
          return 'assets/weather_icons/bkn.png';
        case 'overcast':
          return 'assets/weather_icons/ovc.png';
        case 'rain':
        case 'showers':
          return 'assets/weather_icons/ra.png';
        case 'snow':
          return 'assets/weather_icons/sn.png';
        case 'thunderstorms':
          return 'assets/weather_icons/tsra.png';
        case 'fog':
          return 'assets/weather_icons/fg.png';
        case 'haze':
          return 'assets/weather_icons/hz.png';
        case 'ice pellets':
          return 'assets/weather_icons/ip.png';
        case 'hot':
          return 'assets/weather_icons/hot.png';
        case 'cold':
          return 'assets/weather_icons/cold.png';
        default:
          return 'assets/weather_icons/skc.png';
      }
    } else {
      switch (condition) {
        case 'clear':
        case 'sunny':
          return 'assets/weather_icons/nskc.png';
        case 'few clouds':
          return 'assets/weather_icons/nfew.png';
        case 'partly cloudy':
          return 'assets/weather_icons/nsct.png';
        case 'mostly cloudy':
          return 'assets/weather_icons/nbkn.png';
        case 'overcast':
          return 'assets/weather_icons/novc.png';
        case 'rain':
        case 'showers':
          return 'assets/weather_icons/nra.png';
        case 'snow':
          return 'assets/weather_icons/nsn.png';
        case 'thunderstorms':
          return 'assets/weather_icons/ntsra.png';
        case 'fog':
          return 'assets/weather_icons/nfg.png';
        case 'haze':
          return 'assets/weather_icons/hz.png';
        case 'ice pellets':
          return 'assets/weather_icons/ip.png';
        case 'hot':
          return 'assets/weather_icons/hot.png';
        case 'cold':
          return 'assets/weather_icons/ncold.png';
        default:
          return 'assets/weather_icons/nskc.png';
      }
    }
  }

  String _getWindDirectionWord(double degrees) {
    // Normalize degrees to 0-360
    degrees = degrees % 360;
    
    // Define the compass points and their degree ranges
    const directions = [
      (0, 22.5, 'N'),
      (22.5, 67.5, 'NE'),
      (67.5, 112.5, 'E'),
      (112.5, 157.5, 'SE'),
      (157.5, 202.5, 'S'),
      (202.5, 247.5, 'SW'),
      (247.5, 292.5, 'W'),
      (292.5, 337.5, 'NW'),
      (337.5, 360, 'N'),
    ];
    
    // Find the matching direction
    for (final (start, end, direction) in directions) {
      if (degrees >= start && degrees < end) {
        return direction;
      }
    }
    
    return 'N'; // Default to North if something goes wrong
  }
}