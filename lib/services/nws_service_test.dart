import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/weather_alert.dart';

class NWSServiceTest {
  static const String _baseUrl = 'https://api.weather.gov';
  static const String _userAgent = 'CNYWeatherApp/1.0 (tony@example.com)';
  
  // Test zones
  static const List<String> _zones = [
    'MSZ037', // Attala
    'MSZ038', // Holmes
  ];

  // Clean up resources
  void dispose() {
    // Nothing to clean up in this test version
  }

  Future<List<WeatherAlert>> getAlerts() async {
    debugPrint('\n=== Starting getAlerts() Test Version ===');
    final List<WeatherAlert> allAlerts = [];

    // Try both zone and county parameters
    for (final zone in _zones) {
      debugPrint('\nFetching alerts for zone: $zone');
      try {
        // Try zone parameter
        final zoneUrl = Uri.parse('$_baseUrl/alerts/active?zone=$zone');
        debugPrint('Zone URL: $zoneUrl');
        
        final zoneResponse = await http.get(
          zoneUrl,
          headers: {
            'User-Agent': _userAgent,
            'Accept': 'application/geo+json',
          },
        );
        
        debugPrint('Zone $zone response status: ${zoneResponse.statusCode}');
        
        if (zoneResponse.statusCode == 200) {
          final data = json.decode(zoneResponse.body);
          debugPrint('Zone response body: ${zoneResponse.body}');
          
          final features = data['features'] as List;
          debugPrint('Found ${features.length} alerts for zone $zone');
          
          for (final feature in features) {
            final properties = feature['properties'] as Map<String, dynamic>;
            debugPrint('Processing alert: ${properties['event']} for ${properties['areaDesc']}');
            
            if (properties['event'] == null || 
                properties['event'].toString().toLowerCase().contains('no active')) {
              continue;
            }
            
            final colors = WeatherAlert.getAlertColors(
              properties['event']?.toString().toLowerCase() ?? '',
              properties['severity']?.toString().toLowerCase() ?? '',
            );
            
            final alert = WeatherAlert(
              id: feature['id'] as String,
              event: properties['event'] ?? '',
              severity: properties['severity']?.toLowerCase() ?? '',
              urgency: properties['urgency']?.toLowerCase() ?? '',
              certainty: properties['certainty']?.toLowerCase() ?? '',
              area: properties['areaDesc'] ?? '',
              description: properties['description'] ?? '',
              effective: properties['effective'] ?? '',
              expires: properties['expires'] ?? '',
              instruction: properties['instruction'] ?? '',
              status: properties['status'] ?? '',
              scope: properties['scope'] ?? '',
              msgType: properties['messageType'] ?? '',
              issued: properties['sent'] ?? '',
              backgroundColor: colors['backgroundColor'] ?? '#FFFFFF',
              textColor: colors['textColor'] ?? '#000000',
            );
            allAlerts.add(alert);
          }
        }
        
        // Try county parameter
        final countyCode = zone.replaceAll('Z', 'C');
        final countyUrl = Uri.parse('$_baseUrl/alerts/active?county=$countyCode');
        debugPrint('County URL: $countyUrl');
        
        final countyResponse = await http.get(
          countyUrl,
          headers: {
            'User-Agent': _userAgent,
            'Accept': 'application/geo+json',
          },
        );
        
        debugPrint('County $countyCode response status: ${countyResponse.statusCode}');
        
        if (countyResponse.statusCode == 200) {
          final data = json.decode(countyResponse.body);
          debugPrint('County response body: ${countyResponse.body}');
          
          final features = data['features'] as List;
          debugPrint('Found ${features.length} alerts for county $countyCode');
          
          for (final feature in features) {
            final properties = feature['properties'] as Map<String, dynamic>;
            debugPrint('Processing alert: ${properties['event']} for ${properties['areaDesc']}');
            
            if (properties['event'] == null || 
                properties['event'].toString().toLowerCase().contains('no active')) {
              continue;
            }
            
            final colors = WeatherAlert.getAlertColors(
              properties['event']?.toString().toLowerCase() ?? '',
              properties['severity']?.toString().toLowerCase() ?? '',
            );
            
            final alert = WeatherAlert(
              id: feature['id'] as String,
              event: properties['event'] ?? '',
              severity: properties['severity']?.toLowerCase() ?? '',
              urgency: properties['urgency']?.toLowerCase() ?? '',
              certainty: properties['certainty']?.toLowerCase() ?? '',
              area: properties['areaDesc'] ?? '',
              description: properties['description'] ?? '',
              effective: properties['effective'] ?? '',
              expires: properties['expires'] ?? '',
              instruction: properties['instruction'] ?? '',
              status: properties['status'] ?? '',
              scope: properties['scope'] ?? '',
              msgType: properties['messageType'] ?? '',
              issued: properties['sent'] ?? '',
              backgroundColor: colors['backgroundColor'] ?? '#FFFFFF',
              textColor: colors['textColor'] ?? '#000000',
            );
            allAlerts.add(alert);
          }
        }
      } catch (e) {
        debugPrint('Error fetching alerts for $zone: $e');
      }
    }
    
    // Remove duplicates
    final uniqueAlerts = <String, WeatherAlert>{};
    for (final alert in allAlerts) {
      final uniqueKey = '${alert.event}-${alert.area}-${alert.effective}';
      if (!uniqueAlerts.containsKey(uniqueKey)) {
        uniqueAlerts[uniqueKey] = alert;
      }
    }
    
    final result = uniqueAlerts.values.toList();
    debugPrint('\nTotal unique alerts found: ${result.length}');
    for (final alert in result) {
      debugPrint('Alert: ${alert.event} for ${alert.area}');
    }
    
    return result;
  }
} 