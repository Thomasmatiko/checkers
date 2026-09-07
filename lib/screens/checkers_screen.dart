import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/checkers_ai.dart';
import '../controllers/checkers_engine.dart';
import '../models/game_history.dart';
import '../models/game_piece.dart';
import '../models/rule_variant.dart';
import '../screens/puzzle_screen.dart';
import '../screens/rules_screen.dart';
import '../screens/statistics_screen.dart';
import '../services/audio_service.dart';
import '../services/game_history_service.dart';
import '../services/game_settings.dart';
import '../services/game_statistics.dart';
import '../services/game_storage.dart';
import '../services/rule_manager.dart';

class CheckersScreen extends StatefulWidget {
  final GameSettings settings;
  final GameStatistics statistics;
  final GameStorage storage;
  final GameHistoryService historyService;

  const CheckersScreen({
    super.key,
    required this.settings,
    required this.statistics,
    required this.storage,
    required this.historyService,
  });

  @override
  State<CheckersScreen> createState() => _CheckersScreenState();
}

class _CheckersScreenState extends State<CheckersScreen> {
  late CheckersEngine engine;
  late CheckersAI ai;

  final AudioService audioService = AudioService();
  final RuleManager ruleManager = RuleManager();

  int? selectedRow;
  int? selectedCol;

  List<CheckersMove> availableMoves = [];

  bool aiThinking = false;
  bool gameFinished = false;

  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();

    engine = CheckersEngine();

    ai = CheckersAI(
      difficulty: widget.settings.aiDifficulty,
      aiColor: PieceColor.black,
    );

    audioService.setSoundEnabled(
      widget.settings.soundEnabled,
    );

    audioService.setMusicEnabled(
      widget.settings.musicEnabled,
    );

    _startAutoSave();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _playGameStart();
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // AUDIO
  // ============================================================

  Future<void> _playGameStart() async {
    if (!mounted) {
      return;
    }

    audioService.setSoundEnabled(
      widget.settings.soundEnabled,
    );

    await audioService.playGameStart();
  }

  Future<void> _playButton() async {
    audioService.setSoundEnabled(
      widget.settings.soundEnabled,
    );

    await audioService.playButton();
  }

  Future<void> _playMoveSound({
    required bool capture,
    required bool promoted,
  }) async {
    audioService.setSoundEnabled(
      widget.settings.soundEnabled,
    );

    if (capture) {
      await audioService.playCapture();
    } else {
      await audioService.playMove();
    }

    if (promoted) {
      await audioService.playKingPromotion();
    }
  }

  // ============================================================
  // AUTO SAVE
  // ============================================================

  void _startAutoSave() {
    _saveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        if (!gameFinished && !engine.isGameOver) {
          await widget.storage.saveGame(engine);
        }
      },
    );
  }

  // ============================================================
  // NEW GAME
  // ============================================================

  Future<void> _newGame() async {
    await _playButton();

    if (!mounted) {
      return;
    }

    engine.reset();

    setState(() {
      selectedRow = null;
      selectedCol = null;
      availableMoves = [];
      aiThinking = false;
      gameFinished = false;
    });

    await audioService.playGameStart();
  }

  // ============================================================
  // BOARD TAP
  // ============================================================

  void _onSquareTap(
    int row,
    int col,
  ) {
    if (aiThinking || gameFinished) {
      return;
    }

    if (widget.settings.isPlayerVsAi &&
        engine.turn != PieceColor.red) {
      return;
    }

    final tappedPiece = engine.board[row][col];

    // ==========================================================
    // SELECT PIECE
    // ==========================================================

    if (tappedPiece != null &&
        tappedPiece.color == engine.turn) {
      final moves = engine.legalMovesForPiece(
        row,
        col,
      );

      if (moves.isEmpty) {
        audioService.playInvalidMove();
        return;
      }

      audioService.playSelect();

      if (!mounted) {
        return;
      }

      setState(() {
        selectedRow = row;
        selectedCol = col;
        availableMoves = List<CheckersMove>.from(moves);
      });

      return;
    }

    // ==========================================================
    // NO PIECE SELECTED
    // ==========================================================

    if (selectedRow == null ||
        selectedCol == null) {
      audioService.playInvalidMove();
      return;
    }

    // ==========================================================
    // FIND LEGAL DESTINATION
    // ==========================================================

    final move = _findSelectedMove(
      row,
      col,
    );

    if (move == null) {
      audioService.playInvalidMove();
      return;
    }

    _executeMove(move);
  }

  // ============================================================
  // FIND SELECTED MOVE
  // ============================================================

  CheckersMove? _findSelectedMove(
    int row,
    int col,
  ) {
    for (final move in availableMoves) {
      if (move.toRow == row &&
          move.toCol == col) {
        return move;
      }
    }

    return null;
  }

  // ============================================================
  // PLAYER MOVE
  // ============================================================

  Future<void> _executeMove(
    CheckersMove move,
  ) async {
    if (gameFinished || aiThinking) {
      return;
    }

    final movingPiece =
        engine.board[move.fromRow][move.fromCol];

    if (movingPiece == null) {
      return;
    }

    final wasCapture = move.isCapture;
    final wasKing = movingPiece.isKing;

    PieceColor? capturedColor;

    if (move.capturedRow != null &&
        move.capturedCol != null) {
      capturedColor =
          engine.board[move.capturedRow!]
              [move.capturedCol!]
              ?.color;
    }

    final success = engine.makeMove(move);

    if (!success) {
      await audioService.playInvalidMove();
      return;
    }

    final movedPiece =
        engine.board[move.toRow][move.toCol];

    final promoted =
        !wasKing && movedPiece?.isKing == true;

    // ==========================================================
    // SOUND
    // ==========================================================

    await _playMoveSound(
      capture: wasCapture,
      promoted: promoted,
    );

    // ==========================================================
    // STATISTICS
    // ==========================================================

    if (wasCapture &&
        capturedColor != null) {
      widget.statistics.recordCapture(
        capturedColor: capturedColor,
        playerColor: PieceColor.red,
      );
    }

    if (promoted) {
      widget.statistics.recordKingCreated();
    }

    // ==========================================================
    // MULTIPLE CAPTURE
    // ==========================================================

    final additionalCaptures = wasCapture
        ? engine.captureMovesForPiecePublic(
            move.toRow,
            move.toCol,
          )
        : <CheckersMove>[];

    if (mounted) {
      setState(() {
        if (wasCapture &&
            additionalCaptures.isNotEmpty) {
          selectedRow = move.toRow;
          selectedCol = move.toCol;

          availableMoves =
              List<CheckersMove>.from(
            additionalCaptures,
          );
        } else {
          selectedRow = null;
          selectedCol = null;
          availableMoves = [];
        }
      });
    }

    // ==========================================================
    // CHECK GAME END
    // ==========================================================

    await _checkGameEnd();

    if (!mounted || gameFinished) {
      return;
    }

    // Same piece must continue capturing.
    if (wasCapture &&
        additionalCaptures.isNotEmpty) {
      return;
    }

    // ==========================================================
    // AI TURN
    // ==========================================================

    if (widget.settings.isPlayerVsAi &&
        engine.turn == PieceColor.black &&
        widget.settings.autoAiMove) {
      await _runAiTurn();
    }
  }

  // ============================================================
  // AI TURN
  // ============================================================

  Future<void> _runAiTurn() async {
    if (aiThinking || gameFinished) {
      return;
    }

    if (engine.turn != PieceColor.black) {
      return;
    }

    if (!widget.settings.isPlayerVsAi) {
      return;
    }

    if (mounted) {
      setState(() {
        aiThinking = true;
        selectedRow = null;
        selectedCol = null;
        availableMoves = [];
      });
    }

    await Future.delayed(
      widget.settings.aiThinkingDelay,
    );

    if (!mounted || gameFinished) {
      return;
    }

    ai.setDifficulty(
      widget.settings.aiDifficulty,
    );

    final move = ai.findBestMove(engine);

    if (!mounted || gameFinished) {
      return;
    }

    if (move == null) {
      if (mounted) {
        setState(() {
          aiThinking = false;
        });
      }

      await _checkGameEnd();
      return;
    }

    final movingPiece =
        engine.board[move.fromRow][move.fromCol];

    if (movingPiece == null) {
      if (mounted) {
        setState(() {
          aiThinking = false;
        });
      }

      return;
    }

    final wasKing = movingPiece.isKing;

    PieceColor? capturedColor;

    if (move.capturedRow != null &&
        move.capturedCol != null) {
      capturedColor =
          engine.board[move.capturedRow!]
              [move.capturedCol!]
              ?.color;
    }

    final success = engine.makeMove(move);

    if (!success) {
      if (mounted) {
        setState(() {
          aiThinking = false;
        });
      }

      return;
    }

    final movedPiece =
        engine.board[move.toRow][move.toCol];

    final promoted =
        !wasKing && movedPiece?.isKing == true;

    // ==========================================================
    // AI SOUND
    // ==========================================================

    await _playMoveSound(
      capture: move.isCapture,
      promoted: promoted,
    );

    // ==========================================================
    // AI STATISTICS
    // ==========================================================

    if (move.isCapture &&
        capturedColor != null) {
      widget.statistics.recordCapture(
        capturedColor: capturedColor,
        playerColor: PieceColor.black,
      );
    }

    if (promoted) {
      widget.statistics.recordKingCreated();
    }

    // ==========================================================
    // AI MULTIPLE CAPTURE
    // ==========================================================

    final additionalCaptures = move.isCapture
        ? engine.captureMovesForPiecePublic(
            move.toRow,
            move.toCol,
          )
        : <CheckersMove>[];

    if (mounted) {
      setState(() {
        aiThinking = false;

        if (move.isCapture &&
            additionalCaptures.isNotEmpty) {
          selectedRow = move.toRow;
          selectedCol = move.toCol;

          availableMoves =
              List<CheckersMove>.from(
            additionalCaptures,
          );
        } else {
          selectedRow = null;
          selectedCol = null;
          availableMoves = [];
        }
      });
    }

    // ==========================================================
    // CHECK GAME END
    // ==========================================================

    await _checkGameEnd();

    if (!mounted || gameFinished) {
      return;
    }

    if (move.isCapture &&
        additionalCaptures.isNotEmpty) {
      await _runAiTurn();
    }
  }

  // ============================================================
  // GAME END
  // ============================================================

  Future<void> _checkGameEnd() async {
    if (gameFinished) {
      return;
    }

    final winner = engine.winner();
    final draw = engine.isDraw;

    // ----------------------------------------------------------
    // GAME STILL RUNNING
    // ----------------------------------------------------------

    if (winner == null && !draw) {
      return;
    }

    gameFinished = true;
    aiThinking = false;

    selectedRow = null;
    selectedCol = null;
    availableMoves = [];

    // ----------------------------------------------------------
    // AUTOMATIC DRAW
    // ----------------------------------------------------------

    if (draw && winner == null) {
      await _recordDrawResult(
        showDialogAfterSave: true,
      );

      return;
    }

    // ----------------------------------------------------------
    // WIN / LOSS
    // ----------------------------------------------------------

    if (winner == null) {
      return;
    }

    final gameWinner = winner;

    widget.statistics.recordGameResult(
      playerColor: PieceColor.red,
      winner: gameWinner,
      moves: engine.moveCount,
    );

    await widget.storage.saveStatistics(
      widget.statistics,
    );

    final history = GameHistory(
      date: DateTime.now(),
      playerColor: PieceColor.red,
      winner: gameWinner,
      moves: engine.moveCount,
      captures: _countCapturesForCurrentGame(),
      kingsCreated: _countKingsForCurrentGame(),
      playerVsAi: widget.settings.isPlayerVsAi,
      difficulty: _difficultyText(
        widget.settings.aiDifficulty,
      ),
    );

    await widget.historyService.addGame(
      history,
    );

    await widget.storage.deleteSavedGame();

    if (!mounted) {
      return;
    }

    if (gameWinner == PieceColor.red) {
      await audioService.playWin();
    } else {
      await audioService.playLoss();
    }

    if (!mounted) {
      return;
    }

    final String message;

    if (gameWinner == PieceColor.red) {
      message = 'You won!';
    } else {
      message = widget.settings.isPlayerVsAi
          ? 'AI wins!'
          : 'Black wins!';
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(
            '$message\n\n'
            'Moves: ${engine.moveCount}\n'
            'History saved.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playButton();
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                _playButton();
                Navigator.pop(dialogContext);
                _newGame();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // RECORD DRAW
  // ============================================================

  Future<void> _recordDrawResult({
    required bool showDialogAfterSave,
  }) async {
    // A draw is now considered a completed game.
    gameFinished = true;
    aiThinking = false;

    selectedRow = null;
    selectedCol = null;
    availableMoves = [];

    // ----------------------------------------------------------
    // STATISTICS
    // ----------------------------------------------------------

    widget.statistics.recordGameResult(
      playerColor: PieceColor.red,
      winner: null,
      moves: engine.moveCount,
    );

    await widget.storage.saveStatistics(
      widget.statistics,
    );

    // ----------------------------------------------------------
    // HISTORY
    // ----------------------------------------------------------

    final history = GameHistory(
      date: DateTime.now(),
      playerColor: PieceColor.red,
      winner: null,
      moves: engine.moveCount,
      captures: _countCapturesForCurrentGame(),
      kingsCreated: _countKingsForCurrentGame(),
      playerVsAi: widget.settings.isPlayerVsAi,
      difficulty: _difficultyText(
        widget.settings.aiDifficulty,
      ),
    );

    await widget.historyService.addGame(
      history,
    );

    // ----------------------------------------------------------
    // REMOVE RESUMABLE SAVE
    // ----------------------------------------------------------

    await widget.storage.deleteSavedGame();

    if (!mounted) {
      return;
    }

    setState(() {});

    if (!showDialogAfterSave) {
      return;
    }

    await _showDrawDialog();
  }

  // ============================================================
  // SAVE AS DRAW
  // ============================================================

  Future<void> _saveAsDraw() async {
    await _playButton();

    // ----------------------------------------------------------
    // DO NOT ALLOW DRAW AFTER GAME IS FINISHED
    // ----------------------------------------------------------

    if (gameFinished) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This game has already finished.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // CHECK WHETHER THERE IS ALREADY A WINNER
    // ----------------------------------------------------------

    final winner = engine.winner();

    if (winner != null || engine.isGameOver) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The game already has a winner and cannot be saved as a draw.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // AI MUST NOT BE THINKING
    // ----------------------------------------------------------

    if (aiThinking) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please wait for the AI to finish its move.',
          ),
        ),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // CONFIRM
    // ----------------------------------------------------------

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Save as Draw?'),
          content: const Text(
            'Are you sure you want to end the current game as a draw?\n\n'
            'The game will be completed and recorded in your '
            'game history and statistics.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playButton();
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                _playButton();
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              icon: const Icon(
                Icons.handshake_outlined,
              ),
              label: const Text('Save as Draw'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    // ----------------------------------------------------------
    // SAVE DRAW
    // ----------------------------------------------------------

    await _recordDrawResult(
      showDialogAfterSave: true,
    );
  }

  // ============================================================
  // DRAW DIALOG
  // ============================================================

  Future<void> _showDrawDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Game Draw'),
          content: Text(
            'DRAW\n\n'
            'Moves: ${engine.moveCount}\n'
            'Game saved to history.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playButton();
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                _playButton();
                Navigator.pop(dialogContext);
                _newGame();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CAPTURES
  // ============================================================

  int _countCapturesForCurrentGame() {
    return engine.redCaptured +
        engine.blackCaptured;
  }

  // ============================================================
  // KINGS
  // ============================================================

  int _countKingsForCurrentGame() {
    int count = 0;

    for (final row in engine.board) {
      for (final piece in row) {
        if (piece != null && piece.isKing) {
          count++;
        }
      }
    }

    return count;
  }

  // ============================================================
  // SAVE GAME
  // ============================================================

  Future<void> _saveGame() async {
    await _playButton();

    if (gameFinished || engine.isGameOver) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completed games cannot be saved as resumable games.',
          ),
        ),
      );

      return;
    }

    final result =
        await widget.storage.saveGame(engine);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result
              ? 'Game saved successfully.'
              : 'Unable to save game.',
        ),
      ),
    );
  }

  // ============================================================
  // LOAD GAME
  // ============================================================

  Future<void> _loadGame() async {
    await _playButton();

    final result =
        await widget.storage.loadGame(engine);

    if (!mounted) {
      return;
    }

    if (result) {
      final winner = engine.winner();

      setState(() {
        selectedRow = null;
        selectedCol = null;
        availableMoves = [];
        aiThinking = false;

        gameFinished =
            engine.isGameOver || winner != null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved game loaded.'),
        ),
      );

      if (!gameFinished &&
          widget.settings.isPlayerVsAi &&
          engine.turn == PieceColor.black &&
          widget.settings.autoAiMove) {
        await _runAiTurn();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved game found.'),
        ),
      );
    }
  }

  // ============================================================
  // MENU
  // ============================================================

  void _openMenu() {
    _playButton();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'CHECKERS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                _menuItem(
                  icon: Icons.add_circle_outline,
                  title: 'New Game',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _newGame();
                  },
                ),

                _menuItem(
                  icon: Icons.save_outlined,
                  title: 'Save Game',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _saveGame();
                  },
                ),

                _menuItem(
                  icon: Icons.handshake_outlined,
                  title: 'Save as Draw',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _saveAsDraw();
                  },
                ),

                _menuItem(
                  icon: Icons.folder_open_outlined,
                  title: 'Load Game',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _loadGame();
                  },
                ),

                _menuItem(
                  icon: Icons.rule_outlined,
                  title: 'Rule Selection',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openRuleSelection();
                  },
                ),

                _menuItem(
                  icon: Icons.menu_book_outlined,
                  title: 'Rules',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RulesScreen(),
                      ),
                    );
                  },
                ),

                _menuItem(
                  icon: Icons.history,
                  title: 'Game History',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openGameHistory();
                  },
                ),

                _menuItem(
                  icon: Icons.bar_chart_outlined,
                  title: 'Statistics',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StatisticsScreen(
                          statistics:
                              widget.statistics,
                        ),
                      ),
                    );
                  },
                ),

                _menuItem(
                  icon: Icons.extension_outlined,
                  title: 'Challenges',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PuzzleScreen(
                          historyService:
                              widget.historyService,
                        ),
                      ),
                    );
                  },
                ),

                _menuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showSettings();
                  },
                ),

                _menuItem(
                  icon: Icons.help_outline,
                  title: 'How to Play',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showHelp();
                  },
                ),

                _menuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAbout();
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // RULE SELECTION
  // ============================================================

  Future<void> _openRuleSelection() async {
    await _playButton();

    if (!mounted) {
      return;
    }

    final variants = ruleManager.availableVariants;

    final selected =
        await showModalBottomSheet<RuleVariant>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Rule Selection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Choose the rules used by the Checkers game.',
                ),

                const SizedBox(height: 20),

                ...variants.map(
                  (variant) {
                    final isSelected =
                        ruleManager.currentVariant ==
                            variant;

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(
                          _ruleVariantName(
                            variant,
                          ),
                        ),
                        subtitle: Text(
                          _ruleVariantDescription(
                            variant,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                            variant,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    final changed =
        ruleManager.setVariant(selected);

    if (!changed) {
      return;
    }

    await _newGame();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rule changed to ${_ruleVariantName(selected)}.',
        ),
      ),
    );
  }

  String _ruleVariantName(
    RuleVariant variant,
  ) {
    final text = variant.toString();

    final name = text.contains('.')
        ? text.split('.').last
        : text;

    if (name.isEmpty) {
      return 'Unknown';
    }

    return name[0].toUpperCase() +
        name.substring(1);
  }

  String _ruleVariantDescription(
    RuleVariant variant,
  ) {
    final name = _ruleVariantName(variant);

    switch (name.toLowerCase()) {
      case 'eastafrica':
      case 'eastafrican':
        return 'East African rules. Backward captures are not allowed.';

      case 'international':
        return 'International rules with international capture and king movement rules.';

      case 'american':
      case 'americancheckers':
        return 'American / English draughts rules.';

      default:
        return 'Use the rules defined for this variant.';
    }
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Future<void> _openGameHistory() async {
    final historyFuture =
        widget.historyService.getHistory();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder<List<GameHistory>>(
          future: historyFuture,
          builder: (
            dialogBuilderContext,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const AlertDialog(
                title: Text('Game History'),
                content: SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final history = snapshot.data ?? [];

            if (history.isEmpty) {
              return AlertDialog(
                title: const Text('Game History'),
                content: const Text(
                  'No completed games yet.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: const Text('Game History'),
              content: SizedBox(
                width: double.maxFinite,
                height: 420,
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (
                    listContext,
                    index,
                  ) {
                    final game = history[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          game.isDraw
                              ? Icons.handshake_outlined
                              : game.playerWon
                                  ? Icons.emoji_events
                                  : Icons.close,
                        ),
                      ),
                      title: Text(
                        game.result,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${game.dateText} • '
                        '${game.timeText}\n'
                        '${game.opponentName} • '
                        '${game.moves} moves',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        onPressed: () async {
                          await widget.historyService
                              .deleteGame(index);

                          if (!mounted) {
                            return;
                          }

                          if (!dialogContext.mounted) {
                            return;
                          }

                          Navigator.pop(dialogContext);

                          if (!mounted) {
                            return;
                          }

                          _openGameHistory();
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    await widget.historyService
                        .clearHistory();

                    if (!mounted) {
                      return;
                    }

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    if (!mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Game history cleared.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Clear History',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // MENU ITEM
  // ============================================================

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: onTap,
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  void _showSettings() {
    _playButton();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogBuilderContext,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text('Settings'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<GameMode>(
                      initialValue:
                          widget.settings.gameMode,
                      decoration:
                          const InputDecoration(
                        labelText: 'Game Mode',
                      ),
                      items: GameMode.values.map(
                        (mode) {
                          return DropdownMenuItem<GameMode>(
                            value: mode,
                            child: Text(
                              mode ==
                                      GameMode.playerVsAi
                                  ? 'Player vs AI'
                                  : 'Player vs Player',
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        widget.settings.gameMode =
                            value;

                        setDialogState(() {});
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<AiDifficulty>(
                      initialValue:
                          widget.settings.aiDifficulty,
                      decoration:
                          const InputDecoration(
                        labelText: 'AI Difficulty',
                      ),
                      items: AiDifficulty.values.map(
                        (difficulty) {
                          return DropdownMenuItem<
                              AiDifficulty>(
                            value: difficulty,
                            child: Text(
                              _difficultyText(
                                difficulty,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        widget.settings.aiDifficulty =
                            value;

                        ai.setDifficulty(value);

                        setDialogState(() {});
                      },
                    ),

                    const SizedBox(height: 10),

                    SwitchListTile(
                      title: const Text('Sound'),
                      value:
                          widget.settings.soundEnabled,
                      onChanged: (value) {
                        widget.settings.soundEnabled =
                            value;

                        audioService.setSoundEnabled(
                          value,
                        );

                        if (value) {
                          audioService.playButton();
                        }

                        setDialogState(() {});
                      },
                    ),

                    SwitchListTile(
                      title: const Text('Music'),
                      value:
                          widget.settings.musicEnabled,
                      onChanged: (value) {
                        widget.settings.musicEnabled =
                            value;

                        audioService.setMusicEnabled(
                          value,
                        );

                        if (value) {
                          audioService.startMusic();
                        }

                        setDialogState(() {});
                      },
                    ),

                    SwitchListTile(
                      title: const Text(
                        'Show Coordinates',
                      ),
                      value:
                          widget.settings.showCoordinates,
                      onChanged: (value) {
                        widget.settings.showCoordinates =
                            value;

                        setDialogState(() {});
                      },
                    ),

                    SwitchListTile(
                      title: const Text(
                        'Show Legal Moves',
                      ),
                      value:
                          widget.settings.showLegalMoves,
                      onChanged: (value) {
                        widget.settings.showLegalMoves =
                            value;

                        setDialogState(() {});
                      },
                    ),

                    SwitchListTile(
                      title: const Text(
                        'Animations',
                      ),
                      value:
                          widget.settings.animationsEnabled,
                      onChanged: (value) {
                        widget.settings.animationsEnabled =
                            value;

                        setDialogState(() {});
                      },
                    ),

                    SwitchListTile(
                      title: const Text(
                        'Game Timer',
                      ),
                      value:
                          widget.settings.gameTimerEnabled,
                      onChanged: (value) {
                        widget.settings.gameTimerEnabled =
                            value;

                        setDialogState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await widget.storage.saveSettings(
                      widget.settings,
                    );

                    if (!mounted) {
                      return;
                    }

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext);

                    setState(() {});
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DIFFICULTY
  // ============================================================

  String _difficultyText(
    AiDifficulty difficulty,
  ) {
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

  // ============================================================
  // HELP
  // ============================================================

  void _showHelp() {
    _playButton();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const SingleChildScrollView(
            child: Text(
              '1. Select one of your pieces.\n\n'
              '2. The selected piece gets a highlighted border.\n\n'
              '3. Legal destination squares are shown with yellow dots.\n\n'
              '4. Tap a yellow destination to move.\n\n'
              '5. Captures are mandatory when available.\n\n'
              '6. If another capture is available after '
              'a capture, the same piece must continue.\n\n'
              '7. Reach the opposite end of the board '
              'to promote your piece to a king.\n\n'
              '8. Capture all opponent pieces or block '
              'all their legal moves to win.\n\n'
              '9. You can choose "Save as Draw" from the '
              'menu to end the current unfinished game as a draw.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAbout() {
    _playButton();

    showAboutDialog(
      context: context,
      applicationName: 'Drafts Game',
      applicationVersion: '1.0.0',
      applicationLegalese:
          'Advanced Drafts / Checkers Game',
      children: const [
        SizedBox(height: 15),
        Text(
          'A modern Drafts game with AI, '
          'statistics, settings, saving, '
          'game history, challenges, '
          'sound and multiple rule variants.',
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            return Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildMainArea(
                    constraints,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(12),
              color: const Color(0xFFE53935),
            ),
            child: const Icon(
              Icons.grid_4x4,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'DRAFTS',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Advanced Checkers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          _turnBadge(),

          const SizedBox(width: 8),

          IconButton(
            tooltip: 'Menu',
            onPressed: _openMenu,
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TURN BADGE
  // ============================================================

  Widget _turnBadge() {
    final isRed =
        engine.turn == PieceColor.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: isRed
              ? Colors.redAccent
              : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRed
                  ? Colors.redAccent
                  : Colors.white70,
            ),
          ),

          const SizedBox(width: 7),

          Text(
            aiThinking
                ? 'AI THINKING'
                : isRed
                    ? 'YOUR TURN'
                    : 'BLACK TURN',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN AREA
  // ============================================================

  Widget _buildMainArea(
    BoxConstraints constraints,
  ) {
    final wide =
        constraints.maxWidth >= 850;

    if (wide) {
      return Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: _buildBoardArea(),
          ),

          const SizedBox(width: 25),

          SizedBox(
            width: 260,
            child: _buildSidePanel(),
          ),

          const SizedBox(width: 20),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBoardArea(),
          _buildSidePanel(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // ============================================================
  // BOARD AREA
  // ============================================================

  Widget _buildBoardArea() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AspectRatio(
          aspectRatio: 1,
          child: _buildBoard(),
        ),
      ),
    );
  }

  // ============================================================
  // BOARD
  // ============================================================

  Widget _buildBoard() {
    final boardSize = engine.board.length;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 30,
            spreadRadius: 2,
            offset: Offset(0, 10),
            color: Colors.black54,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(12),
        child: GridView.builder(
          physics:
              const NeverScrollableScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: boardSize,
          ),
          itemCount:
              boardSize * boardSize,
          itemBuilder: (
            context,
            index,
          ) {
            final row =
                index ~/ boardSize;

            final col =
                index % boardSize;

            return _buildSquare(
              row,
              col,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SQUARE
  // ============================================================

  Widget _buildSquare(
    int row,
    int col,
  ) {
    final dark =
        (row + col).isOdd;

    final boardSize =
        engine.board.length;

    final piece =
        engine.board[row][col];

    final selected =
        selectedRow == row &&
            selectedCol == col;

    final legal =
        _isLegalDestination(
      row,
      col,
    );

    Color squareColor;

    switch (widget.settings.boardTheme) {
      case BoardTheme.classic:
        squareColor = dark
            ? const Color(0xFF7A4E2D)
            : const Color(0xFFE8D0A9);
        break;

      case BoardTheme.wood:
        squareColor = dark
            ? const Color(0xFF5D3A22)
            : const Color(0xFFD5B48A);
        break;

      case BoardTheme.modern:
        squareColor = dark
            ? const Color(0xFF30363D)
            : const Color(0xFFE6EDF3);
        break;

      case BoardTheme.midnight:
        squareColor = dark
            ? const Color(0xFF18202B)
            : const Color(0xFF5C677D);
        break;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onSquareTap(
          row,
          col,
        );
      },
      child: AnimatedContainer(
        duration:
            widget.settings.animationsEnabled
                ? const Duration(
                    milliseconds: 120,
                  )
                : Duration.zero,
        decoration: BoxDecoration(
          color: squareColor,
          border: selected
              ? Border.all(
                  color:
                      Colors.yellowAccent,
                  width:
                      boardSize <= 8
                          ? 3
                          : 2.5,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ==================================================
            // COORDINATES
            // ==================================================

            if (widget.settings.showCoordinates &&
                col == 0)
              Positioned(
                left: 4,
                top: 3,
                child: Text(
                  '${boardSize - row}',
                  style: TextStyle(
                    fontSize:
                        boardSize <= 8
                            ? 9
                            : 7,
                    fontWeight:
                        FontWeight.bold,
                    color: dark
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ),

            if (widget.settings.showCoordinates &&
                row == boardSize - 1)
              Positioned(
                right: 4,
                bottom: 3,
                child: Text(
                  String.fromCharCode(
                    65 + col,
                  ),
                  style: TextStyle(
                    fontSize:
                        boardSize <= 8
                            ? 9
                            : 7,
                    fontWeight:
                        FontWeight.bold,
                    color: dark
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ),

            // ==================================================
            // LEGAL MOVE DOT
            // ==================================================

            if (legal &&
                widget.settings.showLegalMoves)
              _buildLegalMoveIndicator(
                hasPiece: piece != null,
                boardSize: boardSize,
              ),

            // ==================================================
            // PIECE
            // ==================================================

            if (piece != null)
              _buildPiece(
                piece,
                selected,
                boardSize,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LEGAL DESTINATION
  // ============================================================

  bool _isLegalDestination(
    int row,
    int col,
  ) {
    for (final move in availableMoves) {
      if (move.toRow == row &&
          move.toCol == col) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // LEGAL MOVE DOT
  // ============================================================

  Widget _buildLegalMoveIndicator({
    required bool hasPiece,
    required int boardSize,
  }) {
    final double size;

    if (hasPiece) {
      size =
          boardSize <= 8 ? 9 : 7;
    } else {
      size =
          boardSize <= 8 ? 16 : 12;
    }

    return IgnorePointer(
      child: AnimatedContainer(
        duration:
            widget.settings.animationsEnabled
                ? const Duration(
                    milliseconds: 120,
                  )
                : Duration.zero,
        width: size,
        height: size,
        decoration:
            const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.yellowAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PIECE
  // ============================================================

  Widget _buildPiece(
    GamePiece piece,
    bool selected,
    int boardSize,
  ) {
    final red =
        piece.color == PieceColor.red;

    final double pieceSize =
        boardSize <= 8 ? 42 : 34;

    return AnimatedContainer(
      duration:
          widget.settings.animationsEnabled
              ? widget.settings.moveAnimationDuration
              : Duration.zero,
      width: pieceSize,
      height: pieceSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(
            -0.3,
            -0.3,
          ),
          colors: red
              ? const [
                  Color(0xFFFF6B6B),
                  Color(0xFFC62828),
                  Color(0xFF7F0000),
                ]
              : const [
                  Color(0xFFF5F5F5),
                  Color(0xFF9E9E9E),
                  Color(0xFF303030),
                ],
        ),
        border: Border.all(
          color: selected
              ? Colors.yellowAccent
              : Colors.white24,
          width: selected
              ? (boardSize <= 8
                  ? 3.5
                  : 2.5)
              : 1,
        ),
        boxShadow: [
          const BoxShadow(
            blurRadius: 5,
            offset: Offset(0, 3),
            color: Colors.black54,
          ),
          if (selected)
            const BoxShadow(
              blurRadius: 10,
              spreadRadius: 2,
              color: Colors.yellowAccent,
            ),
        ],
      ),
      child: piece.isKing
          ? Icon(
              Icons.workspace_premium,
              size:
                  boardSize <= 8
                      ? 22
                      : 17,
              color: Colors.amber,
            )
          : null,
    );
  }

  // ============================================================
  // SIDE PANEL
  // ============================================================

  Widget _buildSidePanel() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          _buildPlayerCard(
            name: 'RED PLAYER',
            pieceColor: PieceColor.red,
            pieces: engine.redPieces,
            captured: engine.redCaptured,
            active:
                engine.turn ==
                    PieceColor.red,
          ),

          const SizedBox(height: 12),

          _buildPlayerCard(
            name:
                widget.settings.isPlayerVsAi
                    ? 'BLACK • AI'
                    : 'BLACK PLAYER',
            pieceColor:
                PieceColor.black,
            pieces:
                engine.blackPieces,
            captured:
                engine.blackCaptured,
            active:
                engine.turn ==
                    PieceColor.black,
          ),

          const SizedBox(height: 15),

          Container(
            padding:
                const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color:
                  const Color(0xFF161B22),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color: Colors.white10,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'MOVES',
                      style: TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${engine.moveCount}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'DIFFICULTY',
                      style: TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      ai.difficultyName,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'RULES',
                      style: TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _ruleVariantName(
                          ruleManager
                              .currentVariant,
                        ),
                        textAlign:
                            TextAlign.right,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      FilledButton.icon(
                    onPressed:
                        _newGame,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label:
                        const Text(
                      'NEW GAME',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLAYER CARD
  // ============================================================

  Widget _buildPlayerCard({
    required String name,
    required PieceColor pieceColor,
    required int pieces,
    required int captured,
    required bool active,
  }) {
    final red =
        pieceColor == PieceColor.red;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 200),
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF20262E)
            : const Color(0xFF161B22),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? (red
                  ? Colors.redAccent
                  : Colors.white54)
              : Colors.white10,
          width:
              active ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: red
                  ? Colors.redAccent
                  : Colors.grey.shade300,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black45,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing:
                        0.8,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '$pieces pieces',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              const Text(
                'CAPTURED',
                style: TextStyle(
                  fontSize: 8,
                  color:
                      Colors.white38,
                ),
              ),
              Text(
                '$captured',
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}