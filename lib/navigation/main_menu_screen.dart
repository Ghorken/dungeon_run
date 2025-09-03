import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/trophies/trophy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:dungeon_run/audio/audio_controller.dart';
import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:rive/rive.dart';

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
  Artboard? _artboard;
  late NavigatorState _navigator;
  late AudioController _audioController;

  @override
  void initState() {
    super.initState();
    // Call loadFromMemory when the screen is initialized
    Provider.of<UpgradeProvider>(context, listen: false).loadFromMemory();
    Provider.of<LevelProvider>(context, listen: false).loadFromMemory();
    Provider.of<TrophyProvider>(context, listen: false).loadFromMemory();
    RiveFile.initialize();
    _loadRiveFile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _navigator = Navigator.of(context);
    _audioController = context.read<AudioController>();
  }

  Future<void> _loadRiveFile() async {
    final ByteData data = await rootBundle.load('assets/animations/home.riv');
    final RiveFile file = RiveFile.import(data);
    final Artboard artboard = file.mainArtboard;

    final StateMachineController? artboardController = StateMachineController.fromArtboard(
      artboard,
      'Home',
      onStateChange: (String stateMachineName, String stateName) {
        switch (stateName) {
          case 'Bottone entra':
            // If the enter button is pressed, go to the store
            Future.delayed(const Duration(seconds: 1), () {
              _play();
            });
            break;
          case 'Bottone impostazioni':
            // If the settings button is pressed, go to the settings screen
            _audioController.playSfx(SfxType.buttonTap);
            Future.delayed(const Duration(milliseconds: 200), () {
              _navigator.pushNamed('/settings');
            });
            break;
          case 'Bottone negozio':
            // If the exit button is pressed, exit the game
            _audioController.playSfx(SfxType.buttonTap);
            Future.delayed(const Duration(milliseconds: 200), () {
              _navigator.pushNamed('/store');
            });
            break;
          case 'Bottone trofei':
            // If the trophies button is pressed, go to the trophies room
            _audioController.playSfx(SfxType.buttonTap);
            Future.delayed(const Duration(milliseconds: 200), () {
              _navigator.pushNamed('/trophies');
            });
            break;
          case 'Bottone luka':
            // If the trophies button is pressed, go to the trophies room
            _audioController.playSfx(SfxType.buttonTap);
            Future.delayed(const Duration(milliseconds: 200), () {
              _navigator.pushNamed('/luka');
            });
            break;
        }
      },
    );

    if (artboardController != null) {
      artboard.addController(artboardController);
    }

    setState(() => _artboard = artboard);
  }

  void _play() {
    final List<Upgrade> upgrades = Provider.of<UpgradeProvider>(context, listen: false).upgrades;
    final List<Level> levels = Provider.of<LevelProvider>(context, listen: false).levels;

    int unlockedCharacters = upgrades.where((Upgrade entry) => entry.characterType != null && entry.unlocked == true).length;

    // If there are more than one characters unlocked go to the selection screen
    if (unlockedCharacters > 1) {
      _navigator.pushNamed('/selectCharacters');
    } else {
      // If there are no characters unlocked prepare the party with only the [Warrior]
      final List<CharacterType?> selectedCharacters = List<CharacterType?>.filled(3, null);
      selectedCharacters[1] = CharacterType.warrior;
      if (levels.first.completed == true) {
        // If the first level is completed go to the level selection screen
        Map<String, dynamic> extra = {
          'selectedCharacters': selectedCharacters,
        };
        _navigator.pushNamed('/selectLevel', arguments: extra);
      } else {
        // If the first level is not completed go to game screen
        Map<String, dynamic> extra = {
          'selectedCharacters': selectedCharacters,
          'level': levels.first,
        };
        _navigator.pushNamed('/loading', arguments: extra);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: Center(
        // child: InteractiveViewer(
        child: _artboard == null
            ? const CircularProgressIndicator()
            : Rive(
                artboard: _artboard!,
                enablePointerEvents: true,
                fit: BoxFit.fill, // Distorce ma riempie tutto lo schermo
                // fit: BoxFit.contain, // Mantiene le proporzioni ma non riempie tutto lo schermo
                // fit: BoxFit.cover, // Mantiene le proporzioni e riempie tutto lo schermo, ma alcune parti possono essere tagliate
              ),
      ),
      // ),
    );
  }
}
