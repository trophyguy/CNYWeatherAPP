import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenWeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String _apiKey;

  OpenWeatherService(this._apiKey);

  Future<Map<String, dynamic>> getAirQuality(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'aqi': data['list'][0]['main']['aqi'],
          'components': data['list'][0]['components'],
        };
      } else {
        throw Exception('Failed to fetch air quality data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch air quality data: $e');
    }
  }
} 