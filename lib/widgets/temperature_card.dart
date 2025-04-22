import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class TemperatureCard extends StatefulWidget {
  final WeatherData weatherData;

  const TemperatureCard({
    Key? key,
    required this.weatherData,
  }) : super(key: key);

  @override
  State<TemperatureCard> createState() => _TemperatureCardState();
}

class _TemperatureCardState extends State<TemperatureCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temperature',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDataRow('Current', '${widget.weatherData.temperature}°F'),
            _buildDataRow('Feels Like', '${widget.weatherData.feelsLike}°F'),
            _buildDataRow('High Today', '${widget.weatherData.maxTemp}°F'),
            _buildDataRow('Low Today', '${widget.weatherData.minTemp}°F'),
            _buildDataRow('Humidity', '${widget.weatherData.humidity}%'),
            _buildDataRow('Dew Point', '${widget.weatherData.dewPoint}°F'),
            _buildDataRow('UV Index', widget.weatherData.uvIndex.toString()),
          ],
        ),
      ),
    );
  }

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
} 