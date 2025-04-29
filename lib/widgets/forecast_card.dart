import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../screens/forecast_screen.dart';
import '../screens/main_navigation_screen.dart';

class ForecastCard extends StatelessWidget {
  final WeatherData weatherData;

  const ForecastCard({super.key, required this.weatherData});

  Widget _buildForecastPeriod(ForecastPeriod period) {
    String iconPath = 'assets/weather_icons/${period.iconName}.png';
    debugPrint('Building forecast period:');
    debugPrint('  Condition: ${period.condition}');
    debugPrint('  Is Night: ${period.isNight}');
    debugPrint('  Icon Name: ${period.iconName}');
    debugPrint('  Full Icon Path: $iconPath');
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            period.shortName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Image.asset(
            iconPath,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading icon: $iconPath');
              debugPrint('Error details: $error');
              return const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            period.condition,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Text(
            '${period.isNight ? "Lo" : "Hi"} ${period.temperature.round()}°',
            style: TextStyle(
              fontSize: 14,
              color: period.isNight ? Colors.blue : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (period.popPercent > 0)
            Text(
              'POP ${period.popPercent}%',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.lightBlue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 120,
      color: Colors.white24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(initialIndex: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Forecast',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (weatherData.forecast.isEmpty)
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
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < min(4, weatherData.forecast.length); i++) ...[
                      if (i > 0) _buildDivider(),
                      _buildForecastPeriod(weatherData.forecast[i]),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
} 