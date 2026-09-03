
import '../models/game_piece.dart';

/// Represents one completed Drafts / Checkers game.
///
/// A history record contains the important information about
/// the completed game so it can be displayed later.
class GameHistory {
  final DateTime date;

  final PieceColor playerColor;
  final PieceColor winner;

  final int moves;
  final int captures;
  final int kingsCreated;

  final bool playerVsAi;
  final String difficulty;

  const GameHistory({
    required this.date,
    required this.playerColor,
    required this.winner,
    required this.moves,
    required this.captures,
    required this.kingsCreated,
    required this.playerVsAi,
    required this.difficulty,
  });

  // ============================================================
  // RESULT
  // ============================================================

  bool get playerWon {
    return winner == playerColor;
  }

  bool get playerLost {
    return winner != playerColor;
  }

  String get result {
    if (playerWon) {
      return 'WIN';
    }

    return 'LOSS';
  }

  // ============================================================
  // OPPONENT
  // ============================================================

  String get opponentName {
    if (playerVsAi) {
      return 'AI • $difficulty';
    }

    return 'Player 2';
  }

  // ============================================================
  // PLAYER COLOR TEXT
  // ============================================================

  String get playerColorText {
    switch (playerColor) {
      case PieceColor.red:
        return 'Red';

      case PieceColor.black:
        return 'Black';
    }
  }

  // ============================================================
  // WINNER TEXT
  // ============================================================

  String get winnerText {
    switch (winner) {
      case PieceColor.red:
        return 'Red';

      case PieceColor.black:
        return 'Black';
    }
  }

  // ============================================================
  // GAME MODE TEXT
  // ============================================================

  String get gameModeText {
    return playerVsAi
        ? 'Player vs AI'
        : 'Player vs Player';
  }

  // ============================================================
  // DATE TEXT
  // ============================================================

  String get dateText {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // TIME TEXT
  // ============================================================

  String get timeText {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),

      'playerColor': playerColor.name,

      'winner': winner.name,

      'moves': moves,

      'captures': captures,

      'kingsCreated': kingsCreated,

      'playerVsAi': playerVsAi,

      'difficulty': difficulty,
    };
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory GameHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    return GameHistory(
      date: _readDate(json['date']),
      playerColor: _readColor(
        json['playerColor'],
        PieceColor.red,
      ),
      winner: _readColor(
        json['winner'],
        PieceColor.black,
      ),
      moves: _readInt(json['moves']),
      captures: _readInt(json['captures']),
      kingsCreated: _readInt(
        json['kingsCreated'],
      ),
      playerVsAi: _readBool(
        json['playerVsAi'],
        true,
      ),
      difficulty:
          json['difficulty'] is String
              ? json['difficulty'] as String
              : 'Unknown',
    );
  }

  // ============================================================
  // SAFE DATE
  // ============================================================

  static DateTime _readDate(
    dynamic value,
  ) {
    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    return DateTime.now();
  }

  // ============================================================
  // SAFE COLOR
  // ============================================================

  static PieceColor _readColor(
    dynamic value,
    PieceColor fallback,
  ) {
    if (value is String) {
      for (final color in PieceColor.values) {
        if (color.name == value) {
          return color;
        }
      }
    }

    return fallback;
  }

  // ============================================================
  // SAFE INTEGER
  // ============================================================

  static int _readInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  // ============================================================
  // SAFE BOOLEAN
  // ============================================================

  static bool _readBool(
    dynamic value,
    bool fallback,
  ) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      if (value.toLowerCase() == 'true') {
        return true;
      }

      if (value.toLowerCase() == 'false') {
        return false;
      }
    }

    return fallback;
  }
}
