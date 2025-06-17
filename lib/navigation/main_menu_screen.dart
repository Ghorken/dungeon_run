import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/trophies/trophy_provider.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dungeon_run/audio/audio_controller.dart';
import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/settings/settings_controller.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/navigation/responsive_screen.dart';
import 'package:dungeon_run/utils/wobbly_button.dart';

/// The class that defines the main page of the game
class MainMenuScreen extends StatefulWidget {
  static const String routeName = "/mainMenu";

  const MainMenuScreen({
    super.key,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  /// The gap between elements
  static const _gap = SizedBox(height: 10);

  @override
  void initState() {
    super.initState();
    // Call loadFromMemory when the screen is initialized
    Provider.of<UpgradeProvider>(context, listen: false).loadFromMemory();
    Provider.of<LevelProvider>(context, listen: false).loadFromMemory();
    Provider.of<TrophyProvider>(context, listen: false).loadFromMemory();
  }

  @override
  Widget build(BuildContext context) {
    final List<Upgrade> upgrades = Provider.of<UpgradeProvider>(context).upgrades;
    final List<Level> levels = Provider.of<LevelProvider>(context).levels;
    final SettingsController settingsController = context.watch<SettingsController>();
    final AudioController audioController = context.watch<AudioController>();
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: ResponsiveScreen(
        squarishMainArea: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The main image
              Image.asset(
                'assets/images/dungeon_door.png',
                filterQuality: FilterQuality.none,
              ),
              _gap,
              // The title of the game
              Transform.rotate(
                angle: -0.1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Text(
                    Strings.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Press Start 2P',
                      fontSize: 32,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        rectangularMenuArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WobblyButton(
              onPressed: () {
                int unlockedCharacters = upgrades.where((Upgrade entry) => entry.characterType != null && entry.unlocked == true).length;

                // If there are more than one characters unlocked go to the selection screen
                if (unlockedCharacters > 1) {
                  navigator.pushNamed('/selectCharacters');
                } else {
                  // If there are no characters unlocked prepare the party with only the [Warrior]
                  final List<CharacterType?> selectedCharacters = List<CharacterType?>.filled(3, null);
                  selectedCharacters[1] = CharacterType.warrior;
                  if (levels.first.completed == true) {
                    // If the first level is completed go to the level selection screen
                    Map<String, dynamic> extra = {
                      'selectedCharacters': selectedCharacters,
                    };
                    navigator.pushNamed('/selectLevel', arguments: extra);
                  } else {
                    // If the first level is not completed go to game screen
                    Map<String, dynamic> extra = {
                      'selectedCharacters': selectedCharacters,
                      'level': levels.first,
                    };
                    navigator.pushNamed('/play', arguments: extra);
                  }
                }
              },
              child: Text(Strings.play),
            ),
            _gap,
            if (levels.isNotEmpty && levels.first.completed == true)
              WobblyButton(
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  navigator.pushNamed('/store');
                },
                child: Text(Strings.store),
              ),
            _gap,
            if (levels.isNotEmpty && levels.first.completed == true)
              WobblyButton(
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  navigator.pushNamed('/trophies');
                },
                child: Text(Strings.trophiesRoom),
              ),
            _gap,
            WobblyButton(
              onPressed: () {
                audioController.playSfx(SfxType.buttonTap);
                navigator.pushNamed('/settings');
              },
              child: Text(Strings.settings),
            ),
            _gap,
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: ValueListenableBuilder<bool>(
                valueListenable: settingsController.audioOn,
                builder: (context, audioOn, child) {
                  return IconButton(
                    onPressed: () => settingsController.toggleAudioOn(),
                    icon: Icon(audioOn ? Icons.volume_up : Icons.volume_off),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
