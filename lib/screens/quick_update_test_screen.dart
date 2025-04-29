import 'package:flutter/material.dart';
import '../repositories/weather_repository.dart';
import '../services/cache_service.dart';
import '../services/purple_air_service.dart';
import '../services/openweather_service.dart';
import '../config/api_keys.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickUpdateTestScreen extends StatefulWidget {
  const QuickUpdateTestScreen({super.key});

  @override
  State<QuickUpdateTestScreen> createState() => _QuickUpdateTestScreenState();
}

class _QuickUpdateTestScreenState extends State<QuickUpdateTestScreen> {
  String _updateStatus = 'No update performed yet';
  bool _isUpdating = false;
  WeatherRepository? _weatherRepo;
  final _timeFormat = DateFormat('HH:mm:ss');

  String _getWindDirection(String degrees) {
    try {
      final deg = double.parse(degrees);
      if (deg >= 337.5 || deg < 22.5) return 'N';
      if (deg >= 22.5 && deg < 67.5) return 'NE';
      if (deg >= 67.5 && deg < 112.5) return 'E';
      if (deg >= 112.5 && deg < 157.5) return 'SE';
      if (deg >= 157.5 && deg < 202.5) return 'S';
      if (deg >= 202.5 && deg < 247.5) return 'SW';
      if (deg >= 247.5 && deg < 292.5) return 'W';
      if (deg >= 292.5 && deg < 337.5) return 'NW';
    } catch (e) {
      return 'Unknown';
    }
    return 'Unknown';
  }

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9/5) + 32;
  }

  double _knotsToMph(double knots) {
    return knots * 1.15078;
  }

  double _hpaToInHg(double hpa) {
    return hpa * 0.02953;
  }

  double _mmToInches(double mm) {
    return mm * 0.0393701;
  }

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Create and initialize cache service
      final cacheService = CacheService();
      await cacheService.init();
      
      // Create other services
      final purpleAirService = PurpleAirService(
        ApiKeys.purpleAirApiKey,
        ApiKeys.purpleAirSensorId,
      );
      
      // Create repository instance
      _weatherRepo = WeatherRepository(
        cacheService,
        OpenWeatherService('dummy-key'),  // Dummy instance since it's required but not used
        purpleAirService,
      );

      if (mounted) {
        setState(() {
          // Update state to show services are initialized
          _updateStatus = 'Services initialized. Ready for quick update test.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _updateStatus = 'Error initializing services: $e';
        });
      }
    }
  }

  Future<void> _performQuickUpdate() async {
    if (_isUpdating || _weatherRepo == null) {
      setState(() {
        _updateStatus = _weatherRepo == null 
            ? 'Services not yet initialized. Please wait...'
            : 'Update already in progress...';
      });
      return;
    }

    setState(() {
      _isUpdating = true;
      _updateStatus = 'Updating...';
    });

    try {
      final data = await _weatherRepo!.getQuickUpdate();
      
      // Debug print raw data
      debugPrint('\n=== Raw Quick Update Data ===');
      data.forEach((key, value) {
        debugPrint('$key: $value (${value.runtimeType})');
      });
      
      // Convert values with proper units
      final tempC = double.tryParse(data['temperature'].toString()) ?? 0.0;
      final tempF = _celsiusToFahrenheit(tempC);
      
      final windSpeedKnots = double.tryParse(data['windSpeed'].toString()) ?? 0.0;
      final windSpeedMph = _knotsToMph(windSpeedKnots);
      
      final avgWindSpeedKnots = double.tryParse(data['avgWindSpeed'].toString()) ?? 0.0;
      final avgWindSpeedMph = _knotsToMph(avgWindSpeedKnots);
      
      final windGustKnots = double.tryParse(data['windGust'].toString()) ?? 0.0;
      final windGustMph = _knotsToMph(windGustKnots);
      
      final maxGustKnots = double.tryParse(data['maxGust'].toString()) ?? 0.0;
      final maxGustMph = _knotsToMph(maxGustKnots);
      
      final windDirName = _getWindDirection(data['windDirection'].toString());
      
      final pressureHpa = double.tryParse(data['pressure'].toString()) ?? 0.0;
      final pressureInHg = _hpaToInHg(pressureHpa);
      
      final rainfallMm = double.tryParse(data['rainfall'].toString()) ?? 0.0;
      final rainfallIn = _mmToInches(rainfallMm);
      
      final monthlyRainMm = double.tryParse(data['monthlyRain'].toString()) ?? 0.0;
      final monthlyRainIn = _mmToInches(monthlyRainMm);
      
      final yearlyRainMm = double.tryParse(data['yearlyRain'].toString()) ?? 0.0;
      final yearlyRainIn = _mmToInches(yearlyRainMm);
      
      final rainRateMm = double.tryParse(data['rainRate'].toString()) ?? 0.0;
      final rainRateIn = _mmToInches(rainRateMm);
      
      final maxRainRateMm = double.tryParse(data['maxRainRate'].toString()) ?? 0.0;
      final maxRainRateIn = _mmToInches(maxRainRateMm);
      
      final windChillC = double.tryParse(data['windChill'].toString()) ?? tempC;
      final windChillF = _celsiusToFahrenheit(windChillC);
      
      final heatIndexC = double.tryParse(data['heatIndex'].toString()) ?? tempC;
      final heatIndexF = _celsiusToFahrenheit(heatIndexC);
      
      setState(() {
        _updateStatus = 'Update completed at ${_timeFormat.format(DateTime.now())}\n\n'
            '=== Current Conditions ===\n'
            'Temperature: ${tempF.toStringAsFixed(1)}°F (${tempC.toStringAsFixed(1)}°C)\n'
            'Heat Index: ${heatIndexF.toStringAsFixed(1)}°F (${heatIndexC.toStringAsFixed(1)}°C)\n'
            'Wind Chill: ${windChillF.toStringAsFixed(1)}°F (${windChillC.toStringAsFixed(1)}°C)\n'
            'Humidity: ${data['humidity']}%\n'
            'Pressure: ${pressureInHg.toStringAsFixed(2)} inHg (${pressureHpa.toStringAsFixed(1)} hPa)\n\n'
            '=== Wind ===\n'
            'Current Speed: ${windSpeedMph.toStringAsFixed(1)} mph (${windSpeedKnots.toStringAsFixed(1)} kts)\n'
            'Average Speed: ${avgWindSpeedMph.toStringAsFixed(1)} mph (${avgWindSpeedKnots.toStringAsFixed(1)} kts)\n'
            'Wind Gust: ${windGustMph.toStringAsFixed(1)} mph (${windGustKnots.toStringAsFixed(1)} kts)\n'
            'Max Gust: ${maxGustMph.toStringAsFixed(1)} mph (${maxGustKnots.toStringAsFixed(1)} kts)\n'
            'Direction: $windDirName (${data['windDirection']}°)\n\n'
            '=== Precipitation ===\n'
            'Daily Rain: ${rainfallIn.toStringAsFixed(2)} in (${rainfallMm.toStringAsFixed(1)} mm)\n'
            'Monthly Rain: ${monthlyRainIn.toStringAsFixed(2)} in (${monthlyRainMm.toStringAsFixed(1)} mm)\n'
            'Yearly Rain: ${yearlyRainIn.toStringAsFixed(2)} in (${yearlyRainMm.toStringAsFixed(1)} mm)\n'
            'Current Rate: ${rainRateIn.toStringAsFixed(2)} in/hr (${rainRateMm.toStringAsFixed(1)} mm/hr)\n'
            'Max Rate: ${maxRainRateIn.toStringAsFixed(2)} in/hr (${maxRainRateMm.toStringAsFixed(1)} mm/hr)';
      });
    } catch (e) {
      setState(() {
        _updateStatus = 'Error during update: $e';
      });
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Update Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isUpdating ? null : _performQuickUpdate,
              child: Text(_isUpdating ? 'Updating...' : 'Perform Quick Update'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Status:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_updateStatus),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 