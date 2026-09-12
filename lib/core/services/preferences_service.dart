import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyThemeMode = 'vervejot_theme_mode'; // 'system', 'light', 'dark'
  static const String _keySoundEnabled = 'vervejot_sound_enabled';
  static const String _keySoundVolume = 'vervejot_sound_volume';
  static const String _keyHapticsEnabled = 'vervejot_haptics_enabled';
  static const String _keyGridView = 'vervejot_grid_view';
  static const String _keySortOption = 'vervejot_sort_option';

  static PreferencesService? _instance;
  final SharedPreferences _prefs;

  PreferencesService._(this._prefs);

  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = PreferencesService._(prefs);
    }
    return _instance!;
  }

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<bool> setThemeMode(String value) => _prefs.setString(_keyThemeMode, value);

  bool get soundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  Future<bool> setSoundEnabled(bool value) => _prefs.setBool(_keySoundEnabled, value);

  double get soundVolume => _prefs.getDouble(_keySoundVolume) ?? 0.8;
  Future<bool> setSoundVolume(double value) => _prefs.setDouble(_keySoundVolume, value);

  bool get hapticsEnabled => _prefs.getBool(_keyHapticsEnabled) ?? true;
  Future<bool> setHapticsEnabled(bool value) => _prefs.setBool(_keyHapticsEnabled, value);

  bool get isGridView => _prefs.getBool(_keyGridView) ?? true;
  Future<bool> setGridView(bool value) => _prefs.setBool(_keyGridView, value);

  String get sortOption => _prefs.getString(_keySortOption) ?? 'lastEditedDesc';
  Future<bool> setSortOption(String value) => _prefs.setString(_keySortOption, value);
}
