import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/weather_service.dart';
import 'services/cache_service.dart';
import 'repositories/weather_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cache service
  final cacheService = CacheService();
  await cacheService.init();
  
  // Create repository and service
  final weatherRepository = WeatherRepository(cacheService);
  final weatherService = WeatherService(weatherRepository, cacheService);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherService>(
          create: (_) => weatherService,
        ),
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
      title: 'CNY Weather',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.green.shade300,
          secondary: Colors.green.shade300,
          surface: const Color(0xFF1E1E1E),
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardTheme(
          color: Colors.grey.shade900,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
