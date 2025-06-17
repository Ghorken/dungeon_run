import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/trophies/trophy_provider.dart';
import 'package:dungeon_run/utils/enemies_provider.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/utils/special_attack_button.dart';
import 'package:dungeon_run/audio/audio_controller.dart';
import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/navigation/endless_runner.dart';

/// This widget defines the properties of the game screen.
///
/// It mostly sets up the overlays (widgets shown on top of the Flame game) and
/// the gets the [AudioController] from the context and passes it in to the
/// [EndlessRunner] class so that it can play audio.
class GameScreen extends StatelessWidget {
  static const String routeName = "/play";

  const GameScreen({
    required this.selectedCharacters,
    required this.level,
    super.key,
  });

  /// The keys for the back buttons
  static const String backButtonKey = 'back_buttton';

  /// The keys for the special attack buttons
  static const String leftSpecialAttackKey = 'left_special_attack_button';
  static const String frontSpecialAttackKey = 'front_special_attack_button';
  static const String rightSpecialAttackKey = 'right_special_attack_button';

  /// The keys for the win and loose dialogs
  static const String winDialogKey = 'win_dialog';
  static const String looseDialogKey = 'loose_dialog';

  /// The selected characters to show
  final List<CharacterType?> selectedCharacters;

  /// The level of the game
  final Level level;

  @override
  Widget build(BuildContext context) {
    final AudioController audioController = context.read<AudioController>();
    final UpgradeProvider upgradeProvider = context.read<UpgradeProvider>();
    final EnemiesProvider enemiesProvider = context.read<EnemiesProvider>();
    final LevelProvider levelProvider = context.read<LevelProvider>();
    final TrophyProvider trophyProvider = context.read<TrophyProvider>();
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      body: GameWidget<EndlessRunner>(
        key: const Key('play session'),
        game: EndlessRunner(
          audioController: audioController,
          selectedCharacters: selectedCharacters,
          level: level,
          upgradeProvider: upgradeProvider,
          enemiesProvider: enemiesProvider,
          levelProvider: levelProvider,
          trophyProvider: trophyProvider,
        ),
        overlayBuilderMap: {
          // The button the allows to quit the level
          backButtonKey: (BuildContext context, EndlessRunner game) {
            return Positioned(
              top: 20,
              right: 10,
              child: NesButton(
                type: NesButtonType.normal,
                onPressed: () {
                  // When pressed return to the home page
                  navigator.popUntil((route) {
                    return route.settings.name == null;
                  });
                },
                child: NesIcon(iconData: NesIcons.leftArrowIndicator),
              ),
            );
          },
          // The button that cause the special attack
          leftSpecialAttackKey: (BuildContext context, EndlessRunner game) {
            if (game.world.characters[0] != null) {
              final Character character = game.world.characters[0]!;

              return SpecialAttackButton(
                character: character,
                topPosition: 100,
              );
            }
            return const SizedBox.shrink();
          },
          frontSpecialAttackKey: (BuildContext context, EndlessRunner game) {
            if (game.world.characters[1] != null) {
              final Character character = game.world.characters[1]!;

              return SpecialAttackButton(
                character: character,
                topPosition: 180,
              );
            }
            return const SizedBox.shrink();
          },
          rightSpecialAttackKey: (BuildContext context, EndlessRunner game) {
            if (game.world.characters[2] != null) {
              final Character character = game.world.characters[2]!;

              return SpecialAttackButton(
                character: character,
                topPosition: 260,
              );
            }
            return const SizedBox.shrink();
          },
          // The win dialog of the level
          winDialogKey: (BuildContext context, EndlessRunner game) {
            return Center(
              child: NesContainer(
                width: 320,
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          level.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    NesButton(
                      onPressed: () {
                        navigator.popUntil((route) {
                          return route.settings.name == null;
                        });
                      },
                      type: NesButtonType.normal,
                      child: Text(Strings.ok),
                    ),
                  ],
                ),
              ),
            );
          },
          // The loose dialog of the level
          looseDialogKey: (BuildContext context, EndlessRunner game) {
            return Center(
              child: NesContainer(
                width: 320,
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Strings.sorry,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    NesButton(
                      onPressed: () {
                        navigator.popUntil((route) {
                          return route.settings.name == null;
                        });
                      },
                      type: NesButtonType.normal,
                      child: Text(Strings.ok),
                    ),
                  ],
                ),
              ),
            );
          },
        },
      ),
    );
  }
}
