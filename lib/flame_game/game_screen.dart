import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import 'package:dungeon_run/audio/audio_controller.dart';
import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/endless_runner.dart';

/// This widget defines the properties of the game screen.
///
/// It mostly sets up the overlays (widgets shown on top of the Flame game) and
/// the gets the [AudioController] from the context and passes it in to the
/// [EndlessRunner] class so that it can play audio.
class GameScreen extends StatelessWidget {
  const GameScreen({
    required this.selectedCharacters,
    super.key,
  });

  static const String backButtonKey = 'back_buttton';
  static const String winDialogKey = 'win_dialog';
  static const String looseDialogKey = 'loose_dialog';
  final List<CharacterType?> selectedCharacters;

  @override
  Widget build(BuildContext context) {
    final audioController = context.read<AudioController>();
    return Scaffold(
      body: GameWidget<EndlessRunner>(
        key: const Key('play session'),
        game: EndlessRunner(
          audioController: audioController,
          selectedCharacters: selectedCharacters,
        ),
        overlayBuilderMap: {
          // The button the allows to quit the level
          backButtonKey: (BuildContext context, EndlessRunner game) {
            return Positioned(
              top: 20,
              right: 10,
              child: NesButton(
                type: NesButtonType.normal,
                onPressed: GoRouter.of(context).pop,
                child: NesIcon(iconData: NesIcons.leftArrowIndicator),
              ),
            );
          },
          // The win dialog of the level
          winDialogKey: (BuildContext context, EndlessRunner game) {
            return Center(
              child: NesContainer(
                width: 320,
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bravo! Hai sconfitto il re goblin!',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    NesButton(
                      onPressed: () {
                        GoRouter.of(context).go('/');
                      },
                      type: NesButtonType.normal,
                      child: const Text('Ok'),
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
                      'Peccato, sei stato sconfitto!',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    NesButton(
                      onPressed: () {
                        GoRouter.of(context).go('/');
                      },
                      type: NesButtonType.normal,
                      child: const Text('Ok'),
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
