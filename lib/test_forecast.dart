import 'package:flutter/material.dart';
import 'services/nws_service.dart';

void main() {
  runApp(const ForecastTestApp());
}

class ForecastTestApp extends StatelessWidget {
  const ForecastTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Forecast Test'),
        ),
        body: const ForecastTestPage(),
      ),
    );
  }
}

class ForecastTestPage extends StatefulWidget {
  const ForecastTestPage({super.key});

  @override
  State<ForecastTestPage> createState() => _ForecastTestPageState();
}

class _ForecastTestPageState extends State<ForecastTestPage> {
  final nwsService = NWSService();
  List<String> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      setState(() {
        logs.add('Fetching forecast...');
        isLoading = true;
      });

      final forecast = await nwsService.getForecast();
      
      setState(() {
        logs.add('Forecast fetched successfully!');
        logs.add('Number of periods: ${forecast.length}');
        
        // Add details of each forecast period
        for (var period in forecast) {
          logs.add('\nPeriod: ${period.name}');
          logs.add('Temperature: ${period.temperature}°F');
          logs.add('Condition: ${period.condition}');
          logs.add('Wind: ${period.windSpeed} mph ${period.windDirection}');
          logs.add('POP: ${period.popPercent}%');
          logs.add('Detailed: ${period.detailedForecast}');
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        logs.add('Error fetching forecast: $e');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: logs.map((log) => Text(log)).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _fetchForecast,
            child: const Text('Refresh Forecast'),
          ),
        ),
      ],
    );
  }
} 