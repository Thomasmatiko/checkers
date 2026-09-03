
import 'package:flutter/material.dart';

import '../controllers/checkers_engine.dart';
import '../models/checkers_puzzle.dart';
import '../models/game_piece.dart';
import '../services/game_history_service.dart';
import '../services/puzzle_service.dart';

class PuzzleScreen extends StatefulWidget {
  final GameHistoryService historyService;

  const PuzzleScreen({
    super.key,
    required this.historyService,
  });

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final PuzzleService _puzzleService = PuzzleService();

  CheckersPuzzle? _selectedPuzzle;
  CheckersEngine? _engine;

  int _solutionIndex = 0;
  int _mistakes = 0;
  int _score = 0;

  bool _completed = false;
  bool _loading = true;

  int? _selectedRow;
  int? _selectedCol;

  Set<String> _highlightedSquares = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFirstPuzzle();
  }

  // ============================================================
  // LOAD PUZZLE
  // ============================================================

  Future<void> _loadFirstPuzzle() async {
    final puzzles = _puzzleService.puzzles;

    if (puzzles.isEmpty) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      return;
    }

    await _loadPuzzle(puzzles.first);
  }

  Future<void> _loadPuzzle(CheckersPuzzle puzzle) async {
    final engine = CheckersEngine();

    engine.fromJson({
      'board': puzzle.board,
      'turn': puzzle.turn,
      'redCaptured': 0,
      'blackCaptured': 0,
      'moveCount': 0,
      'noProgressMoveCount': 0,
      'moveHistory': [],
      'forcedCaptureRow': null,
      'forcedCaptureCol': null,
    });

    if (!mounted) return;

    setState(() {
      _selectedPuzzle = puzzle;
      _engine = engine;

      _solutionIndex = 0;
      _mistakes = 0;
      _score = puzzle.points;

      _completed = false;
      _loading = false;

      _selectedRow = null;
      _selectedCol = null;
      _highlightedSquares = <String>{};
    });
  }

  // ============================================================
  // CHOOSE PUZZLE
  // ============================================================

  Future<void> _choosePuzzle() async {
    final puzzle = await showModalBottomSheet<CheckersPuzzle>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Challenges & Puzzles',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ..._puzzleService.puzzles.map(
                (puzzle) {
                  return ListTile(
                    leading: Icon(
                      _difficultyIcon(
                        puzzle.difficulty,
                      ),
                    ),
                    title: Text(
                      puzzle.title,
                    ),
                    subtitle: Text(
                      '${_difficultyName(puzzle.difficulty)} • '
                      '${puzzle.category.name}',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        puzzle,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (puzzle != null) {
      await _loadPuzzle(puzzle);
    }
  }

  // ============================================================
  // BOARD TAP
  // ============================================================

  void _handleSquareTap(
    int row,
    int col,
  ) {
    if (_completed) {
      return;
    }

    final engine = _engine;

    if (engine == null) {
      return;
    }

    final piece = engine.pieceAt(
      row,
      col,
    );

    // ----------------------------------------------------------
    // SELECT PIECE
    // ----------------------------------------------------------

    if (_selectedRow == null) {
      if (piece != null &&
          piece.color == engine.turn) {
        _selectPiece(
          row,
          col,
        );
      }

      return;
    }

    // ----------------------------------------------------------
    // SELECT ANOTHER OWN PIECE
    // ----------------------------------------------------------

    if (piece != null &&
        piece.color == engine.turn) {
      _selectPiece(
        row,
        col,
      );

      return;
    }

    // ----------------------------------------------------------
    // TRY MOVE
    // ----------------------------------------------------------

    _tryPuzzleMove(
      _selectedRow!,
      _selectedCol!,
      row,
      col,
    );
  }

  // ============================================================
  // SELECT PIECE
  // ============================================================

  void _selectPiece(
    int row,
    int col,
  ) {
    final engine = _engine;

    if (engine == null) {
      return;
    }

    final moves = engine.legalMovesForPiece(
      row,
      col,
    );

    setState(() {
      _selectedRow = row;
      _selectedCol = col;

      _highlightedSquares = moves
          .map(
            (move) => '${move.toRow},${move.toCol}',
          )
          .toSet();
    });
  }

  // ============================================================
  // TRY PUZZLE MOVE
  // ============================================================

  Future<void> _tryPuzzleMove(
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) async {
    final puzzle = _selectedPuzzle;
    final engine = _engine;

    if (puzzle == null ||
        engine == null) {
      return;
    }

    if (_solutionIndex >= puzzle.solution.length) {
      return;
    }

    final expected =
        puzzle.solution[_solutionIndex];

    final correct =
        expected[0] == fromRow &&
        expected[1] == fromCol &&
        expected[2] == toRow &&
        expected[3] == toCol;

    if (!correct) {
      _registerMistake();
      return;
    }

    final move = engine.findMove(
      fromRow,
      fromCol,
      toRow,
      toCol,
    );

    if (move == null) {
      _registerMistake();
      return;
    }

    final success = engine.makeMove(
      move,
    );

    if (!success) {
      _registerMistake();
      return;
    }

    _solutionIndex++;

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedRow = null;
      _selectedCol = null;
      _highlightedSquares = <String>{};
    });

    // ----------------------------------------------------------
    // PUZZLE COMPLETE
    // ----------------------------------------------------------

    if (_solutionIndex >=
        puzzle.solution.length) {
      await _completePuzzle();
      return;
    }

    // ----------------------------------------------------------
    // FORCED MULTIPLE CAPTURE
    // ----------------------------------------------------------

    if (engine.forcedCaptureRow != null &&
        engine.forcedCaptureCol != null) {
      _selectPiece(
        engine.forcedCaptureRow!,
        engine.forcedCaptureCol!,
      );
    }
  }

  // ============================================================
  // MISTAKE
  // ============================================================

  void _registerMistake() {
    if (!mounted) {
      return;
    }

    setState(() {
      _mistakes++;

      _score -= 25;

      if (_score < 0) {
        _score = 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'That is not the correct move. Try again.',
        ),
        duration: Duration(
          milliseconds: 900,
        ),
      ),
    );
  }

  // ============================================================
  // COMPLETE PUZZLE
  // ============================================================

  Future<void> _completePuzzle() async {
    final puzzle = _selectedPuzzle;

    if (puzzle == null) {
      return;
    }

    await _puzzleService.completePuzzle(
      puzzleId: puzzle.id,
      score: _score,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _completed = true;
    });

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Puzzle Solved! 🎉',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                puzzle.explanation,
              ),

              const SizedBox(height: 16),

              Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Mistakes: $_mistakes',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Continue',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // NEXT PUZZLE
  // ============================================================

  Future<void> _nextPuzzle() async {
    final current = _selectedPuzzle;

    if (current == null) {
      return;
    }

    final puzzles = _puzzleService.puzzles;

    if (puzzles.isEmpty) {
      return;
    }

    final index = puzzles.indexWhere(
      (puzzle) => puzzle.id == current.id,
    );

    final nextIndex =
        index < 0
            ? 0
            : (index + 1) % puzzles.length;

    await _loadPuzzle(
      puzzles[nextIndex],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final puzzle = _selectedPuzzle;
    final engine = _engine;

    if (puzzle == null ||
        engine == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No puzzles available.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Challenges & Puzzles',
        ),
        actions: [
          IconButton(
            tooltip: 'Choose puzzle',
            onPressed: _choosePuzzle,
            icon: const Icon(
              Icons.extension,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPuzzleHeader(
              puzzle,
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildBoard(
                    engine,
                  ),
                ),
              ),
            ),

            _buildBottomPanel(
              puzzle,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PUZZLE HEADER
  // ============================================================

  Widget _buildPuzzleHeader(
    CheckersPuzzle puzzle,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        4,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  puzzle.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Chip(
                label: Text(
                  _difficultyName(
                    puzzle.difficulty,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            puzzle.description,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOARD
  // ============================================================

  Widget _buildBoard(
    CheckersEngine engine,
  ) {
    return GridView.builder(
      physics:
          const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (
        context,
        index,
      ) {
        final row = index ~/ 8;
        final col = index % 8;

        return _buildSquare(
          engine,
          row,
          col,
        );
      },
    );
  }

  // ============================================================
  // SQUARE
  // ============================================================

  Widget _buildSquare(
    CheckersEngine engine,
    int row,
    int col,
  ) {
    final dark =
        engine.isDarkSquare(
      row,
      col,
    );

    final selected =
        _selectedRow == row &&
        _selectedCol == col;

    final highlighted =
        _highlightedSquares.contains(
      '$row,$col',
    );

    final piece =
        engine.pieceAt(
      row,
      col,
    );

    return GestureDetector(
      onTap: () {
        _handleSquareTap(
          row,
          col,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? Colors.amber
              : highlighted
                  ? Colors.green
                  : dark
                      ? Colors.brown.shade700
                      : Colors.brown.shade200,
          border: Border.all(
            color: Colors.black12,
          ),
        ),
        child: piece == null
            ? highlighted
                ? const Center(
                    child: CircleAvatar(
                      radius: 7,
                    ),
                  )
                : null
            : Center(
                child: _buildPiece(
                  piece,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // PIECE
  // ============================================================

  Widget _buildPiece(
    GamePiece piece,
  ) {
    final isRed =
        piece.color == PieceColor.red;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isRed ? Colors.red : Colors.black,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: piece.isKing
          ? const Center(
              child: Text(
                '♛',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            )
          : null,
    );
  }

  // ============================================================
  // BOTTOM PANEL
  // ============================================================

  Widget _buildBottomPanel(
    CheckersPuzzle puzzle,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _stat(
                'Score',
                '$_score',
              ),
              _stat(
                'Mistakes',
                '$_mistakes',
              ),
              _stat(
                'Step',
                '${_solutionIndex + 1}/${puzzle.solution.length}',
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_completed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _nextPuzzle,
                icon: const Icon(
                  Icons.arrow_forward,
                ),
                label: const Text(
                  'Next Puzzle',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT
  // ============================================================

  Widget _stat(
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }

  // ============================================================
  // DIFFICULTY
  // ============================================================

  String _difficultyName(
    PuzzleDifficulty difficulty,
  ) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 'Easy';

      case PuzzleDifficulty.medium:
        return 'Medium';

      case PuzzleDifficulty.hard:
        return 'Hard';

      case PuzzleDifficulty.expert:
        return 'Expert';
    }
  }

  IconData _difficultyIcon(
    PuzzleDifficulty difficulty,
  ) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return Icons.star_border;

      case PuzzleDifficulty.medium:
        return Icons.star_half;

      case PuzzleDifficulty.hard:
        return Icons.star;

      case PuzzleDifficulty.expert:
        return Icons.workspace_premium;
    }
  }
}

