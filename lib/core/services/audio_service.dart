import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _player;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  double _volume = 0.8;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  double get volume => _volume;

  void init({
    bool soundEnabled = true,
    bool hapticsEnabled = true,
    double volume = 0.8,
  }) {
    _soundEnabled = soundEnabled;
    _hapticsEnabled = hapticsEnabled;
    _volume = volume.clamp(0.0, 1.0);
    _player ??= AudioPlayer();
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
      _player?.setVolume(_volume);
    }
  }

  Future<void> playTap({bool haptic = true}) async {
    if (haptic && _hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(_volume * 0.6);
      await player.play(AssetSource('audio/tap.wav'), mode: PlayerMode.lowLatency);
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (_) {
      // Audio playback failsafe
    }
  }

  Future<void> playChime({bool haptic = true}) async {
    if (haptic && _hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(_volume);
      await player.play(AssetSource('audio/chime.wav'), mode: PlayerMode.lowLatency);
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (_) {
      // Audio playback failsafe
    }
  }

  Future<void> playRustle({bool haptic = true}) async {
    if (haptic && _hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(_volume * 0.7);
      await player.play(AssetSource('audio/rustle.wav'), mode: PlayerMode.lowLatency);
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (_) {
      // Audio playback failsafe
    }
  }

  Future<void> playDelete({bool haptic = true}) async {
    if (haptic && _hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(_volume * 0.7);
      await player.play(AssetSource('audio/delete.wav'), mode: PlayerMode.lowLatency);
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (_) {
      // Audio playback failsafe
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
