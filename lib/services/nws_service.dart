import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/forecast_data.dart';
import '../models/weather_alert.dart';

class NWSService {
  static const String _baseUrl = 'https://api.weather.gov';
  static const String _userAgent = 'CNYWeatherApp/1.0 (tony@example.com)';
  
  // Rome, NY coordinates
  static const double _latitude = 43.2105;
  static const double _longitude = -75.4557;

  static const List<String> _zones = [
    'NYZ037', // Southern Oneida
    'NYZ009', // Northern Oneida
    'NYZ038', // Southern Herkimer
    'NYZ032', // Northern Herkimer
    'NYZ046', // Otsego
    'NYZ036', // Madison
    'NYZ008', // Lewis
    'NYZ018', // Onondaga
  ];
  static const List<String> _counties = [
    'NYC065', // Oneida
    'NYC043', // Herkimer
    'NYC077', // Otsego
    'NYC053', // Madison
    'NYC049', // Lewis
    'NYC067', // Onondaga
  ];

  Future<List<ForecastPeriod>> getForecast() async {
    try {
      // First, get the forecast grid point
      final pointResponse = await http.get(
        Uri.parse('$_baseUrl/points/$_latitude,$_longitude'),
        headers: {'User-Agent': _userAgent},
      );

      if (pointResponse.statusCode != 200) {
        throw Exception('Failed to get grid point: ${pointResponse.statusCode}');
      }

      final pointData = json.decode(pointResponse.body);
      final forecastUrl = pointData['properties']['forecast'];

      // Then, get the forecast data
      final forecastResponse = await http.get(
        Uri.parse(forecastUrl),
        headers: {'User-Agent': _userAgent},
      );

      if (forecastResponse.statusCode != 200) {
        throw Exception('Failed to get forecast: ${forecastResponse.statusCode}');
      }

      final forecastData = json.decode(forecastResponse.body);
      final periods = forecastData['properties']['periods'] as List;

      // Convert NWS periods to our ForecastPeriod model
      List<ForecastPeriod> forecastPeriods = [];
      for (var i = 0; i < min(8, periods.length); i++) {  // Increased from 4 to 8 periods
        final period = periods[i];
        final name = period['name'] as String;
        
        // Extract wind speed and direction
        final windSpeed = period['windSpeed'].toString().replaceAll(RegExp(r'[^\d]'), '');
        final windDirection = period['windDirection'] as String;
        
        forecastPeriods.add(ForecastPeriod(
          name: name,
          shortName: _getShortName(name),
          condition: _simplifyForecast(period['shortForecast'] as String),
          temperature: (period['temperature'] as num).toDouble(),
          isNight: !(period['isDaytime'] as bool),
          iconName: _getIconName(period['shortForecast'] as String, !(period['isDaytime'] as bool)),
          popPercent: _extractPOP(period['detailedForecast'] as String),
          windSpeed: windSpeed,
          windDirection: windDirection,
          detailedForecast: period['detailedForecast'] as String,
        ));
      }

      return forecastPeriods;
    } catch (e) {
      debugPrint('Error fetching forecast: $e');
      return [];
    }
  }

  String _getShortName(String fullName) {
    // Convert "Monday Night" to "Mon Nite", "Monday" to "Mon", etc.
    final parts = fullName.split(' ');
    String day = parts[0].substring(0, 3);
    return parts.length > 1 ? '$day Nite' : day;
  }

  String _simplifyForecast(String forecast) {
    // Map NWS forecast text to simpler versions
    final Map<String, String> simplifications = {
      'Slight Chance Rain Showers': 'Chance Rain',
      'Chance Rain Showers': 'Chance Rain',
      'Rain Showers Likely': 'Rain Likely',
      'Slight Chance Snow Showers': 'Chance Snow',
      'Chance Snow Showers': 'Chance Snow',
      'Snow Showers Likely': 'Snow Likely',
      'Partly Sunny': 'Partly Sunny',
      'Mostly Sunny': 'Mostly Sunny',
      'Partly Cloudy': 'Partly Cloudy',
      'Mostly Cloudy': 'Mostly Cloudy',
      // Add more mappings as needed
    };

    return simplifications[forecast] ?? forecast;
  }

  String _getIconName(String forecast, bool isNight) {
    // Map forecast conditions to icon names
    final lowerForecast = forecast.toLowerCase();
    
    if (lowerForecast.contains('snow')) return 'sn';
    if (lowerForecast.contains('rain')) return 'ra';
    if (lowerForecast.contains('thunderstorm')) return 'tsra';
    if (lowerForecast.contains('cloudy')) {
      if (lowerForecast.startsWith('partly')) return 'sct';
      if (lowerForecast.startsWith('mostly')) return 'bkn';
      return 'ovc';
    }
    if (lowerForecast.contains('sunny')) {
      if (lowerForecast.startsWith('partly')) return 'sct';
      if (lowerForecast.startsWith('mostly')) return 'few';
      return 'skc';
    }
    return 'skc'; // Default to clear sky
  }

  int _extractPOP(String detailedForecast) {
    // Extract probability of precipitation from detailed forecast
    final popMatch = RegExp(r'Chance of precipitation is (\d+)%').firstMatch(detailedForecast);
    if (popMatch != null) {
      return int.tryParse(popMatch.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  int min(int a, int b) => a < b ? a : b;

  Future<List<WeatherAlert>> getAlerts() async {
    try {
      final List<WeatherAlert> allAlerts = [];
      
      // Fetch alerts for zones
      for (final zone in _zones) {
        final response = await http.get(Uri.parse('$_baseUrl?zone=$zone'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final features = data['features'] as List;
          for (final feature in features) {
            final properties = feature['properties'];
            allAlerts.add(WeatherAlert.fromJson(properties));
          }
        }
      }

      // Fetch alerts for counties
      for (final county in _counties) {
        final response = await http.get(Uri.parse('$_baseUrl?area=$county'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final features = data['features'] as List;
          for (final feature in features) {
            final properties = feature['properties'];
            allAlerts.add(WeatherAlert.fromJson(properties));
          }
        }
      }

      // Remove duplicates based on event ID
      final uniqueAlerts = <String, WeatherAlert>{};
      for (final alert in allAlerts) {
        uniqueAlerts[alert.event] = alert;
      }

      return uniqueAlerts.values.toList();
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }
} 