
import 'package:flutter/material.dart';

/// Main home screen for the Drafts Game app.
///
/// Checkers is playable now.
/// Ludo and Bao are displayed as upcoming games.
class HomeScreen extends StatelessWidget {
  final VoidCallback onPlayCheckers;
  final VoidCallback? onPlayLudo;
  final VoidCallback? onPlayBao;
  final VoidCallback? onStatistics;
  final VoidCallback? onSettings;
  final VoidCallback? onHowToPlay;

  const HomeScreen({
    super.key,
    required this.onPlayCheckers,
    this.onPlayLudo,
    this.onPlayBao,
    this.onStatistics,
    this.onSettings,
    this.onHowToPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            _AppLogo(),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DRAFTS GAME',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Board games in one app',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (onStatistics != null)
            IconButton(
              tooltip: 'Statistics',
              onPressed: onStatistics,
              icon: const Icon(Icons.bar_chart_rounded),
            ),
          if (onSettings != null)
            IconButton(
              tooltip: 'Settings',
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth >= 900 ? 48.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeCard(context),
                      const SizedBox(height: 26),
                      _buildSectionTitle(
                        context,
                        'Choose a game',
                        'Select a board game to start playing.',
                      ),
                      const SizedBox(height: 14),
                      _buildGameCards(
                        context,
                        constraints.maxWidth,
                      ),
                      const SizedBox(height: 28),
                      _buildQuickInfo(context),
                      const SizedBox(height: 28),
                      _buildFeatures(context),
                      const SizedBox(height: 28),
                      _buildHowToPlayCard(context),
                      const SizedBox(height: 28),
                      _buildBottomInfo(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcomeCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.primaryContainer,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 25,
            offset: Offset(0, 10),
            color: Colors.black26,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Drafts Game',
                style: TextStyle(
                  fontSize: compact ? 25 : 32,
                  fontWeight: FontWeight.w900,
                  color: scheme.onPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Play classic board games with friends, '
                'family, or against the computer.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onPlayCheckers,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'PLAY CHECKERS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _WelcomeBoardPreview(),
                const SizedBox(height: 20),
                text,
              ],
            );
          }

          return Row(
            children: [
              const Expanded(
                flex: 2,
                child: _WelcomeBoardPreview(),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 3,
                child: text,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // GAME CARDS
  // ============================================================

  Widget _buildGameCards(
    BuildContext context,
    double availableWidth,
  ) {
    final horizontal = availableWidth >= 800;

    final cards = [
      _buildGameCard(
        context: context,
        title: 'Checkers',
        subtitle: 'Play now',
        description:
            'Classic checkers with AI, two-player mode, '
            'statistics, history, challenges and more.',
        icon: Icons.grid_4x4_rounded,
        active: true,
        onTap: onPlayCheckers,
        preview: const _CheckersPreview(),
      ),
      _buildGameCard(
        context: context,
        title: 'Ludo',
        subtitle: 'Coming soon',
        description:
            'A fun multiplayer board game for friends '
            'and family.',
        icon: Icons.casino_rounded,
        active: false,
        onTap: onPlayLudo,
        preview: const _LudoPreview(),
      ),
      _buildGameCard(
        context: context,
        title: 'Bao',
        subtitle: 'Coming soon',
        description:
            'Experience the traditional East African '
            'strategy board game.',
        icon: Icons.circle_outlined,
        active: false,
        onTap: onPlayBao,
        preview: const _BaoPreview(),
      ),
    ];

    if (horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 14),
          Expanded(child: cards[1]),
          const SizedBox(width: 14),
          Expanded(child: cards[2]),
        ],
      );
    }

    return Column(
      children: [
        cards[0],
        const SizedBox(height: 14),
        cards[1],
        const SizedBox(height: 14),
        cards[2],
      ],
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required bool active,
    required VoidCallback? onTap,
    required Widget preview,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: active ? 5 : 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: active ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 150,
                child: preview,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: active
                          ? scheme.primary.withValues(alpha: 0.12)
                          : scheme.onSurface.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: active
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: active
                                ? scheme.primary
                                : scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (active)
                    const Icon(Icons.arrow_forward_rounded)
                  else
                    Icon(
                      Icons.lock_outline_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),

SizedBox(
  width: double.infinity,
  child: active
      ? FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('PLAY NOW'),
        )
      : OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.schedule_rounded),
          label: const Text('COMING SOON'),
        ),
),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUICK INFO
  // ============================================================

  Widget _buildQuickInfo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;

          const items = [
            _InfoItem(
              icon: Icons.people_alt_outlined,
              title: '2 Players',
              text: 'Play against another person.',
            ),
            _InfoItem(
              icon: Icons.smart_toy_outlined,
              title: 'Play AI',
              text: 'Challenge the computer.',
            ),
            _InfoItem(
              icon: Icons.phone_android_outlined,
              title: 'Your Phone',
              text: 'Designed for Android devices.',
            ),
          ];

          if (compact) {
            return Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i != items.length - 1)
                    const Divider(height: 28),
                ],
              ],
            );
          }

          return Row(
  children: [
    Expanded(child: items[0]),
    const SizedBox(width: 12),
    Expanded(child: items[1]),
    const SizedBox(width: 12),
    Expanded(child: items[2]),
  ],
);
        },
      ),
    );
  }

  // ============================================================
  // FEATURES
  // ============================================================

  Widget _buildFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          'What you can do',
          'More than just a board.',
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FeatureChip(
              icon: Icons.psychology_outlined,
              text: 'AI difficulty levels',
            ),
            _FeatureChip(
              icon: Icons.people_outline,
              text: 'Two-player mode',
            ),
            _FeatureChip(
              icon: Icons.emoji_events_outlined,
              text: 'Statistics',
            ),
            _FeatureChip(
              icon: Icons.history,
              text: 'Game history',
            ),
            _FeatureChip(
              icon: Icons.extension_outlined,
              text: 'Challenges',
            ),
            _FeatureChip(
              icon: Icons.save_outlined,
              text: 'Save & load',
            ),
            _FeatureChip(
              icon: Icons.volume_up_outlined,
              text: 'Sound effects',
            ),
            _FeatureChip(
              icon: Icons.palette_outlined,
              text: 'Board themes',
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // HOW TO PLAY
  // ============================================================

  Widget _buildHowToPlayCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: scheme.primary,
                ),
                const SizedBox(width: 10),
                const Text(
                  'New to Checkers?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose Checkers, select your piece, and tap a '
              'highlighted legal destination. Captures are '
              'mandatory when available.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onHowToPlay,
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('HOW TO PLAY'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM INFO
  // ============================================================

  Widget _buildBottomInfo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          Icons.sports_esports_outlined,
          size: 34,
          color: scheme.primary,
        ),
        const SizedBox(height: 10),
        const Text(
          'More games are coming',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Checkers is ready now. Ludo and Bao will be '
          'added to the same app later.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// APP LOGO
// ============================================================

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: scheme.primary,
      ),
      child: const Icon(
        Icons.grid_4x4_rounded,
        color: Colors.white,
      ),
    );
  }
}

// ============================================================
// WELCOME BOARD PREVIEW
// ============================================================

class _WelcomeBoardPreview extends StatelessWidget {
  const _WelcomeBoardPreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 230,
          maxHeight: 230,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 20,
              offset: Offset(0, 8),
              color: Colors.black38,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            final dark = (row + col).isOdd;

            return Container(
              color: dark
                  ? const Color(0xFF70452B)
                  : const Color(0xFFE8D0A9),
              child: _previewPiece(row, col),
            );
          },
        ),
      ),
    );
  }

  Widget _previewPiece(int row, int col) {
    const redPieces = {
      '6-1',
      '6-3',
      '6-5',
      '6-7',
      '7-0',
      '7-2',
      '7-4',
      '7-6',
    };

    const blackPieces = {
      '0-1',
      '0-3',
      '0-5',
      '0-7',
      '1-0',
      '1-2',
      '1-4',
      '1-6',
      '2-1',
      '2-3',
      '2-5',
      '2-7',
    };

    final key = '$row-$col';

    if (!redPieces.contains(key) &&
        !blackPieces.contains(key)) {
      return const SizedBox.shrink();
    }

    final red = redPieces.contains(key);

    return Center(
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: red
                ? const [
                    Color(0xFFFF6B6B),
                    Color(0xFFC62828),
                  ]
                : const [
                    Color(0xFFF5F5F5),
                    Color(0xFF303030),
                  ],
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              offset: Offset(0, 2),
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CHECKERS PREVIEW
// ============================================================

class _CheckersPreview extends StatelessWidget {
  const _CheckersPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF6E452B),
      ),
      padding: const EdgeInsets.all(6),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (context, index) {
          final row = index ~/ 8;
          final col = index % 8;
          final dark = (row + col).isOdd;

          return Container(
            color: dark
                ? const Color(0xFF70452B)
                : const Color(0xFFE8D0A9),
            child: _smallPiece(index),
          );
        },
      ),
    );
  }

  Widget _smallPiece(int index) {
    final row = index ~/ 8;
    final col = index % 8;

    if ((row == 0 || row == 1) &&
        (row + col).isOdd) {
      return const Center(
        child: _PreviewPiece(red: false),
      );
    }

    if (row == 2 &&
        (row + col).isOdd &&
        col != 3 &&
        col != 5) {
      return const Center(
        child: _PreviewPiece(red: false),
      );
    }

    if ((row == 5 || row == 6) &&
        (row + col).isOdd) {
      return const Center(
        child: _PreviewPiece(red: true),
      );
    }

    if (row == 7 &&
        (row + col).isOdd &&
        col != 0 &&
        col != 6) {
      return const Center(
        child: _PreviewPiece(red: true),
      );
    }

    return const SizedBox.shrink();
  }
}

// ============================================================
// LUDO PREVIEW
// ============================================================

class _LudoPreview extends StatelessWidget {
  const _LudoPreview();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: scheme.surfaceContainerHighest,
      ),
      child: CustomPaint(
        painter: _LudoPainter(),
        child: const Center(
          child: Icon(
            Icons.casino_rounded,
            size: 46,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BAO PREVIEW
// ============================================================

class _BaoPreview extends StatelessWidget {
  const _BaoPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF8A6239),
      ),
      padding: const EdgeInsets.all(12),
      child: const Row(
        children: [
          Expanded(child: _BaoRow()),
          SizedBox(width: 6),
          Expanded(child: _BaoRow()),
        ],
      ),
    );
  }
}

class _BaoRow extends StatelessWidget {
  const _BaoRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => Container(
          width: 13,
          height: 13,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF3E2723),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PREVIEW PIECE
// ============================================================

class _PreviewPiece extends StatelessWidget {
  final bool red;

  const _PreviewPiece({
    required this.red,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: red
              ? const [
                  Color(0xFFFF6B6B),
                  Color(0xFFC62828),
                ]
              : const [
                  Color(0xFFF5F5F5),
                  Color(0xFF303030),
                ],
        ),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
    );
  }
}

// ============================================================
// INFO ITEM
// ============================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// FEATURE CHIP
// ============================================================

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 19,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LUDO PAINTER
// ============================================================

class _LudoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;

    paint.color = const Color(0xFFE53935);
    canvas.drawRect(
      Rect.fromLTWH(
        12,
        12,
        width * 0.28,
        height * 0.35,
      ),
      paint,
    );

    paint.color = const Color(0xFF43A047);
    canvas.drawRect(
      Rect.fromLTWH(
        width * 0.70,
        12,
        width * 0.28,
        height * 0.35,
      ),
      paint,
    );

    paint.color = const Color(0xFF1E88E5);
    canvas.drawRect(
      Rect.fromLTWH(
        12,
        height * 0.63,
        width * 0.28,
        height * 0.35,
      ),
      paint,
    );

    paint.color = const Color(0xFFFDD835);
    canvas.drawRect(
      Rect.fromLTWH(
        width * 0.70,
        height * 0.63,
        width * 0.28,
        height * 0.35,
      ),
      paint,
    );

    paint.color = Colors.white;

    canvas.drawCircle(
      Offset(width * 0.25, height * 0.28),
      10,
      paint,
    );

    canvas.drawCircle(
      Offset(width * 0.75, height * 0.28),
      10,
      paint,
    );

    canvas.drawCircle(
      Offset(width * 0.25, height * 0.75),
      10,
      paint,
    );

    canvas.drawCircle(
      Offset(width * 0.75, height * 0.75),
      10,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
