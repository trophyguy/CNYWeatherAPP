import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class ForecastCard extends StatelessWidget {
  final WeatherData weatherData;

  const ForecastCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement forecast data in WeatherData model
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forecast',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Placeholder for forecast data
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_queue,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Forecast data coming soon',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 