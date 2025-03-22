import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/style/wobbly_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectCharactersScreen extends StatefulWidget {
  const SelectCharactersScreen({super.key});

  @override
  State<SelectCharactersScreen> createState() => _SelectCharactersScreenState();
}

class _SelectCharactersScreenState extends State<SelectCharactersScreen> {
  static const _gap = SizedBox(height: 60);

  final List<int?> _selectedCharacters = List<int?>.filled(4, null);

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
                        for (int rowIndex = 0; rowIndex < 5; rowIndex++)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _getRowLabel(rowIndex),
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
                                    value: _selectedCharacters[colIndex] == rowIndex,
                                    onChanged: (value) {
                                      setState(() {
                                        // Update the selected row for the current column
                                        if (value == true) {
                                          _selectedCharacters[colIndex] = rowIndex;
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
                    _gap,
                    const Text(
                      'Il guerriero attacca a corta distanza\n l\'arciere a media distanza\n il mago a lunga distanza\n l\'assassino colpisce un nemico a caso in tutto lo schermo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WobblyButton(
              onPressed: () {
                // Handle button press
                // Map the selected row indices to character types
                if (_selectedCharacters.every((element) => element == null)) {
                  return;
                }
                final Map<String, String?> pathParameters = {
                  'sx': _getCharacterType(_selectedCharacters[0]),
                  'front': _getCharacterType(_selectedCharacters[1]),
                  'dx': _getCharacterType(_selectedCharacters[2]),
                };

                GoRouter.of(context).go('/selectCharacters/play', extra: pathParameters);
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

  // Helper method to get the label for each row
  String _getRowLabel(int rowIndex) {
    switch (rowIndex) {
      case 0:
        return 'Guerriero';
      case 1:
        return 'Arciere';
      case 2:
        return 'Mago';
      case 3:
        return 'Assassino';
      case 4:
        return 'Berserk';
      default:
        return '';
    }
  }

  String? _getCharacterType(int? rowIndex) {
    switch (rowIndex) {
      case 0:
        return 'warrior';
      case 1:
        return 'archer';
      case 2:
        return 'wizard';
      case 3:
        return 'assassin';
      case 4:
        return 'berserk';
      default:
        return null; // Return null if no character is selected
    }
  }
}
