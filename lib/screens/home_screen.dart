import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../widgets/weather_advisory_card.dart';
import '../widgets/current_conditions_card.dart';
import '../widgets/wind_card.dart';
import '../widgets/precipitation_card.dart';
import '../widgets/forecast_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<WeatherService>(
          builder: (context, weatherService, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CNY Weather'),
                Text(
                  'Last Updated: ${weatherService.weatherData?.lastUpdatedTime ?? ''} ${weatherService.weatherData?.lastUpdatedDate ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
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

          final weatherData = weatherService.weatherData;
          if (weatherData == null) {
            return const Center(
              child: Text('No weather data available'),
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
                ),
                const SizedBox(height: 16),
                WindCard(
                  weatherData: weatherData,
                ),
                const SizedBox(height: 16),
                PrecipitationCard(
                  weather: weatherData,
                ),
                const SizedBox(height: 16),
                ForecastCard(
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