import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_alert.dart';
import '../models/forecast_data.dart';
import 'nws_service_base.dart';
import 'notification_service.dart';
import '../models/settings.dart';

class NWSServiceCAP implements NWSServiceBase {
  static const String _baseUrl = 'https://api.weather.gov/alerts/active';
  static const String _userAgent = 'CNYWeatherApp/1.0 (tony@example.com)';
  static const String _cacheKey = 'cached_weather_alerts';
  static const String _cacheTimestampKey = 'cached_alerts_timestamp';
  
  // NY County codes
  static const List<String> _counties = [
    'NYC065', // Oneida County
    'NYC043', // Madison County
    'NYC053', // Onondaga County
    'NYC067', // Oswego County
    'NYC041', // Lewis County
    'NYC049', // Herkimer County
    'NYC077', // Otsego County
    'NYC111', // Ulster County (for testing)
  ];

  // Request management
  Future<List<WeatherAlert>>? _currentRequest;
  DateTime? _lastFetchTime;
  List<WeatherAlert>? _cachedAlerts;
  static const Duration _minFetchIntervalWithAlerts = Duration(minutes: 2);
  static const Duration _minFetchIntervalNoAlerts = Duration(minutes: 5);
  static const Duration _cacheExpiration = Duration(hours: 1);
  static const Duration _refreshCooldown = Duration(seconds: 30);  // Add cooldown period

  // Add refresh state tracking
  bool _isRefreshing = false;
  DateTime? _lastRefreshAttempt;

  // Stream controller for alerts
  final _alertsController = StreamController<List<WeatherAlert>>.broadcast();
  Stream<List<WeatherAlert>> get alertsStream => _alertsController.stream;

  final NotificationService _notificationService;
  final Settings _settings;
  Set<String> _lastAlertIds = {};

  static const double _latitude = 43.2105; // Rome, NY latitude
  static const double _longitude = -75.4557; // Rome, NY longitude

  NWSServiceCAP(this._notificationService, this._settings);

  // Initialize the service
  Future<void> initialize() async {
    await _loadCachedAlerts();
    await _notificationService.initialize();
  }

  // Load cached alerts from shared preferences
  Future<void> _loadCachedAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (cachedJson != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        
        // Check if cache is still valid
        if (now.difference(cacheTime) < _cacheExpiration) {
          final List<dynamic> decoded = json.decode(cachedJson);
          _cachedAlerts = decoded
              .where((item) => item != null && item is Map<String, dynamic>)
              .map((item) => WeatherAlert.fromJson(item as Map<String, dynamic>))
              .toList();
          _lastFetchTime = cacheTime;
          debugPrint('Loaded ${_cachedAlerts!.length} alerts from cache');
          
          // Notify listeners of cached data
          _alertsController.add(_cachedAlerts!);
        } else {
          debugPrint('Cache expired, will fetch fresh data');
        }
      }
    } catch (e) {
      debugPrint('Error loading cached alerts: $e');
    }
  }

  // Save alerts to shared preferences
  Future<void> _saveAlertsToCache(List<WeatherAlert> alerts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(alerts.map((alert) => alert.toJson()).toList());
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('Saved ${alerts.length} alerts to cache');
    } catch (e) {
      debugPrint('Error saving alerts to cache: $e');
    }
  }

  // Clean up resources
  void dispose() {
    _currentRequest = null;
    _lastFetchTime = null;
    _cachedAlerts = null;
    _lastAlertIds.clear();
    _alertsController.close();
    _notificationService.cancelAllNotifications();
  }

  // Parse VTEC code
  Map<String, dynamic> _parseVTEC(String vtec) {
    try {
      // Example: /O.EXT.KJAN.FL.W.0056.250509T2212Z-000000T0000Z/
      final parts = vtec.split('.');
      if (parts.length >= 6) {
        return {
          'office': parts[2],      // KJAN
          'phenomena': parts[3],   // FL
          'significance': parts[4], // W
          'number': parts[5],      // 0056
          'startTime': parts[6].split('-')[0], // 250509T2212Z
          'endTime': parts[6].split('-')[1],   // 000000T0000Z
        };
      }
    } catch (e) {
      debugPrint('Error parsing VTEC: $e');
    }
    return {};
  }

  // Clear cached alerts to force a fresh fetch
  Future<void> clearCache() async {
    debugPrint('=== WEATHER_PERF: Clearing alert cache ===');
    _cachedAlerts = null;
    _lastFetchTime = null;
    _lastAlertIds.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      debugPrint('=== WEATHER_PERF: Cache cleared from SharedPreferences ===');
    } catch (e) {
      debugPrint('=== WEATHER_PERF: Error clearing cache: $e ===');
    }
  }

  Future<List<WeatherAlert>> getAlerts() async {
    debugPrint('\n=== WEATHER_PERF: getAlerts() called ===');
    // If we have a request in progress, return it
    if (_currentRequest != null) {
      debugPrint('=== WEATHER_PERF: Alert fetch already in progress, returning existing request ===');
      return _currentRequest!;
    }

    // Return cached alerts immediately if available
    if (_cachedAlerts != null) {
      debugPrint('=== WEATHER_PERF: Returning ${_cachedAlerts!.length} cached alerts immediately ===');
      
      // Only check for background refresh if we haven't fetched recently
      if (_lastFetchTime != null && !_isRefreshing) {
        final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
        final hasActiveAlerts = _cachedAlerts?.isNotEmpty ?? false;
        final minInterval = hasActiveAlerts ? _minFetchIntervalWithAlerts : _minFetchIntervalNoAlerts;
        
        // Check if we're in cooldown period
        if (_lastRefreshAttempt != null) {
          final timeSinceLastAttempt = DateTime.now().difference(_lastRefreshAttempt!);
          if (timeSinceLastAttempt < _refreshCooldown) {
            debugPrint('=== WEATHER_PERF: In cooldown period, skipping refresh check ===');
            return _cachedAlerts!;
          }
        }
        
        if (timeSinceLastFetch >= minInterval) {
          debugPrint('=== WEATHER_PERF: Starting background refresh ===');
          _lastRefreshAttempt = DateTime.now();
          _checkAndRefreshInBackground();
        }
      }
      
      return _cachedAlerts!;
    }

    // If no cache, fetch new data
    debugPrint('=== WEATHER_PERF: No cache, fetching new alerts ===');
    _currentRequest = _fetchAlerts();
    _lastFetchTime = DateTime.now();
    _lastRefreshAttempt = DateTime.now();

    try {
      final result = await _currentRequest!;
      _cachedAlerts = result;
      await _saveAlertsToCache(result);
      debugPrint('=== WEATHER_PERF: Cached ${result.length} alerts ===');
      debugPrint('=== WEATHER_PERF: Sending ${result.length} alerts to stream ===');
      _alertsController.add(result);
      return result;
    } finally {
      _currentRequest = null;
      _isRefreshing = false;
    }
  }

  // Check if we need to refresh in the background
  Future<void> _checkAndRefreshInBackground() async {
    if (_lastFetchTime == null || _isRefreshing) {
      debugPrint('Skipping background refresh: ${_isRefreshing ? "already refreshing" : "no last fetch time"}');
      return;
    }

    final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
    final hasActiveAlerts = _cachedAlerts?.isNotEmpty ?? false;
    final minInterval = hasActiveAlerts ? _minFetchIntervalWithAlerts : _minFetchIntervalNoAlerts;

    if (timeSinceLastFetch >= minInterval) {
      debugPrint('Starting background refresh of alerts');
      _isRefreshing = true;
      _currentRequest = _fetchAlerts();
      _lastFetchTime = DateTime.now();

      try {
        final result = await _currentRequest!;
        _cachedAlerts = result;
        await _saveAlertsToCache(result);
        debugPrint('Background refresh completed: ${result.length} alerts');
        _alertsController.add(result);
      } finally {
        _currentRequest = null;
        _isRefreshing = false;
      }
    } else {
      debugPrint('Skipping background refresh, too soon since last fetch');
    }
  }

  @override
  Future<List<ForecastPeriod>> getForecast() async {
    try {
      debugPrint('Fetching forecast for lat=$_latitude, lon=$_longitude');
      final pointResponse = await http.get(
        Uri.parse('https://api.weather.gov/points/$_latitude,$_longitude'),
        headers: {'User-Agent': _userAgent},
      );
      if (pointResponse.statusCode != 200) {
        throw Exception('Failed to get grid point: \\${pointResponse.statusCode}');
      }
      final pointData = json.decode(pointResponse.body);
      final forecastUrl = pointData['properties']['forecast'];
      debugPrint('Forecast URL: $forecastUrl');

      // Get the forecast data
      final forecastResponse = await http.get(
        Uri.parse(forecastUrl),
        headers: {'User-Agent': _userAgent},
      );
      if (forecastResponse.statusCode != 200) {
        throw Exception('Failed to get forecast: \\${forecastResponse.statusCode}');
      }
      final forecastData = json.decode(forecastResponse.body);
      final periods = forecastData['properties']['periods'] as List;

      // Convert NWS periods to our ForecastPeriod model
      List<ForecastPeriod> forecastPeriods = [];
      for (var i = 0; i < (periods.length < 8 ? periods.length : 8); i++) {
        final period = periods[i];
        final name = period['name'] as String;
        final windSpeed = period['windSpeed'].toString().replaceAll(RegExp(r'[^\d]'), '');
        final windDirection = period['windDirection'] as String;
        forecastPeriods.add(ForecastPeriod(
          name: name,
          shortName: _getShortName(name),
          condition: period['shortForecast'] as String,
          temperature: (period['temperature'] as num).toDouble(),
          isNight: !(period['isDaytime'] as bool),
          iconName: _getIconName(period['shortForecast'] as String, !(period['isDaytime'] as bool)),
          popPercent: _extractPOP(period['detailedForecast'] as String),
          windSpeed: windSpeed,
          windDirection: windDirection,
          detailedForecast: period['detailedForecast'] as String,
        ));
      }
      debugPrint('Forecast periods fetched: \\${forecastPeriods.length}');
      return forecastPeriods;
    } catch (e) {
      debugPrint('Error fetching forecast: $e');
      return [];
    }
  }

  String _getIconName(String forecast, bool isNight) {
    final forecastLower = forecast.toLowerCase();
    // Fair/Clear conditions
    if (forecastLower.contains('fair') || 
        forecastLower.contains('clear') ||
        forecastLower.contains('sunny')) {
      return isNight ? 'nskc' : 'skc';
    }
    if (forecastLower.contains('few clouds') || 
        forecastLower.contains('mostly clear') ||
        forecastLower.contains('mostly sunny')) {
      return isNight ? 'nfew' : 'few';
    }
    if (forecastLower.contains('partly cloudy') || 
        forecastLower.contains('partly sunny')) {
      return isNight ? 'nsct' : 'sct';
    }
    if (forecastLower.contains('mostly cloudy')) {
      return isNight ? 'nbkn' : 'bkn';
    }
    if (forecastLower.contains('overcast') || 
        forecastLower.contains('cloudy')) {
      return isNight ? 'novc' : 'ovc';
    }
    if (forecastLower.contains('snow')) {
      return isNight ? 'nsn' : 'sn';
    }
    if (forecastLower.contains('rain')) {
      return isNight ? 'nra' : 'ra';
    }
    if (forecastLower.contains('thunderstorm')) {
      return isNight ? 'ntsra' : 'tsra';
    }
    if (forecastLower.contains('fog') || 
        forecastLower.contains('mist')) {
      return isNight ? 'nfg' : 'fg';
    }
    if (forecastLower.contains('haze')) {
      return 'hz';
    }
    if (forecastLower.contains('hot')) {
      return 'hot';
    }
    if (forecastLower.contains('cold')) {
      return isNight ? 'ncold' : 'cold';
    }
    if (forecastLower.contains('blizzard')) {
      return isNight ? 'nblizzard' : 'blizzard';
    }
    return isNight ? 'novc' : 'ovc';
  }

  int _extractPOP(String detailedForecast) {
    final popMatch = RegExp(r'Chance of precipitation is (\d+)%').firstMatch(detailedForecast);
    if (popMatch != null) {
      return int.tryParse(popMatch.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  Future<String> getHazardousWeatherOutlook() async {
    // For now, return empty HWO since we're focusing on alerts
    return 'No hazardous weather outlook available.';
  }

  Future<List<WeatherAlert>> _fetchAlerts() async {
    debugPrint('\n=== WEATHER_PERF: _fetchAlerts() starting ===');
    final Set<String> currentAlertIds = {};
    List<WeatherAlert> allAlerts = [];

    try {
      // Get alerts for New York
      final capUrl = Uri.parse('$_baseUrl?area=NY');
      debugPrint('=== WEATHER_PERF: CAP URL: $capUrl ===');
      debugPrint('=== WEATHER_PERF: Selected counties: ${_settings.selectedCounties} ===');
      
      final response = await http.get(
        capUrl,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/geo+json',
        },
      );
      
      debugPrint('=== WEATHER_PERF: CAP response status: ${response.statusCode} ===');
      
      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonData = json.decode(response.body);
        debugPrint('=== WEATHER_PERF: Parsing alerts from response ===');
        
        // Parse alerts directly
        final features = jsonData['features'] as List;
        for (final feature in features) {
          try {
            final properties = feature['properties'];
            final event = properties['event']?.toString() ?? 'Unknown Event';
            final severity = properties['severity']?.toString().toLowerCase() ?? 'unknown';
            final areaDesc = properties['areaDesc']?.toString() ?? 'Unknown Area';
            final description = properties['description']?.toString() ?? '';
            final instruction = properties['instruction']?.toString() ?? '';
            final effective = properties['effective']?.toString() ?? DateTime.now().toIso8601String();
            final expires = properties['expires']?.toString();
            final status = properties['status']?.toString() ?? 'Unknown';
            final msgType = properties['messageType']?.toString() ?? 'Unknown';
            final id = properties['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            final updated = properties['updated']?.toString() ?? DateTime.now().toIso8601String();
            final certainty = properties['certainty']?.toString().toLowerCase() ?? 'unknown';
            final urgency = properties['urgency']?.toString().toLowerCase() ?? 'unknown';
            final geocode = properties['geocode'] as Map<String, dynamic>?;
            final sameCodes = (geocode?['SAME'] as List<dynamic>?)?.cast<String>() ?? [];
            final ugcCodes = (geocode?['UGC'] as List<dynamic>?)?.cast<String>() ?? [];

            debugPrint('\n=== WEATHER_PERF: Processing alert ===');
            debugPrint('- Event: $event');
            debugPrint('- Area: $areaDesc');
            debugPrint('- SAME codes: $sameCodes');
            debugPrint('- UGC codes: $ugcCodes');

            // Check if alert is relevant to selected counties
            bool isRelevant = false;

            // First check SAME codes
            for (final code in sameCodes) {
              if (_settings.selectedCounties.contains(code)) {
                debugPrint('=== WEATHER_PERF: Alert matches selected county by SAME code: $code ===');
                isRelevant = true;
                break;
              }
            }

            // Then check UGC codes
            if (!isRelevant) {
              for (final code in ugcCodes) {
                if (_settings.selectedCounties.contains(code)) {
                  debugPrint('=== WEATHER_PERF: Alert matches selected county by UGC code: $code ===');
                  isRelevant = true;
                  break;
                }
              }
            }

            // Finally check area description against county names
            if (!isRelevant) {
              for (final countyCode in _settings.selectedCounties) {
                final countyName = _getCountyName(countyCode);
                if (countyName != null && areaDesc.contains(countyName)) {
                  debugPrint('=== WEATHER_PERF: Alert matches selected county by name: $countyName ===');
                  isRelevant = true;
                  break;
                }
              }
            }

            // Skip alerts that don't include Otsego County
            if (isRelevant && !areaDesc.contains('Otsego')) {
              debugPrint('=== WEATHER_PERF: Alert skipped - does not include Otsego County ===');
              isRelevant = false;
            }

            if (!isRelevant) {
              debugPrint('=== WEATHER_PERF: Alert skipped - not relevant to selected counties ===');
              continue;
            }

            // Get alert colors based on event type and severity
            final eventLower = event.toLowerCase();
            final severityLower = severity.toLowerCase();
            Map<String, String> colors;
            
            // Watch colors (yellow) - check this first
            if (eventLower.contains('watch')) {
              colors = {
                'backgroundColor': '#FFFF00', // NWS Yellow
                'textColor': '#000000'
              };
            }
            // Warning colors (red)
            else if (eventLower.contains('warning') || 
                     severityLower == 'extreme' || 
                     severityLower == 'severe') {
              colors = {
                'backgroundColor': '#FF0000', // NWS Red
                'textColor': '#FFFFFF'
              };
            }
            // Advisory colors (blue)
            else if (eventLower.contains('advisory')) {
              colors = {
                'backgroundColor': '#00BFFF', // NWS Blue
                'textColor': '#000000'
              };
            }
            // Statement colors (light blue)
            else if (eventLower.contains('statement')) {
              colors = {
                'backgroundColor': '#ADD8E6', // NWS Light Blue
                'textColor': '#000000'
              };
            }
            // Outlook colors (green)
            else if (eventLower.contains('outlook')) {
              colors = {
                'backgroundColor': '#00FF00', // NWS Green
                'textColor': '#000000'
              };
            }
            // Emergency colors (purple)
            else if (eventLower.contains('emergency')) {
              colors = {
                'backgroundColor': '#800080', // NWS Purple
                'textColor': '#FFFFFF'
              };
            }
            // Default colors (gray)
            else {
              colors = {
                'backgroundColor': '#808080', // NWS Gray
                'textColor': '#FFFFFF'
              };
            }

            final alert = WeatherAlert(
              id: id,
              event: event,
              severity: severity,
              urgency: urgency,
              certainty: certainty,
              area: areaDesc,
              description: description,
              effective: effective,
              expires: expires,
              instruction: instruction,
              status: status,
              scope: 'Public',
              msgType: msgType,
              issued: updated,
              backgroundColor: colors['backgroundColor'] ?? '#FFFFFF',
              textColor: colors['textColor'] ?? '#000000',
            );
            allAlerts.add(alert);
            currentAlertIds.add(id);
            debugPrint('=== WEATHER_PERF: Added alert: ${alert.event} for ${alert.area} ===');
          } catch (e) {
            debugPrint('=== WEATHER_PERF: Error parsing alert: $e ===');
          }
        }
        
        debugPrint('=== WEATHER_PERF: Found ${allAlerts.length} relevant alerts in response ===');
        
        // Log each alert's details
        for (final alert in allAlerts) {
          debugPrint('=== WEATHER_PERF: Alert details ===');
          debugPrint('- Event: ${alert.event}');
          debugPrint('- Area: ${alert.area}');
          debugPrint('- Severity: ${alert.severity}');
          debugPrint('- Effective: ${alert.effective}');
          debugPrint('- Expires: ${alert.expires}');
        }
      } else {
        debugPrint('=== WEATHER_PERF: Error response from CAP feed: ${response.statusCode} ===');
        debugPrint('=== WEATHER_PERF: Response body: ${response.body} ===');
      }
    } catch (e) {
      debugPrint('=== WEATHER_PERF: Error fetching CAP feed: $e ===');
    }
    
    // Check for new alerts and show notifications
    for (final alert in allAlerts) {
      if (!_lastAlertIds.contains(alert.id)) {
        debugPrint('=== WEATHER_PERF: New alert detected: ${alert.event} ===');
        await _notificationService.showAlertNotification(alert);
      }
    }
    // Update last alert IDs
    _lastAlertIds = currentAlertIds;
    debugPrint('\n=== WEATHER_PERF: Total unique alerts found: ${allAlerts.length} ===');
    for (final alert in allAlerts) {
      debugPrint('=== WEATHER_PERF: Alert: ${alert.event} for ${alert.area} ===');
    }

    // Emit alerts through the stream
    debugPrint('=== WEATHER_PERF: Emitting ${allAlerts.length} alerts through stream ===');
    _alertsController.add(allAlerts);
    
    return allAlerts;
  }

  @override
  Future<void> cleanup() async {
    await _notificationService.cancelAllNotifications();
  }

  @override
  Future<List<WeatherAlert>> fetchAlerts() async {
    try {
      final alerts = await getAlerts();
      return alerts;
    } catch (e) {
      developer.log('Error fetching alerts: $e', name: 'NWSServiceCAP');
      return [];
    }
  }

  String _getShortName(String fullName) {
    // Convert "Monday Night" to "Mon Nite", "Monday" to "Mon", etc.
    final parts = fullName.split(' ');
    if (parts[0] == 'Today') {
      return 'Today';
    } else if (parts[0] == 'Tonight') {
      return 'Tonight';
    } else if (parts[0] == 'This' || parts[0] == 'Thi') {
      return 'This Afternoon';  // Always use "This Afternoon" for consistency
    }
    String day = parts[0].substring(0, 3);
    return parts.length > 1 ? '$day Nite' : day;
  }

  // Helper method to get county name from code
  String? _getCountyName(String code) {
    switch (code) {
      case 'NYC065': return 'Oneida';
      case 'NYC043': return 'Madison';
      case 'NYC053': return 'Onondaga';
      case 'NYC067': return 'Oswego';
      case 'NYC041': return 'Lewis';
      case 'NYC049': return 'Herkimer';
      case 'NYC077': return 'Otsego';
      case 'NYC111': return 'Ulster';
      default: return null;
    }
  }
} 