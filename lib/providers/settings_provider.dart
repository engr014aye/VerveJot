import 'package:flutter/foundation.dart';
import '../core/services/audio_service.dart';
import '../core/services/preferences_service.dart';

class SettingsProvider with ChangeNotifier {
  final PreferencesService _prefs;

  late bool _isDarkMode;
  late bool _soundEnabled;
  late double _soundVolume;
  late bool _hapticsEnabled;
  late bool _isGridView;

  SettingsProvider(this._prefs) {
    _isDarkMode = _prefs.isDarkMode;
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

  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  double get soundVolume => _soundVolume;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isGridView => _isGridView;

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setDarkMode(value);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
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
