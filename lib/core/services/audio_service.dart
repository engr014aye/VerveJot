import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _tapPlayer;
  AudioPlayer? _chimePlayer;
  AudioPlayer? _rustlePlayer;
  AudioPlayer? _deletePlayer;

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  double _volume = 0.5;
  bool _initialized = false;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  double get volume => _volume;

  void init({
    bool soundEnabled = true,
    bool hapticsEnabled = true,
    double volume = 0.5,
  }) {
    _soundEnabled = soundEnabled;
    _hapticsEnabled = hapticsEnabled;
    _volume = volume.clamp(0.0, 1.0);
    _initPlayers();
  }

  void _initPlayers() {
    if (_initialized) return;
    try {
      _tapPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _chimePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _rustlePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _deletePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _initialized = true;
    } catch (_) {}
  }

  void updateSettings({
    bool? soundEnabled,
    bool? hapticsEnabled,
    double? volume,
  }) {
    if (soundEnabled != null) _soundEnabled = soundEnabled;
    if (hapticsEnabled != null) _hapticsEnabled = hapticsEnabled;
    if (volume != null) {
      _volume = volume.clamp(0.0, 1.0);
    }
  }

  Future<void> playTap({bool haptic = false}) async {
    if (_hapticsEnabled || haptic) {
      HapticFeedback.selectionClick();
    }
    if (!_soundEnabled || _volume <= 0.0) return;

    try {
      if (_tapPlayer == null) _initPlayers();
      await _tapPlayer?.setVolume(_volume);
      await _tapPlayer?.stop();
      await _tapPlayer?.play(AssetSource('audio/tap.wav'));
    } catch (_) {}
  }

  Future<void> playChime({bool haptic = false}) async {
    if (_hapticsEnabled || haptic) {
      HapticFeedback.mediumImpact();
    }
    if (!_soundEnabled || _volume <= 0.0) return;

    try {
      if (_chimePlayer == null) _initPlayers();
      await _chimePlayer?.setVolume(_volume);
      await _chimePlayer?.stop();
      await _chimePlayer?.play(AssetSource('audio/chime.wav'));
    } catch (_) {}
  }

  Future<void> playRustle({bool haptic = false}) async {
    if (_hapticsEnabled || haptic) {
      HapticFeedback.lightImpact();
    }
    if (!_soundEnabled || _volume <= 0.0) return;

    try {
      if (_rustlePlayer == null) _initPlayers();
      await _rustlePlayer?.setVolume(_volume);
      await _rustlePlayer?.stop();
      await _rustlePlayer?.play(AssetSource('audio/rustle.wav'));
    } catch (_) {}
  }

  Future<void> playDelete({bool haptic = false}) async {
    if (_hapticsEnabled || haptic) {
      HapticFeedback.heavyImpact();
    }
    if (!_soundEnabled || _volume <= 0.0) return;

    try {
      if (_deletePlayer == null) _initPlayers();
      await _deletePlayer?.setVolume(_volume);
      await _deletePlayer?.stop();
      await _deletePlayer?.play(AssetSource('audio/delete.wav'));
    } catch (_) {}
  }

  void dispose() {
    _tapPlayer?.dispose();
    _chimePlayer?.dispose();
    _rustlePlayer?.dispose();
    _deletePlayer?.dispose();
    _tapPlayer = null;
    _chimePlayer = null;
    _rustlePlayer = null;
    _deletePlayer = null;
    _initialized = false;
  }
}
