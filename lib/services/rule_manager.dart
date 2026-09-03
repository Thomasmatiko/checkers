import '../models/checkers_rules.dart';
import '../models/rule_variant.dart';

/// Central manager for the currently selected Checkers / Draughts
/// rule variant.
///
/// The UI works with [RuleVariant], while the engine can continue
/// using [CheckersRules] / [RulesConfig].
class RuleManager {
  // ============================================================
  // SINGLETON
  // ============================================================

  static final RuleManager instance = RuleManager._internal();

  RuleManager._internal();

  factory RuleManager() {
    return instance;
  }

  // ============================================================
  // CURRENT RULE
  // ============================================================

  CheckersRules _currentRules = CheckersRules.tanzania;

  /// Currently selected raw rules enum.
  CheckersRules get currentRules => _currentRules;

  /// Currently selected rule variant.
  RuleVariant get currentVariant {
    return RuleVariant.fromRules(_currentRules);
  }

  /// All rule variants available to the application.
  List<RuleVariant> get availableVariants {
    return RuleVariant.all;
  }

  /// Full configuration for the currently selected rules.
  RulesConfig get config {
    return RulesConfig.forRules(_currentRules);
  }

  // ============================================================
  // SET RULES
  // ============================================================

  /// Changes the current rules directly.
  ///
  /// Returns true if the selected rule actually changed.
  bool setRules(CheckersRules rules) {
    if (_currentRules == rules) {
      return false;
    }

    _currentRules = rules;
    return true;
  }

  // ============================================================
  // SET VARIANT
  // ============================================================

  /// Changes the current rule variant.
  ///
  /// This is the method used by CheckersScreen.
  ///
  /// Returns true if the selected variant actually changed.
  bool setVariant(RuleVariant variant) {
    return setRules(variant.rules);
  }

  // ============================================================
  // CONVENIENCE SETTERS
  // ============================================================

  void setTanzania() {
    _currentRules = CheckersRules.tanzania;
  }

  void setEnglish() {
    _currentRules = CheckersRules.english;
  }

  void setAmerican() {
    _currentRules = CheckersRules.american;
  }

  void setRussian() {
    _currentRules = CheckersRules.russian;
  }

  void setBrazilian() {
    _currentRules = CheckersRules.brazilian;
  }

  void setPolish() {
    _currentRules = CheckersRules.polish;
  }

  void setItalian() {
    _currentRules = CheckersRules.italian;
  }

  void setTurkish() {
    _currentRules = CheckersRules.turkish;
  }

  // ============================================================
  // INFORMATION
  // ============================================================

  String get displayName {
    return config.displayName;
  }

  String get description {
    return config.description;
  }

  int get boardSize {
    return config.boardSize;
  }

  int get startingPieces {
    return config.startingPieces;
  }

  bool get mandatoryCapture {
    return config.mandatoryCapture;
  }

  bool get maximumCaptureRequired {
    return config.maximumCaptureRequired;
  }

  bool get flyingKings {
    return config.flyingKings;
  }

  bool get flyingKingCaptures {
    return config.flyingKingCaptures;
  }

  bool get menCanCaptureBackward {
    return config.menCanCaptureBackward;
  }

  bool get continueAfterPromotion {
    return config.continueAfterPromotion;
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'currentRules': _currentRules.name,
    };
  }

  // ============================================================
  // LOAD JSON
  // ============================================================

  void fromJson(Map<String, dynamic> json) {
    final value = json['currentRules'];

    if (value is! String) {
      return;
    }

    for (final rules in CheckersRules.values) {
      if (rules.name == value) {
        _currentRules = rules;
        return;
      }
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _currentRules = CheckersRules.tanzania;
  }
}