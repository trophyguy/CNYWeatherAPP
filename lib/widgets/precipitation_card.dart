import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class PrecipitationCard extends StatelessWidget {
  final WeatherData weather;

  const PrecipitationCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Precipitation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPrecipItem('${weather.dailyRain.toStringAsFixed(2)}"', 'Today'),
                _buildPrecipItem('${weather.yesterdayRain.toStringAsFixed(2)}"', 'Yesterday'),
                _buildPrecipItem('${weather.monthlyRain.toStringAsFixed(2)}"', 'Month'),
                _buildPrecipItem('${weather.yearlyRain.toStringAsFixed(2)}"', 'Year'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecipItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 