
import 'package:flutter/material.dart';

enum GameMode {
  playerVsAi,
  playerVsPlayer,
}

enum AiDifficulty {
  easy,
  medium,
  hard,
  expert,
}

enum BoardTheme {
  classic,
  wood,
  modern,
  midnight,
}

class GameSettings extends ChangeNotifier {
  GameMode _gameMode = GameMode.playerVsAi;

  AiDifficulty _aiDifficulty =
      AiDifficulty.medium;

  BoardTheme _boardTheme =
      BoardTheme.classic;

  bool _soundEnabled = true;
  bool _musicEnabled = false;
  bool _showCoordinates = false;
  bool _showLegalMoves = true;
  bool _animationsEnabled = true;
  bool _gameTimerEnabled = true;
  bool _autoAiMove = true;

  ThemeMode _themeMode = ThemeMode.dark;

  int _aiThinkingDelayMilliseconds = 500;

  int _moveAnimationMilliseconds = 180;

  // ==========================================================
  // GETTERS
  // ==========================================================

  GameMode get gameMode => _gameMode;

  AiDifficulty get aiDifficulty =>
      _aiDifficulty;

  BoardTheme get boardTheme =>
      _boardTheme;

  bool get soundEnabled =>
      _soundEnabled;

  bool get musicEnabled =>
      _musicEnabled;

  bool get showCoordinates =>
      _showCoordinates;

  bool get showLegalMoves =>
      _showLegalMoves;

  bool get animationsEnabled =>
      _animationsEnabled;

  bool get gameTimerEnabled =>
      _gameTimerEnabled;

  bool get autoAiMove =>
      _autoAiMove;

  ThemeMode get themeMode =>
      _themeMode;

  bool get isPlayerVsAi =>
      _gameMode == GameMode.playerVsAi;

  Duration get aiThinkingDelay =>
      Duration(
        milliseconds:
            _aiThinkingDelayMilliseconds,
      );

  Duration get moveAnimationDuration =>
      Duration(
        milliseconds:
            _moveAnimationMilliseconds,
      );

  // ==========================================================
  // SETTERS
  // ==========================================================

  set gameMode(GameMode value) {
    _gameMode = value;
    notifyListeners();
  }

  set aiDifficulty(
    AiDifficulty value,
  ) {
    _aiDifficulty = value;
    notifyListeners();
  }

  set boardTheme(BoardTheme value) {
    _boardTheme = value;
    notifyListeners();
  }

  set soundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  set musicEnabled(bool value) {
    _musicEnabled = value;
    notifyListeners();
  }

  set showCoordinates(bool value) {
    _showCoordinates = value;
    notifyListeners();
  }

  set showLegalMoves(bool value) {
    _showLegalMoves = value;
    notifyListeners();
  }

  set animationsEnabled(bool value) {
    _animationsEnabled = value;
    notifyListeners();
  }

  set gameTimerEnabled(bool value) {
    _gameTimerEnabled = value;
    notifyListeners();
  }

  set autoAiMove(bool value) {
    _autoAiMove = value;
    notifyListeners();
  }

  set themeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  set aiThinkingDelay(
    Duration value,
  ) {
    _aiThinkingDelayMilliseconds =
        value.inMilliseconds;

    notifyListeners();
  }

  set moveAnimationDuration(
    Duration value,
  ) {
    _moveAnimationMilliseconds =
        value.inMilliseconds;

    notifyListeners();
  }

  // ==========================================================
  // RESET
  // ==========================================================

  void reset() {
    _gameMode =
        GameMode.playerVsAi;

    _aiDifficulty =
        AiDifficulty.medium;

    _boardTheme =
        BoardTheme.classic;

    _soundEnabled = true;
    _musicEnabled = false;
    _showCoordinates = false;
    _showLegalMoves = true;
    _animationsEnabled = true;
    _gameTimerEnabled = true;
    _autoAiMove = true;

    _themeMode =
        ThemeMode.dark;

    _aiThinkingDelayMilliseconds =
        500;

    _moveAnimationMilliseconds =
        180;

    notifyListeners();
  }

  // ==========================================================
  // SERIALIZATION
  // ==========================================================

  Map<String, dynamic> toJson() {
    return {
      'gameMode':
          _gameMode.name,
      'aiDifficulty':
          _aiDifficulty.name,
      'boardTheme':
          _boardTheme.name,
      'soundEnabled':
          _soundEnabled,
      'musicEnabled':
          _musicEnabled,
      'showCoordinates':
          _showCoordinates,
      'showLegalMoves':
          _showLegalMoves,
      'animationsEnabled':
          _animationsEnabled,
      'gameTimerEnabled':
          _gameTimerEnabled,
      'autoAiMove':
          _autoAiMove,
      'themeMode':
          _themeMode.name,
      'aiThinkingDelayMilliseconds':
          _aiThinkingDelayMilliseconds,
      'moveAnimationMilliseconds':
          _moveAnimationMilliseconds,
    };
  }

  void fromJson(
    Map<String, dynamic> json,
  ) {
    final gameModeValue =
        json['gameMode'];

    if (gameModeValue is String) {
      _gameMode =
          GameMode.values.firstWhere(
        (value) =>
            value.name ==
            gameModeValue,
        orElse: () =>
            GameMode.playerVsAi,
      );
    }

    final difficultyValue =
        json['aiDifficulty'];

    if (difficultyValue is String) {
      _aiDifficulty =
          AiDifficulty.values.firstWhere(
        (value) =>
            value.name ==
            difficultyValue,
        orElse: () =>
            AiDifficulty.medium,
      );
    }

    final boardThemeValue =
        json['boardTheme'];

    if (boardThemeValue is String) {
      _boardTheme =
          BoardTheme.values.firstWhere(
        (value) =>
            value.name ==
            boardThemeValue,
        orElse: () =>
            BoardTheme.classic,
      );
    }

    _soundEnabled =
        json['soundEnabled'] is bool
            ? json['soundEnabled'] as bool
            : true;

    _musicEnabled =
        json['musicEnabled'] is bool
            ? json['musicEnabled'] as bool
            : false;

    _showCoordinates =
        json['showCoordinates'] is bool
            ? json['showCoordinates']
                as bool
            : false;

    _showLegalMoves =
        json['showLegalMoves'] is bool
            ? json['showLegalMoves']
                as bool
            : true;

    _animationsEnabled =
        json['animationsEnabled'] is bool
            ? json['animationsEnabled']
                as bool
            : true;

    _gameTimerEnabled =
        json['gameTimerEnabled'] is bool
            ? json['gameTimerEnabled']
                as bool
            : true;

    _autoAiMove =
        json['autoAiMove'] is bool
            ? json['autoAiMove'] as bool
            : true;

    final themeValue =
        json['themeMode'];

    if (themeValue is String) {
      _themeMode =
          ThemeMode.values.firstWhere(
        (value) =>
            value.name ==
            themeValue,
        orElse: () =>
            ThemeMode.dark,
      );
    }

    if (json[
            'aiThinkingDelayMilliseconds']
        is num) {
      _aiThinkingDelayMilliseconds =
          (json[
                  'aiThinkingDelayMilliseconds']
              as num)
          .toInt();
    }

    if (json[
            'moveAnimationMilliseconds']
        is num) {
      _moveAnimationMilliseconds =
          (json[
                  'moveAnimationMilliseconds']
              as num)
          .toInt();
    }

    notifyListeners();
  }
}

