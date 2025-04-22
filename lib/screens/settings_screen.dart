import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  Map<String, bool> _countyNotifications = {
    'Oneida': true,
    'Herkimer': true,
    'Otsego': true,
    'Madison': true,
    'Lewis': true,
    'Onondaga': true,
  };
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeNotifications();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _countyNotifications['Oneida'] = prefs.getBool('notify_oneida') ?? true;
      _countyNotifications['Herkimer'] = prefs.getBool('notify_herkimer') ?? true;
      _countyNotifications['Otsego'] = prefs.getBool('notify_otsego') ?? true;
      _countyNotifications['Madison'] = prefs.getBool('notify_madison') ?? true;
      _countyNotifications['Lewis'] = prefs.getBool('notify_lewis') ?? true;
      _countyNotifications['Onondaga'] = prefs.getBool('notify_onondaga') ?? true;
    });
  }

  Future<void> _saveCountySetting(String county, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notify_${county.toLowerCase()}', value);
    setState(() {
      _countyNotifications[county] = value;
    });
  }

  Future<void> _initializeNotifications() async {
    const androidInitSettings = AndroidInitializationSettings('notification_icon');
    const iosInitSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInitSettings, iOS: iosInitSettings);
    
    await _notifications.initialize(initSettings);

    // Request notification permissions
    final androidNotificationDetails = const AndroidNotificationDetails(
      'weather_alerts',
      'Weather Alerts',
      channelDescription: 'Notifications for weather alerts in your area',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      icon: 'notification_icon',
    );
    final iosNotificationDetails = const DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails, 
      iOS: iosNotificationDetails
    );

    // Show a test notification immediately after initialization
    await _notifications.show(
      0,
      'Weather Alerts Test',
      'This is a test notification to verify alerts are working',
      notificationDetails,
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (value) {
      // Request notification permissions
      final androidNotificationDetails = const AndroidNotificationDetails(
        'weather_alerts',
        'Weather Alerts',
        channelDescription: 'Notifications for weather alerts in your area',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );
      final iosNotificationDetails = const DarwinNotificationDetails();
      final notificationDetails = NotificationDetails(
        android: androidNotificationDetails, 
        iOS: iosNotificationDetails
      );

      // Show a test notification
      await _notifications.show(
        0,
        'Weather Alerts Enabled',
        'You will now receive notifications for weather alerts in your area',
        notificationDetails,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Weather Alert Notifications'),
                  subtitle: const Text('Enable notifications for weather alerts'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                ),
                if (_notificationsEnabled) ...[
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: Text(
                      'Monitored Counties',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ..._countyNotifications.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      trailing: Switch(
                        value: entry.value,
                        onChanged: (value) => _saveCountySetting(entry.key, value),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('• Notifications: ${_notificationsEnabled ? 'Enabled' : 'Disabled'}'),
                  if (_notificationsEnabled) ...[
                    const SizedBox(height: 4),
                    const Text('• Monitored Counties:'),
                    ..._countyNotifications.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text('  - ${entry.key}: ${entry.value ? 'Enabled' : 'Disabled'}'),
                      );
                    }).toList(),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Data Sources',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• National Weather Service'),
                  const Text('• CNYWeather.com'),
                  const SizedBox(height: 16),
                  const Text(
                    'Version',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('1.1.0'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 