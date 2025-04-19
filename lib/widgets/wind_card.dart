import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class WindCard extends StatelessWidget {
  final WeatherData weather;

  const WindCard({
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
              'Wind',
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
                _buildWindItem(
                  '${weather.windSpeed.round()} mph',
                  weather.windDirection,
                ),
                _buildWindItem('5 mph', 'Gust'),
                _buildWindItem('20 mph', 'Max Day'),
                _buildWindItem('26 mph', 'Month Gust'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindItem(String value, String label) {
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