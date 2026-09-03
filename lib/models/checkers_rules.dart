
/// Supported Checkers / Draughts rule sets.
///
/// The rules are configurable so the game engine, AI and puzzles
/// can all use the same selected rules.
enum CheckersRules {
  /// East African / Tanzanian-style Drafts.
  ///
  /// Ordinary men DO NOT capture backward.
  tanzania,

  /// English Draughts.
  english,

  /// American Checkers.
  american,

  /// Russian Draughts.
  russian,

  /// Brazilian Draughts.
  brazilian,

  /// International Draughts.
  ///
  /// Kept as "polish" internally for compatibility with the
  /// existing project.
  polish,

  /// Italian Draughts.
  italian,

  /// Turkish Dama.
  turkish,
}

/// Complete configuration for one Checkers / Draughts ruleset.
class RulesConfig {
  final CheckersRules rules;

  /// Board dimension.
  final int boardSize;

  /// Number of pieces each player starts with.
  final int startingPieces;

  /// Whether ordinary men can capture backward.
  final bool menCanCaptureBackward;

  /// Whether kings can move multiple squares diagonally.
  final bool flyingKings;

  /// Whether kings can capture an enemy from multiple squares away.
  final bool flyingKingCaptures;

  /// Whether a capture is compulsory.
  final bool mandatoryCapture;

  /// Whether the player must choose a capture sequence that
  /// captures the maximum number of pieces.
  final bool maximumCaptureRequired;

  /// Whether reaching the promotion row creates a king.
  final bool promoteOnLastRow;

  /// Whether a capture sequence must stop immediately after promotion.
  final bool stopAfterPromotion;

  /// Whether a newly promoted piece may continue capturing
  /// during the same capture sequence.
  final bool continueAfterPromotion;

  /// Whether kings can move backward.
  final bool kingsMoveBackward;

  /// Whether this ruleset uses Turkish/Dama-style placement.
  final bool turkishInitialPlacement;

  /// Human-readable ruleset name.
  final String displayName;

  /// Description displayed in the rules selector.
  final String description;

  const RulesConfig({
    required this.rules,
    required this.boardSize,
    required this.startingPieces,
    required this.menCanCaptureBackward,
    required this.flyingKings,
    required this.flyingKingCaptures,
    required this.mandatoryCapture,
    required this.maximumCaptureRequired,
    required this.promoteOnLastRow,
    required this.stopAfterPromotion,
    required this.continueAfterPromotion,
    required this.kingsMoveBackward,
    required this.turkishInitialPlacement,
    required this.displayName,
    required this.description,
  });

  // ============================================================
  // PRESETS
  // ============================================================

  /// Returns the configuration for the selected ruleset.
  static RulesConfig forRules(
    CheckersRules rules,
  ) {
    switch (rules) {
      // ========================================================
      // EAST AFRICA / TANZANIA
      // ========================================================

      case CheckersRules.tanzania:
        return const RulesConfig(
          rules: CheckersRules.tanzania,

          boardSize: 8,
          startingPieces: 12,

          // IMPORTANT:
          // East African/Tanzanian rule in this app:
          // ordinary men CANNOT capture backward.
          menCanCaptureBackward: false,

          // Kings can move across multiple empty diagonal squares.
          flyingKings: true,

          // Kings can capture from multiple squares away.
          flyingKingCaptures: true,

          // Captures are compulsory.
          mandatoryCapture: true,

          // No maximum-capture requirement.
          maximumCaptureRequired: false,

          promoteOnLastRow: true,

          // A capture sequence does not automatically stop
          // just because promotion occurred.
          stopAfterPromotion: false,

          // Newly promoted kings may continue capturing.
          continueAfterPromotion: true,

          kingsMoveBackward: true,

          turkishInitialPlacement: false,

          displayName: 'East African Drafts',

          description:
              'East African / Tanzanian Drafts. '
              'Ordinary men cannot capture backward. '
              'Kings can move and capture backward.',
        );

      // ========================================================
      // ENGLISH DRAUGHTS
      // ========================================================

      case CheckersRules.english:
        return const RulesConfig(
          rules: CheckersRules.english,

          boardSize: 8,
          startingPieces: 12,

          // Men cannot capture backward.
          menCanCaptureBackward: false,

          // English kings are short-range kings.
          flyingKings: false,
          flyingKingCaptures: false,

          mandatoryCapture: true,
          maximumCaptureRequired: false,

          promoteOnLastRow: true,

          // Capture sequence stops after promotion.
          stopAfterPromotion: true,
          continueAfterPromotion: false,

          kingsMoveBackward: true,

          turkishInitialPlacement: false,

          displayName: 'English Draughts',

          description:
              'Traditional English Draughts. '
              'Men capture forward only and kings move one square diagonally.',
        );

      // ========================================================
      // AMERICAN CHECKERS
      // ========================================================

      case CheckersRules.american:
        return const RulesConfig(
          rules: CheckersRules.american,

          boardSize: 8,
          startingPieces: 12,

          // IMPORTANT:
          // American Checkers men CANNOT capture backward.
          menCanCaptureBackward: false,

          // American kings are short-range.
          flyingKings: false,
          flyingKingCaptures: false,

          mandatoryCapture: true,
          maximumCaptureRequired: false,

          promoteOnLastRow: true,

          // Promotion ends the capture sequence.
          stopAfterPromotion: true,
          continueAfterPromotion: false,

          kingsMoveBackward: true,

          turkishInitialPlacement: false,

          displayName: 'American Checkers',

          description:
              'Standard American Checkers. '
              'Men capture forward only and kings move one square diagonally.',
        );

      // ========================================================
      // RUSSIAN DRAUGHTS
      // ========================================================

      case CheckersRules.russian:
        return const RulesConfig(
          rules: CheckersRules.russian,

          boardSize: 8,
          startingPieces: 12,

          // Russian Draughts allows backward captures by men.
          menCanCaptureBackward: true,

          // Flying kings.
          flyingKings: true,
          flyingKingCaptures: true,

          mandatoryCapture: true,
          maximumCaptureRequired: false,

          promoteOnLastRow: true,

          stopAfterPromotion: false,
          continueAfterPromotion: true,

          kingsMoveBackward: true,

          turkishInitialPlacement: false,

          displayName: 'Russian Draughts',

          description:
              'Russian Draughts with backward captures and flying kings.',
        );

      // ========================================================
      // BRAZILIAN DRAUGHTS
      // ========================================================

      case CheckersRules.brazilian:
        return const RulesConfig(
          rules: CheckersRules.brazilian,

          boardSize: 8,
          startingPieces: 12,

          // Brazilian Draughts allows backward captures.
          menCanCaptureBackward: true,

          // Flying kings.
          flyingKings: true,
          flyingKingCaptures: true,

          mandatoryCapture: true,

          // Maximum capture is required.
          maximumCaptureRequired: true,

          promoteOnLastRow: true,

          stopAfterPromotion: false,
          continueAfterPromotion: true,

          kingsMoveBackward: true,

          turkishInitialPlacement: false,

          displayName: 'Brazilian Draughts',

          description:
              'Brazilian Draughts with backward captures, '
              'flying kings and compulsory maximum captures.',
        );

      // ========================================================
      // INTERNATIONAL DRAUGHTS
      // ========================================================

      case CheckersRules.polish:
        return const RulesConfig(
          rules: CheckersRules.polish,

          // International Draughts uses a 10x10 board.
          boardSize: 10,
          startingPieces: 20,

          // IMPORTANT:
          // International Draughts allows men to capture backward.
          menCanCaptureBackward: true,

          // International kings are flying kings.
          flyingKings: true,
          flyingKingCaptures: true,

          // Captures are compulsory.
          mandatoryCapture: true,

          // The maximum number of captures must be taken.
          maximumCaptureRequired: true,

          promoteOnLastRow: true,

          // A man can continue the capture sequence after promotion.
          stopAfterPromotion: false,
          continueAfterPromotion: true,

          kingsMoveBackward: true,

          turkishInitialPlacement: false,

          displayName: 'International Draughts',

          description:
              'International Draughts on a 10×10 board. '
              'Men can capture backward and the maximum capture is compulsory.',
        );

      // ========================================================
      // ITALIAN DRAUGHTS
      // ========================================================

      case CheckersRules.italian:
        return const RulesConfig(
          rules: CheckersRules.italian,

          boardSize: 8,
          startingPieces: 12,

          // Italian Draughts men cannot capture backward.
          menCanCaptureBackward: false,

          flyingKings: false,
          flyingKingCaptures: false,

          mandatoryCapture: true,

          // Maximum capture is required.
          maximumCaptureRequired: true,

          promoteOnLastRow: true,

          stopAfterPromotion: true,
          continueAfterPromotion: false,

          kingsMoveBackward: true,

          turkishInitialPlacement: false,

          displayName: 'Italian Draughts',

          description:
              'Italian Draughts with forward-only captures for men '
              'and compulsory maximum captures.',
        );

      // ========================================================
      // TURKISH DAMA
      // ========================================================

      case CheckersRules.turkish:
        return const RulesConfig(
          rules: CheckersRules.turkish,

          boardSize: 8,
          startingPieces: 16,

          // Turkish Dama allows backward captures.
          menCanCaptureBackward: true,

          flyingKings: true,
          flyingKingCaptures: true,

          mandatoryCapture: true,
          maximumCaptureRequired: false,

          promoteOnLastRow: true,

          stopAfterPromotion: false,
          continueAfterPromotion: true,

          kingsMoveBackward: true,

          turkishInitialPlacement: true,

          displayName: 'Turkish Dama',

          description:
              'Turkish Dama with backward captures, '
              'flying kings and its distinctive starting placement.',
        );
    }
  }

  // ============================================================
  // ALL CONFIGURATIONS
  // ============================================================

  /// Returns every supported ruleset.
  static List<RulesConfig> get all {
    return CheckersRules.values
        .map(RulesConfig.forRules)
        .toList(growable: false);
  }

  // ============================================================
  // JSON
  // ============================================================

  /// Converts the selected ruleset to JSON.
  Map<String, dynamic> toJson() {
    return {
      'rules': rules.name,
    };
  }

  /// Creates a rules configuration from JSON.
  ///
  /// Unknown or missing values safely fall back to
  /// East African Drafts.
  static RulesConfig fromJson(
    Map<String, dynamic> json,
  ) {
    final value = json['rules'];

    if (value is String) {
      for (final rule in CheckersRules.values) {
        if (rule.name == value) {
          return RulesConfig.forRules(rule);
        }
      }
    }

    return RulesConfig.forRules(
      CheckersRules.tanzania,
    );
  }

  // ============================================================
  // CONVENIENCE GETTERS
  // ============================================================

  /// True when this is an 8×8 ruleset.
  bool get isEightByEight {
    return boardSize == 8;
  }

  /// True when this is a 10×10 ruleset.
  bool get isTenByTen {
    return boardSize == 10;
  }

  /// True when this ruleset uses flying kings.
  bool get usesFlyingKings {
    return flyingKings;
  }

  /// True when ordinary men can capture backward.
  bool get usesBackwardCaptures {
    return menCanCaptureBackward;
  }

  /// True when captures are compulsory.
  bool get usesMandatoryCapture {
    return mandatoryCapture;
  }

  /// True when maximum capture selection is required.
  bool get usesMaximumCapture {
    return maximumCaptureRequired;
  }

  /// True when this is the East African ruleset.
  bool get isEastAfrican {
    return rules == CheckersRules.tanzania;
  }

  /// True when this is American Checkers.
  bool get isAmerican {
    return rules == CheckersRules.american;
  }

  /// True when this is International Draughts.
  bool get isInternational {
    return rules == CheckersRules.polish;
  }

  @override
  String toString() {
    return 'RulesConfig('
        'rules: ${rules.name}, '
        'displayName: $displayName, '
        'boardSize: $boardSize, '
        'startingPieces: $startingPieces, '
        'menCanCaptureBackward: $menCanCaptureBackward, '
        'flyingKings: $flyingKings, '
        'flyingKingCaptures: $flyingKingCaptures, '
        'mandatoryCapture: $mandatoryCapture, '
        'maximumCaptureRequired: $maximumCaptureRequired, '
        'promoteOnLastRow: $promoteOnLastRow, '
        'stopAfterPromotion: $stopAfterPromotion, '
        'continueAfterPromotion: $continueAfterPromotion, '
        'kingsMoveBackward: $kingsMoveBackward, '
        'turkishInitialPlacement: $turkishInitialPlacement'
        ')';
  }
}

