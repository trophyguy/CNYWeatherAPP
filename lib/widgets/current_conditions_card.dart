import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class CurrentConditionsCard extends StatelessWidget {
  final WeatherData weatherData;

  const CurrentConditionsCard({
    super.key,
    required this.weatherData,
  });

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
                        '${weatherData.feelsLike > 50 ? 'Heat Index' : 'Wind Chill'}: ${weatherData.feelsLike.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.cloud,
                      size: 64,
                      color: Colors.white70,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDataColumn('${weatherData.humidity.toInt()}%', 'Humidity'),
                  _buildDataColumn('${weatherData.pressure.toStringAsFixed(2)}"', 'Pressure'),
                  _buildDataColumn('${weatherData.dewPoint.toInt()}°', 'Dew Point'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          Text(
            isNewRecordHigh && isNewRecordLow 
                ? '* New Record High & Low' 
                : isNewRecordHigh 
                    ? '* New Record High' 
                    : '* New Record Low',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.amber,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDataColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 