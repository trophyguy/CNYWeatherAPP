import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import 'home_screen.dart';
import 'radar_screen.dart';
import 'forecast_screen.dart';
import 'advisories_screen.dart';
import 'webcams_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int? initialIndex;
  
  const MainNavigationScreen({
    super.key,
    this.initialIndex,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherService>(
      builder: (context, weatherService, child) {
        final List<Widget> screens = [
          const HomeScreen(),
          const RadarScreen(),
          ForecastScreen(forecast: weatherService.weatherData?.forecast ?? []),
          const AdvisoriesScreen(),
          const WebcamsScreen(),
        ];

        return Scaffold(
          body: screens[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
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
        );
      },
    );
  }
} 