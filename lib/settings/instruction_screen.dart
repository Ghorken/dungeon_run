import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/settings/persistence.dart';
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
  Map<String, dynamic> _upgrades = {};

  /// The unlocked characeters
  List<CharacterType> _unlockedCharacters = [];

  @override
  void initState() {
    super.initState();
    _loadUpgrades();
  }

  /// Recover the buyed upgrades
  Future<void> _loadUpgrades() async {
    final Map<String, dynamic> recoveredUpgrades = await _persistence.getUpgrades();
    setState(() {
      _upgrades = recoveredUpgrades;
    });
    _retrieveUnlockedCharacters();
  }

  /// Recover the unlocked Characters
  Future<void> _retrieveUnlockedCharacters() async {
    _unlockedCharacters = _upgrades.entries.where((MapEntry<String, dynamic> entry) => entry.key.contains('_unlocked') && (entry.value['current_level'] as int) > 0).map((MapEntry<String, dynamic> entry) => getCharacterType(entry.value['character_type'] as String)).toList();
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
                  };
                  GoRouter.of(context).go('/selectCharacters', extra: extra);
                } else {
                  // Otherwise prepare the party with only the [Warrior] and go to game screen
                  final List<CharacterType?> selectedCharacters = List<CharacterType?>.filled(3, null);
                  selectedCharacters[1] = CharacterType.warrior;
                  Map<String, dynamic> extra = {
                    'upgrades': _upgrades,
                    'selectedCharacters': selectedCharacters,
                  };
                  GoRouter.of(context).go('/play', extra: extra);
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
