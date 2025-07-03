import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/weather_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  static const String _channelId = 'weather_alerts';
  static const String _channelName = 'Weather Alerts';
  static const String _channelDescription = 'Notifications for weather alerts and warnings';
  static const String _prefsKey = 'shown_alert_ids';
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Set<String> _shownAlertIds = {};
  final GlobalKey<NavigatorState> _navigatorKey;
  bool _isInitialized = false;
  File? _logFile;

  NotificationService(this._navigatorKey);

  Future<void> _writeLog(String message) async {
    try {
      if (_logFile == null) {
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        _logFile = File('${directory.path}/weather_app_notification_logs.txt');
      }
      final timestamp = DateTime.now().toString();
      await _logFile!.writeAsString('$timestamp: $message\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Error writing to log file: $e');
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _writeLog('Initializing NotificationService');
      
      // Request notification permission for Android 13+
      final status = await Permission.notification.status;
      await _writeLog('Initial notification permission status: $status');
      
      if (!status.isGranted) {
        await _writeLog('Requesting notification permission');
        final result = await Permission.notification.request();
        await _writeLog('Permission request result: $result');
        
        if (!result.isGranted) {
          await _writeLog('Notification permission denied');
          return;
        }
      }

      // Load previously shown alert IDs
      await _loadShownAlertIds();

      const androidSettings = AndroidInitializationSettings('ic_stat_weather_bell');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create the notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        showBadge: true,
      );
      
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        await _writeLog('Android notification channel created successfully');
      }

      _isInitialized = true;
      await _writeLog('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      await _writeLog('Error initializing NotificationService: $e\n$stackTrace');
      _isInitialized = false;
    }
  }

  Future<void> _loadShownAlertIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList(_prefsKey) ?? [];
      _shownAlertIds.addAll(savedIds);
    } catch (e) {
      debugPrint('Error loading shown alert IDs: $e');
    }
  }

  Future<void> _saveShownAlertIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _shownAlertIds.toList());
    } catch (e) {
      debugPrint('Error saving shown alert IDs: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped with action: ${response.actionId}');
    debugPrint('Notification payload: ${response.payload}');
    
    if (response.actionId == 'view' || response.payload == '/alerts') {
      debugPrint('Navigating to alerts screen');
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/alerts',
        (route) => false,
      );
    }
  }

  Future<void> showAlertNotification(WeatherAlert alert) async {
    if (!_isInitialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    // Skip if we've already shown this alert
    if (_shownAlertIds.contains(alert.id)) {
      debugPrint('Alert ${alert.id} already shown');
      return;
    }

    try {
      // Determine notification priority based on alert severity
      final importance = _getNotificationPriority(alert);
      final priority = _getNotificationPriorityLevel(alert);
      
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: importance,
        priority: priority,
        color: Color(int.parse(alert.backgroundColor.replaceAll('#', '0xFF'))),
        styleInformation: BigTextStyleInformation(alert.description),
        fullScreenIntent: importance == Importance.high,
        category: AndroidNotificationCategory.alarm,
        groupKey: 'weather_alerts',
        setAsGroupSummary: true,
        groupAlertBehavior: GroupAlertBehavior.all,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: _getIOSInterruptionLevel(alert),
        categoryIdentifier: 'weather_alerts',
        threadIdentifier: 'weather_alerts',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Create a unique notification ID based on the alert ID
      final notificationId = alert.id.hashCode;
      
      await _notifications.show(
        notificationId,
        '${alert.severity.toUpperCase()}: ${alert.event}',
        '${alert.area}\n${alert.description}',
        details,
        payload: '/alerts',
      );

      // Add to shown alerts and save
      _shownAlertIds.add(alert.id);
      await _saveShownAlertIds();
      
      debugPrint('Successfully showed notification for alert: ${alert.event}');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Importance _getNotificationPriority(WeatherAlert alert) {
    switch (alert.severity.toLowerCase()) {
      case 'extreme':
        return Importance.high;
      case 'severe':
        return Importance.high;
      case 'moderate':
        return Importance.defaultImportance;
      default:
        return Importance.low;
    }
  }

  Priority _getNotificationPriorityLevel(WeatherAlert alert) {
    switch (alert.severity.toLowerCase()) {
      case 'extreme':
        return Priority.high;
      case 'severe':
        return Priority.high;
      case 'moderate':
        return Priority.defaultPriority;
      default:
        return Priority.low;
    }
  }

  InterruptionLevel _getIOSInterruptionLevel(WeatherAlert alert) {
    switch (alert.severity.toLowerCase()) {
      case 'extreme':
      case 'severe':
        return InterruptionLevel.timeSensitive;
      case 'moderate':
        return InterruptionLevel.active;
      default:
        return InterruptionLevel.passive;
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _shownAlertIds.clear();
      await _saveShownAlertIds();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await _writeLog('NotificationService not initialized');
      return;
    }

    try {
      // Check if notification permission is granted
      final status = await Permission.notification.status;
      await _writeLog('Current notification permission status: $status');
      
      if (!await Permission.notification.isGranted) {
        await _writeLog('Notification permission not granted, requesting permission...');
        final result = await Permission.notification.request();
        await _writeLog('Permission request result: $result');
        
        if (!result.isGranted) {
          await _writeLog('Notification permission still not granted after request');
          return;
        }
      }

      await _writeLog('Notification permission is granted, proceeding with test notification');

      final testAlert = WeatherAlert(
        id: 'test_alert_${DateTime.now().millisecondsSinceEpoch}',
        event: 'Test Weather Alert',
        severity: 'severe',
        urgency: 'immediate',
        certainty: 'observed',
        area: 'Test Area',
        description: 'This is a test notification to verify the notification system is working properly.',
        effective: DateTime.now().toIso8601String(),
        expires: DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        instruction: 'This is just a test.',
        status: 'actual',
        scope: 'public',
        msgType: 'alert',
        issued: DateTime.now().toIso8601String(),
        backgroundColor: '#FF0000',
        textColor: '#FFFFFF',
      );

      await _writeLog('Attempting to show test notification...');
      await showAlertNotification(testAlert);
      await _writeLog('Test notification sent successfully');
    } catch (e, stackTrace) {
      await _writeLog('Error showing test notification: $e\n$stackTrace');
    }
  }
} 