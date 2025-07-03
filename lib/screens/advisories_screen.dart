// **************************************************************************
// * WARNING: DO NOT MODIFY THIS FILE WITHOUT EXPLICIT APPROVAL                *
// * Changes to this file should be properly reviewed and authorized          *
// * Version: 1.1.0                                                          *
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../services/nws_service_cap.dart';
import '../models/weather_alert.dart';

class AdvisoriesScreen extends StatefulWidget {
  const AdvisoriesScreen({super.key});

  @override
  State<AdvisoriesScreen> createState() => _AdvisoriesScreenState();
}

class _AdvisoriesScreenState extends State<AdvisoriesScreen> {
  String _hwoText = 'Loading...';
  bool _isLoading = true;
  DateTime? _lastHWOFetch;
  static const _hwoCacheDuration = Duration(hours: 6);

  @override
  void initState() {
    super.initState();
    _loadHWO();
  }

  Future<void> _loadHWO() async {
    if (!mounted) return;

    // Check if we have cached data that's still valid
    if (_lastHWOFetch != null && 
        DateTime.now().difference(_lastHWOFetch!) < _hwoCacheDuration) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    final weatherService = Provider.of<WeatherService>(context, listen: false);
    try {
      final hwo = await weatherService.getHazardousWeatherOutlook();
      if (mounted) {
        setState(() {
          _hwoText = hwo;
          _isLoading = false;
          _lastHWOFetch = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hwoText = 'Unable to load Hazardous Weather Outlook';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    debugPrint('\n=== Starting _refreshData() ===');
    setState(() {
      _isLoading = true;
    });
    
    // Only refresh HWO if cache is expired
    if (_lastHWOFetch == null || 
        DateTime.now().difference(_lastHWOFetch!) >= _hwoCacheDuration) {
      debugPrint('HWO cache expired, refreshing HWO');
      await _loadHWO();
    } else {
      debugPrint('Using cached HWO data');
      setState(() {
        _isLoading = false;
      });
    }
    
    // Always refresh weather data and force refresh alerts
    debugPrint('Refreshing weather data and alerts');
    final weatherService = Provider.of<WeatherService>(context, listen: false);
    final nwsService = Provider.of<NWSServiceCAP>(context, listen: false);
    
    // Force refresh alerts
    debugPrint('Calling nwsService.getAlerts()');
    await nwsService.getAlerts();
    debugPrint('Finished nwsService.getAlerts()');
    
    // Refresh weather data
    debugPrint('Refreshing weather data');
    await weatherService.refreshWeatherData();
    debugPrint('Finished refreshing weather data');
    
    debugPrint('=== Finished _refreshData() ===\n');
  }

  List<WeatherAlert> _filterAlerts(List<WeatherAlert> alerts) {
    if (alerts.isEmpty) return alerts;

    // Sort alerts by severity level (lower number = more severe)
    alerts.sort((a, b) => a.severityLevel.compareTo(b.severityLevel));
    
    // Group alerts by type (warning, watch, advisory)
    final warnings = alerts.where((a) => a.severityLevel < 50).toList();
    final watches = alerts.where((a) => a.severityLevel >= 50 && a.severityLevel < 90).toList();
    final advisories = alerts.where((a) => a.severityLevel >= 90 && a.severityLevel < 120).toList();
    
    // If we have warnings, only show warnings
    if (warnings.isNotEmpty) {
      return warnings;
    }
    
    // If we have watches but no warnings, show watches
    if (watches.isNotEmpty) {
      return watches;
    }
    
    // If we have advisories but no warnings or watches, show advisories
    if (advisories.isNotEmpty) {
      return advisories;
    }
    
    // If we have other types of alerts, show them
    return alerts.where((a) => a.severityLevel >= 120).toList();
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  IconData _getAlertIcon(String event) {
    event = event.toLowerCase();
    if (event.contains('tornado')) return Icons.tornado;
    if (event.contains('thunderstorm')) return Icons.flash_on;
    if (event.contains('flood')) return Icons.water;
    if (event.contains('winter') || event.contains('snow')) return Icons.ac_unit;
    if (event.contains('heat')) return Icons.wb_sunny;
    if (event.contains('wind')) return Icons.air;
    if (event.contains('freeze') || event.contains('frost')) return Icons.thermostat;
    return Icons.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherService>(
      builder: (context, weatherService, child) {
        final alerts = _filterAlerts(weatherService.weatherData?.alerts ?? []);
        if (alerts.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.green,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'No Active Advisories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Hazardous Weather Outlook',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(_hwoText),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...alerts.map((alert) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Color(int.parse(alert.backgroundColor.replaceAll('#', '0xFF'))),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getAlertIcon(alert.event),
                                  color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${alert.severity.toUpperCase()}: ${alert.event}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alert.area,
                              style: TextStyle(
                                fontSize: 16,
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
                            if (alert.instruction.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Instructions: ${alert.instruction}',
                                style: TextStyle(
                                  color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Effective: ${_formatDateTime(alert.effective)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                              ),
                            ),
                            if (alert.expires != null)
                              Text(
                                'Expires: ${_formatDateTime(alert.expires!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(int.parse(alert.textColor.replaceAll('#', '0xFF'))),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )).toList(),
                    const SizedBox(height: 16),
                    const Text(
                      'Hazardous Weather Outlook',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_hwoText),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 