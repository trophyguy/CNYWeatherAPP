import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../services/nws_service.dart';

class AdvisoriesScreen extends StatefulWidget {
  const AdvisoriesScreen({super.key});

  @override
  State<AdvisoriesScreen> createState() => _AdvisoriesScreenState();
}

class _AdvisoriesScreenState extends State<AdvisoriesScreen> {
  String _hwoText = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHWO();
  }

  Future<void> _loadHWO() async {
    final nwsService = NWSService();
    final hwo = await nwsService.getHazardousWeatherOutlook();
    if (mounted) {
      setState(() {
        _hwoText = hwo;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherService>(
      builder: (context, weatherService, child) {
        final alerts = weatherService.weatherData?.alerts ?? [];
        if (alerts.isEmpty) {
          return RefreshIndicator(
            onRefresh: _loadHWO,
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
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hazardous Weather Outlook',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_isLoading)
                                const Center(child: CircularProgressIndicator())
                              else
                                Text(
                                  _hwoText,
                                  style: const TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ExpansionTile(
                leading: Icon(
                  _getAlertIcon(alert.severity),
                  color: _getAlertColor(alert.severity),
                ),
                title: Text(
                  alert.event,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getAlertColor(alert.severity),
                  ),
                ),
                subtitle: Text(alert.area),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.description,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Issued: ${alert.issued}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (alert.expires != null)
                          Text(
                            'Expires: ${alert.expires}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
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
    );
  }

  IconData _getAlertIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
      case 'severe':
        return Icons.warning_amber;
      case 'moderate':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return const Color(0xFFDC143C); // Crimson for Hurricane/Typhoon Warning
      case 'severe':
        return const Color(0xFFFF0000); // Red for Tornado Warning
      case 'moderate':
        return const Color(0xFFFFA500); // Orange for Severe Thunderstorm Warning
      case 'minor':
        return const Color(0xFF8B0000); // Darkred for Flash Flood Warning
      case 'watch':
        return const Color(0xFFFFFF00); // Yellow for Tornado Watch
      case 'advisory':
        return const Color(0xFF00FFFF); // Aqua for Special Marine Warning
      case 'statement':
        return const Color(0xFF00FFFF); // Aqua for Severe Weather Statement
      case 'winter':
        return const Color(0xFFFF4500); // Orangered for Blizzard Warning
      case 'flood':
        return const Color(0xFF00FF00); // Lime for Flood Warning
      case 'coastal':
        return const Color(0xFF228B22); // Forestgreen for Coastal Flood Warning
      case 'heat':
        return const Color(0xFFC71585); // Mediumvioletred for Excessive Heat Warning
      case 'fire':
        return const Color(0xFFFF1493); // Deeppink for Red Flag Warning
      case 'wind':
        return const Color(0xFF90EE90); // Lightgreen for Wind Advisory
      case 'avalanche':
        return const Color(0xFF1E90FF); // Dodgerblue for Avalanche Warning
      case 'dust':
        return const Color(0xFFFFE4C4); // Bisque for Dust Storm Warning
      case 'freeze':
        return const Color(0xFF00FFFF); // Cyan for Freeze Warning
      case 'gale':
        return const Color(0xFF9400D3); // Darkviolet for Gale Warning
      case 'tropical':
        return const Color(0xFFB22222); // Firebrick for Tropical Storm Warning
      case 'ice':
        return const Color(0xFF8B008B); // Darkmagenta for Ice Storm Warning
      case 'snow':
        return const Color(0xFF8A2BE2); // Blueviolet for Heavy Snow Warning
      case 'tsunami':
        return const Color(0xFFFD6347); // Tomato for Tsunami Warning
      case 'volcano':
        return const Color(0xFF696969); // Dimgray for Volcano Warning
      case 'earthquake':
        return const Color(0xFF8B4513); // Saddlebrown for Earthquake Warning
      case 'hazardous':
        return const Color(0xFF4B0082); // Indigo for Hazardous Materials Warning
      case 'civil':
        return const Color(0xFFFFB6C1); // Lightpink for Civil Danger Warning
      case 'evacuation':
        return const Color(0xFF7FFF00); // Chartreuse for Evacuation - Immediate
      case 'shelter':
        return const Color(0xFFFA8072); // Salmon for Shelter In Place Warning
      default:
        return const Color(0xFF1E90FF); // Dodger Blue for other alerts
    }
  }
} 