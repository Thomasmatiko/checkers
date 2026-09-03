
import 'package:flutter_test/flutter_test.dart';

import 'package:drafts_game/main.dart';
import 'package:drafts_game/services/game_history_service.dart';
import 'package:drafts_game/services/game_settings.dart';
import 'package:drafts_game/services/game_statistics.dart';
import 'package:drafts_game/services/game_storage.dart';

void main() {
  testWidgets(
    'Drafts Game loads',
    (WidgetTester tester) async {
      final settings = GameSettings();
      final statistics = GameStatistics();
      final storage = GameStorage();
      final historyService = GameHistoryService();

      await tester.pumpWidget(
        DraftsApp(
          settings: settings,
          statistics: statistics,
          storage: storage,
          historyService: historyService,
        ),
      );

      expect(
        find.text('DRAFTS'),
        findsWidgets,
      );
    },
  );
}
