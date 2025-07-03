import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import './animated_value_text.dart';

class WindCard extends StatelessWidget {
  final WeatherData weatherData;

  const WindCard({
    super.key,
    required this.weatherData,
  });

  String _getFullDirection(String shortDirection) {
    switch (shortDirection.toUpperCase()) {
      case 'N': return 'North';
      case 'NNE': return 'North Northeast';
      case 'NE': return 'Northeast';
      case 'ENE': return 'East Northeast';
      case 'E': return 'East';
      case 'ESE': return 'East Southeast';
      case 'SE': return 'Southeast';
      case 'SSE': return 'South Southeast';
      case 'S': return 'South';
      case 'SSW': return 'South Southwest';
      case 'SW': return 'Southwest';
      case 'WSW': return 'West Southwest';
      case 'W': return 'West';
      case 'WNW': return 'West Northwest';
      case 'NW': return 'Northwest';
      case 'NNW': return 'North Northwest';
      default: return shortDirection;
    }
  }

  Widget _buildWindColumn(String value, String label, {String? subLabel}) {
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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wind',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWindColumn(
                  '${weatherData.windSpeed.round()} mph',
                  _getFullDirection(weatherData.windDirection),
                ),
                _buildWindColumn(
                  '${weatherData.windGust.round()} mph',
                  'Gust',
                ),
                _buildWindColumn(
                  '${weatherData.maxGust.round()} mph',
                  'Today\'s High',
                ),
                _buildWindColumn(
                  '${weatherData.monthlyHighWindGust.round()} mph',
                  'Monthly High',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 