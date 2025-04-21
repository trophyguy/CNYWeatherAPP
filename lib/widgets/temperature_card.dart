import 'package:flutter/material.dart';

class TemperatureCard extends StatefulWidget {
  // ... (existing code)
}

class _TemperatureCardState extends State<TemperatureCard> {
  // ... (existing code)

  Widget _buildDataRow(String label, String value, {Color? valueColor}) {
    if (label == 'UV Index') {
      final uvValue = double.tryParse(value) ?? 0;
      if (uvValue <= 2) {
        valueColor = Colors.green;
      } else if (uvValue <= 5) {
        valueColor = Colors.yellow;
      } else if (uvValue <= 7) {
        valueColor = Colors.orange;
      } else if (uvValue <= 10) {
        valueColor = Colors.red;
      } else {
        valueColor = Colors.purple;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ... (rest of the existing code)
} 