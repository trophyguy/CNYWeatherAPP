// **************************************************************************
// * WARNING: DO NOT MODIFY THIS FILE WITHOUT EXPLICIT APPROVAL                *
// * Changes to this file should be properly reviewed and authorized          *
// * Version: 1.1.0                                                          *
// **************************************************************************

import 'package:flutter/material.dart';
import '../models/forecast_data.dart';
import 'package:intl/intl.dart';

class ForecastScreen extends StatelessWidget {
  final List<ForecastPeriod> forecast;

  const ForecastScreen({
    super.key,
    required this.forecast,
  });

  Widget _buildForecastPeriod(ForecastPeriod period) {
    String iconPath = 'assets/weather_icons/${period.iconName}.png';
    debugPrint('Building forecast period:');
    debugPrint('  Condition: ${period.condition}');
    debugPrint('  Is Night: ${period.isNight}');
    debugPrint('  Icon Name: ${period.iconName}');
    debugPrint('  Full Icon Path: $iconPath');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              period.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  '${period.temperature.round()}°F',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: period.isNight ? Colors.blue : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
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
                ),
              ],
            ),
          ],
        ),
        subtitle: Text(
          period.condition,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              period.detailedForecast,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Forecast'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        itemCount: forecast.length,
        itemBuilder: (context, index) => _buildForecastPeriod(forecast[index]),
      ),
    );
  }
} 