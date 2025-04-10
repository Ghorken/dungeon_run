import 'package:dungeon_run/app_lifecycle/app_lifecycle.dart';
import 'package:dungeon_run/audio/audio_controller.dart';
import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/endless_runner.dart';
import 'package:dungeon_run/flame_game/game_screen.dart';
import 'package:dungeon_run/main.dart';
import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/settings/settings_controller.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<Upgrade> upgrades;

  Future<List<Upgrade>> loadUpgrades() async {
    final List<Upgrade> recoveredUpgrades = await Persistence().getUpgrades();
    return recoveredUpgrades;
  }

  testWidgets('smoke test menus', (tester) async {
    upgrades = await loadUpgrades();

    // Build our game and trigger a frame.
    await tester.pumpWidget(const DungeonRun());

    // Verify that the 'Play' button is shown.
    expect(find.text('Gioca'), findsOneWidget);

    // Verify that the 'Settings' button is shown.
    expect(find.text('Impostazioni'), findsOneWidget);

    // Go to 'Settings'.
    await tester.tap(find.text('Impostazioni'));
    await tester.pumpAndSettle();
    expect(find.text('Musica'), findsOneWidget);

    // Go back to main menu.
    await tester.tap(find.text('Indietro'));
    await tester.pumpAndSettle();

    // Tap 'Play'.
    await tester.tap(find.text('Gioca'));
    await tester.pumpAndSettle();

    // Tap 'Play'.
    await tester.tap(find.text('Gioca'));
    await tester.pumpAndSettle();

    await tester.pump();
  });

  testWithGame(
    'smoke test flame game',
    () {
      return EndlessRunner(
        audioController: _MockAudioController(),
        selectedCharacters: [
          CharacterType.warrior,
          CharacterType.mage,
          CharacterType.archer
        ],
        upgrades: upgrades,
      );
    },
    (game) async {
      game.overlays.addEntry(
        GameScreen.backButtonKey,
        (context, game) => Container(),
      );
      await game.onLoad();
      game.update(0);
      // expect(game.children.length, 3);
      // expect(game.world.children.length, 2);
      // expect(game.camera.viewport.children.length, 2);
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
