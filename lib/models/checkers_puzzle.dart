/// Represents a single Drafts / Checkers puzzle.
///
/// A puzzle contains:
/// - a starting board position
/// - the side to move
/// - the correct solution
/// - difficulty
/// - category
/// - optional explanation
class CheckersPuzzle {
  final String id;
  final String title;
  final String description;

  /// JSON-compatible board data.
  final List<List<Map<String, dynamic>?>> board;

  /// Color whose turn it is.
  final String turn;

  /// Correct sequence of moves.
  ///
  /// Each move is:
  /// [fromRow, fromCol, toRow, toCol]
  final List<List<int>> solution;

  final PuzzleDifficulty difficulty;
  final PuzzleCategory category;

  /// Explanation shown after successful completion.
  final String explanation;

  /// Points awarded for solving the puzzle.
  final int points;

  const CheckersPuzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.board,
    required this.turn,
    required this.solution,
    required this.difficulty,
    required this.category,
    required this.explanation,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'board': board,
      'turn': turn,
      'solution': solution,
      'difficulty': difficulty.name,
      'category': category.name,
      'explanation': explanation,
      'points': points,
    };
  }

  factory CheckersPuzzle.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawBoard = json['board'];

    final parsedBoard =
        <List<Map<String, dynamic>?>>[];

    if (rawBoard is List) {
      for (final rawRow in rawBoard) {
        final row =
            <Map<String, dynamic>?>[];

        if (rawRow is List) {
          for (final value in rawRow) {
            if (value is Map) {
              row.add(
                Map<String, dynamic>.from(value),
              );
            } else {
              row.add(null);
            }
          }
        }

        while (row.length < 8) {
          row.add(null);
        }

        if (row.length > 8) {
          row.removeRange(8, row.length);
        }

        parsedBoard.add(row);
      }
    }

    while (parsedBoard.length < 8) {
      parsedBoard.add(
        List<Map<String, dynamic>?>.filled(
          8,
          null,
        ),
      );
    }

    if (parsedBoard.length > 8) {
      parsedBoard.removeRange(8, parsedBoard.length);
    }

    final rawSolution = json['solution'];

    final parsedSolution = <List<int>>[];

    if (rawSolution is List) {
      for (final item in rawSolution) {
        if (item is List && item.length >= 4) {
          parsedSolution.add([
            _readInt(item[0]),
            _readInt(item[1]),
            _readInt(item[2]),
            _readInt(item[3]),
          ]);
        }
      }
    }

    return CheckersPuzzle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
      board: parsedBoard,
      turn: json['turn']?.toString() ?? 'red',
      solution: parsedSolution,
      difficulty: PuzzleDifficulty.values.firstWhere(
        (value) =>
            value.name == json['difficulty'],
        orElse: () => PuzzleDifficulty.easy,
      ),
      category: PuzzleCategory.values.firstWhere(
        (value) =>
            value.name == json['category'],
        orElse: () => PuzzleCategory.capture,
      ),
      explanation:
          json['explanation']?.toString() ?? '',
      points: _readInt(json['points']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

enum PuzzleDifficulty {
  easy,
  medium,
  hard,
  expert,
}

enum PuzzleCategory {
  capture,
  multiJump,
  king,
  promotion,
  defense,
  tactics,
}