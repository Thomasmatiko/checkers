
import '../models/checkers_rules.dart';

/// Central registry for all supported Checkers / Draughts rules.
///
/// The registry provides one place for the application to:
///
/// - list available rules
/// - find a ruleset
/// - get a configuration
/// - convert rules to/from JSON
/// - validate a selected ruleset
class RulesRegistry {
  RulesRegistry._();

  /// Returns every supported rules configuration.
  static List<RulesConfig> get all {
    return RulesConfig.all;
  }

  /// Default rules used when the application starts.
  static RulesConfig get defaultRules {
    return RulesConfig.forRules(
      CheckersRules.tanzania,
    );
  }

  /// Finds a configuration by enum.
  static RulesConfig get(
    CheckersRules rules,
  ) {
    return RulesConfig.forRules(rules);
  }

  /// Finds a ruleset by its enum name.
  ///
  /// Returns null if the name is not recognized.
  static RulesConfig? findByName(
    String name,
  ) {
    for (final rules in CheckersRules.values) {
      if (rules.name == name) {
        return RulesConfig.forRules(rules);
      }
    }

    return null;
  }

  /// Returns true when [rules] is supported.
  static bool supports(
    CheckersRules rules,
  ) {
    return CheckersRules.values.contains(rules);
  }

  /// Converts a ruleset to JSON.
  static Map<String, dynamic> toJson(
    CheckersRules rules,
  ) {
    return {
      'rules': rules.name,
    };
  }

  /// Reads a ruleset from JSON.
  ///
  /// Tanzania is used as the safe fallback.
  static CheckersRules fromJson(
    Map<String, dynamic> json,
  ) {
    final value = json['rules'];

    if (value is String) {
      for (final rules in CheckersRules.values) {
        if (rules.name == value) {
          return rules;
        }
      }
    }

    return CheckersRules.tanzania;
  }

  /// Finds a configuration from JSON.
  static RulesConfig configFromJson(
    Map<String, dynamic> json,
  ) {
    return RulesConfig.forRules(
      fromJson(json),
    );
  }

  /// Returns display names for all rules.
  static List<String> get displayNames {
    return all
        .map((config) => config.displayName)
        .toList(growable: false);
  }

  /// Returns a compact summary of all supported rules.
  static List<Map<String, dynamic>> summary() {
    return all.map((config) {
      return {
        'rules': config.rules.name,
        'displayName': config.displayName,
        'boardSize': config.boardSize,
        'startingPieces': config.startingPieces,
        'flyingKings': config.flyingKings,
        'backwardCaptures':
            config.menCanCaptureBackward,
        'mandatoryCapture':
            config.mandatoryCapture,
        'maximumCapture':
            config.maximumCaptureRequired,
      };
    }).toList(growable: false);
  }
}
