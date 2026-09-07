import '../models/game_piece.dart';

class GameHistory {
  final DateTime date;
  final PieceColor playerColor;
  final PieceColor? winner;

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

  bool get playerWon {
    return winner != null && winner == playerColor;
  }

  bool get playerLost {
    return winner != null && winner != playerColor;
  }

  bool get isDraw {
    return winner == null;
  }

  String get result {
    if (isDraw) {
      return 'DRAW';
    }

    if (playerWon) {
      return 'WIN';
    }

    return 'LOSS';
  }

  String get opponentName {
    if (playerVsAi) {
      return 'AI • $difficulty';
    }

    return 'Player 2';
  }

  String get playerColorText {
    switch (playerColor) {
      case PieceColor.red:
        return 'Red';

      case PieceColor.black:
        return 'Black';
    }
  }

  String get winnerText {
    if (winner == null) {
      return 'Draw';
    }

    switch (winner!) {
      case PieceColor.red:
        return 'Red';

      case PieceColor.black:
        return 'Black';
    }
  }

  String get gameModeText {
    return playerVsAi ? 'Player vs AI' : 'Player vs Player';
  }

  String get dateText {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  String get timeText {
    final localDate = date.toLocal();

    return '${localDate.hour.toString().padLeft(2, '0')}:'
        '${localDate.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'playerColor': playerColor.name,
      'winner': winner?.name,
      'moves': moves,
      'captures': captures,
      'kingsCreated': kingsCreated,
      'playerVsAi': playerVsAi,
      'difficulty': difficulty,
    };
  }

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      date: _readDate(json['date']),
      playerColor: _readColor(
        json['playerColor'],
        PieceColor.red,
      ),
      winner: _readNullableColor(json['winner']),
      moves: _readInt(json['moves']),
      captures: _readInt(json['captures']),
      kingsCreated: _readInt(json['kingsCreated']),
      playerVsAi: _readBool(
        json['playerVsAi'],
        true,
      ),
      difficulty: json['difficulty'] is String
          ? json['difficulty'] as String
          : 'Unknown',
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }

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

  static PieceColor? _readNullableColor(dynamic value) {
    if (value is String) {
      for (final color in PieceColor.values) {
        if (color.name == value) {
          return color;
        }
      }
    }

    return null;
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static bool _readBool(
    dynamic value,
    bool fallback,
  ) {
    if (value is bool) {
      return value;
    }

    return fallback;
  }
}