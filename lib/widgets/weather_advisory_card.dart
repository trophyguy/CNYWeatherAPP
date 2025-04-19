import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import 'package:timeago/timeago.dart' as timeago;

class WeatherAdvisoryCard extends StatelessWidget {
  final List<WeatherAdvisory> advisories;

  const WeatherAdvisoryCard({
    Key? key,
    required this.advisories,
  }) : super(key: key);

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getAdvisoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'storm':
        return Icons.thunderstorm;
      case 'flood':
        return Icons.water;
      case 'wind':
        return Icons.air;
      case 'heat':
        return Icons.whatshot;
      case 'cold':
        return Icons.ac_unit;
      default:
        return Icons.warning;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return timeago.format(timestamp);
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return timestamp.toString().substring(0, 16); // YYYY-MM-DD HH:mm
    }
  }

  @override
  Widget build(BuildContext context) {
    if (advisories.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('No active weather advisories'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Advisories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...advisories.map((advisory) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(advisory.severity).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAdvisoryIcon(advisory.type),
                      color: _getSeverityColor(advisory.severity),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advisory.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          advisory.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(advisory.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}