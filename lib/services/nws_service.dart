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
      'Partly Sunny': 'Partly Cloudy',
      'Mostly Sunny': 'Partly Cloudy',
      'Partly Cloudy': 'Partly Cloudy',
      'Mostly Cloudy': 'Mostly Cloudy',
      'Clear': 'Clear',
      'Sunny': 'Clear',
      // Add more mappings as needed
    };

    // Get the simplified version for display
    final simplified = simplifications[forecast] ?? forecast;
    debugPrint('Original forecast: $forecast, Simplified: $simplified');
    return simplified;
  }

  String _getIconName(String forecast, bool isNight) {
    final forecastLower = forecast.toLowerCase();
    print('Getting icon for forecast: $forecastLower (isNight: $isNight)');

    // Fair/Clear conditions
    if (forecastLower.contains('fair') || 
        forecastLower.contains('clear') ||
        forecastLower.contains('sunny')) {
      return isNight ? 'nskc' : 'skc';
    }

    // A Few Clouds
    if (forecastLower.contains('few clouds') || 
        forecastLower.contains('mostly clear') ||
        forecastLower.contains('mostly sunny')) {
      return isNight ? 'nfew' : 'few';
    }

    // Partly Cloudy
    if (forecastLower.contains('partly cloudy') || 
        forecastLower.contains('partly sunny')) {
      return isNight ? 'nsct' : 'sct';
    }

    // Mostly Cloudy
    if (forecastLower.contains('mostly cloudy')) {
      return isNight ? 'nbkn' : 'bkn';
    }

    // Overcast
    if (forecastLower.contains('overcast') || 
        forecastLower.contains('cloudy')) {
      return isNight ? 'novc' : 'ovc';
    }

    // Snow conditions
    if (forecastLower.contains('snow')) {
      return isNight ? 'nsn' : 'sn';
    }

    // Rain conditions
    if (forecastLower.contains('rain')) {
      return isNight ? 'nra' : 'ra';
    }

    // Thunderstorm
    if (forecastLower.contains('thunderstorm')) {
      return isNight ? 'ntsra' : 'tsra';
    }

    // Fog/Mist
    if (forecastLower.contains('fog') || 
        forecastLower.contains('mist')) {
      return isNight ? 'nfg' : 'fg';
    }

    // Haze
    if (forecastLower.contains('haze')) {
      return 'hz';
    }

    // Hot
    if (forecastLower.contains('hot')) {
      return 'hot';
    }

    // Cold
    if (forecastLower.contains('cold')) {
      return isNight ? 'ncold' : 'cold';
    }

    // Blizzard
    if (forecastLower.contains('blizzard')) {
      return isNight ? 'nblizzard' : 'blizzard';
    }

    print('Using default icon for: $forecastLower');
    return isNight ? 'novc' : 'ovc';
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

  Future<String> getHazardousWeatherOutlook() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.weather.gov/products/types/HWO/locations/BGM'),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['@graph'] != null && data['@graph'].isNotEmpty) {
          final latestProduct = data['@graph'][0];
          final productUrl = latestProduct['@id'];
          
          final productResponse = await http.get(
            Uri.parse(productUrl),
            headers: {'User-Agent': _userAgent},
          );
          
          if (productResponse.statusCode == 200) {
            final productData = json.decode(productResponse.body);
            final rawText = productData['productText'] ?? '';
            
            // Clean up the text
            final lines = rawText.split('\n');
            final cleanedLines = <String>[];
            bool startCollecting = false;
            String? lastSection = null;
            bool isFirstSection = true;
            
            for (final line in lines) {
              // Skip header lines until we find the area description
              if (line.contains('This Hazardous Weather Outlook is for')) {
                startCollecting = true;
              }
              
              if (startCollecting) {
                // Skip empty lines and certain header lines
                if (line.trim().isEmpty || 
                    line.contains('National Weather Service') ||
                    line.contains('AM EDT') ||
                    line.contains('HWOBGM')) {
                  continue;
                }
                
                // Stop at the end marker
                if (line.trim() == '\$\$') {
                  break;
                }

                // Check if this is a new section
                if (line.startsWith('.')) {
                  if (!isFirstSection) {
                    cleanedLines.add(''); // Add extra line break between sections
                  }
                  isFirstSection = false;
                  lastSection = line.split('...')[0];
                }
                
                cleanedLines.add(line);
              }
            }
            
            return cleanedLines.join('\n').trim();
          }
        }
      }
      return 'Unable to fetch Hazardous Weather Outlook';
    } catch (e) {
      print('Error fetching HWO: $e');
      return 'Error fetching Hazardous Weather Outlook';
    }
  }

  Future<Map<String, dynamic>> getCurrentConditions() async {
    try {
      // First, get the observation stations
      final stationsResponse = await http.get(
        Uri.parse('$_baseUrl/points/$_latitude,$_longitude/stations'),
        headers: {'User-Agent': _userAgent},
      );

      if (stationsResponse.statusCode != 200) {
        throw Exception('Failed to get stations: ${stationsResponse.statusCode}');
      }

      final stationsData = json.decode(stationsResponse.body);
      final stations = stationsData['features'] as List;
      
      if (stations.isEmpty) {
        throw Exception('No observation stations found');
      }

      // Get the latest observation from the first station
      final stationId = stations[0]['properties']['stationIdentifier'];
      final observationsResponse = await http.get(
        Uri.parse('$_baseUrl/stations/$stationId/observations/latest'),
        headers: {'User-Agent': _userAgent},
      );

      if (observationsResponse.statusCode != 200) {
        throw Exception('Failed to get observations: ${observationsResponse.statusCode}');
      }

      final observationData = json.decode(observationsResponse.body);
      final properties = observationData['properties'];
      
      // Extract and format the data
      final condition = properties['textDescription'] ?? '';
      final isNight = !(properties['isDaytime'] ?? true);
      
      return {
        'temperature': properties['temperature']['value']?.toDouble() ?? 0.0,
        'humidity': properties['relativeHumidity']['value']?.toDouble() ?? 0.0,
        'windSpeed': properties['windSpeed']['value']?.toDouble() ?? 0.0,
        'windDirection': properties['windDirection']['value']?.toString() ?? '',
        'pressure': properties['barometricPressure']['value']?.toDouble() ?? 0.0,
        'condition': condition,
        'iconName': _getIconName(condition, isNight),
        'isNight': isNight,
      };
    } catch (e) {
      debugPrint('Error fetching current conditions: $e');
      return {
        'temperature': 0.0,
        'humidity': 0.0,
        'windSpeed': 0.0,
        'windDirection': '',
        'pressure': 0.0,
        'condition': '',
        'iconName': 'skc',
        'isNight': false,
      };
    }
  }
} 