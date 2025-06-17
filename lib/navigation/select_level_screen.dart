import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/utils/wobbly_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The class that handle the selection of the level
class SelectLevelScreen extends StatelessWidget {
  static const String routeName = "/selectLevel";

  /// The list of unlocked characters recovered from upgrades
  final List<CharacterType?> selectedCharacters;

  SelectLevelScreen({
    required this.selectedCharacters,
    super.key,
  });

  /// The gap between elements
  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final List<Level> levels = Provider.of<LevelProvider>(context).levels;
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  _gap,
                  Text(
                    Strings.selectLevel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Press Start 2P',
                      fontSize: 30,
                      height: 1,
                    ),
                  ),
                  _gap,
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 2.0,
                      child: Stack(
                        children: [
                          // Background image
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/dungeon_door.png',
                            ),
                          ),
                          // Buttons for levels
                          for (int index = 0; index < levels.length; index++) _buildLevelButton(context, levels[index], index, navigator),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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

  /// Helper method to build a button for each level
  Widget _buildLevelButton(BuildContext context, Level level, int index, NavigatorState navigator) {
    // Define specific positions for each button
    final List<Offset> buttonPositions = [
      Offset(MediaQuery.of(context).size.width / 2, 500),
      Offset(MediaQuery.of(context).size.width / 2, 400),
      Offset(MediaQuery.of(context).size.width / 5, 300),
      Offset(MediaQuery.of(context).size.width / 2, 100),
      Offset(MediaQuery.of(context).size.width / 5 * 4, 200),
    ];

    // Button dimensions
    const double buttonWidth = 150;
    const double buttonHeight = 50;

    // Check if the level is available
    final List<String>? dependencyLevels = level.dependency;
    bool isAvailable = false;

    if (dependencyLevels != null) {
      for (String dependency in dependencyLevels) {
        if (Provider.of<LevelProvider>(context, listen: false).levels.any((Level l) => l.name == dependency && l.completed)) {
          isAvailable = true;
          break;
        }
      }
    } else {
      isAvailable = true;
    }

    return isAvailable
        ? Positioned(
            left: buttonPositions[index].dx - (buttonWidth / 2),
            top: buttonPositions[index].dy - (buttonHeight / 2),
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: isAvailable
                  ? () {
                      Map<String, dynamic> extra = {
                        'selectedCharacters': selectedCharacters,
                        'level': level,
                      };
                      navigator.pushNamed('/loading', arguments: extra);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? Colors.blue : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: Text(
                level.name,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
              ),
            ),
          )
        : Container();
  }
}
