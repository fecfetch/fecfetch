import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  
  factory AudioService() => _instance;
  
  AudioService._internal();
  
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer _soundEffectsPlayer = AudioPlayer();
  bool _isBackgroundPlaying = false;
  bool _shouldResumeBackgroundAfterEffect = false;
  
  // Background music assets
  // Use full asset paths as referenced by the Flutter asset bundle.
  static const String menuMusic = 'assets/Music/music_menu.ogg';
  static const String levelMusic = 'assets/Music/Level_Screen_Music.ogg';
  static const String mainMusic = 'assets/Music/Level_Screen_Music.ogg'; // Using level music as fallback

  // Sound effect assets
  static const String buttonSound = 'assets/Music/button.mp3';
  static const String matchSound = 'assets/Music/match.ogg';
  static const String winSound = 'assets/Music/win.ogg';
  
  bool _isMusicEnabled = true;
  bool _areSoundEffectsEnabled = true;
  
  // Initialize the audio service
  Future<void> init() async {
    // Set initial volume levels
    await _backgroundMusicPlayer.setVolume(0.5);
    await _soundEffectsPlayer.setVolume(0.7);

  // Note: setting specific PlayerMode values (e.g. media/lowLatency) is
  // omitted here because the audioplayers version in this project does not
  // expose the same enum names across platforms. If you upgrade the
  // audioplayers package, re-introduce explicit player mode configuration
  // using the correct enum names for that version.

    // When a sound effect finishes, resume background music if we paused it for the effect.
    _soundEffectsPlayer.onPlayerComplete.listen((_) async {
      if (_shouldResumeBackgroundAfterEffect) {
        try {
          await _backgroundMusicPlayer.resume();
        } catch (e) {
          print('AudioService: failed to resume background music: $e');
        }
        _shouldResumeBackgroundAfterEffect = false;
      }
    });
    // Debug: verify assets are present in the Flutter asset bundle at runtime.
    // This helps diagnose 'Unable to load asset' errors. Await these checks so
    // they run before init() returns and the app continues startup.
    final assetsToCheck = [
      menuMusic,
      levelMusic,
      buttonSound,
    ];

    for (final asset in assetsToCheck) {
      try {
        final data = await rootBundle.load(asset);
        print('AudioService: asset found: $asset (length=${data.lengthInBytes})');
      } catch (e) {
        print('AudioService: asset NOT found or failed to load: $asset -> $e');
      }
    }
  }
  
  // Music control methods
  Future<void> playBackgroundMusic(String assetPath) async {
    if (!_isMusicEnabled) return;
    
    try {
  print('AudioService: attempting to play background music: $assetPath');
      await _backgroundMusicPlayer.stop();
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      // Try the given assetPath first. If it fails, try the variant without a
      // leading 'assets/' prefix. If both AssetSource attempts fail, try
      // loading bytes from the rootBundle and play via BytesSource.
      var played = false;
      try {
        await _backgroundMusicPlayer.play(AssetSource(assetPath));
        played = true;
      } catch (e) {
        final alt = assetPath.startsWith('assets/') ? assetPath.substring(7) : 'assets/$assetPath';
        print('AudioService: primary play failed, trying alternative asset path: $alt');
        try {
          await _backgroundMusicPlayer.play(AssetSource(alt));
          played = true;
        } catch (_) {
          // continue to bytes fallback
        }
      }

      if (!played) {
        // Try bytes fallback
        try {
          ByteData data;
          try {
            data = await rootBundle.load(assetPath);
          } catch (_) {
            final alt = assetPath.startsWith('assets/') ? assetPath.substring(7) : 'assets/$assetPath';
            data = await rootBundle.load(alt);
          }
          final bytes = data.buffer.asUint8List();
          await _backgroundMusicPlayer.play(BytesSource(bytes));
          played = true;
          print('AudioService: played background music via BytesSource for: $assetPath');
        } catch (e) {
          // bytes fallback failed
          print('AudioService: bytes fallback failed for $assetPath -> $e');
        }
      }
      if (played) {
        _isBackgroundPlaying = true;
      }
      print('AudioService: background music play called for: $assetPath (played=$played)');
    } catch (e) {
      // Handle error silently to avoid crashing the app
  print('Error playing background music for asset "$assetPath": $e');
    }
  }
  
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.stop();
  _isBackgroundPlaying = false;
  _shouldResumeBackgroundAfterEffect = false;
    } catch (e) {
      // Handle error silently
      print('Error stopping background music: $e');
    }
  }
  
  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.pause();
    } catch (e) {
      // Handle error silently
      print('Error pausing background music: $e');
    }
  }
  
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled || !_isBackgroundPlaying) return;
    try {
      await _backgroundMusicPlayer.resume();
    } catch (e) {
      // Handle error silently
      print('Error resuming background music: $e');
    }
  }
  
  // Sound effect methods
  Future<void> playSoundEffect(String assetPath) async {
    if (!_areSoundEffectsEnabled) return;
    
    try {
  print('AudioService: attempting to play sound effect: $assetPath');
      // If background music is playing, pause it and mark for resume on effect completion
      final backgroundWasPlaying = _isBackgroundPlaying;
      if (backgroundWasPlaying) {
        try {
          _shouldResumeBackgroundAfterEffect = true;
          await _backgroundMusicPlayer.pause();
        } catch (e) {
          _shouldResumeBackgroundAfterEffect = false;
          // ignore
        }
      }

      var played = false;
      try {
        await _soundEffectsPlayer.play(AssetSource(assetPath));
        played = true;
      } catch (e) {
        final alt = assetPath.startsWith('assets/') ? assetPath.substring(7) : 'assets/$assetPath';
        print('AudioService: primary play failed, trying alternative asset path: $alt');
        try {
          await _soundEffectsPlayer.play(AssetSource(alt));
          played = true;
        } catch (_) {
          // continue
        }
      }

      if (!played) {
        try {
          ByteData data;
          try {
            data = await rootBundle.load(assetPath);
          } catch (_) {
            final alt = assetPath.startsWith('assets/') ? assetPath.substring(7) : 'assets/$assetPath';
            data = await rootBundle.load(alt);
          }
          final bytes = data.buffer.asUint8List();
          await _soundEffectsPlayer.play(BytesSource(bytes));
          played = true;
          print('AudioService: played sound effect via BytesSource for: $assetPath');
        } catch (e) {
          print('AudioService: bytes fallback failed for sound $assetPath -> $e');
        }
      }
  print('AudioService: sound effect play called for: $assetPath');
    } catch (e) {
      // Handle error silently
  print('Error playing sound effect for asset "$assetPath": $e');
    }
  }
  
  // Volume control methods
  Future<void> setMusicVolume(double volume) async {
    try {
      await _backgroundMusicPlayer.setVolume(volume);
    } catch (e) {
      // Handle error silently
      print('Error setting music volume: $e');
    }
  }
  
  Future<void> setSoundEffectsVolume(double volume) async {
    try {
      await _soundEffectsPlayer.setVolume(volume);
    } catch (e) {
      // Handle error silently
      print('Error setting sound effects volume: $e');
    }
  }
  
  // Enable/disable methods
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }
  
  void setSoundEffectsEnabled(bool enabled) {
    _areSoundEffectsEnabled = enabled;
  }
  
  bool isMusicEnabled() => _isMusicEnabled;
  bool areSoundEffectsEnabled() => _areSoundEffectsEnabled;
  
  // Cleanup method
  Future<void> dispose() async {
    try {
      await _backgroundMusicPlayer.dispose();
      await _soundEffectsPlayer.dispose();
    } catch (e) {
      // Handle error silently
      print('Error disposing audio players: $e');
    }
  }
}