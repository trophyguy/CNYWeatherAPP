import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import './animated_value_text.dart';

class PrecipitationCard extends StatelessWidget {
  final WeatherData weatherData;

  const PrecipitationCard({
    super.key,
    required this.weatherData,
  });

  Widget _buildRainColumn(String value, String label, {String? subLabel}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedValueText(
          value: value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          flashColor: Colors.orange,
          flashOpacity: 0.7,
          duration: const Duration(milliseconds: 1000),
        ),
        const SizedBox(height: 2),
        AnimatedValueText(
          value: label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          flashColor: Colors.orange,
          flashOpacity: 0.7,
          duration: const Duration(milliseconds: 1000),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 1),
          AnimatedValueText(
            value: subLabel,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            flashColor: Colors.orange,
            flashOpacity: 0.7,
            duration: const Duration(milliseconds: 1000),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRainRate = weatherData.currentRainRate != null && weatherData.currentRainRate.toStringAsFixed(3) != '0.000';
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Precipitation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (showRainRate) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${weatherData.currentRainRate.toStringAsFixed(2)} in/hr)',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.titleLarge?.fontSize ?? 18,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRainColumn(
                  '${weatherData.dailyRain.toStringAsFixed(2)}"',
                  'Today',
                ),
                _buildRainColumn(
                  '${weatherData.yesterdayRain.toStringAsFixed(2)}"',
                  'Yesterday',
                ),
                _buildRainColumn(
                  '${weatherData.monthlyRain.toStringAsFixed(2)}"',
                  'Month',
                ),
                _buildRainColumn(
                  '${weatherData.yearlyRain.toStringAsFixed(2)}"',
                  'Year',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 