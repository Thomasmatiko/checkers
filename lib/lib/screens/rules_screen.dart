
import 'package:flutter/material.dart';

import '../models/checkers_rules.dart';
import '../services/rule_manager.dart';

/// Simple screen for selecting the Drafts / Checkers rules.
class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final RuleManager _ruleManager = RuleManager();

  late CheckersRules _selectedRules;

  @override
  void initState() {
    super.initState();

    // Tanzania is the default rule.
    _selectedRules = _ruleManager.currentRules;
  }

  // ============================================================
  // RULE INFORMATION
  // ============================================================

  String _ruleName(CheckersRules rules) {
    switch (rules) {
      case CheckersRules.tanzania:
        return 'Tanzania';

      case CheckersRules.english:
        return 'International';

      case CheckersRules.american:
        return 'American';

      case CheckersRules.russian:
        return 'Russian';

      case CheckersRules.brazilian:
        return 'Brazilian';

      case CheckersRules.polish:
        return 'Polish';

      case CheckersRules.italian:
        return 'Italian';

      case CheckersRules.turkish:
        return 'Turkish';
    }
  }

  String _ruleIcon(CheckersRules rules) {
    switch (rules) {
      case CheckersRules.tanzania:
        return '🇹🇿';

      case CheckersRules.english:
        return '🌍';

      case CheckersRules.american:
        return '🇺🇸';

      case CheckersRules.russian:
        return '🇷🇺';

      case CheckersRules.brazilian:
        return '🇧🇷';

      case CheckersRules.polish:
        return '🇵🇱';

      case CheckersRules.italian:
        return '🇮🇹';

      case CheckersRules.turkish:
        return '🇹🇷';
    }
  }

  // ============================================================
  // SELECT RULE
  // ============================================================

  void _selectRule(CheckersRules rules) {
    if (_selectedRules == rules) {
      return;
    }

    setState(() {
      _selectedRules = rules;
    });

    _ruleManager.setRules(rules);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

  const rules = CheckersRules.values;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rules',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rules.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          final rule = rules[index];

          return _buildRuleTile(rule);
        },
      ),
    );
  }

  // ============================================================
  // RULE TILE
  // ============================================================

  Widget _buildRuleTile(CheckersRules rules) {
    final selected = _selectedRules == rules;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _selectRule(rules);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12)
                : Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // FLAG / ICON
              SizedBox(
                width: 45,
                child: Text(
                  _ruleIcon(rules),
                  style: const TextStyle(
                    fontSize: 27,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // RULE NAME
              Expanded(
                child: Text(
                  _ruleName(rules),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // SELECTED CHECKMARK
              AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 180,
                ),
                child: selected
                    ? Icon(
                        Icons.check_circle,
                        key: const ValueKey('selected'),
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        size: 25,
                      )
                    : const SizedBox(
                        key: ValueKey('unselected'),
                        width: 25,
                        height: 25,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

