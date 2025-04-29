import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class CurrentConditionsCard extends StatelessWidget {
  final WeatherData weatherData;

  const CurrentConditionsCard({
    super.key,
    required this.weatherData,
  });

  Color _getAQIColor(double aqi) {
    if (aqi <= 1) return Colors.green;
    if (aqi <= 2) return Colors.yellow;
    if (aqi <= 3) return Colors.orange;
    if (aqi <= 4) return Colors.red;
    return Colors.purple;
  }

  String _getAQIDescription(double aqi) {
    if (aqi <= 1) return 'Good';
    if (aqi <= 2) return 'Fair';
    if (aqi <= 3) return 'Moderate';
    if (aqi <= 4) return 'Poor';
    return 'Very Poor';
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

  Widget _buildDataColumn(String value, String label, {Color? valueColor, String? description}) {
    Color? getAQIColor(double aqi) {
      if (aqi <= 50) return Colors.green;
      if (aqi <= 100) return Colors.yellow;
      if (aqi <= 150) return Colors.orange;
      if (aqi <= 200) return Colors.red;
      if (aqi <= 300) return Colors.purple;
      return Colors.brown; // Maroon color for hazardous
    }

    String? getAQIDescription(double aqi) {
      if (aqi <= 50) return 'Good';
      if (aqi <= 100) return 'Moderate';
      if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
      if (aqi <= 200) return 'Unhealthy';
      if (aqi <= 300) return 'Very Unhealthy';
      return 'Hazardous';
    }

    Color? getUVColor(double uv) {
      if (uv <= 2) return Colors.green;
      if (uv <= 5) return Colors.yellow;
      if (uv <= 7) return Colors.orange;
      if (uv <= 10) return Colors.red;
      return Colors.purple;
    }

    String? getUVDescription(double uv) {
      if (uv <= 2) return 'Low';
      if (uv <= 5) return 'Moderate';
      if (uv <= 7) return 'High';
      if (uv <= 10) return 'Very High';
      return 'Extreme';
    }

    final isAQI = label.toLowerCase().contains('aqi');
    final isUV = label.toLowerCase().contains('uv');
    final numValue = isAQI || isUV ? double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) : null;
    
    Color? effectiveValueColor;
    String? effectiveDescription;
    
    if (isAQI && numValue != null) {
      effectiveValueColor = getAQIColor(numValue);
      effectiveDescription = getAQIDescription(numValue);
    } else if (isUV && numValue != null) {
      effectiveValueColor = getUVColor(numValue);
      effectiveDescription = getUVDescription(numValue);
    } else {
      effectiveValueColor = valueColor;
      effectiveDescription = description;
    }

    return Container(
      height: 65,  // Fixed height for alignment
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,  // Align to top
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
            style: const TextStyle(fontSize: 12),
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
    debugPrint('CurrentConditionsCard - tempNoDecimal: ${weatherData.tempNoDecimal}');
    debugPrint('CurrentConditionsCard - temperature: ${weatherData.temperature}');
    
    // Debug prints for last year, record, and average temperatures
    debugPrint('\nCurrentConditionsCard - Last Year Temperatures:');
    debugPrint('maxTempLastYear: ${weatherData.maxTempLastYear}');
    debugPrint('minTempLastYear: ${weatherData.minTempLastYear}');
    
    debugPrint('\nCurrentConditionsCard - Record Temperatures:');
    debugPrint('maxTempRecord: ${weatherData.maxTempRecord}');
    debugPrint('minTempRecord: ${weatherData.minTempRecord}');
    
    debugPrint('\nCurrentConditionsCard - Average Temperatures:');
    debugPrint('maxTempAverage: ${weatherData.maxTempAverage}');
    debugPrint('minTempAverage: ${weatherData.minTempAverage}');
    
    // Check for new records
    final isNewRecordHigh = weatherData.maxTemp > weatherData.maxTempRecord;
    final isNewRecordLow = weatherData.minTemp < weatherData.minTempRecord;
    
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
                      Text(
                        '${weatherData.tempNoDecimal.toInt()}°',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                        ),
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
                          'assets/weather_icons/${weatherData.isNight ? "n" : ""}${weatherData.iconName}.png',
                          width: 64,
                          height: 64,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading icon: ${weatherData.iconName}');
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
                      isNewRecordHigh: isNewRecordHigh,
                      isNewRecordLow: isNewRecordLow),
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
                            '${weatherData.pressure.toStringAsFixed(2)}"',
                            'Pressure',
                            description: weatherData.pressureTrend,
                          ),
                          _buildDataColumn(
                            '${weatherData.dewPoint.toStringAsFixed(0)}°',
                            'Dew Point',
                          ),
                          _buildDataColumn(
                            '${weatherData.humidity.toStringAsFixed(0)}%',
                            'Humidity',
                          ),
                          _buildDataColumn(
                            '${weatherData.uvIndex.toInt()}',
                            'UV',
                          ),
                          _buildDataColumn(
                            '${weatherData.aqi.toStringAsFixed(0)}',
                            'AQI',
                            valueColor: _getAQIColor(weatherData.aqi),
                            description: _getAQIDescription(weatherData.aqi),
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