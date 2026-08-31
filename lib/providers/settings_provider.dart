import 'package:flutter/material.dart';
import '../core/services/audio_service.dart';
import '../core/services/preferences_service.dart';

class SettingsProvider with ChangeNotifier {
  final PreferencesService _prefs;

  late ThemeMode _themeMode;
  late bool _soundEnabled;
  late double _soundVolume;
  late bool _hapticsEnabled;
  late bool _isGridView;

  SettingsProvider(this._prefs) {
    _themeMode = _parseThemeMode(_prefs.themeMode);
    _soundEnabled = _prefs.soundEnabled;
    _soundVolume = _prefs.soundVolume;
    _hapticsEnabled = _prefs.hapticsEnabled;
    _isGridView = _prefs.isGridView;

    AudioService().init(
      soundEnabled: _soundEnabled,
      hapticsEnabled: _hapticsEnabled,
      volume: _soundVolume,
    );
  }

  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  double get soundVolume => _soundVolume;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isGridView => _isGridView;

  static ThemeMode _parseThemeMode(String val) {
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setThemeMode(_themeModeToString(mode));
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs.setSoundEnabled(value);
    AudioService().updateSettings(soundEnabled: value);
    notifyListeners();
  }

  Future<void> setSoundVolume(double value) async {
    _soundVolume = value.clamp(0.0, 1.0);
    await _prefs.setSoundVolume(_soundVolume);
    AudioService().updateSettings(volume: _soundVolume);
    notifyListeners();
  }

  Future<void> setHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    await _prefs.setHapticsEnabled(value);
    AudioService().updateSettings(hapticsEnabled: value);
    notifyListeners();
  }

  Future<void> toggleViewMode() async {
    _isGridView = !_isGridView;
    await _prefs.setGridView(_isGridView);
    notifyListeners();
  }
}
