
/// The two sides in the Drafts game.
enum PieceColor {
  red,
  black,
}

/// Represents one checkers/drafts piece.
///
/// A piece has:
/// - a color
/// - a king status
///
/// The class is immutable. When a piece becomes a king,
/// [promote] returns a new GamePiece instead of modifying
/// the existing one.
class GamePiece {
  final PieceColor color;
  final bool isKing;

  const GamePiece({
    required this.color,
    this.isKing = false,
  });

  /// Creates a normal piece.
  const GamePiece.normal({
    required this.color,
  }) : isKing = false;

  /// Creates a king piece.
  const GamePiece.king({
    required this.color,
  }) : isKing = true;

  /// Creates a copy of this piece with changed properties.
  GamePiece copyWith({
    PieceColor? color,
    bool? isKing,
  }) {
    return GamePiece(
      color: color ?? this.color,
      isKing: isKing ?? this.isKing,
    );
  }

  /// Promotes this piece to a king.
  GamePiece promote() {
    if (isKing) {
      return this;
    }

    return GamePiece(
      color: color,
      isKing: true,
    );
  }

  /// Converts the piece to a short symbol.
  ///
  /// r = red normal
  /// R = red king
  /// b = black normal
  /// B = black king
  String get symbol {
    if (color == PieceColor.red) {
      return isKing ? 'R' : 'r';
    }

    return isKing ? 'B' : 'b';
  }

  /// Human-readable name.
  String get displayName {
    if (color == PieceColor.red) {
      return isKing ? 'Red King' : 'Red Piece';
    }

    return isKing ? 'Black King' : 'Black Piece';
  }

  /// Converts this piece into JSON-compatible data.
  Map<String, dynamic> toJson() {
    return {
      'color': color.name,
      'isKing': isKing,
    };
  }

  /// Creates a GamePiece from saved JSON data.
  factory GamePiece.fromJson(
    Map<String, dynamic> json,
  ) {
    final colorName =
        json['color'] as String? ?? 'red';

    final color = PieceColor.values.firstWhere(
      (value) => value.name == colorName,
      orElse: () => PieceColor.red,
    );

    return GamePiece(
      color: color,
      isKing: json['isKing'] == true,
    );
  }

  @override
  String toString() {
    return displayName;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is GamePiece &&
        other.color == color &&
        other.isKing == isKing;
  }

  @override
  int get hashCode =>
      Object.hash(color, isKing);
}
