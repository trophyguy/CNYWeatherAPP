import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const String _alertsEnabledKey = 'alerts_enabled';
  static const String _selectedCountiesKey = 'selected_counties';
  
  // Default counties to monitor
  static const List<String> defaultCounties = [
    'NYC065', // Oneida County
    'NYC053', // Madison County
    'NYC067', // Onondaga County
    'NYC075', // Oswego County
    'NYC049', // Lewis County
    'NYC043', // Herkimer County
    'NYC077', // Otsego County
    'NYC111', // Ulster County (for testing)
  ];

  final SharedPreferences _prefs;
  bool _alertsEnabled;
  List<String> _selectedCounties;

  Settings._(this._prefs)
      : _alertsEnabled = _prefs.getBool(_alertsEnabledKey) ?? true,
        _selectedCounties = _prefs.getStringList(_selectedCountiesKey) ?? [];

  static Future<Settings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = Settings._(prefs);
    
    // If no counties are selected (first run), select all default counties
    if (settings._selectedCounties.isEmpty) {
      settings._selectedCounties = List.from(defaultCounties);
      await settings.setSelectedCounties(settings._selectedCounties);
    }
    
    return settings;
  }

  bool get alertsEnabled => _alertsEnabled;
  List<String> get selectedCounties => _selectedCounties;

  Future<void> setAlertsEnabled(bool enabled) async {
    _alertsEnabled = enabled;
    await _prefs.setBool(_alertsEnabledKey, enabled);
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

  // Clear saved preferences and reset to default counties
  Future<void> resetToDefaults() async {
    await _prefs.remove(_selectedCountiesKey);
    _selectedCounties = List.from(defaultCounties);
    await setSelectedCounties(_selectedCounties);
  }
} 