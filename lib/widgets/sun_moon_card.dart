import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class SunMoonCard extends StatelessWidget {
  final WeatherData weatherData;

  const SunMoonCard({
    super.key,
    required this.weatherData,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString()}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _getDaylightChange(Duration change) {
    final minutes = change.inMinutes.abs();
    final sign = change.isNegative ? '-' : '+';
    return '$sign${minutes ~/ 60}h ${minutes % 60}m';
  }

  String _formatDaylightHours(double hours) {
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    return '${wholeHours}h ${minutes}m';
  }

  String _getMoonPhaseIcon(double phase) {
    // Moon phase is typically represented as a number between 0 and 1
    // 0/1: New Moon
    // 0.25: First Quarter
    // 0.5: Full Moon
    // 0.75: Last Quarter
    if (phase <= 0.05 || phase > 0.95) return '🌑'; // New Moon
    if (phase <= 0.20) return '🌒'; // Waxing Crescent
    if (phase <= 0.30) return '🌓'; // First Quarter
    if (phase <= 0.45) return '🌔'; // Waxing Gibbous
    if (phase <= 0.55) return '🌕'; // Full Moon
    if (phase <= 0.70) return '🌖'; // Waning Gibbous
    if (phase <= 0.80) return '🌗'; // Last Quarter
    return '🌘'; // Waning Crescent
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sun & Moon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getMoonPhaseIcon(weatherData.moonPhase),
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sun information (left side)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.wb_sunny,
                              color: Colors.amber,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sun',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Rise', _formatTime(weatherData.sunrise)),
                        _buildInfoRow('Set', _formatTime(weatherData.sunset)),
                        _buildInfoRow('Daylight', _formatDaylightHours(weatherData.possibleDaylight)),
                        _buildInfoRow('Change', _getDaylightChange(weatherData.daylightChange)),
                      ],
                    ),
                  ),
                  // Vertical divider
                  const VerticalDivider(
                    color: Colors.white24,
                    width: 32,
                    thickness: 1,
                  ),
                  // Moon information (right side)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getMoonPhaseIcon(weatherData.moonPhase),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Moon',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Rise', _formatTime(weatherData.moonrise)),
                        _buildInfoRow('Set', _formatTime(weatherData.moonset)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phase',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weatherData.moonPhaseName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ],
                    ),
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