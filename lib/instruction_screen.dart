import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/style/wobbly_button.dart';

/// The page to display the game instructions
class InstructionScreen extends StatefulWidget {
  const InstructionScreen({
    super.key,
  });

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  /// The gap between elements
  static const _gap = SizedBox(height: 60);

  /// The container of the local saved data
  final Persistence _persistence = Persistence();

  /// The map to store recovered upgrades
  List<Upgrade> _upgrades = [];

  /// The unlocked characeters
  List<CharacterType> _unlockedCharacters = [];

  /// The progression of the player
  List<Level> _levels = [];

  @override
  void initState() {
    super.initState();
    _loadFromMemory();
  }

  /// Recover the buyed upgrades and the progression of the player
  Future<void> _loadFromMemory() async {
    final List<Upgrade> recoveredUpgrades = await _persistence.getUpgrades();
    final List<Level> recoveredLevels = await _persistence.getLevels();
    setState(() {
      _upgrades = recoveredUpgrades;
      _levels = recoveredLevels;
    });
    _retrieveUnlockedCharacters();
  }

  /// Recover the unlocked Characters
  Future<void> _retrieveUnlockedCharacters() async {
    _unlockedCharacters = _upgrades.where((Upgrade entry) => entry.characterType != null && entry.unlocked == true).map((Upgrade entry) => entry.characterType!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: ListView(
                  children: [
                    _gap,
                    Text(
                      Strings.instructions,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 30,
                        height: 1,
                      ),
                    ),
                    _gap,
                    Text(
                      Strings.instructionsText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WobblyButton(
              onPressed: () {
                // If there are more than one characters unlocked go to the selection screen
                if (_unlockedCharacters.length > 1) {
                  Map<String, dynamic> extra = {
                    'upgrades': _upgrades,
                    'unlockedCharacters': _unlockedCharacters,
                    'levels': _levels,
                  };
                  GoRouter.of(context).go('/selectCharacters', extra: extra);
                } else {
                  // If there are no characters unlocked
                  final List<CharacterType?> selectedCharacters = List<CharacterType?>.filled(3, null);
                  selectedCharacters[1] = CharacterType.warrior;
                  if (_levels.first.completed == true) {
                    // If the first level is completed go to the level selection screen
                    Map<String, dynamic> extra = {
                      'upgrades': _upgrades,
                      'selectedCharacters': selectedCharacters,
                      'levels': _levels,
                    };
                    GoRouter.of(context).go('/selectLevel', extra: extra);
                  } else {
                    // If the first level is not completed prepare the party with only the [Warrior] and go to game screen

                    Map<String, dynamic> extra = {
                      'upgrades': _upgrades,
                      'selectedCharacters': selectedCharacters,
                      'level': _levels.first,
                    };
                    GoRouter.of(context).go('/play', extra: extra);
                  }
                }
              },
              child: Text(Strings.play),
            ),
            _gap,
            WobblyButton(
              onPressed: () {
                GoRouter.of(context).pop();
              },
              child: Text(Strings.back),
            ),
            _gap,
          ],
        ),
      ),
    );
  }
}
