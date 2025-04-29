import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PurpleAirService {
  final String _apiKey;
  final String _sensorId;
  static const String _baseUrl = 'https://api.purpleair.com/v1/sensors';

  PurpleAirService(this._apiKey, this._sensorId);

  Future<Map<String, dynamic>> getAQIData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$_sensorId'),
        headers: {
          'X-API-Key': _apiKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final stats = jsonData['sensor']['stats_a'];
        
        // Get the 10-minute average PM2.5 value
        final pm25_10min = stats['pm2.5_10minute']?.toDouble() ?? 0.0;
        
        // Calculate AQI from PM2.5
        final aqi = _calculateAQI(pm25_10min);
        
        // Get AQI description
        final description = _getAQIDescription(aqi);
        
        return {
          'aqi': aqi,
          'pm25_10min': pm25_10min,
          'description': description,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        debugPrint('Error fetching Purple Air data: ${response.statusCode}');
        throw Exception('Failed to fetch Purple Air data');
      }
    } catch (e) {
      debugPrint('Error in PurpleAirService: $e');
      rethrow;
    }
  }

  int _calculateAQI(double pm25) {
    if (pm25.isNaN || pm25 < 0) return 0;
    if (pm25 > 1000) return 500;

    if (pm25 > 350.5) {
      return _calcAQI(pm25, 500.0, 401.0, 500.0, 350.5);
    } else if (pm25 > 250.5) {
      return _calcAQI(pm25, 400.0, 301.0, 350.4, 250.5);
    } else if (pm25 > 150.5) {
      return _calcAQI(pm25, 300.0, 201.0, 250.4, 150.5);
    } else if (pm25 > 55.5) {
      return _calcAQI(pm25, 200.0, 151.0, 150.4, 55.5);
    } else if (pm25 > 35.5) {
      return _calcAQI(pm25, 150.0, 101.0, 55.4, 35.5);
    } else if (pm25 > 12.1) {
      return _calcAQI(pm25, 100.0, 51.0, 35.4, 12.1);
    } else if (pm25 >= 0.0) {
      return _calcAQI(pm25, 50.0, 0.0, 12.0, 0.0);
    } else {
      return 0;
    }
  }

  int _calcAQI(double cp, double ih, double il, double bph, double bpl) {
    final a = (ih - il);
    final b = (bph - bpl);
    final c = (cp - bpl);
    return ((a / b) * c + il).round();
  }

  String _getAQIDescription(int aqi) {
    if (aqi >= 401) return 'Hazardous';
    if (aqi >= 301) return 'Hazardous';
    if (aqi >= 201) return 'Very Unhealthy';
    if (aqi >= 151) return 'Unhealthy';
    if (aqi >= 101) return 'Unhealthy';
    if (aqi >= 51) return 'Moderate';
    if (aqi >= 0) return 'Good';
    return 'Unknown';
  }
} 