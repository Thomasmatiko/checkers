import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Central audio service for the entire game application.
///
/// Currently supports:
/// - Checkers / Drafts
/// - Future Rudo sounds
/// - Future Bao sounds
///
/// Audio files are loaded from:
/// assets/sounds/
class AudioService extends ChangeNotifier {
  AudioService._internal();

  static final AudioService instance = AudioService._internal();

  factory AudioService() {
    return instance;
  }

  // ============================================================
  // AUDIO PLAYERS
  // ============================================================

  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // ============================================================
  // SETTINGS
  // ============================================================

  bool _soundEnabled = true;
  bool _musicEnabled = false;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  // ============================================================
  // AVAILABLE AUDIO FILES
  // ============================================================
  //
  // These are the files currently present in:
  //
  // assets/sounds/
  //
  // button.mp3
  // capture.mp3
  // denielcz-achievement-unlocked-463070.mp3
  // lose.mp3
  // move.mp3
  // win.mp3
  //
  // ============================================================

  static const String _buttonSound = 'button.mp3';
  static const String _captureSound = 'capture.mp3';
  static const String _moveSound = 'move.mp3';
  static const String _winSound = 'win.mp3';
  static const String _loseSound = 'lose.mp3';

  static const String _achievementSound =
      'denielcz-achievement-unlocked-463070.mp3';

  // ============================================================
  // OPTIONAL FUTURE SOUNDS
  // ============================================================
  //
  // These names are kept here so we can easily add the files
  // later without changing the whole audio architecture.
  //
  // ============================================================

  static const String _kingSound = 'king.mp3';
  static const String _gameStartSound = 'game_start.mp3';
  static const String _drawSound = 'draw.mp3';
  static const String _selectSound = 'select.mp3';
  static const String _invalidSound = 'invalid.mp3';

  static const String _puzzleCorrectSound =
      'puzzle_correct.mp3';

  static const String _puzzleWrongSound =
      'puzzle_wrong.mp3';

  static const String _puzzleCompleteSound =
      'puzzle_complete.mp3';

  static const String _backgroundMusic =
      'background.mp3';

  // ============================================================
  // SOUND SETTINGS
  // ============================================================

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;

    notifyListeners();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;

    if (!enabled) {
      stopMusic();
    }

    notifyListeners();
  }

  // ============================================================
  // CHECKERS / DRAFTS SOUNDS
  // ============================================================

  /// Plays the normal piece movement sound.
  Future<void> playMove() async {
    await _play(_moveSound);
  }

  /// Plays the capture sound.
  Future<void> playCapture() async {
    await _play(_captureSound);
  }

  /// Plays the king promotion sound.
  ///
  /// The file can be added later:
  /// assets/sounds/king.mp3
  Future<void> playKingPromotion() async {
    await _playOptional(_kingSound);
  }

  /// Plays the game-start sound.
  ///
  /// The file can be added later:
  /// assets/sounds/game_start.mp3
  Future<void> playGameStart() async {
    await _playOptional(_gameStartSound);
  }

  /// Plays the winning sound.
  Future<void> playWin() async {
    await _play(_winSound);
  }

  /// Plays the losing sound.
  Future<void> playLoss() async {
    await _play(_loseSound);
  }

  /// Plays the draw sound.
  ///
  /// The file can be added later:
  /// assets/sounds/draw.mp3
  Future<void> playDraw() async {
    await _playOptional(_drawSound);
  }

  /// Plays a button-click sound.
  Future<void> playButton() async {
    await _play(_buttonSound);
  }

  /// Plays piece-selection sound.
  ///
  /// The file can be added later:
  /// assets/sounds/select.mp3
  Future<void> playSelect() async {
    await _playOptional(_selectSound);
  }

  /// Plays invalid-move sound.
  ///
  /// The file can be added later:
  /// assets/sounds/invalid.mp3
  Future<void> playInvalidMove() async {
    await _playOptional(_invalidSound);
  }

  // ============================================================
  // ACHIEVEMENT
  // ============================================================

  /// Plays the achievement-unlocked sound.
  Future<void> playAchievement() async {
    await _play(_achievementSound);
  }

  // ============================================================
  // PUZZLE SOUNDS
  // ============================================================

  Future<void> playPuzzleCorrect() async {
    await _playOptional(_puzzleCorrectSound);
  }

  Future<void> playPuzzleWrong() async {
    await _playOptional(_puzzleWrongSound);
  }

  Future<void> playPuzzleComplete() async {
    await _playOptional(_puzzleCompleteSound);
  }

  // ============================================================
  // BACKGROUND MUSIC
  // ============================================================

  /// Starts background music if music is enabled.
  ///
  /// The file can be added later:
  /// assets/sounds/background.mp3
  Future<void> startMusic() async {
    if (!_musicEnabled) {
      return;
    }

    try {
      await _musicPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await _musicPlayer.play(
        AssetSource(
          'sounds/$_backgroundMusic',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AudioService: background music unavailable: $e',
        );
      }
    }
  }

  /// Stops background music.
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AudioService: could not stop music: $e',
        );
      }
    }
  }

  /// Pauses background music.
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AudioService: could not pause music: $e',
        );
      }
    }
  }

  /// Resumes background music.
  Future<void> resumeMusic() async {
    if (!_musicEnabled) {
      return;
    }

    try {
      await _musicPlayer.resume();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AudioService: could not resume music: $e',
        );
      }
    }
  }

  // ============================================================
  // GENERIC SOUND PLAYBACK
  // ============================================================

  /// Plays a sound that is known to exist.
  Future<void> _play(String fileName) async {
    if (!_soundEnabled) {
      return;
    }

    try {
      await _effectPlayer.stop();

      await _effectPlayer.play(
        AssetSource(
          'sounds/$fileName',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AudioService: could not play '
          '$fileName: $e',
        );
      }
    }
  }

  /// Plays an optional sound.
  ///
  /// Missing optional files do not break the game.
  Future<void> _playOptional(String fileName) async {
    if (!_soundEnabled) {
      return;
    }

    try {
      await _effectPlayer.stop();

      await _effectPlayer.play(
        AssetSource(
          'sounds/$fileName',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AudioService: optional sound '
          '$fileName is not available yet.',
        );
      }
    }
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void dispose() {
    _effectPlayer.dispose();
    _musicPlayer.dispose();

    super.dispose();
  }
}