import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../models/weather_alert.dart';

class AdvisoriesScreen extends StatelessWidget {
  const AdvisoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Advisories'),
      ),
      body: Consumer<WeatherService>(
        builder: (context, weatherService, child) {
          if (weatherService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (weatherService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${weatherService.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      weatherService.fetchWeatherData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final alerts = weatherService.weatherData?.alerts ?? [];
          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Active Advisories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'There are no active weather advisories for the selected areas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final alertColor = _getAlertColor(alert.severity);
              final lightAlertColor = alertColor.withOpacity(0.1);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                color: lightAlertColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: alertColor,
                    width: 2.0,
                  ),
                ),
                child: ExpansionTile(
                  title: Text(
                    alert.event,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: alertColor,
                    ),
                  ),
                  subtitle: Text(
                    '${alert.area} - ${alert.effective}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  leading: Icon(
                    _getAlertIcon(alert.severity),
                    color: alertColor,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.description,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Issued: ${alert.issued}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          if (alert.expires != null)
                            Text(
                              'Expires: ${alert.expires}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getAlertIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
      case 'severe':
        return Icons.warning_amber;
      case 'moderate':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return const Color(0xFFDC143C); // Crimson for Hurricane/Typhoon Warning
      case 'severe':
        return const Color(0xFFFF0000); // Red for Tornado Warning
      case 'moderate':
        return const Color(0xFFFFA500); // Orange for Severe Thunderstorm Warning
      case 'minor':
        return const Color(0xFF8B0000); // Darkred for Flash Flood Warning
      case 'watch':
        return const Color(0xFFFFFF00); // Yellow for Tornado Watch
      case 'advisory':
        return const Color(0xFF00FFFF); // Aqua for Special Marine Warning
      case 'statement':
        return const Color(0xFF00FFFF); // Aqua for Severe Weather Statement
      case 'winter':
        return const Color(0xFFFF4500); // Orangered for Blizzard Warning
      case 'flood':
        return const Color(0xFF00FF00); // Lime for Flood Warning
      case 'coastal':
        return const Color(0xFF228B22); // Forestgreen for Coastal Flood Warning
      case 'heat':
        return const Color(0xFFC71585); // Mediumvioletred for Excessive Heat Warning
      case 'fire':
        return const Color(0xFFFF1493); // Deeppink for Red Flag Warning
      case 'wind':
        return const Color(0xFF90EE90); // Lightgreen for Wind Advisory
      case 'avalanche':
        return const Color(0xFF1E90FF); // Dodgerblue for Avalanche Warning
      case 'dust':
        return const Color(0xFFFFE4C4); // Bisque for Dust Storm Warning
      case 'freeze':
        return const Color(0xFF00FFFF); // Cyan for Freeze Warning
      case 'gale':
        return const Color(0xFF9400D3); // Darkviolet for Gale Warning
      case 'tropical':
        return const Color(0xFFB22222); // Firebrick for Tropical Storm Warning
      case 'ice':
        return const Color(0xFF8B008B); // Darkmagenta for Ice Storm Warning
      case 'snow':
        return const Color(0xFF8A2BE2); // Blueviolet for Heavy Snow Warning
      case 'tsunami':
        return const Color(0xFFFD6347); // Tomato for Tsunami Warning
      case 'volcano':
        return const Color(0xFF696969); // Dimgray for Volcano Warning
      case 'earthquake':
        return const Color(0xFF8B4513); // Saddlebrown for Earthquake Warning
      case 'hazardous':
        return const Color(0xFF4B0082); // Indigo for Hazardous Materials Warning
      case 'civil':
        return const Color(0xFFFFB6C1); // Lightpink for Civil Danger Warning
      case 'evacuation':
        return const Color(0xFF7FFF00); // Chartreuse for Evacuation - Immediate
      case 'shelter':
        return const Color(0xFFFA8072); // Salmon for Shelter In Place Warning
      default:
        return const Color(0xFF1E90FF); // Dodger Blue for other alerts
    }
  }
} 