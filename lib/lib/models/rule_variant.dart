
import 'checkers_rules.dart';

/// A selectable game rule variant.
///
/// This model connects the UI's rule selection to the complete
/// [RulesConfig] used by the game engine.
class RuleVariant {
  final CheckersRules rules;
  final RulesConfig config;

  const RuleVariant({
    required this.rules,
    required this.config,
  });

  /// Creates a variant from a ruleset.
  factory RuleVariant.fromRules(
    CheckersRules rules,
  ) {
    return RuleVariant(
      rules: rules,
      config: RulesConfig.forRules(rules),
    );
  }

  /// All supported rule variants.
  static List<RuleVariant> get all {
    return CheckersRules.values
        .map(RuleVariant.fromRules)
        .toList(growable: false);
  }

  /// The variant's display name.
  String get displayName => config.displayName;

  /// The variant's description.
  String get description => config.description;

  /// Board size for this variant.
  int get boardSize => config.boardSize;

  /// Starting pieces for this variant.
  int get startingPieces => config.startingPieces;

  /// Converts the variant to JSON.
  Map<String, dynamic> toJson() {
    return {
      'rules': rules.name,
    };
  }

  /// Creates a variant from JSON.
  factory RuleVariant.fromJson(
    Map<String, dynamic> json,
  ) {
    final config = RulesConfig.fromJson(json);

    return RuleVariant(
      rules: config.rules,
      config: config,
    );
  }

  @override
  String toString() {
    return 'RuleVariant('
        '${rules.name}, '
        '${config.displayName}'
        ')';
  }
}

