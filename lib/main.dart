import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cnyweatherapp/screens/main_navigation_screen.dart';
import 'package:cnyweatherapp/services/weather_service.dart';
import 'package:cnyweatherapp/repositories/weather_repository.dart';
import 'package:cnyweatherapp/services/cache_service.dart';
import 'package:cnyweatherapp/services/openweather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final cacheService = CacheService();
  await cacheService.init();
  
  final openWeatherService = OpenWeatherService('114f72c764fa4af6462ff1f35b2befb5');
  final weatherRepository = WeatherRepository(cacheService, openWeatherService);
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MainNavigationScreen(),
    );
  }
}
