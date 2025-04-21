// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cnyweatherapp/main.dart';
import 'package:cnyweatherapp/services/weather_service.dart';
import 'package:cnyweatherapp/repositories/weather_repository.dart';
import 'package:cnyweatherapp/services/cache_service.dart';
import 'package:cnyweatherapp/models/weather_data.dart';
import 'package:cnyweatherapp/services/openweather_service.dart';

class MockWeatherRepository extends WeatherRepository {
  MockWeatherRepository(super.cacheService, super.openWeatherService);

  @override
  Future<WeatherData> getWeatherData() async {
    return WeatherData(
      lastUpdatedTime: '12:00 PM',
      lastUpdatedDate: '4/19/2024',
      temperature: 72.0,
      tempNoDecimal: 72.0,
      humidity: 45.0,
      dewPoint: 50.0,
      maxTemp: 75.0,
      maxTempTime: '2:00 PM',
      minTemp: 65.0,
      minTempTime: '6:00 AM',
      maxTempLastYear: 70.0,
      minTempLastYear: 60.0,
      maxTempRecord: 80.0,
      minTempRecord: 55.0,
      maxTempAverage: 70.0,
      minTempAverage: 60.0,
      feelsLike: 73.0,
      heatIndex: 72.0,
      windChill: 72.0,
      humidex: 72.0,
      apparentTemp: 72.0,
      apparentSolarTemp: 72.0,
      tempChangeHour: 1.0,
      aqi: 2.0,
      windSpeed: 5.0,
      windGust: 8.0,
      maxGust: 10.0,
      maxGustTime: '1:00 PM',
      windDirection: 'N',
      windDirectionDegrees: 0,
      avgWind10Min: 5.0,
      beaufortScale: '2',
      beaufortText: 'Light breeze',
      pressure: 1015.0,
      pressureTrend: 'Rising',
      pressureTrend3Hour: 'Rising',
      forecastText: 'Clear skies',
      dailyRain: 0.0,
      monthlyRain: 0.0,
      yearlyRain: 0.0,
      daysWithNoRain: 5,
      daysWithRain: 0,
      currentRainRate: 0.0,
      maxRainRate: 0.0,
      maxRainRateTime: '',
      solarRadiation: 800.0,
      uvIndex: 5.0,
      highSolar: 1000.0,
      highUV: 7.0,
      highSolarTime: '1:00 PM',
      highUVTime: '1:00 PM',
      burnTime: 30,
      snowSeason: 0.0,
      snowMonth: 0.0,
      snowToday: 0.0,
      snowYesterday: 0.0,
      snowHeight: 0.0,
      snowDepth: 0.0,
      snowDaysThisMonth: 0,
      snowDaysThisYear: 0,
      advisories: [],
      maxTempYesterday: 70.0,
      minTempYesterday: 60.0,
    );
  }

  @override
  Future<Map<String, dynamic>> getQuickUpdate() async {
    return {
      'temperature': 72.0,
      'humidity': 45.0,
      'windSpeed': 5.0,
      'windDirection': 'N',
      'pressure': 1015.0,
    };
  }
}

void main() {
  late WeatherService weatherService;

  setUp(() {
    final cacheService = CacheService();
    final openWeatherService = OpenWeatherService('test_key');
    final weatherRepository = MockWeatherRepository(cacheService, openWeatherService);
    weatherService = WeatherService(weatherRepository, cacheService);
  });

  tearDown(() {
    weatherService.dispose();
  });

  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WeatherService>.value(value: weatherService),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for the initial data fetch
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that the app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Weather App Test', (WidgetTester tester) async {
    final weatherData = WeatherData(
      lastUpdatedTime: '12:00 PM',
      lastUpdatedDate: '2024-04-19',
      temperature: 64.0,
      tempNoDecimal: 64.0,
      humidity: 50.0,
      dewPoint: 45.0,
      maxTemp: 70.0,
      maxTempTime: '2:00 PM',
      minTemp: 55.0,
      minTempTime: '6:00 AM',
      maxTempLastYear: 68.0,
      minTempLastYear: 52.0,
      maxTempRecord: 75.0,
      minTempRecord: 45.0,
      maxTempAverage: 65.0,
      minTempAverage: 50.0,
      feelsLike: 65.0,
      heatIndex: 65.0,
      windChill: 64.0,
      humidex: 65.0,
      apparentTemp: 64.0,
      apparentSolarTemp: 64.0,
      tempChangeHour: 1.0,
      aqi: 2.0,
      windSpeed: 5.0,
      windGust: 10.0,
      maxGust: 15.0,
      maxGustTime: '1:00 PM',
      windDirection: 'NE',
      windDirectionDegrees: 45,
      avgWind10Min: 5.0,
      beaufortScale: 'Light Breeze',
      beaufortText: 'Light Breeze',
      pressure: 29.92,
      pressureTrend: 'Steady',
      pressureTrend3Hour: 'Steady',
      forecastText: 'Partly Cloudy',
      dailyRain: 0.0,
      monthlyRain: 2.5,
      yearlyRain: 25.0,
      daysWithNoRain: 5,
      daysWithRain: 3,
      currentRainRate: 0.0,
      maxRainRate: 0.5,
      maxRainRateTime: '10:00 AM',
      solarRadiation: 500.0,
      uvIndex: 5.0,
      highSolar: 600.0,
      highUV: 6.0,
      highSolarTime: '12:00 PM',
      highUVTime: '12:00 PM',
      burnTime: 30,
      snowSeason: 0.0,
      snowMonth: 0.0,
      snowToday: 0.0,
      snowYesterday: 0.0,
      snowHeight: 0.0,
      snowDepth: 0.0,
      snowDaysThisMonth: 0,
      snowDaysThisYear: 0,
      advisories: [],
      maxTempYesterday: 68.0,
      minTempYesterday: 50.0,
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  });
}
