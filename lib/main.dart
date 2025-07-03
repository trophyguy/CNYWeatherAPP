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
import 'screens/weather_alerts_screen.dart';
import 'services/weather_service.dart';
import 'repositories/weather_repository.dart';
import 'services/cache_service.dart';
import 'services/purpleair_service.dart';
import 'services/nws_service_cap.dart';
import 'services/notification_service.dart';
import 'services/nws_service_base.dart';
import 'models/settings.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  debugPrint('=== WEATHER_PERF: main() starting runApp ===');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create navigator key for notification handling
  final navigatorKey = GlobalKey<NavigatorState>();
  
  debugPrint('=== WEATHER_PERF: Initializing CacheService ===');
  // Initialize services
  final cacheService = CacheService();
  await cacheService.init();
  await cacheService.populateWithDefaultIfEmpty();
  
  debugPrint('=== WEATHER_PERF: Initializing PurpleAirService ===');
  // Initialize PurpleAir service with API key and sensor ID
  final purpleAirService = PurpleAirService(
    '0DA17F1E-D046-11EE-A056-42010A80000C', // API key
    '211619' // Sensor ID
  );
  
  debugPrint('=== WEATHER_PERF: Loading Settings ===');
  // Load settings first
  final settings = await Settings.load();
  
  debugPrint('=== WEATHER_PERF: Initializing NotificationService ===');
  // Initialize notification service with navigator key
  final notificationService = NotificationService(navigatorKey);
  await notificationService.initialize();
  
  debugPrint('=== WEATHER_PERF: Initializing NWSService ===');
  // Initialize NWS service with notifications and settings
  final nwsService = NWSServiceCAP(notificationService, settings);
  await nwsService.initialize();
  
  debugPrint('=== WEATHER_PERF: Initializing Repository and WeatherService ===');
  // Initialize repository and weather service
  final weatherRepository = WeatherRepository(
    cacheService,
    purpleAirService,
    settings,
    notificationService,
  );
  final weatherService = WeatherService(
    weatherRepository,
    cacheService,
    settings,
    purpleAirService,
    notificationService,
  );

  debugPrint('=== WEATHER_PERF: Starting runApp ===');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => weatherService),
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'CNY Weather App Template',
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
        routes: {
          '/alerts': (context) => WeatherAlertsScreen(
            weatherService: Provider.of<WeatherService>(context, listen: false),
          ),
        },
      ),
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
      home: const MainNavigationScreen(),
    );
  }
}
