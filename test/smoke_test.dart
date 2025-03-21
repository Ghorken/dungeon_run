import 'package:dungeon_run/app_lifecycle/app_lifecycle.dart';
import 'package:dungeon_run/audio/audio_controller.dart';
import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/endless_runner.dart';
import 'package:dungeon_run/flame_game/game_screen.dart';
import 'package:dungeon_run/main.dart';
import 'package:dungeon_run/settings/settings.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test menus', (tester) async {
    // Build our game and trigger a frame.
    await tester.pumpWidget(const DungeonRun());

    // Verify that the 'Play' button is shown.
    expect(find.text('Play'), findsOneWidget);

    // Verify that the 'Settings' button is shown.
    expect(find.text('Settings'), findsOneWidget);

    // Go to 'Settings'.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Music'), findsOneWidget);

    // Go back to main menu.
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    // Tap 'Play'.
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.pump();
  });

  testWithGame(
    'smoke test flame game',
    () {
      return EndlessRunner(
        level: (
          number: 1,
        ),
        audioController: _MockAudioController(),
      );
    },
    (game) async {
      game.overlays.addEntry(
        GameScreen.backButtonKey,
        (context, game) => Container(),
      );
      await game.onLoad();
      game.update(0);
      expect(game.children.length, 3);
      expect(game.world.children.length, 2);
      expect(game.camera.viewport.children.length, 2);
      expect(game.world.frontCharacter.isLoading, isTrue);
    },
  );
}

class _MockAudioController implements AudioController {
  @override
  void attachDependencies(AppLifecycleStateNotifier lifecycleNotifier, SettingsController settingsController) {}

  @override
  void dispose() {}

  @override
  void playSfx(SfxType type) {}
}
