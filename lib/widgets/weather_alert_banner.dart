import 'package:flutter/material.dart';

class WeatherAlertBanner extends StatelessWidget {
  final int alertCount;

  const WeatherAlertBanner({
    super.key,
    required this.alertCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.red.shade900,
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '$alertCount Active Weather Advisories',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // Navigate to advisories
            },
            icon: const Text(
              'View',
              style: TextStyle(color: Colors.white),
            ),
            label: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }
} 