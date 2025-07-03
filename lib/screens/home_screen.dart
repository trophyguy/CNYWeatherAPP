// **************************************************************************
// * WARNING: DO NOT MODIFY THIS FILE WITHOUT EXPLICIT APPROVAL                *
// * Changes to this file should be properly reviewed and authorized          *
// * Version: 1.1.0                                                          *
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../widgets/weather_advisory_card.dart';
import '../widgets/current_conditions_card.dart';
import '../widgets/wind_card.dart';
import '../widgets/precipitation_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/sun_moon_card.dart';
import '../widgets/animated_value_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherService = Provider.of<WeatherService>(context);
    final weatherData = weatherService.weatherData;
    final condition = weatherData?.condition ?? 'clear';
    final isNight = false; // Replace with your logic if you have night detection
    final iconPath = weatherService.getConditionIcon(condition, isNight: isNight);

    return Scaffold(
      appBar: AppBar(
        title: Consumer<WeatherService>(
          builder: (context, weatherService, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CNY Weather',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AnimatedValueText(
                  value: 'Last Updated: ${weatherService.weatherData?.updateTime ?? ''} ${weatherService.weatherData?.date ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  flashColor: Colors.orange,
                  flashOpacity: 0.7,
                  duration: const Duration(milliseconds: 1000),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear the cache
              if (context.mounted) {
                context.read<WeatherService>().fetchWeatherData();
              }
            },
          ),
        ],
      ),
      body: Consumer<WeatherService>(
        builder: (context, weatherService, child) {
          debugPrint('=== WEATHER_PERF: HomeScreen building with weatherData: ${weatherData != null} ===');
          if (weatherData == null) {
            debugPrint('=== WEATHER_PERF: Weather data is null, showing loading indicator ===');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Weather data now updating...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => weatherService.fetchWeatherData(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (weatherData.alerts.isEmpty)
                  Card(
                    color: Colors.green.shade700,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'No Active Weather Advisories',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MainNavigationScreen(initialIndex: 3),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.red.shade700,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              '${weatherData.alerts.length} Active Advisories',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                CurrentConditionsCard(
                  weatherData: weatherData,
                  iconPath: iconPath,
                ),
                const SizedBox(height: 16),
                WindCard(
                  weatherData: weatherData,
                ),
                const SizedBox(height: 16),
                PrecipitationCard(
                  weatherData: weatherData,
                ),
                const SizedBox(height: 16),
                ForecastCard(
                  weatherData: weatherData,
                ),
                const SizedBox(height: 16),
                SunMoonCard(
                  weatherData: weatherData,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}