
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/checkers_engine.dart';
import 'game_settings.dart';
import 'game_statistics.dart';

/// Handles persistent storage for:
///
/// - Current Checkers game
/// - Game settings
/// - Game statistics
///
/// This service does not contain game rules.
/// All Checkers rules remain inside [CheckersEngine].
class GameStorage {
  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _savedGameKey =
      'saved_checkers_game';

  static const String _settingsKey =
      'checkers_settings';

  static const String _statisticsKey =
      'checkers_statistics';

  // ============================================================
  // INITIALIZE
  // ============================================================

  /// Initializes the storage service.
  Future<void> initialize() async {
    await SharedPreferences.getInstance();
  }

  // ============================================================
  // SAVE GAME
  // ============================================================

  /// Saves the current Checkers game.
  ///
  /// Returns true when the save succeeds.
  Future<bool> saveGame(
    CheckersEngine engine,
  ) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final gameData = engine.toJson();

      final jsonString =
          jsonEncode(gameData);

      return await preferences.setString(
        _savedGameKey,
        jsonString,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // CHECK SAVED GAME
  // ============================================================

  /// Returns true if a saved game exists.
  Future<bool> hasSavedGame() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final savedGame =
          preferences.getString(
        _savedGameKey,
      );

      return savedGame != null &&
          savedGame.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // LOAD GAME
  // ============================================================

  /// Loads the saved game into [engine].
  ///
  /// Returns true when the game was loaded successfully.
  Future<bool> loadGame(
    CheckersEngine engine,
  ) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final jsonString =
          preferences.getString(
        _savedGameKey,
      );

      if (jsonString == null ||
          jsonString.isEmpty) {
        return false;
      }

      final decoded =
          jsonDecode(jsonString);

      if (decoded is! Map) {
        return false;
      }

      final gameData =
          Map<String, dynamic>.from(
        decoded,
      );

      engine.fromJson(gameData);

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // DELETE SAVED GAME
  // ============================================================

  /// Deletes the saved game.
  ///
  /// Returns true when the saved game was removed.
  Future<bool> deleteSavedGame() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      return await preferences.remove(
        _savedGameKey,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // GET SAVED GAME DATA
  // ============================================================

  /// Returns the saved game as JSON-compatible data.
  ///
  /// Returns null if no valid saved game exists.
  Future<Map<String, dynamic>?> getSavedGame() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final jsonString =
          preferences.getString(
        _savedGameKey,
      );

      if (jsonString == null ||
          jsonString.isEmpty) {
        return null;
      }

      final decoded =
          jsonDecode(jsonString);

      if (decoded is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(
        decoded,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // CLEAR SAVED GAME
  // ============================================================

  /// Removes the saved Checkers game.
  Future<bool> clearSavedGame() async {
    return deleteSavedGame();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  /// Loads saved settings into [settings].
  ///
  /// If no settings have been saved yet, the existing
  /// default settings are preserved.
  Future<void> loadSettings(
    GameSettings settings,
  ) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final jsonString =
          preferences.getString(
        _settingsKey,
      );

      if (jsonString == null ||
          jsonString.isEmpty) {
        return;
      }

      final decoded =
          jsonDecode(jsonString);

      if (decoded is! Map) {
        return;
      }

      final data =
          Map<String, dynamic>.from(
        decoded,
      );

      _applySettings(
        settings,
        data,
      );
    } catch (_) {
      // Keep default settings if loading fails.
    }
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  /// Saves application settings.
  ///
  /// Returns true when the save succeeds.
  Future<bool> saveSettings(
    GameSettings settings,
  ) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final data =
          _settingsToJson(settings);

      return await preferences.setString(
        _settingsKey,
        jsonEncode(data),
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // SETTINGS TO JSON
  // ============================================================

  Map<String, dynamic> _settingsToJson(
    GameSettings settings,
  ) {
    return {
      'gameMode':
          settings.gameMode.name,

      'aiDifficulty':
          settings.aiDifficulty.name,

      'soundEnabled':
          settings.soundEnabled,

      'musicEnabled':
          settings.musicEnabled,

      'showCoordinates':
          settings.showCoordinates,

      'showLegalMoves':
          settings.showLegalMoves,

      'animationsEnabled':
          settings.animationsEnabled,

      'gameTimerEnabled':
          settings.gameTimerEnabled,

      'autoAiMove':
          settings.autoAiMove,

      'boardTheme':
          settings.boardTheme.name,
    };
  }

  // ============================================================
  // APPLY SETTINGS
  // ============================================================

  void _applySettings(
    GameSettings settings,
    Map<String, dynamic> data,
  ) {
    // ----------------------------------------------------------
    // GAME MODE
    // ----------------------------------------------------------

    final gameModeValue =
        data['gameMode'];

    if (gameModeValue is String) {
      for (final mode in GameMode.values) {
        if (mode.name == gameModeValue) {
          settings.gameMode = mode;
          break;
        }
      }
    }

    // ----------------------------------------------------------
    // AI DIFFICULTY
    // ----------------------------------------------------------

    final difficultyValue =
        data['aiDifficulty'];

    if (difficultyValue is String) {
      for (final difficulty
          in AiDifficulty.values) {
        if (difficulty.name ==
            difficultyValue) {
          settings.aiDifficulty =
              difficulty;
          break;
        }
      }
    }

    // ----------------------------------------------------------
    // SOUND
    // ----------------------------------------------------------

    final soundEnabled =
        data['soundEnabled'];

    if (soundEnabled is bool) {
      settings.soundEnabled =
          soundEnabled;
    }

    // ----------------------------------------------------------
    // MUSIC
    // ----------------------------------------------------------

    final musicEnabled =
        data['musicEnabled'];

    if (musicEnabled is bool) {
      settings.musicEnabled =
          musicEnabled;
    }

    // ----------------------------------------------------------
    // SHOW COORDINATES
    // ----------------------------------------------------------

    final showCoordinates =
        data['showCoordinates'];

    if (showCoordinates is bool) {
      settings.showCoordinates =
          showCoordinates;
    }

    // ----------------------------------------------------------
    // SHOW LEGAL MOVES
    // ----------------------------------------------------------

    final showLegalMoves =
        data['showLegalMoves'];

    if (showLegalMoves is bool) {
      settings.showLegalMoves =
          showLegalMoves;
    }

    // ----------------------------------------------------------
    // ANIMATIONS
    // ----------------------------------------------------------

    final animationsEnabled =
        data['animationsEnabled'];

    if (animationsEnabled is bool) {
      settings.animationsEnabled =
          animationsEnabled;
    }

    // ----------------------------------------------------------
    // GAME TIMER
    // ----------------------------------------------------------

    final gameTimerEnabled =
        data['gameTimerEnabled'];

    if (gameTimerEnabled is bool) {
      settings.gameTimerEnabled =
          gameTimerEnabled;
    }

    // ----------------------------------------------------------
    // AUTO AI MOVE
    // ----------------------------------------------------------

    final autoAiMove =
        data['autoAiMove'];

    if (autoAiMove is bool) {
      settings.autoAiMove =
          autoAiMove;
    }

    // ----------------------------------------------------------
    // BOARD THEME
    // ----------------------------------------------------------

    final boardThemeValue =
        data['boardTheme'];

    if (boardThemeValue is String) {
      for (final theme in BoardTheme.values) {
        if (theme.name ==
            boardThemeValue) {
          settings.boardTheme =
              theme;
          break;
        }
      }
    }
  }

  // ============================================================
  // LOAD STATISTICS
  // ============================================================

  /// Loads saved statistics into [statistics].
  ///
  /// If no statistics exist, the existing default statistics
  /// are preserved.
  Future<void> loadStatistics(
    GameStatistics statistics,
  ) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final jsonString =
          preferences.getString(
        _statisticsKey,
      );

      if (jsonString == null ||
          jsonString.isEmpty) {
        return;
      }

      final decoded =
          jsonDecode(jsonString);

      if (decoded is! Map) {
        return;
      }

      final data =
          Map<String, dynamic>.from(
        decoded,
      );

      statistics.fromJson(data);
    } catch (_) {
      // Keep default statistics if loading fails.
    }
  }

  // ============================================================
  // SAVE STATISTICS
  // ============================================================

  /// Saves game statistics.
  ///
  /// Returns true when the save succeeds.
  Future<bool> saveStatistics(
    GameStatistics statistics,
  ) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final data =
          statistics.toJson();

      return await preferences.setString(
        _statisticsKey,
        jsonEncode(data),
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // DELETE STATISTICS
  // ============================================================

  /// Deletes stored statistics.
  ///
  /// This does not reset the in-memory statistics object.
  Future<bool> deleteStatistics() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      return await preferences.remove(
        _statisticsKey,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // CLEAR ALL STORAGE
  // ============================================================

  /// Removes saved game, settings, and statistics.
  Future<bool> clearAll() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      await preferences.remove(
        _savedGameKey,
      );

      await preferences.remove(
        _settingsKey,
      );

      await preferences.remove(
        _statisticsKey,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}

