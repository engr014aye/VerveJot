import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _tapPlayer;
  AudioPlayer? _chimePlayer;
  AudioPlayer? _rustlePlayer;
  AudioPlayer? _deletePlayer;

  // Sound and Haptics are globally disabled for now
  final bool _soundEnabled = false;
  final bool _hapticsEnabled = false;
  double _volume = 0.0;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  double get volume => _volume;

  void init({
    bool soundEnabled = false,
    bool hapticsEnabled = false,
    double volume = 0.0,
  }) {
    _volume = 0.0;
  }

  void updateSettings({
    bool? soundEnabled,
    bool? hapticsEnabled,
    double? volume,
  }) {
    // Disabled for now
  }

  Future<void> playTap({bool haptic = false}) async {
    // Audio disabled for now
  }

  Future<void> playChime({bool haptic = false}) async {
    // Audio disabled for now
  }

  Future<void> playRustle({bool haptic = false}) async {
    // Audio disabled for now
  }

  Future<void> playDelete({bool haptic = false}) async {
    // Audio disabled for now
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
  }
}
