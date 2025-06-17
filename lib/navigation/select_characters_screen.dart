import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/utils/wobbly_button.dart';
import 'package:provider/provider.dart';

/// The class that handle the compositions of the party
class SelectCharactersScreen extends StatefulWidget {
  static const String routeName = "/selectCharacters";

  const SelectCharactersScreen({
    super.key,
  });

  @override
  State<SelectCharactersScreen> createState() => _SelectCharactersScreenState();
}

class _SelectCharactersScreenState extends State<SelectCharactersScreen> {
  /// The gap between elements
  static const _gap = SizedBox(height: 60);

  /// The list of the characters and the relative postions that the player selected
  List<CharacterType?> _selectedCharacters = List<CharacterType?>.filled(3, null);

  /// The container of the local saved data
  final Persistence _persistence = Persistence();

  @override
  void initState() {
    super.initState();
    // Call getCharactersPosition when the screen is initialized
    getCharactersPosition();
  }

  @override
  Widget build(BuildContext context) {
    final List<Upgrade> upgrades = Provider.of<UpgradeProvider>(context).upgrades;
    final List<CharacterType> unlockedCharacters =
        upgrades.where((Upgrade entry) => entry.characterType != null && entry.unlocked == true).map((Upgrade entry) => entry.characterType!).toList();
    final NavigatorState navigator = Navigator.of(context);

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
                      Strings.chooseParty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 30,
                        height: 1,
                      ),
                    ),
                    _gap,
                    // The grid with the checkboxes
                    Table(
                      border: TableBorder.all(color: Colors.white),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        // Header row
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                Strings.position,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Press Start 2P',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                Strings.left,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Press Start 2P',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                Strings.front,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Press Start 2P',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                Strings.right,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Press Start 2P',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Data rows
                        for (CharacterType characterType in unlockedCharacters)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  // The label of the character
                                  getLabel(characterType),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Press Start 2P',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              for (int colIndex = 0; colIndex < 3; colIndex++)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Checkbox(
                                    value: _selectedCharacters[colIndex] == characterType,
                                    onChanged: (value) {
                                      setState(() {
                                        // Update the selected row for the current column
                                        if (value == true) {
                                          _selectedCharacters[colIndex] = characterType;
                                        } else {
                                          _selectedCharacters[colIndex] = null;
                                        }
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            WobblyButton(
              onPressed: () {
                // Handle button press
                // Send the selected character types to the game and alert the player otherwise
                if (_selectedCharacters.every((element) => element == null)) {
                  Fluttertoast.showToast(
                    msg: Strings.selectOneCharacter,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  return;
                }

                // Save the selected characters in memory
                _persistence.saveCharactersPosition(_selectedCharacters);

                // If the first level is completed go to the level selection screen
                Map<String, dynamic> extra = {
                  'selectedCharacters': _selectedCharacters,
                };
                navigator.pushNamed('/selectLevel', arguments: extra);
              },
              child: Text(Strings.play),
            ),
            _gap,
            WobblyButton(
              onPressed: () {
                navigator.pop();
              },
              child: Text(Strings.back),
            ),
            _gap,
          ],
        ),
      ),
    );
  }

  /// Get the characters position from memory
  Future<void> getCharactersPosition() async {
    final List<CharacterType?> charactersPosition = await _persistence.getCharactersPosition();
    setState(() {
      _selectedCharacters = charactersPosition;
    });
  }
}
