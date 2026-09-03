import '../models/game_piece.dart';

/// Stores information about a completed checkers move.
///
/// This is separate from [CheckersMove] because [CheckersMove]
/// describes a possible move, while this class describes a move
/// that has actually been played.
class CheckersMoveHistory {
  final int moveNumber;

  final PieceColor player;

  final int fromRow;
  final int fromCol;

  final int toRow;
  final int toCol;

  final bool wasCapture;

  final int? capturedRow;
  final int? capturedCol;

  final PieceColor? capturedPieceColor;

  final bool wasPromotion;

  final bool wasKingBeforeMove;

  const CheckersMoveHistory({
    required this.moveNumber,
    required this.player,
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.wasCapture,
    this.capturedRow,
    this.capturedCol,
    this.capturedPieceColor,
    required this.wasPromotion,
    required this.wasKingBeforeMove,
  });

  /// Human-readable player name.
  String get playerName {
    return player == PieceColor.red
        ? 'Red'
        : 'Black';
  }

  /// Human-readable starting square.
  String get fromSquare {
    return '${fromRow + 1},${fromCol + 1}';
  }

  /// Human-readable destination square.
  String get toSquare {
    return '${toRow + 1},${toCol + 1}';
  }

  /// Creates a readable description of the move.
  String get description {
    final captureText =
        wasCapture ? ' CAPTURE' : '';

    final promotionText =
        wasPromotion ? ' KING' : '';

    return '$playerName: '
        '$fromSquare → $toSquare'
        '$captureText'
        '$promotionText';
  }

  Map<String, dynamic> toJson() {
    return {
      'moveNumber': moveNumber,
      'player': player.name,
      'fromRow': fromRow,
      'fromCol': fromCol,
      'toRow': toRow,
      'toCol': toCol,
      'wasCapture': wasCapture,
      'capturedRow': capturedRow,
      'capturedCol': capturedCol,
      'capturedPieceColor':
          capturedPieceColor?.name,
      'wasPromotion': wasPromotion,
      'wasKingBeforeMove':
          wasKingBeforeMove,
    };
  }

  factory CheckersMoveHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    final playerName =
        json['player'] as String? ?? 'red';

    final capturedColorName =
        json['capturedPieceColor'] as String?;

    return CheckersMoveHistory(
      moveNumber:
          _safeInt(json['moveNumber']),
      player: PieceColor.values.firstWhere(
        (color) => color.name == playerName,
        orElse: () => PieceColor.red,
      ),
      fromRow:
          _safeInt(json['fromRow']),
      fromCol:
          _safeInt(json['fromCol']),
      toRow:
          _safeInt(json['toRow']),
      toCol:
          _safeInt(json['toCol']),
      wasCapture:
          json['wasCapture'] == true,
      capturedRow:
          _nullableInt(json['capturedRow']),
      capturedCol:
          _nullableInt(json['capturedCol']),
      capturedPieceColor:
          capturedColorName == null
              ? null
              : PieceColor.values.firstWhere(
                  (color) =>
                      color.name ==
                      capturedColorName,
                  orElse: () =>
                      PieceColor.red,
                ),
      wasPromotion:
          json['wasPromotion'] == true,
      wasKingBeforeMove:
          json['wasKingBeforeMove'] == true,
    );
  }

  static int _safeInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }
}