import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class MainWeatherCard extends StatelessWidget {
  final WeatherData weather;

  const MainWeatherCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('MainWeatherCard - tempNoDecimal: ${weather.tempNoDecimal}');
    debugPrint('MainWeatherCard - temperature: ${weather.temperature}');
    return RepaintBoundary(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(1)}°',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Updated: ${weather.time}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonColumn(String title, String high, String low) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          high,
          style: TextStyle(
            color: Colors.red[300],
            fontSize: 12,
          ),
        ),
        Text(
          low,
          style: TextStyle(
            color: Colors.blue[300],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 