import '../models/game_piece.dart';

import '../services/game_settings.dart';
import 'checkers_engine.dart';

/// AI opponent for Checkers / Draughts.
///
/// The AI always uses the active CheckersEngine, meaning
/// country-specific movement and capture rules are respected.
class CheckersAI {
  AiDifficulty difficulty;

  final PieceColor aiColor;

  CheckersAI({
    this.difficulty =
        AiDifficulty.medium,
    this.aiColor =
        PieceColor.black,
  });

  // ============================================================
  // DIFFICULTY
  // ============================================================

  void setDifficulty(
    AiDifficulty value,
  ) {
    difficulty = value;
  }

  String get difficultyName {
    switch (difficulty) {
      case AiDifficulty.easy:
        return 'Easy';

      case AiDifficulty.medium:
        return 'Medium';

      case AiDifficulty.hard:
        return 'Hard';

      case AiDifficulty.expert:
        return 'Expert';
    }
  }

  int get searchDepth {
    switch (difficulty) {
      case AiDifficulty.easy:
        return 1;

      case AiDifficulty.medium:
        return 3;

      case AiDifficulty.hard:
        return 5;

      case AiDifficulty.expert:
        return 6;
    }
  }

  // ============================================================
  // BEST MOVE
  // ============================================================

  CheckersMove? findBestMove(
    CheckersEngine engine,
  ) {
    if (engine.turn != aiColor) {
      return null;
    }

    if (engine.isGameOver) {
      return null;
    }

    final moves =
        engine.allLegalMoves();

    if (moves.isEmpty) {
      return null;
    }

    if (difficulty ==
        AiDifficulty.easy) {
      return _findEasyMove(
        engine,
        moves,
      );
    }

    final orderedMoves =
        _orderMoves(
      engine,
      moves,
    );

    CheckersMove? bestMove;

    double bestScore =
        double.negativeInfinity;

    for (final move
        in orderedMoves) {
      final simulation =
          _copyEngine(
        engine,
      );

      if (!simulation.makeMove(
        move,
      )) {
        continue;
      }

      final score =
          _minimax(
        simulation,
        searchDepth - 1,
        double.negativeInfinity,
        double.infinity,
      );

      if (bestMove == null ||
          score > bestScore) {
        bestMove = move;
        bestScore = score;
      }
    }

    return bestMove ??
        moves.first;
  }

  // ============================================================
  // EASY
  // ============================================================

  CheckersMove _findEasyMove(
    CheckersEngine engine,
    List<CheckersMove> moves,
  ) {
    for (final move in moves) {
      if (move.isCapture) {
        return move;
      }
    }

    for (final move in moves) {
      final piece =
          engine.board[
              move.fromRow]
              [move.fromCol];

      if (piece == null) {
        continue;
      }

      if (_willPromote(
        engine,
        piece,
        move.toRow,
      )) {
        return move;
      }
    }

    return moves.first;
  }

  // ============================================================
  // MINIMAX
  // ============================================================

  double _minimax(
    CheckersEngine engine,
    int depth,
    double alpha,
    double beta,
  ) {
    final winner =
        engine.winner();

    if (winner != null) {
      if (winner == aiColor) {
        return 1000000.0 +
            depth;
      }

      return -1000000.0 -
          depth;
    }

    if (engine.isDraw) {
      return 0;
    }

    if (depth <= 0) {
      return _evaluate(
        engine,
      );
    }

    final moves =
        engine.allLegalMoves();

    if (moves.isEmpty) {
      return _evaluate(
        engine,
      );
    }

    final maximizing =
        engine.turn == aiColor;

    final ordered =
        _orderMoves(
      engine,
      moves,
    );

    if (maximizing) {
      double value =
          double.negativeInfinity;

      for (final move
          in ordered) {
        final simulation =
            _copyEngine(
          engine,
        );

        if (!simulation.makeMove(
          move,
        )) {
          continue;
        }

        final score =
            _minimax(
          simulation,
          depth - 1,
          alpha,
          beta,
        );

        if (score > value) {
          value = score;
        }

        if (value > alpha) {
          alpha = value;
        }

        if (beta <= alpha) {
          break;
        }
      }

      return value;
    }

    double value =
        double.infinity;

    for (final move
        in ordered) {
      final simulation =
          _copyEngine(
        engine,
      );

      if (!simulation.makeMove(
        move,
      )) {
        continue;
      }

      final score =
          _minimax(
        simulation,
        depth - 1,
        alpha,
        beta,
      );

      if (score < value) {
        value = score;
      }

      if (value < beta) {
        beta = value;
      }

      if (beta <= alpha) {
        break;
      }
    }

    return value;
  }

  // ============================================================
  // MOVE ORDERING
  // ============================================================

  List<CheckersMove> _orderMoves(
    CheckersEngine engine,
    List<CheckersMove> moves,
  ) {
    final result =
        List<CheckersMove>.from(
      moves,
    );

    result.sort(
      (a, b) {
        return _moveScore(
          engine,
          b,
        ).compareTo(
          _moveScore(
            engine,
            a,
          ),
        );
      },
    );

    return result;
  }

  double _moveScore(
    CheckersEngine engine,
    CheckersMove move,
  ) {
    double score = 0;

    final piece =
        engine.board[
            move.fromRow]
            [move.fromCol];

    if (piece == null) {
      return score;
    }

    if (move.isCapture) {
      score += 10000;
    }

    if (_willPromote(
      engine,
      piece,
      move.toRow,
    )) {
      score += 3000;
    }

    if (piece.isKing) {
      score += 500;
    }

    final center =
        (engine.size - 1) / 2;

    final distance =
        (move.toRow - center).abs() +
        (move.toCol - center).abs();

    score +=
        (engine.size * 2) -
        distance;

    return score;
  }

  // ============================================================
  // EVALUATION
  // ============================================================

  double _evaluate(
    CheckersEngine engine,
  ) {
    double score = 0;

    for (int row = 0;
        row < engine.size;
        row++) {
      for (int col = 0;
          col < engine.size;
          col++) {
        final piece =
            engine.board[row][col];

        if (piece == null) {
          continue;
        }

        double value = 100;

        if (piece.isKing) {
          value += 180;

          final center =
              (engine.size - 1) / 2;

          final distance =
              (row - center).abs() +
              (col - center).abs();

          value +=
              engine.size * 2 -
              distance;
        } else {
          // Promotion progress.
          if (piece.color ==
              PieceColor.black) {
            value +=
                (engine.size - 1 - row) *
                    5;
          } else {
            value +=
                row * 5;
          }
        }

        // Mobility / central control.
        final center =
            (engine.size - 1) / 2;

        final distance =
            (row - center).abs() +
            (col - center).abs();

        value +=
            engine.size -
            distance;

        if (piece.color ==
            aiColor) {
          score += value;
        } else {
          score -= value;
        }
      }
    }

    // ----------------------------------------------------------
    // PIECE ADVANTAGE
    // ----------------------------------------------------------

    score +=
        (engine.countPieces(
                  aiColor,
                ) -
                engine.countPieces(
                  _opponentColor,
                )) *
            25;

    // ----------------------------------------------------------
    // KING ADVANTAGE
    // ----------------------------------------------------------

    score +=
        (engine.countKings(
                  aiColor,
                ) -
                engine.countKings(
                  _opponentColor,
                )) *
            40;

    // ----------------------------------------------------------
    // MOBILITY
    // ----------------------------------------------------------

    final currentMoves =
        engine.allLegalMoves().length;

    if (engine.turn == aiColor) {
      score +=
          currentMoves * 4;
    } else {
      score -=
          currentMoves * 4;
    }

    // ----------------------------------------------------------
    // CAPTURE PRESSURE
    // ----------------------------------------------------------

    if (engine.playerHasCapture(
      aiColor,
    )) {
      score += 30;
    }

    if (engine.playerHasCapture(
      _opponentColor,
    )) {
      score -= 30;
    }

    // ----------------------------------------------------------
    // RULE-SPECIFIC BONUS
    // ----------------------------------------------------------

    if (engine.rulesConfig
            .maximumCaptureRequired) {
      if (engine.turn == aiColor &&
          engine.playerHasCapture(
            aiColor,
          )) {
        score += 20;
      }
    }

    return score;
  }

  PieceColor get _opponentColor {
    return aiColor ==
            PieceColor.red
        ? PieceColor.black
        : PieceColor.red;
  }

  // ============================================================
  // PROMOTION
  // ============================================================

  bool _willPromote(
    CheckersEngine engine,
    GamePiece piece,
    int destinationRow,
  ) {
    if (piece.isKing) {
      return false;
    }

    if (!engine.rulesConfig
        .promoteOnLastRow) {
      return false;
    }

    if (piece.color ==
        PieceColor.red) {
      return destinationRow == 0;
    }

    return destinationRow ==
        engine.size - 1;
  }

  // ============================================================
  // COPY ENGINE
  // ============================================================

  CheckersEngine _copyEngine(
    CheckersEngine source,
  ) {
    final copy =
        CheckersEngine(
      rules:
          source.rulesConfig,
    );

    copy.fromJson(
      source.toJson(),
      preserveUndoRedo: true,
    );

    return copy;
  }
}