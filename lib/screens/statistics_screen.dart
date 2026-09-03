
import 'package:flutter/material.dart';

import '../models/game_piece.dart';
import '../services/game_statistics.dart';

/// Full statistics screen for the Drafts / Checkers game.
class StatisticsScreen extends StatelessWidget {
  final GameStatistics statistics;

  const StatisticsScreen({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOverviewCard(),
              const SizedBox(height: 16),
              _buildResultsCard(),
              const SizedBox(height: 16),
              _buildGameplayCard(),
              const SizedBox(height: 16),
              _buildStreakCard(),
              const SizedBox(height: 16),
              _buildColorCard(),
              const SizedBox(height: 16),
              _buildPerformanceCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverviewCard() {
    return _card(
      title: 'GAME OVERVIEW',
      icon: Icons.insights_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statBox(
                  icon: Icons.sports_esports_outlined,
                  title: 'Games',
                  value: '${statistics.gamesPlayed}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(
                  icon: Icons.emoji_events_outlined,
                  title: 'Wins',
                  value: '${statistics.wins}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  icon: Icons.close_outlined,
                  title: 'Losses',
                  value: '${statistics.losses}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(
                  icon: Icons.handshake_outlined,
                  title: 'Draws',
                  value: '${statistics.draws}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULTS
  // ============================================================

  Widget _buildResultsCard() {
    return _card(
      title: 'RESULTS',
      icon: Icons.bar_chart_outlined,
      child: Column(
        children: [
          _statRow(
            'Win Rate',
            statistics.winRateText,
            Icons.trending_up,
          ),
          _divider(),
          _statRow(
            'Loss Rate',
            statistics.lossRateText,
            Icons.trending_down,
          ),
          _divider(),
          _statRow(
            'Draw Rate',
            statistics.drawRateText,
            Icons.horizontal_rule,
          ),
          _divider(),
          _statRow(
            'Win/Loss Ratio',
            statistics.winLossRatio.toStringAsFixed(2),
            Icons.balance_outlined,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GAMEPLAY
  // ============================================================

  Widget _buildGameplayCard() {
    return _card(
      title: 'GAMEPLAY',
      icon: Icons.grid_4x4,
      child: Column(
        children: [
          _statRow(
            'Total Moves',
            '${statistics.totalMoves}',
            Icons.swap_horiz,
          ),
          _divider(),
          _statRow(
            'Average Moves',
            statistics.averageMovesText,
            Icons.timeline,
          ),
          _divider(),
          _statRow(
            'Longest Game',
            '${statistics.longestGameMoves} moves',
            Icons.more_horiz,
          ),
          _divider(),
          _statRow(
            'Total Captures',
            '${statistics.totalCaptures}',
            Icons.remove_circle_outline,
          ),
          _divider(),
          _statRow(
            'Kings Created',
            '${statistics.kingsCreated}',
            Icons.workspace_premium_outlined,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STREAKS
  // ============================================================

  Widget _buildStreakCard() {
    return _card(
      title: 'STREAKS',
      icon: Icons.local_fire_department_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statBox(
                  icon: Icons.local_fire_department,
                  title: 'Current Wins',
                  value: '${statistics.currentWinStreak}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(
                  icon: Icons.emoji_events,
                  title: 'Best Wins',
                  value: '${statistics.bestWinStreak}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  icon: Icons.warning_amber_outlined,
                  title: 'Current Losses',
                  value: '${statistics.currentLossStreak}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(
                  icon: Icons.history,
                  title: 'Best Losses',
                  value: '${statistics.bestLossStreak}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLOR RESULTS
  // ============================================================

  Widget _buildColorCard() {
    return _card(
      title: 'BOARD RESULTS',
      icon: Icons.palette_outlined,
      child: Column(
        children: [
          _colorResult(
            color: PieceColor.red,
            title: 'Red Wins',
            value: statistics.redWins,
          ),
          const SizedBox(height: 12),
          _colorResult(
            color: PieceColor.black,
            title: 'Black Wins',
            value: statistics.blackWins,
          ),
        ],
      ),
    );
  }

  Widget _colorResult({
    required PieceColor color,
    required String title,
    required int value,
  }) {
    final isRed = color == PieceColor.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isRed
                    ? const [
                        Color(0xFFFF6B6B),
                        Color(0xFFC62828),
                      ]
                    : const [
                        Color(0xFFF5F5F5),
                        Color(0xFF555555),
                      ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFORMANCE
  // ============================================================

  Widget _buildPerformanceCard() {
    final games = statistics.gamesPlayed;

    final captureAverage = games == 0
        ? 0.0
        : statistics.totalCaptures / games;

    return _card(
      title: 'PERFORMANCE',
      icon: Icons.speed_outlined,
      child: Column(
        children: [
          _statRow(
            'Pieces Captured',
            '${statistics.piecesCapturedByPlayer}',
            Icons.ads_click,
          ),
          _divider(),
          _statRow(
            'Pieces Lost',
            '${statistics.piecesLostByPlayer}',
            Icons.remove_circle_outline,
          ),
          _divider(),
          _statRow(
            'Capture Average',
            captureAverage.toStringAsFixed(1),
            Icons.analytics_outlined,
          ),
          _divider(),
          _statRow(
            'Kings Created',
            '${statistics.kingsCreated}',
            Icons.workspace_premium,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF161B22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            offset: Offset(0, 6),
            color: Colors.black38,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // STAT BOX
  // ============================================================

  Widget _statBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 21,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT ROW
  // ============================================================

  Widget _statRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.white54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Divider(
        height: 1,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}

