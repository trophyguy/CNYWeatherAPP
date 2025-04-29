// **************************************************************************
// * WARNING: DO NOT MODIFY THIS FILE WITHOUT EXPLICIT APPROVAL                *
// * Changes to this file should be properly reviewed and authorized          *
// * Version: 1.1.0                                                          *
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/advisories_screen.dart';
import 'screens/radar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/webcams_screen.dart';
import 'services/weather_service.dart';
import 'repositories/weather_repository.dart';
import 'services/cache_service.dart';
import 'services/openweather_service.dart';
import 'services/purple_air_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final cacheService = CacheService();
  await cacheService.init();
  
  final openWeatherService = OpenWeatherService('114f72c764fa4af6462ff1f35b2befb5');
  final purpleAirService = PurpleAirService('0DA17F1E-D046-11EE-A056-42010A80000C', '211619');
  final weatherRepository = WeatherRepository(cacheService, openWeatherService, purpleAirService);
  final weatherService = WeatherService(weatherRepository, cacheService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherService>.value(value: weatherService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CNY Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue,
          labelTextStyle: MaterialStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          iconTheme: MaterialStatePropertyAll(
            IconThemeData(size: 24),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.black,
          indicatorColor: Colors.blue,
          labelTextStyle: MaterialStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          iconTheme: MaterialStatePropertyAll(
            IconThemeData(size: 24),
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Consumer<WeatherService>(
          builder: (context, weatherService, child) {
            final pages = <Widget>[
              const HomeScreen(),
              const RadarScreen(),
              ForecastScreen(forecast: weatherService.weatherData?.forecast ?? []),
              const AdvisoriesScreen(),
              const WebcamsScreen(),
            ];
            
            return pages[_selectedIndex];
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.radar_outlined),
              selectedIcon: Icon(Icons.radar),
              label: 'Radar',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Forecast',
            ),
            NavigationDestination(
              icon: Icon(Icons.warning_amber_outlined),
              selectedIcon: Icon(Icons.warning_amber),
              label: 'Advisories',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: 'Webcams',
            ),
          ],
        ),
      ),
    );
  }
}
