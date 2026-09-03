import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checkers_puzzle.dart';

/// Provides built-in puzzles and stores puzzle progress.
class PuzzleService {
  static const String _completedKey =
      'checkers_completed_puzzles';

  static const String _scoresKey =
      'checkers_puzzle_scores';

  static const String _streakKey =
      'checkers_puzzle_streak';

  // ============================================================
  // SINGLETON
  // ============================================================

  static final PuzzleService instance =
      PuzzleService._internal();

  PuzzleService._internal();

  factory PuzzleService() {
    return instance;
  }

  // ============================================================
  // PUZZLES
  // ============================================================

  List<CheckersPuzzle> get puzzles {
    return _builtInPuzzles;
  }

  List<CheckersPuzzle> get easyPuzzles {
    return puzzles
        .where(
          (puzzle) =>
              puzzle.difficulty ==
              PuzzleDifficulty.easy,
        )
        .toList();
  }

  List<CheckersPuzzle> get mediumPuzzles {
    return puzzles
        .where(
          (puzzle) =>
              puzzle.difficulty ==
              PuzzleDifficulty.medium,
        )
        .toList();
  }

  List<CheckersPuzzle> get hardPuzzles {
    return puzzles
        .where(
          (puzzle) =>
              puzzle.difficulty ==
              PuzzleDifficulty.hard,
        )
        .toList();
  }

  List<CheckersPuzzle> get expertPuzzles {
    return puzzles
        .where(
          (puzzle) =>
              puzzle.difficulty ==
              PuzzleDifficulty.expert,
        )
        .toList();
  }

  CheckersPuzzle? findById(
    String id,
  ) {
    for (final puzzle in puzzles) {
      if (puzzle.id == id) {
        return puzzle;
      }
    }

    return null;
  }

  // ============================================================
  // COMPLETED PUZZLES
  // ============================================================

  Future<Set<String>> completedPuzzleIds() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final raw =
          preferences.getStringList(
        _completedKey,
      );

      if (raw == null) {
        return <String>{};
      }

      return raw.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<bool> isCompleted(
    String puzzleId,
  ) async {
    final completed =
        await completedPuzzleIds();

    return completed.contains(puzzleId);
  }

  // ============================================================
  // SCORE
  // ============================================================

  Future<Map<String, int>> _readScores() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final raw =
          preferences.getString(
        _scoresKey,
      );

      if (raw == null || raw.isEmpty) {
        return <String, int>{};
      }

      final decoded =
          jsonDecode(raw);

      if (decoded is! Map) {
        return <String, int>{};
      }

      final scores = <String, int>{};

      for (final entry in decoded.entries) {
        final value = entry.value;

        if (value is int) {
          scores[
              entry.key.toString()] = value;
        } else if (value is num) {
          scores[
              entry.key.toString()] = value.toInt();
        }
      }

      return scores;
    } catch (_) {
      return <String, int>{};
    }
  }

  Future<int> bestScore(
    String puzzleId,
  ) async {
    final scores = await _readScores();

    return scores[puzzleId] ?? 0;
  }

  // ============================================================
  // COMPLETE PUZZLE
  // ============================================================

  Future<bool> completePuzzle({
    required String puzzleId,
    required int score,
  }) async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      // --------------------------------------------------------
      // COMPLETED LIST
      // --------------------------------------------------------

      final completed =
          await completedPuzzleIds();

      completed.add(puzzleId);

      await preferences.setStringList(
        _completedKey,
        completed.toList(),
      );

      // --------------------------------------------------------
      // BEST SCORE
      // --------------------------------------------------------

      final scores =
          await _readScores();

      final oldScore =
          scores[puzzleId] ?? 0;

      if (score > oldScore) {
        scores[puzzleId] = score;

        await preferences.setString(
          _scoresKey,
          jsonEncode(scores),
        );
      }

      // --------------------------------------------------------
      // STREAK
      // --------------------------------------------------------

      final currentStreak =
          await puzzleStreak();

      await preferences.setInt(
        _streakKey,
        currentStreak + 1,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // STREAK
  // ============================================================

  Future<int> puzzleStreak() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      return preferences.getInt(
            _streakKey,
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> resetStreak() async {
  try {
    final preferences =
        await SharedPreferences.getInstance();

    return await preferences.setInt(
      _streakKey,
      0,
    );
  } catch (_) {
    return false;
  }
}
  // ============================================================
  // TOTAL SCORE
  // ============================================================

  Future<int> totalScore() async {
    final scores = await _readScores();

    int total = 0;

    for (final score in scores.values) {
      total += score;
    }

    return total;
  }

  // ============================================================
  // RESET PUZZLE PROGRESS
  // ============================================================

  Future<bool> resetProgress() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      await preferences.remove(
        _completedKey,
      );

      await preferences.remove(
        _scoresKey,
      );

      await preferences.remove(
        _streakKey,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // BUILT-IN PUZZLES
  // ============================================================

  static final List<CheckersPuzzle>
      _builtInPuzzles = [

    // ----------------------------------------------------------
    // PUZZLE 1
    // ----------------------------------------------------------

    CheckersPuzzle(
      id: 'capture_001',
      title: 'First Capture',
      description:
          'Find the mandatory capture.',
      board: _board(
        red: [
          [5, 0],
        ],
        black: [
          [4, 1],
        ],
      ),
      turn: 'red',
      solution: [
        [5, 0, 3, 2],
      ],
      difficulty:
          PuzzleDifficulty.easy,
      category:
          PuzzleCategory.capture,
      explanation:
          'The black piece is directly diagonal to the red piece, so the capture is mandatory.',
      points: 100,
    ),

    // ----------------------------------------------------------
    // PUZZLE 2
    // ----------------------------------------------------------

    CheckersPuzzle(
      id: 'multijump_001',
      title: 'Double Jump',
      description:
          'Complete the entire multiple-capture sequence.',
      board: _board(
        red: [
          [5, 0],
        ],
        black: [
          [4, 1],
          [2, 3],
        ],
      ),
      turn: 'red',
      solution: [
        [5, 0, 3, 2],
        [3, 2, 1, 4],
      ],
      difficulty:
          PuzzleDifficulty.medium,
      category:
          PuzzleCategory.multiJump,
      explanation:
          'After the first capture, the same red piece must continue capturing.',
      points: 200,
    ),

    // ----------------------------------------------------------
    // PUZZLE 3
    // ----------------------------------------------------------

    CheckersPuzzle(
      id: 'king_001',
      title: 'Flying King',
      description:
          'Use the king to capture the enemy from distance.',
      board: _board(
        redKings: [
          [5, 0],
        ],
        black: [
          [3, 2],
        ],
      ),
      turn: 'red',
      solution: [
        [5, 0, 1, 4],
      ],
      difficulty:
          PuzzleDifficulty.hard,
      category:
          PuzzleCategory.king,
      explanation:
          'A flying king can travel diagonally across empty squares and land beyond the captured piece.',
      points: 300,
    ),

    // ----------------------------------------------------------
    // PUZZLE 4
    // ----------------------------------------------------------

    CheckersPuzzle(
      id: 'promotion_001',
      title: 'Become a King',
      description:
          'Reach the promotion row.',
      board: _board(
        red: [
          [1, 2],
        ],
        black: [],
      ),
      turn: 'red',
      solution: [
        [1, 2, 0, 3],
      ],
      difficulty:
          PuzzleDifficulty.easy,
      category:
          PuzzleCategory.promotion,
      explanation:
          'Red pieces become kings when they reach row 0.',
      points: 100,
    ),

    // ----------------------------------------------------------
    // PUZZLE 5
    // ----------------------------------------------------------

    CheckersPuzzle(
      id: 'capture_002',
      title: 'Choose the Capture',
      description:
          'Make the available capture.',
      board: _board(
        red: [
          [5, 2],
        ],
        black: [
          [4, 1],
        ],
      ),
      turn: 'red',
      solution: [
        [5, 2, 3, 0],
      ],
      difficulty:
          PuzzleDifficulty.easy,
      category:
          PuzzleCategory.tactics,
      explanation:
          'Captures have priority over ordinary movement.',
      points: 100,
    ),
  ];

  // ============================================================
  // BOARD BUILDER
  // ============================================================

  static List<List<Map<String, dynamic>?>>
      _board({
    List<List<int>> red =
        const [],
    List<List<int>> black =
        const [],
    List<List<int>> redKings =
        const [],
    List<List<int>> blackKings =
        const [],
  }) {
    final board =
        List.generate(
      8,
      (_) =>
          List<Map<String, dynamic>?>.filled(
        8,
        null,
      ),
    );

    for (final position in red) {
      board[position[0]][position[1]] = {
        'color': 'red',
        'isKing': false,
      };
    }

    for (final position in black) {
      board[position[0]][position[1]] = {
        'color': 'black',
        'isKing': false,
      };
    }

    for (final position in redKings) {
      board[position[0]][position[1]] = {
        'color': 'red',
        'isKing': true,
      };
    }

    for (final position in blackKings) {
      board[position[0]][position[1]] = {
        'color': 'black',
        'isKing': true,
      };
    }

    return board;
  }
}