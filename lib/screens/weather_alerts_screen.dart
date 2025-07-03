import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../models/weather_alert.dart';
import 'package:intl/intl.dart';
import '../services/nws_service_base.dart';
import '../services/nws_service_cap.dart';

class WeatherAlertsScreen extends StatefulWidget {
  final WeatherService weatherService;
  
  const WeatherAlertsScreen({
    super.key,
    required this.weatherService,
  });

  @override
  State<WeatherAlertsScreen> createState() => _WeatherAlertsScreenState();
}

class _WeatherAlertsScreenState extends State<WeatherAlertsScreen> {
  bool _isRefreshing = false;
  String _lastRefreshTime = 'Never';

  @override
  void initState() {
    super.initState();
    debugPrint('=== WEATHER_PERF: WeatherAlertsScreen initState ===');
    // Force a refresh when the screen is opened
    _refreshAlerts();
  }

  Future<void> _refreshAlerts() async {
    debugPrint('=== WEATHER_PERF: Refresh triggered ===');
    if (_isRefreshing) {
      debugPrint('=== WEATHER_PERF: Already refreshing, skipping ===');
      return;
    }
    
    debugPrint('=== WEATHER_PERF: WeatherAlertsScreen _refreshAlerts starting ===');
    setState(() {
      _isRefreshing = true;
      _lastRefreshTime = DateFormat('h:mm:ss a').format(DateTime.now());
    });

    try {
      debugPrint('=== WEATHER_PERF: Getting NWSService from Provider ===');
      final nwsService = Provider.of<NWSServiceBase>(context, listen: false);
      debugPrint('=== WEATHER_PERF: Got NWSService, calling getAlerts() ===');
      
      // Force a refresh by clearing any cached data
      if (nwsService is NWSServiceCAP) {
        debugPrint('=== WEATHER_PERF: Clearing cached alerts ===');
        await nwsService.clearCache();
      }
      
      final alerts = await nwsService.getAlerts();
      debugPrint('=== WEATHER_PERF: Got ${alerts.length} alerts from service ===');
      
      // Force a rebuild of the WeatherService consumer
      if (mounted) {
        debugPrint('=== WEATHER_PERF: Refreshing weather data ===');
        await widget.weatherService.refreshWeatherData();
        debugPrint('=== WEATHER_PERF: Weather data refreshed ===');
      }
    } catch (e, stackTrace) {
      debugPrint('=== WEATHER_PERF: Error refreshing alerts: $e ===');
      debugPrint('=== WEATHER_PERF: Stack trace: $stackTrace ===');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        debugPrint('=== WEATHER_PERF: Refresh complete ===');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=== WEATHER_PERF: WeatherAlertsScreen building ===');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
        actions: [
          IconButton(
            icon: _isRefreshing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshAlerts,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAlerts,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Last refresh: $_lastRefreshTime',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: Consumer<WeatherService>(
                builder: (context, weatherService, child) {
                  final alerts = weatherService.weatherData?.alerts ?? [];
                  debugPrint('=== WEATHER_PERF: WeatherAlertsScreen found ${alerts.length} alerts ===');
                  debugPrint('=== WEATHER_PERF: Alert details: ===');
                  for (final alert in alerts) {
                    debugPrint('- ${alert.event} for ${alert.area}');
                  }
                  
                  if (alerts.isEmpty) {
                    return ListView(
                      children: const [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No active weather alerts',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Color(int.parse(alert.backgroundColor.replaceAll('#', '0xFF'))),
                        child: ExpansionTile(
                          title: Text(
                            alert.event,
                            style: TextStyle(
                              color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${alert.area}\nSeverity: ${alert.severity}',
                            style: TextStyle(
                              color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    alert.description,
                                    style: TextStyle(
                                      color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Instructions:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    alert.instruction,
                                    style: TextStyle(
                                      color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Effective: ${_formatDate(alert.effective)}',
                                    style: TextStyle(
                                      color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                    ),
                                  ),
                                  if (alert.expires != null)
                                    Text(
                                      'Expires: ${_formatDate(alert.expires!)}',
                                      style: TextStyle(
                                        color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, y h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
} 