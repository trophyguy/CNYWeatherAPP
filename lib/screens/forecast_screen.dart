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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and time
            Row(
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
              ],
            ),
            const SizedBox(height: 16),
            // Weather icon and conditions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather icon with fixed size
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading icon: $iconPath');
                      debugPrint('Error details: $error');
                      return const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Weather details with fixed height
                Expanded(
                  child: SizedBox(
                    height: 64, // Fixed height to match icon
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Condition text with wrapping
                        Flexible(
                          child: Text(
                            period.condition,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Temperature row
                        Row(
                          children: [
                            Text(
                              period.isNight ? 'Lo ' : 'Hi ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              '${period.temperature.round()}°F',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: period.isNight ? Colors.blue : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Detailed forecast with consistent spacing and wrapping
            SizedBox(
              height: 72, // Fixed height to accommodate up to 3 lines of text
              child: SingleChildScrollView(
                child: Text(
                  period.detailedForecast,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
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