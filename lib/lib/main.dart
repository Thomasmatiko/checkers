import 'package:flutter/material.dart';

import 'screens/checkers_screen.dart';
import 'services/game_history_service.dart';
import 'services/game_settings.dart';
import 'services/game_statistics.dart';
import 'services/game_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = GameSettings();
  final statistics = GameStatistics();
  final storage = GameStorage();
  final historyService = GameHistoryService();

  await storage.initialize();

  await storage.loadSettings(settings);
  await storage.loadStatistics(statistics);

  runApp(
    DraftsApp(
      settings: settings,
      statistics: statistics,
      storage: storage,
      historyService: historyService,
    ),
  );
}

// ============================================================
// APP
// ============================================================

class DraftsApp extends StatelessWidget {
  final GameSettings settings;
  final GameStatistics statistics;
  final GameStorage storage;
  final GameHistoryService historyService;

  const DraftsApp({
    super.key,
    required this.settings,
    required this.statistics,
    required this.storage,
    required this.historyService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Drafts Game',
          themeMode: settings.themeMode,

          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE53935),
              brightness: Brightness.light,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor:
                const Color(0xFF0D1117),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE53935),
              brightness: Brightness.dark,
            ),
          ),

          home: HomeScreen(
            settings: settings,
            statistics: statistics,
            storage: storage,
            historyService: historyService,
          ),
        );
      },
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  final GameSettings settings;
  final GameStatistics statistics;
  final GameStorage storage;
  final GameHistoryService historyService;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.statistics,
    required this.storage,
    required this.historyService,
  });

  void _openCheckers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckersScreen(
          settings: settings,
          statistics: statistics,
          storage: storage,
          historyService: historyService,
        ),
      ),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String gameName,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$gameName is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius:
                          BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 20,
                          offset: Offset(0, 8),
                          color: Colors.black38,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.grid_4x4,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'DRAFTS',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Choose a game',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 35),

                  _GameChoiceCard(
                    icon: Icons.grid_4x4,
                    title: 'Checkers',
                    subtitle: 'Play now',
                    active: true,
                    onTap: () {
                      _openCheckers(context);
                    },
                  ),

                  const SizedBox(height: 14),

                  _GameChoiceCard(
                    icon: Icons.casino_outlined,
                    title: 'Ludo',
                    subtitle: 'Coming soon',
                    active: false,
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Ludo',
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  _GameChoiceCard(
                    icon: Icons.circle_outlined,
                    title: 'Bao',
                    subtitle: 'Coming soon',
                    active: false,
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Bao',
                      );
                    },
                  ),

                  const SizedBox(height: 35),

                  Text(
                    'More games will be added later',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GAME CHOICE CARD
// ============================================================

class _GameChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  const _GameChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          width: double.infinity,
          padding:
              const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: active
                ? colorScheme.primary.withValues(
                    alpha: 0.10,
                  )
                : colorScheme.onSurface.withValues(
                    alpha: 0.04,
                  ),
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? colorScheme.primary.withValues(
                      alpha: 0.45,
                    )
                  : colorScheme.onSurface.withValues(
                      alpha: 0.10,
                    ),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: active
                      ? colorScheme.primary
                      : colorScheme.onSurface
                          .withValues(
                          alpha: 0.08,
                        ),
                  borderRadius:
                      BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: active
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface
                          .withValues(
                          alpha: 0.45,
                        ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w800,
                        color: active
                            ? colorScheme.onSurface
                            : colorScheme.onSurface
                                .withValues(
                                alpha: 0.55,
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: active
                            ? colorScheme.primary
                            : colorScheme.onSurface
                                .withValues(
                                alpha: 0.4,
                              ),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                active
                    ? Icons.arrow_forward_ios
                    : Icons.lock_outline,
                size: 18,
                color: active
                    ? colorScheme.primary
                    : colorScheme.onSurface
                        .withValues(
                        alpha: 0.35,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}