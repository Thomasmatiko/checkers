
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_history.dart';

/// Handles persistent storage of completed Checkers games.
///
/// This service is separate from [GameStatistics].
/// Statistics store totals, while this service stores
/// individual completed games.
class GameHistoryService {
  // ============================================================
  // SINGLETON
  // ============================================================

  static final GameHistoryService instance =
      GameHistoryService._internal();

  GameHistoryService._internal();

  factory GameHistoryService() {
    return instance;
  }

  // ============================================================
  // STORAGE KEY
  // ============================================================

  static const String _historyKey =
      'checkers_game_history';

  // ============================================================
  // MAXIMUM HISTORY
  // ============================================================

  /// Maximum number of games kept in history.
  ///
  /// Keeping a limit prevents the local storage from growing
  /// forever.
  static const int maxHistory = 100;

  // ============================================================
  // SAVE GAME
  // ============================================================

  /// Adds a completed game to history.
  ///
  /// The newest game is stored first.
  Future<bool> addGame(
    GameHistory game,
  ) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final history =
          await getHistory();

      history.insert(0, game);

      // Keep only the newest games.
      if (history.length > maxHistory) {
        history.removeRange(
          maxHistory,
          history.length,
        );
      }

      final encoded = history
          .map(
            (game) => game.toJson(),
          )
          .toList();

      return await preferences.setString(
        _historyKey,
        jsonEncode(encoded),
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // GET HISTORY
  // ============================================================

  /// Returns all stored games.
  ///
  /// Newest games are returned first.
  Future<List<GameHistory>> getHistory() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final jsonString =
          preferences.getString(
        _historyKey,
      );

      if (jsonString == null ||
          jsonString.isEmpty) {
        return [];
      }

      final decoded =
          jsonDecode(jsonString);

      if (decoded is! List) {
        return [];
      }

      final List<GameHistory> history = [];

      for (final item in decoded) {
        if (item is Map) {
          try {
            final data =
                Map<String, dynamic>.from(item);

            history.add(
              GameHistory.fromJson(data),
            );
          } catch (_) {
            // Ignore invalid history entries.
          }
        }
      }

      return history;
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // GAME COUNT
  // ============================================================

  /// Returns the number of games stored in history.
  Future<int> count() async {
    final history = await getHistory();

    return history.length;
  }

  // ============================================================
  // HAS HISTORY
  // ============================================================

  /// Returns true when at least one completed game exists.
  Future<bool> hasHistory() async {
    final history = await getHistory();

    return history.isNotEmpty;
  }

  // ============================================================
  // GET GAME
  // ============================================================

  /// Returns a game at [index].
  ///
  /// Returns null if the index is invalid.
  Future<GameHistory?> getGame(
    int index,
  ) async {
    final history = await getHistory();

    if (index < 0 ||
        index >= history.length) {
      return null;
    }

    return history[index];
  }

  // ============================================================
  // DELETE ONE GAME
  // ============================================================

  /// Deletes one history entry.
  Future<bool> deleteGame(
    int index,
  ) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final history =
          await getHistory();

      if (index < 0 ||
          index >= history.length) {
        return false;
      }

      history.removeAt(index);

      final encoded = history
          .map(
            (game) => game.toJson(),
          )
          .toList();

      return await preferences.setString(
        _historyKey,
        jsonEncode(encoded),
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // CLEAR HISTORY
  // ============================================================

  /// Deletes every completed game from history.
  Future<bool> clearHistory() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      return await preferences.remove(
        _historyKey,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // GET WINS
  // ============================================================

  /// Returns only games won by the player.
  Future<List<GameHistory>> getWins() async {
    final history = await getHistory();

    return history
        .where(
          (game) => game.playerWon,
        )
        .toList();
  }

  // ============================================================
  // GET LOSSES
  // ============================================================

  /// Returns only games lost by the player.
  Future<List<GameHistory>> getLosses() async {
    final history = await getHistory();

    return history
        .where(
          (game) => game.playerLost,
        )
        .toList();
  }

  // ============================================================
  // GET AI GAMES
  // ============================================================

  /// Returns only Player vs AI games.
  Future<List<GameHistory>> getAiGames() async {
    final history = await getHistory();

    return history
        .where(
          (game) => game.playerVsAi,
        )
        .toList();
  }

  // ============================================================
  // GET PLAYER GAMES
  // ============================================================

  /// Returns only Player vs Player games.
  Future<List<GameHistory>> getPlayerGames() async {
    final history = await getHistory();

    return history
        .where(
          (game) => !game.playerVsAi,
        )
        .toList();
  }

  // ============================================================
  // CLEAR EVERYTHING
  // ============================================================

  /// Alias for [clearHistory].
  Future<bool> deleteAll() async {
    return clearHistory();
  }
}

