import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _testTagUrlKey = 'testtag_url';
  static const String _clientRawUrlKey = 'clientraw_url';
  static const String _latitudeKey = 'latitude';
  static const String _longitudeKey = 'longitude';
  static const String _appNameKey = 'app_name';
  static const String _selectedCountiesKey = 'selected_counties';
  
  // Default values
  static const String defaultTestTagUrl = 'https://your-testtag-url.com';
  static const String defaultClientRawUrl = 'https://your-clientraw-url.com';
  static const double defaultLatitude = 43.2105;  // Rome, NY
  static const double defaultLongitude = -75.4557;  // Rome, NY
  static const String defaultAppName = 'CNY Weather App Template';
  
  // Default counties to monitor
  static const List<String> defaultCounties = [
    'NYC065', // Oneida County
    'NYC053', // Madison County
    'NYC067', // Onondaga County
    'NYC075', // Oswego County
    'NYC049', // Lewis County
    'NYC043', // Herkimer County
    'NYC077', // Otsego County
  ];

  final SharedPreferences _prefs;
  String _testTagUrl;
  String _clientRawUrl;
  double _latitude;
  double _longitude;
  String _appName;
  List<String> _selectedCounties;

  AppConfig._(this._prefs)
      : _testTagUrl = _prefs.getString(_testTagUrlKey) ?? defaultTestTagUrl,
        _clientRawUrl = _prefs.getString(_clientRawUrlKey) ?? defaultClientRawUrl,
        _latitude = _prefs.getDouble(_latitudeKey) ?? defaultLatitude,
        _longitude = _prefs.getDouble(_longitudeKey) ?? defaultLongitude,
        _appName = _prefs.getString(_appNameKey) ?? defaultAppName,
        _selectedCounties = _prefs.getStringList(_selectedCountiesKey) ?? [];

  static Future<AppConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final config = AppConfig._(prefs);
    
    // If no counties are selected (first run), select all default counties
    if (config._selectedCounties.isEmpty) {
      config._selectedCounties = List.from(defaultCounties);
      await config.setSelectedCounties(config._selectedCounties);
    }
    
    return config;
  }

  // Getters
  String get testTagUrl => _testTagUrl;
  String get clientRawUrl => _clientRawUrl;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get appName => _appName;
  List<String> get selectedCounties => _selectedCounties;

  // Setters
  Future<void> setTestTagUrl(String url) async {
    _testTagUrl = url;
    await _prefs.setString(_testTagUrlKey, url);
  }

  Future<void> setClientRawUrl(String url) async {
    _clientRawUrl = url;
    await _prefs.setString(_clientRawUrlKey, url);
  }

  Future<void> setLocation(double latitude, double longitude) async {
    _latitude = latitude;
    _longitude = longitude;
    await _prefs.setDouble(_latitudeKey, latitude);
    await _prefs.setDouble(_longitudeKey, longitude);
  }

  Future<void> setAppName(String name) async {
    _appName = name;
    await _prefs.setString(_appNameKey, name);
  }

  Future<void> setSelectedCounties(List<String> counties) async {
    _selectedCounties = counties;
    await _prefs.setStringList(_selectedCountiesKey, counties);
  }

  Future<void> toggleCounty(String countyCode) async {
    if (_selectedCounties.contains(countyCode)) {
      _selectedCounties.remove(countyCode);
    } else {
      _selectedCounties.add(countyCode);
    }
    await setSelectedCounties(_selectedCounties);
  }
} 