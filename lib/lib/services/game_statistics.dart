
import '../models/game_piece.dart';

/// Stores statistics for the Drafts / Checkers game.
///
/// This class is responsible for tracking:
/// - games played
/// - wins
/// - losses
/// - draws
/// - captures
/// - kings created
/// - longest game
/// - current win/loss streak
/// - best win streak
class GameStatistics {
  // ============================================================
  // SINGLETON
  // ============================================================

  static final GameStatistics instance =
      GameStatistics._internal();

  GameStatistics._internal();

  factory GameStatistics() {
    return instance;
  }

  // ============================================================
  // TOTAL GAMES
  // ============================================================

  int _gamesPlayed = 0;

  int get gamesPlayed =>
      _gamesPlayed;

  // ============================================================
  // WINS
  // ============================================================

  int _wins = 0;

  int get wins =>
      _wins;

  // ============================================================
  // LOSSES
  // ============================================================

  int _losses = 0;

  int get losses =>
      _losses;

  // ============================================================
  // DRAWS
  // ============================================================

  int _draws = 0;

  int get draws =>
      _draws;

  // ============================================================
  // RED WINS
  // ============================================================

  int _redWins = 0;

  int get redWins =>
      _redWins;

  // ============================================================
  // BLACK WINS
  // ============================================================

  int _blackWins = 0;

  int get blackWins =>
      _blackWins;

  // ============================================================
  // TOTAL CAPTURES
  // ============================================================

  int _totalCaptures = 0;

  int get totalCaptures =>
      _totalCaptures;

  // ============================================================
  // TOTAL PIECES CAPTURED BY PLAYER
  // ============================================================

  int _piecesCapturedByPlayer = 0;

  int get piecesCapturedByPlayer =>
      _piecesCapturedByPlayer;

  // ============================================================
  // TOTAL PIECES LOST BY PLAYER
  // ============================================================

  int _piecesLostByPlayer = 0;

  int get piecesLostByPlayer =>
      _piecesLostByPlayer;

  // ============================================================
  // KINGS CREATED
  // ============================================================

  int _kingsCreated = 0;

  int get kingsCreated =>
      _kingsCreated;

  // ============================================================
  // LONGEST GAME
  // ============================================================

  int _longestGameMoves = 0;

  int get longestGameMoves =>
      _longestGameMoves;

  // ============================================================
  // TOTAL MOVES
  // ============================================================

  int _totalMoves = 0;

  int get totalMoves =>
      _totalMoves;

  // ============================================================
  // CURRENT WIN STREAK
  // ============================================================

  int _currentWinStreak = 0;

  int get currentWinStreak =>
      _currentWinStreak;

  // ============================================================
  // BEST WIN STREAK
  // ============================================================

  int _bestWinStreak = 0;

  int get bestWinStreak =>
      _bestWinStreak;

  // ============================================================
  // CURRENT LOSS STREAK
  // ============================================================

  int _currentLossStreak = 0;

  int get currentLossStreak =>
      _currentLossStreak;

  // ============================================================
  // BEST LOSS STREAK
  // ============================================================

  int _bestLossStreak = 0;

  int get bestLossStreak =>
      _bestLossStreak;

  // ============================================================
  // PLAYER COLOR
  // ============================================================

  /// Records the result from the player's perspective.
  ///
  /// [playerColor] = the color controlled by the human player.
  /// [winner] = the color that won.
  ///
  /// If winner is null, the game is treated as a draw.
  void recordGameResult({
    required PieceColor playerColor,
    PieceColor? winner,
    int moves = 0,
  }) {
    _gamesPlayed++;

    _totalMoves += moves;

    if (moves > _longestGameMoves) {
      _longestGameMoves = moves;
    }

    // ----------------------------------------------------------
    // DRAW
    // ----------------------------------------------------------

    if (winner == null) {
      _draws++;

      _currentWinStreak = 0;
      _currentLossStreak = 0;

      return;
    }

    // ----------------------------------------------------------
    // COLOR STATISTICS
    // ----------------------------------------------------------

    if (winner == PieceColor.red) {
      _redWins++;
    } else {
      _blackWins++;
    }

    // ----------------------------------------------------------
    // PLAYER RESULT
    // ----------------------------------------------------------

    if (winner == playerColor) {
      _wins++;

      _currentWinStreak++;

      _currentLossStreak = 0;

      if (_currentWinStreak >
          _bestWinStreak) {
        _bestWinStreak =
            _currentWinStreak;
      }
    } else {
      _losses++;

      _currentLossStreak++;

      _currentWinStreak = 0;

      if (_currentLossStreak >
          _bestLossStreak) {
        _bestLossStreak =
            _currentLossStreak;
      }
    }
  }

  // ============================================================
  // CAPTURE STATISTICS
  // ============================================================

  void recordCapture({
    required PieceColor capturedColor,
    required PieceColor playerColor,
  }) {
    _totalCaptures++;

    if (capturedColor != playerColor) {
      _piecesCapturedByPlayer++;
    } else {
      _piecesLostByPlayer++;
    }
  }

  // ============================================================
  // KING STATISTICS
  // ============================================================

  void recordKingCreated() {
    _kingsCreated++;
  }

  // ============================================================
  // WIN RATE
  // ============================================================

  double get winRate {
    final completedGames =
        _wins +
        _losses +
        _draws;

    if (completedGames == 0) {
      return 0;
    }

    return (_wins /
            completedGames) *
        100;
  }

  // ============================================================
  // LOSS RATE
  // ============================================================

  double get lossRate {
    final completedGames =
        _wins +
        _losses +
        _draws;

    if (completedGames == 0) {
      return 0;
    }

    return (_losses /
            completedGames) *
        100;
  }

  // ============================================================
  // DRAW RATE
  // ============================================================

  double get drawRate {
    final completedGames =
        _wins +
        _losses +
        _draws;

    if (completedGames == 0) {
      return 0;
    }

    return (_draws /
            completedGames) *
        100;
  }

  // ============================================================
  // AVERAGE MOVES
  // ============================================================

  double get averageMovesPerGame {
    if (_gamesPlayed == 0) {
      return 0;
    }

    return _totalMoves /
        _gamesPlayed;
  }

  // ============================================================
  // WIN/LOSS RATIO
  // ============================================================

  double get winLossRatio {
    if (_losses == 0) {
      return _wins.toDouble();
    }

    return _wins / _losses;
  }

  // ============================================================
  // FORMATTED VALUES
  // ============================================================

  String get winRateText {
    return '${winRate.toStringAsFixed(1)}%';
  }

  String get lossRateText {
    return '${lossRate.toStringAsFixed(1)}%';
  }

  String get drawRateText {
    return '${drawRate.toStringAsFixed(1)}%';
  }

  String get averageMovesText {
    return averageMovesPerGame
        .toStringAsFixed(1);
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Map<String, dynamic> get summary {
    return {
      'gamesPlayed':
          _gamesPlayed,

      'wins':
          _wins,

      'losses':
          _losses,

      'draws':
          _draws,

      'redWins':
          _redWins,

      'blackWins':
          _blackWins,

      'totalCaptures':
          _totalCaptures,

      'piecesCapturedByPlayer':
          _piecesCapturedByPlayer,

      'piecesLostByPlayer':
          _piecesLostByPlayer,

      'kingsCreated':
          _kingsCreated,

      'longestGameMoves':
          _longestGameMoves,

      'totalMoves':
          _totalMoves,

      'currentWinStreak':
          _currentWinStreak,

      'bestWinStreak':
          _bestWinStreak,

      'currentLossStreak':
          _currentLossStreak,

      'bestLossStreak':
          _bestLossStreak,

      'winRate':
          winRate,

      'lossRate':
          lossRate,

      'drawRate':
          drawRate,

      'averageMovesPerGame':
          averageMovesPerGame,
    };
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed':
          _gamesPlayed,

      'wins':
          _wins,

      'losses':
          _losses,

      'draws':
          _draws,

      'redWins':
          _redWins,

      'blackWins':
          _blackWins,

      'totalCaptures':
          _totalCaptures,

      'piecesCapturedByPlayer':
          _piecesCapturedByPlayer,

      'piecesLostByPlayer':
          _piecesLostByPlayer,

      'kingsCreated':
          _kingsCreated,

      'longestGameMoves':
          _longestGameMoves,

      'totalMoves':
          _totalMoves,

      'currentWinStreak':
          _currentWinStreak,

      'bestWinStreak':
          _bestWinStreak,

      'currentLossStreak':
          _currentLossStreak,

      'bestLossStreak':
          _bestLossStreak,
    };
  }

  // ============================================================
  // LOAD JSON
  // ============================================================

  void fromJson(
    Map<String, dynamic> json,
  ) {
    _gamesPlayed =
        _readInt(
      json['gamesPlayed'],
    );

    _wins =
        _readInt(
      json['wins'],
    );

    _losses =
        _readInt(
      json['losses'],
    );

    _draws =
        _readInt(
      json['draws'],
    );

    _redWins =
        _readInt(
      json['redWins'],
    );

    _blackWins =
        _readInt(
      json['blackWins'],
    );

    _totalCaptures =
        _readInt(
      json['totalCaptures'],
    );

    _piecesCapturedByPlayer =
        _readInt(
      json['piecesCapturedByPlayer'],
    );

    _piecesLostByPlayer =
        _readInt(
      json['piecesLostByPlayer'],
    );

    _kingsCreated =
        _readInt(
      json['kingsCreated'],
    );

    _longestGameMoves =
        _readInt(
      json['longestGameMoves'],
    );

    _totalMoves =
        _readInt(
      json['totalMoves'],
    );

    _currentWinStreak =
        _readInt(
      json['currentWinStreak'],
    );

    _bestWinStreak =
        _readInt(
      json['bestWinStreak'],
    );

    _currentLossStreak =
        _readInt(
      json['currentLossStreak'],
    );

    _bestLossStreak =
        _readInt(
      json['bestLossStreak'],
    );
  }

  // ============================================================
  // SAFE INTEGER READER
  // ============================================================

  int _readInt(dynamic value) {
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
  // RESET
  // ============================================================

  void reset() {
    _gamesPlayed = 0;

    _wins = 0;

    _losses = 0;

    _draws = 0;

    _redWins = 0;

    _blackWins = 0;

    _totalCaptures = 0;

    _piecesCapturedByPlayer = 0;

    _piecesLostByPlayer = 0;

    _kingsCreated = 0;

    _longestGameMoves = 0;

    _totalMoves = 0;

    _currentWinStreak = 0;

    _bestWinStreak = 0;

    _currentLossStreak = 0;

    _bestLossStreak = 0;
  }
}
