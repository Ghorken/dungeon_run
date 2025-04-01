import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/style/wobbly_button.dart';

/// The class that handle the compositions of the party
class SelectCharactersScreen extends StatefulWidget {
  /// The list of unlocked characters
  final List<CharacterType> unlockedCharacters;

  const SelectCharactersScreen({required this.unlockedCharacters, super.key});

  @override
  State<SelectCharactersScreen> createState() => _SelectCharactersScreenState();
}

class _SelectCharactersScreenState extends State<SelectCharactersScreen> {
  /// The gap between elements
  static const _gap = SizedBox(height: 60);

  /// The list of the characters and the relative postions that the player selected
  final List<CharacterType?> _selectedCharacters = List<CharacterType?>.filled(3, null);

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
                    const Text(
                      'Scegli il tuo party',
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
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Posizione',
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
                                'Sinistra',
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
                                'Centro',
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
                                'Destra',
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
                        for (CharacterType characterType in widget.unlockedCharacters)
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
                    msg: "Seleziona almeno un personaggio",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  return;
                }

                GoRouter.of(context).go('/play', extra: _selectedCharacters);
              },
              child: const Text('Gioca'),
            ),
            _gap,
            WobblyButton(
              onPressed: () {
                GoRouter.of(context).pop();
              },
              child: const Text('Indietro'),
            ),
            _gap,
          ],
        ),
      ),
    );
  }
}
