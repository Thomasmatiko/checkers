
import '../models/game_piece.dart';
import '../models/checkers_move_history.dart';
import '../models/checkers_rules.dart';

/// Represents one possible move.
class CheckersMove {
  final int fromRow;
  final int fromCol;

  final int toRow;
  final int toCol;

  final int? capturedRow;
  final int? capturedCol;

  const CheckersMove({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    this.capturedRow,
    this.capturedCol,
  });

  bool get isCapture =>
      capturedRow != null && capturedCol != null;

  @override
  String toString() {
    return 'Move('
        '$fromRow,$fromCol -> '
        '$toRow,$toCol'
        '${isCapture ? ' CAPTURE' : ''}'
        ')';
  }
}

/// Main Checkers / Draughts rules engine.
///
/// The engine is variant-aware and reads movement and capture
/// behavior from [RulesConfig].
class CheckersEngine {
  static const int defaultBoardSize = 8;

  /// Compatibility getter for existing UI code.
  static const int boardSize = defaultBoardSize;

  static const int drawMoveLimit = 40;

  late List<List<GamePiece?>> board;

  /// Active rules.
  RulesConfig rulesConfig;

  PieceColor turn = PieceColor.red;

  int redCaptured = 0;
  int blackCaptured = 0;

  int moveCount = 0;

  int noProgressMoveCount = 0;

  final List<CheckersMoveHistory> moveHistory =
      <CheckersMoveHistory>[];

  final List<Map<String, dynamic>> _undoStack =
      <Map<String, dynamic>>[];

  final List<Map<String, dynamic>> _redoStack =
      <Map<String, dynamic>>[];

  /// During a multiple capture this identifies the piece that
  /// must continue capturing.
  int? forcedCaptureRow;
  int? forcedCaptureCol;

  CheckersEngine({
    RulesConfig? rules,
  }) : rulesConfig =
            rules ??
            RulesConfig.forRules(
              CheckersRules.tanzania,
            ) {
    reset();
  }

  // ============================================================
  // ACTIVE BOARD SIZE
  // ============================================================

  int get size => rulesConfig.boardSize;

  // ============================================================
  // RULES
  // ============================================================

  void setRules(
    RulesConfig config, {
    bool resetGame = true,
  }) {
    rulesConfig = config;

    if (resetGame) {
      reset();
    }
  }

  void setRuleSet(
    CheckersRules rules, {
    bool resetGame = true,
  }) {
    setRules(
      RulesConfig.forRules(rules),
      resetGame: resetGame,
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    board = List.generate(
      size,
      (_) => List<GamePiece?>.filled(
        size,
        null,
      ),
    );

    _setupInitialPosition();

    turn = PieceColor.red;

    redCaptured = 0;
    blackCaptured = 0;

    moveCount = 0;
    noProgressMoveCount = 0;

    moveHistory.clear();

    forcedCaptureRow = null;
    forcedCaptureCol = null;

    _undoStack.clear();
    _redoStack.clear();
  }

  // ============================================================
  // INITIAL POSITION
  // ============================================================

  void _setupInitialPosition() {
    if (rulesConfig.turkishInitialPlacement) {
      _setupTurkishPosition();
      return;
    }

    final rowsPerSide =
        rulesConfig.startingPieces <= 12 ? 3 : 4;

    int blackPlaced = 0;

    for (int row = 0; row < rowsPerSide; row++) {
      for (int col = 0; col < size; col++) {
        if (!_isPlayableSquare(row, col)) {
          continue;
        }

        if (blackPlaced >= rulesConfig.startingPieces) {
          break;
        }

        board[row][col] = const GamePiece(
          color: PieceColor.black,
        );

        blackPlaced++;
      }
    }

    int redPlaced = 0;

    for (
      int row = size - rowsPerSide;
      row < size;
      row++
    ) {
      for (int col = 0; col < size; col++) {
        if (!_isPlayableSquare(row, col)) {
          continue;
        }

        if (redPlaced >= rulesConfig.startingPieces) {
          break;
        }

        board[row][col] = const GamePiece(
          color: PieceColor.red,
        );

        redPlaced++;
      }
    }
  }

  void _setupTurkishPosition() {
    int blackPlaced = 0;

    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < size; col++) {
        if (blackPlaced >= rulesConfig.startingPieces) {
          break;
        }

        board[row][col] = const GamePiece(
          color: PieceColor.black,
        );

        blackPlaced++;
      }
    }

    int redPlaced = 0;

    for (int row = size - 2; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (redPlaced >= rulesConfig.startingPieces) {
          break;
        }

        board[row][col] = const GamePiece(
          color: PieceColor.red,
        );

        redPlaced++;
      }
    }
  }

  // ============================================================
  // BOARD UTILITIES
  // ============================================================

  bool isInsideBoard(
    int row,
    int col,
  ) {
    return row >= 0 &&
        row < size &&
        col >= 0 &&
        col < size;
  }

  bool isDarkSquare(
    int row,
    int col,
  ) {
    return (row + col).isOdd;
  }

  bool _isPlayableSquare(
    int row,
    int col,
  ) {
    if (rulesConfig.rules == CheckersRules.turkish) {
      return true;
    }

    return isDarkSquare(row, col);
  }

  GamePiece? pieceAt(
    int row,
    int col,
  ) {
    if (!isInsideBoard(row, col)) {
      return null;
    }

    return board[row][col];
  }

  // ============================================================
  // MOVEMENT DIRECTIONS
  // ============================================================

  List<List<int>> movementDirections(
    GamePiece piece,
  ) {
    if (piece.isKing) {
      return const [
        [-1, -1],
        [-1, 1],
        [1, -1],
        [1, 1],
      ];
    }

    final forward =
        piece.color == PieceColor.red ? -1 : 1;

    return [
      [forward, -1],
      [forward, 1],
    ];
  }

  // ============================================================
  // CAPTURE DIRECTIONS
  // ============================================================

  /// Returns legal capture directions.
  ///
  /// IMPORTANT:
  ///
  /// East Africa:
  ///   menCanCaptureBackward == false
  ///
  /// International:
  ///   menCanCaptureBackward == true
  ///
  /// American:
  ///   menCanCaptureBackward == false
  ///
  /// Kings can capture in all four diagonal directions.
  List<List<int>> captureDirections(
    GamePiece piece,
  ) {
    // Kings capture in all four directions.
    if (piece.isKing) {
      return const [
        [-1, -1],
        [-1, 1],
        [1, -1],
        [1, 1],
      ];
    }

    // International/Russian/Brazilian/Turkish etc.
    // when backward captures are enabled.
    if (rulesConfig.menCanCaptureBackward) {
      return const [
        [-1, -1],
        [-1, 1],
        [1, -1],
        [1, 1],
      ];
    }

    // Forward-only capture.
    //
    // Red moves toward row 0.
    // Black moves toward size - 1.
    final forward =
        piece.color == PieceColor.red ? -1 : 1;

    return [
      [forward, -1],
      [forward, 1],
    ];
  }

  // ============================================================
  // LEGAL MOVES
  // ============================================================

  List<CheckersMove> legalMovesForPiece(
    int row,
    int col,
  ) {
    if (!isInsideBoard(row, col)) {
      return <CheckersMove>[];
    }

    final piece = board[row][col];

    if (piece == null) {
      return <CheckersMove>[];
    }

    if (piece.color != turn) {
      return <CheckersMove>[];
    }

    // ----------------------------------------------------------
    // FORCED MULTIPLE CAPTURE
    // ----------------------------------------------------------

    if (forcedCaptureRow != null &&
        forcedCaptureCol != null) {
      if (row != forcedCaptureRow ||
          col != forcedCaptureCol) {
        return <CheckersMove>[];
      }

      return _captureMovesForPiece(
        row,
        col,
      );
    }

    // ----------------------------------------------------------
    // MANDATORY CAPTURE
    // ----------------------------------------------------------

    if (rulesConfig.mandatoryCapture &&
        playerHasCapture(turn)) {
      return _captureMovesForPiece(
        row,
        col,
      );
    }

    // ----------------------------------------------------------
    // CHECK THIS PIECE
    // ----------------------------------------------------------

    final captures = _captureMovesForPiece(
      row,
      col,
    );

    if (captures.isNotEmpty &&
        rulesConfig.mandatoryCapture) {
      return captures;
    }

    // ----------------------------------------------------------
    // NORMAL MOVEMENT
    // ----------------------------------------------------------

    return _normalMovesForPiece(
      row,
      col,
    );
  }

  // ============================================================
  // NORMAL MOVES
  // ============================================================

  List<CheckersMove> _normalMovesForPiece(
    int row,
    int col,
  ) {
    final piece = board[row][col];

    if (piece == null) {
      return <CheckersMove>[];
    }

    final moves = <CheckersMove>[];

    // ----------------------------------------------------------
    // FLYING KING
    // ----------------------------------------------------------

    if (piece.isKing &&
        rulesConfig.flyingKings) {
      for (final direction
          in movementDirections(piece)) {
        var nextRow =
            row + direction[0];

        var nextCol =
            col + direction[1];

        while (isInsideBoard(
          nextRow,
          nextCol,
        )) {
          if (board[nextRow][nextCol] != null) {
            break;
          }

          moves.add(
            CheckersMove(
              fromRow: row,
              fromCol: col,
              toRow: nextRow,
              toCol: nextCol,
            ),
          );

          nextRow += direction[0];
          nextCol += direction[1];
        }
      }

      return moves;
    }

    // ----------------------------------------------------------
    // SHORT MOVEMENT
    // ----------------------------------------------------------

    for (final direction
        in movementDirections(piece)) {
      final nextRow =
          row + direction[0];

      final nextCol =
          col + direction[1];

      if (!isInsideBoard(
        nextRow,
        nextCol,
      )) {
        continue;
      }

      if (board[nextRow][nextCol] != null) {
        continue;
      }

      moves.add(
        CheckersMove(
          fromRow: row,
          fromCol: col,
          toRow: nextRow,
          toCol: nextCol,
        ),
      );
    }

    return moves;
  }

  // ============================================================
  // CAPTURE MOVES
  // ============================================================

  List<CheckersMove> _captureMovesForPiece(
    int row,
    int col,
  ) {
    final piece = board[row][col];

    if (piece == null) {
      return <CheckersMove>[];
    }

    if (piece.isKing &&
        rulesConfig.flyingKingCaptures) {
      return _flyingKingCaptures(
        row,
        col,
      );
    }

    return _shortKingOrManCaptures(
      row,
      col,
    );
  }

  // ============================================================
  // SHORT CAPTURES
  // ============================================================

  List<CheckersMove> _shortKingOrManCaptures(
    int row,
    int col,
  ) {
    final piece = board[row][col];

    if (piece == null) {
      return <CheckersMove>[];
    }

    final moves = <CheckersMove>[];

    for (final direction
        in captureDirections(piece)) {
      final middleRow =
          row + direction[0];

      final middleCol =
          col + direction[1];

      final landingRow =
          row + direction[0] * 2;

      final landingCol =
          col + direction[1] * 2;

      if (!isInsideBoard(
        middleRow,
        middleCol,
      )) {
        continue;
      }

      if (!isInsideBoard(
        landingRow,
        landingCol,
      )) {
        continue;
      }

      final middle =
          board[middleRow][middleCol];

      final landing =
          board[landingRow][landingCol];

      if (middle != null &&
          middle.color != piece.color &&
          landing == null) {
        moves.add(
          CheckersMove(
            fromRow: row,
            fromCol: col,
            toRow: landingRow,
            toCol: landingCol,
            capturedRow: middleRow,
            capturedCol: middleCol,
          ),
        );
      }
    }

    return moves;
  }

  // ============================================================
  // FLYING KING CAPTURES
  // ============================================================

  List<CheckersMove> _flyingKingCaptures(
    int row,
    int col,
  ) {
    final piece = board[row][col];

    if (piece == null) {
      return <CheckersMove>[];
    }

    final moves = <CheckersMove>[];

    for (final direction
        in captureDirections(piece)) {
      var nextRow =
          row + direction[0];

      var nextCol =
          col + direction[1];

      bool foundEnemy = false;

      int? enemyRow;
      int? enemyCol;

      while (isInsideBoard(
        nextRow,
        nextCol,
      )) {
        final current =
            board[nextRow][nextCol];

        // Empty square.
        if (current == null) {
          if (foundEnemy) {
            moves.add(
              CheckersMove(
                fromRow: row,
                fromCol: col,
                toRow: nextRow,
                toCol: nextCol,
                capturedRow: enemyRow,
                capturedCol: enemyCol,
              ),
            );
          }

          nextRow += direction[0];
          nextCol += direction[1];

          continue;
        }

        // Own piece blocks the direction.
        if (current.color == piece.color) {
          break;
        }

        // First enemy encountered.
        if (!foundEnemy) {
          foundEnemy = true;

          enemyRow = nextRow;
          enemyCol = nextCol;

          nextRow += direction[0];
          nextCol += direction[1];

          continue;
        }

        // A second enemy blocks the capture.
        break;
      }
    }

    return moves;
  }

  // ============================================================
  // PUBLIC CAPTURE API
  // ============================================================

  List<CheckersMove> captureMovesForPiecePublic(
    int row,
    int col,
  ) {
    if (!isInsideBoard(row, col)) {
      return <CheckersMove>[];
    }

    return _captureMovesForPiece(
      row,
      col,
    );
  }

  // ============================================================
  // PLAYER CAPTURE CHECK
  // ============================================================

  bool playerHasCapture(
    PieceColor color,
  ) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final piece = board[row][col];

        if (piece == null ||
            piece.color != color) {
          continue;
        }

        if (_captureMovesForPiece(
          row,
          col,
        ).isNotEmpty) {
          return true;
        }
      }
    }

    return false;
  }

  // ============================================================
  // ALL LEGAL MOVES
  // ============================================================

  List<CheckersMove> allLegalMoves() {
    if (forcedCaptureRow != null &&
        forcedCaptureCol != null) {
      return legalMovesForPiece(
        forcedCaptureRow!,
        forcedCaptureCol!,
      );
    }

    final moves = <CheckersMove>[];

    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final piece = board[row][col];

        if (piece == null ||
            piece.color != turn) {
          continue;
        }

        moves.addAll(
          legalMovesForPiece(
            row,
            col,
          ),
        );
      }
    }

    return _applyMaximumCaptureRule(
      moves,
    );
  }

  // ============================================================
  // MAXIMUM CAPTURE RULE
  // ============================================================

  List<CheckersMove> _applyMaximumCaptureRule(
    List<CheckersMove> moves,
  ) {
    if (!rulesConfig.maximumCaptureRequired) {
      return moves;
    }

    final captures = moves
        .where(
          (move) => move.isCapture,
        )
        .toList();

    if (captures.isEmpty) {
      return moves;
    }

    int best = 0;

    final valid = <CheckersMove>[];

    for (final move in captures) {
      final count =
          _captureSequenceLength(move);

      if (count > best) {
        best = count;

        valid.clear();

        valid.add(move);
      } else if (count == best) {
        valid.add(move);
      }
    }

    return valid;
  }

  int _captureSequenceLength(
    CheckersMove firstMove,
  ) {
    final simulation =
        _copyForSimulation();

    if (!simulation.makeMove(firstMove)) {
      return 0;
    }

    return 1 +
        simulation
            ._bestContinuationCaptureLength();
  }

  int _bestContinuationCaptureLength() {
    if (forcedCaptureRow == null ||
        forcedCaptureCol == null) {
      return 0;
    }

    final captures =
        _captureMovesForPiece(
      forcedCaptureRow!,
      forcedCaptureCol!,
    );

    if (captures.isEmpty) {
      return 0;
    }

    int best = 0;

    for (final move in captures) {
      final simulation =
          _copyForSimulation();

      if (!simulation.makeMove(move)) {
        continue;
      }

      final length =
          1 +
          simulation
              ._bestContinuationCaptureLength();

      if (length > best) {
        best = length;
      }
    }

    return best;
  }

  // ============================================================
  // FIND MOVE
  // ============================================================

  CheckersMove? findMove(
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) {
    final moves =
        legalMovesForPiece(
      fromRow,
      fromCol,
    );

    for (final move in moves) {
      if (move.toRow == toRow &&
          move.toCol == toCol) {
        return move;
      }
    }

    return null;
  }

  // ============================================================
  // MAKE MOVE
  // ============================================================

  bool makeMove(
    CheckersMove move,
  ) {
    if (!isInsideBoard(
          move.fromRow,
          move.fromCol,
        ) ||
        !isInsideBoard(
          move.toRow,
          move.toCol,
        )) {
      return false;
    }

    final piece =
        board[move.fromRow][move.fromCol];

    if (piece == null ||
        piece.color != turn) {
      return false;
    }

    final legalMove =
        findMove(
      move.fromRow,
      move.fromCol,
      move.toRow,
      move.toCol,
    );

    if (legalMove == null) {
      return false;
    }

    _undoStack.add(
      _createStateSnapshot(),
    );

    _redoStack.clear();

    final movingPlayer =
        piece.color;

    final wasKingBeforeMove =
        piece.isKing;

    board[move.fromRow][move.fromCol] =
        null;

    board[move.toRow][move.toCol] =
        piece;

    bool wasCapture = false;

    PieceColor? capturedPieceColor;

    // ----------------------------------------------------------
    // CAPTURE
    // ----------------------------------------------------------

    if (legalMove.isCapture) {
      final capturedRow =
          legalMove.capturedRow!;

      final capturedCol =
          legalMove.capturedCol!;

      final capturedPiece =
          board[capturedRow][capturedCol];

      capturedPieceColor =
          capturedPiece?.color;

      board[capturedRow][capturedCol] =
          null;

      if (capturedPiece?.color ==
          PieceColor.red) {
        redCaptured++;
      }

      if (capturedPiece?.color ==
          PieceColor.black) {
        blackCaptured++;
      }

      wasCapture = true;
    }

    // ----------------------------------------------------------
    // PROMOTION
    // ----------------------------------------------------------

    GamePiece movedPiece =
        board[move.toRow][move.toCol]!;

    bool wasPromotion = false;

    if (rulesConfig.promoteOnLastRow &&
        !movedPiece.isKing) {
      final reachedPromotionRow =
          movedPiece.color ==
                  PieceColor.red
              ? move.toRow == 0
              : move.toRow == size - 1;

      if (reachedPromotionRow) {
        movedPiece =
            movedPiece.promote();

        board[move.toRow][move.toCol] =
            movedPiece;

        wasPromotion = true;
      }
    }

    moveCount++;

    moveHistory.add(
      CheckersMoveHistory(
        moveNumber: moveCount,
        player: movingPlayer,
        fromRow: move.fromRow,
        fromCol: move.fromCol,
        toRow: move.toRow,
        toCol: move.toCol,
        wasCapture: wasCapture,
        capturedRow: legalMove.capturedRow,
        capturedCol: legalMove.capturedCol,
        capturedPieceColor:
            capturedPieceColor,
        wasPromotion: wasPromotion,
        wasKingBeforeMove:
            wasKingBeforeMove,
      ),
    );

    // ----------------------------------------------------------
    // DRAW COUNTER
    // ----------------------------------------------------------

    if (wasCapture || wasPromotion) {
      noProgressMoveCount = 0;
    } else {
      noProgressMoveCount++;
    }

    // ----------------------------------------------------------
    // MULTIPLE CAPTURE
    // ----------------------------------------------------------

    if (legalMove.isCapture) {
      // Some rules stop immediately after promotion.
      if (wasPromotion &&
          rulesConfig.stopAfterPromotion &&
          !rulesConfig.continueAfterPromotion) {
        forcedCaptureRow = null;
        forcedCaptureCol = null;
      } else {
        final additionalCaptures =
            _captureMovesForPiece(
          move.toRow,
          move.toCol,
        );

        if (additionalCaptures.isNotEmpty) {
          forcedCaptureRow =
              move.toRow;

          forcedCaptureCol =
              move.toCol;

          return true;
        }
      }
    }

    // ----------------------------------------------------------
    // END TURN
    // ----------------------------------------------------------

    forcedCaptureRow = null;
    forcedCaptureCol = null;

    turn = turn == PieceColor.red
        ? PieceColor.black
        : PieceColor.red;

    return true;
  }

  // ============================================================
  // MOVE BY COORDINATES
  // ============================================================

  bool move(
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) {
    final selectedMove =
        findMove(
      fromRow,
      fromCol,
      toRow,
      toCol,
    );

    if (selectedMove == null) {
      return false;
    }

    return makeMove(
      selectedMove,
    );
  }

  // ============================================================
  // UNDO / REDO
  // ============================================================

  bool get canUndo =>
      _undoStack.isNotEmpty;

  bool get canRedo =>
      _redoStack.isNotEmpty;

  bool undo() {
    if (_undoStack.isEmpty) {
      return false;
    }

    _redoStack.add(
      _createStateSnapshot(),
    );

    final state =
        _undoStack.removeLast();

    _restoreStateSnapshot(
      state,
    );

    return true;
  }

  bool redo() {
    if (_redoStack.isEmpty) {
      return false;
    }

    _undoStack.add(
      _createStateSnapshot(),
    );

    final state =
        _redoStack.removeLast();

    _restoreStateSnapshot(
      state,
    );

    return true;
  }

  // ============================================================
  // PIECE COUNTS
  // ============================================================

  int countPieces(
    PieceColor color,
  ) {
    int count = 0;

    for (final row in board) {
      for (final piece in row) {
        if (piece?.color == color) {
          count++;
        }
      }
    }

    return count;
  }

  int get redPieces =>
      countPieces(PieceColor.red);

  int get blackPieces =>
      countPieces(PieceColor.black);

  int countKings(
    PieceColor color,
  ) {
    int count = 0;

    for (final row in board) {
      for (final piece in row) {
        if (piece != null &&
            piece.color == color &&
            piece.isKing) {
          count++;
        }
      }
    }

    return count;
  }

  int get redKings =>
      countKings(PieceColor.red);

  int get blackKings =>
      countKings(PieceColor.black);

  // ============================================================
  // WINNER
  // ============================================================

  PieceColor? winner() {
    final redCount =
        countPieces(PieceColor.red);

    final blackCount =
        countPieces(PieceColor.black);

    if (redCount == 0) {
      return PieceColor.black;
    }

    if (blackCount == 0) {
      return PieceColor.red;
    }

    if (allLegalMoves().isEmpty) {
      return turn == PieceColor.red
          ? PieceColor.black
          : PieceColor.red;
    }

    return null;
  }

  bool get isGameOver =>
      winner() != null || isDraw;

  // ============================================================
  // DRAW
  // ============================================================

  bool get isDraw {
    if (winner() != null) {
      return false;
    }

    return noProgressMoveCount >=
        drawMoveLimit;
  }

  // ============================================================
  // HISTORY
  // ============================================================

  List<CheckersMoveHistory> get history =>
      List.unmodifiable(moveHistory);

  CheckersMoveHistory? get lastMove {
    if (moveHistory.isEmpty) {
      return null;
    }

    return moveHistory.last;
  }

  int get historyLength =>
      moveHistory.length;

  // ============================================================
  // SERIALIZATION
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'rules': rulesConfig.toJson(),

      'board': board
          .map(
            (row) => row
                .map(
                  (piece) =>
                      piece?.toJson(),
                )
                .toList(),
          )
          .toList(),

      'turn': turn.name,

      'redCaptured': redCaptured,

      'blackCaptured': blackCaptured,

      'moveCount': moveCount,

      'noProgressMoveCount':
          noProgressMoveCount,

      'moveHistory': moveHistory
          .map(
            (move) => move.toJson(),
          )
          .toList(),

      'forcedCaptureRow':
          forcedCaptureRow,

      'forcedCaptureCol':
          forcedCaptureCol,
    };
  }

  // ============================================================
  // LOAD
  // ============================================================

  void fromJson(
    Map<String, dynamic> json, {
    bool preserveUndoRedo = false,
  }) {
    final savedRules =
        json['rules'];

    if (savedRules is Map) {
      rulesConfig =
          RulesConfig.fromJson(
        Map<String, dynamic>.from(
          savedRules,
        ),
      );
    } else if (json['ruleSet'] is String) {
      final value =
          json['ruleSet'];

      for (final rule
          in CheckersRules.values) {
        if (rule.name == value) {
          rulesConfig =
              RulesConfig.forRules(
            rule,
          );
          break;
        }
      }
    }

    final rawBoard =
        json['board'];

    if (rawBoard is! List ||
        rawBoard.length != size) {
      reset();
      return;
    }

    board = List.generate(
      size,
      (row) {
        final rawRow =
            rawBoard[row];

        if (rawRow is! List ||
            rawRow.length != size) {
          return List<GamePiece?>.filled(
            size,
            null,
          );
        }

        return List.generate(
          size,
          (col) {
            final value =
                rawRow[col];

            if (value == null) {
              return null;
            }

            if (value is! Map) {
              return null;
            }

            return GamePiece.fromJson(
              Map<String, dynamic>.from(
                value,
              ),
            );
          },
        );
      },
    );

    final savedTurn =
        json['turn'];

    if (savedTurn is String) {
      turn =
          PieceColor.values.firstWhere(
        (color) =>
            color.name == savedTurn,
        orElse: () =>
            PieceColor.red,
      );
    }

    redCaptured =
        _safeInt(
      json['redCaptured'],
    );

    blackCaptured =
        _safeInt(
      json['blackCaptured'],
    );

    moveCount =
        _safeInt(
      json['moveCount'],
    );

    noProgressMoveCount =
        _safeInt(
      json['noProgressMoveCount'],
    );

    moveHistory.clear();

    final rawHistory =
        json['moveHistory'];

    if (rawHistory is List) {
      for (final item in rawHistory) {
        if (item is Map) {
          try {
            moveHistory.add(
              CheckersMoveHistory.fromJson(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            );
          } catch (_) {
            // Ignore invalid history entries.
          }
        }
      }
    }

    forcedCaptureRow =
        _nullableInt(
      json['forcedCaptureRow'],
    );

    forcedCaptureCol =
        _nullableInt(
      json['forcedCaptureCol'],
    );

    if (!preserveUndoRedo) {
      _undoStack.clear();
      _redoStack.clear();
    }
  }

  // ============================================================
  // SNAPSHOTS
  // ============================================================

  Map<String, dynamic>
      _createStateSnapshot() {
    return _deepCopyMap(
      toJson(),
    );
  }

  void _restoreStateSnapshot(
    Map<String, dynamic> snapshot,
  ) {
    fromJson(
      snapshot,
      preserveUndoRedo: true,
    );
  }

  CheckersEngine
      _copyForSimulation() {
    final copy =
        CheckersEngine(
      rules: rulesConfig,
    );

    copy.fromJson(
      _deepCopyMap(
        toJson(),
      ),
      preserveUndoRedo: true,
    );

    return copy;
  }

  Map<String, dynamic> _deepCopyMap(
    Map<String, dynamic> source,
  ) {
    final result =
        <String, dynamic>{};

    for (final entry
        in source.entries) {
      result[entry.key] =
          _deepCopyValue(
        entry.value,
      );
    }

    return result;
  }

  dynamic _deepCopyValue(
    dynamic value,
  ) {
    if (value is Map) {
      final result =
          <String, dynamic>{};

      for (final entry
          in value.entries) {
        result[
                entry.key.toString()] =
            _deepCopyValue(
          entry.value,
        );
      }

      return result;
    }

    if (value is List) {
      return value
          .map(_deepCopyValue)
          .toList();
    }

    return value;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int _safeInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  int? _nullableInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }

  // ============================================================
  // DEBUG
  // ============================================================

  String boardDebugString() {
    final buffer =
        StringBuffer();

    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final piece =
            board[row][col];

        if (piece == null) {
          buffer.write('.');
        } else {
          buffer.write(piece.symbol);
        }

        if (col < size - 1) {
          buffer.write(' ');
        }
      }

      buffer.writeln();
    }

    return buffer.toString();
  }
}
