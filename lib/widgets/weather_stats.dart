import 'package:flutter/material.dart';

class WeatherStats extends StatelessWidget {
  final double rainRate;
  final double solarRadiation;
  final double uvIndex;

  const WeatherStats({
    super.key,
    required this.rainRate,
    required this.solarRadiation,
    required this.uvIndex,
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
              'Additional Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              Icons.water_drop,
              'Rain Rate',
              '${rainRate.toStringAsFixed(2)} in/hr',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              Icons.wb_sunny,
              'Solar Radiation',
              '${solarRadiation.toStringAsFixed(1)} W/m²',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              Icons.sunny,
              'UV Index',
              uvIndex.toStringAsFixed(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
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