import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import './animated_value_text.dart';

class CurrentConditionsCard extends StatelessWidget {
  final WeatherData weatherData;
  final String iconPath;

  const CurrentConditionsCard({
    super.key,
    required this.weatherData,
    required this.iconPath,
  });

  Color _getAQIColor(double aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.deepPurple;
  }

  String _getAQIDescription(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color _getUVColor(double uv) {
    if (uv <= 2) return Colors.green;
    if (uv <= 5) return Colors.yellow;
    if (uv <= 7) return Colors.orange;
    if (uv <= 10) return Colors.red;
    return Colors.purple;
  }

  String _getUVDescription(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  Widget _buildTemperatureColumn(String label, int high, int low, {bool isNewRecordHigh = false, bool isNewRecordLow = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14),
            children: [
              TextSpan(
                text: 'Hi ${high}°${isNewRecordHigh ? '*' : ''}\n',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
              TextSpan(
                text: 'Lo ${low}°${isNewRecordLow ? '*' : ''}',
                style: const TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        if (isNewRecordHigh || isNewRecordLow) ...[
          const SizedBox(height: 4),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 10,
                color: Colors.amber,
              ),
              children: [
                const TextSpan(text: '*New\n'),
                TextSpan(
                  text: isNewRecordHigh && isNewRecordLow 
                      ? 'Record Hi/Lo' 
                      : isNewRecordHigh 
                          ? 'Record Hi' 
                          : 'Record Lo',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDataColumn(
    String value,
    String label, {
    String? description,
    Color? valueColor,
  }) {
    final effectiveValueColor = valueColor ?? Colors.white;
    final effectiveDescription = description;

    return Container(
      height: 65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: effectiveValueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          if (effectiveDescription != null) ...[
            const SizedBox(height: 2),
            Text(
              effectiveDescription,
              style: TextStyle(
                fontSize: 10,
                color: effectiveValueColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CurrentConditionsCard build: \u001b[33m\u001b[1m[0m');
    debugPrint('Current condition: [33m${weatherData.condition}[0m');
    debugPrint('Current iconName: [33m${weatherData.iconName}[0m');
    debugPrint('Current icon asset path: assets/weather_icons/${weatherData.iconName}.png');
    return RepaintBoundary(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedValueText(
                        value: '${weatherData.tempNoDecimal.toStringAsFixed(1)}°F',
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        flashColor: Colors.orange,
                        flashOpacity: 0.7,
                        duration: const Duration(milliseconds: 1000),
                      ),
                      Text(
                        '${weatherData.tempChangeHour > 0 ? '+' : ''}${weatherData.tempChangeHour.toStringAsFixed(1)}° in last hour',
                        style: TextStyle(
                          fontSize: 16,
                          color: weatherData.tempChangeHour > 0 ? Colors.red : Colors.blue,
                        ),
                      ),
                      Text(
                        '${weatherData.feelsLike > 50 ? 'Heat Index' : 'Wind Chill'}: ${weatherData.feelsLike.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          iconPath,
                          width: 64,
                          height: 64,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading icon: $iconPath');
                            return const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 64,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weatherData.condition,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTemperatureColumn('Today', 
                      weatherData.maxTemp.toInt(), 
                      weatherData.minTemp.toInt(),
                      isNewRecordHigh: weatherData.maxTemp > weatherData.maxTempRecord,
                      isNewRecordLow: weatherData.minTemp < weatherData.minTempRecord),
                    const SizedBox(width: 16),
                    _buildTemperatureColumn('Yesterday', 
                      weatherData.maxTempYesterday.toInt(), 
                      weatherData.minTempYesterday.toInt()),
                    const SizedBox(width: 16),
                    _buildTemperatureColumn('Last Year', 
                      weatherData.maxTempLastYear.toInt(), 
                      weatherData.minTempLastYear.toInt()),
                    const SizedBox(width: 16),
                    _buildTemperatureColumn('Record', 
                      weatherData.maxTempRecord.toInt(), 
                      weatherData.minTempRecord.toInt()),
                    const SizedBox(width: 16),
                    _buildTemperatureColumn('Average', 
                      weatherData.maxTempAverage.toInt(), 
                      weatherData.minTempAverage.toInt()),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: constraints.maxWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDataColumn(
                            '${weatherData.pressure?.toStringAsFixed(2) ?? "0.00"}"',
                            'Pressure',
                            description: weatherData.pressureTrend,
                          ),
                          _buildDataColumn(
                            '${weatherData.dewPoint?.toStringAsFixed(0) ?? "0"}°',
                            'Dew Point',
                          ),
                          _buildDataColumn(
                            '${weatherData.humidity?.toStringAsFixed(0) ?? "0"}%',
                            'Humidity',
                          ),
                          _buildDataColumn(
                            '${weatherData.uvIndex?.toInt() ?? 0}',
                            'UV',
                            valueColor: _getUVColor(weatherData.uvIndex ?? 0),
                            description: _getUVDescription(weatherData.uvIndex ?? 0),
                          ),
                          _buildDataColumn(
                            '${weatherData.aqi?.toStringAsFixed(0) ?? "N/A"}',
                            'AQI',
                            valueColor: _getAQIColor(weatherData.aqi ?? 0),
                            description: _getAQIDescription(weatherData.aqi ?? 0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 