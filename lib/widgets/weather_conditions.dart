import 'package:flutter/material.dart';

class WeatherConditions extends StatelessWidget {
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double pressure;

  const WeatherConditions({
    super.key,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Conditions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildConditionRow(
              context,
              Icons.water_drop,
              'Humidity',
              '${humidity.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            _buildConditionRow(
              context,
              Icons.air,
              'Wind',
              '${windSpeed.toStringAsFixed(1)} mph $windDirection',
            ),
            const SizedBox(height: 8),
            _buildConditionRow(
              context,
              Icons.speed,
              'Pressure',
              '${pressure.toStringAsFixed(2)} inHg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 16),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
} 