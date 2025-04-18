import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/utils/wobbly_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// The class that handle the selection of the level
class SelectLevelScreen extends StatelessWidget {
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

    /// The list of the available levels
    /// Retrieve for every level the dependency and check if at least one is completed
    /// If the level has no dependency, it is available
    final List<Level> availableLevels = levels.where((Level level) {
      final List<String>? dependencyLevels = level.dependency;

      if (dependencyLevels != null) {
        for (String dependency in dependencyLevels) {
          if (levels.any((Level level) => level.name == dependency && level.completed)) {
            return true;
          }
        }
        return false;
      } else {
        return true;
      }
    }).toList();

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
                    // The list of the available levels
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availableLevels.length,
                      itemBuilder: (context, index) {
                        final Level level = availableLevels[index];
                        return WobblyButton(
                          onPressed: () {
                            Map<String, dynamic> extra = {
                              'selectedCharacters': selectedCharacters,
                              'level': level,
                            };
                            GoRouter.of(context).go('/play', extra: extra);
                          },
                          child: Text(level.name),
                        );
                      },
                    ),
                  ],
                ),
              ),
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
