import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/utils/enemies_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  static const String routeName = "/loading";

  /// The selected characters to show
  final List<CharacterType?> selectedCharacters;

  /// The level of the game
  final Level level;

  const LoadingScreen({
    required this.selectedCharacters,
    required this.level,
    super.key,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Loading...',
              ),
              const SizedBox(height: 20),
              Text(
                'Tap on one of your character to make it attacks enemies in range.',
              ),
              const SizedBox(height: 20),
              Text(
                'Tap on one of the special ability button when available to use it.',
              ),
              const SizedBox(height: 20),
              Text(
                'Tap on traps to disarm them.',
              ),
              const SizedBox(height: 20),
              Text(
                'Tap on collectables elements to collect them.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadLevel() async {
    final LevelProvider levelProvider = context.read<LevelProvider>();
    final List<Level> levels = levelProvider.levels;

    final UpgradeProvider upgradeProvider = context.read<UpgradeProvider>();
    final List<Upgrade> upgrades = upgradeProvider.upgrades;
    final EnemiesProvider enemiesProvider = context.read<EnemiesProvider>();
    // Retrieve the level of the gold upgrade
    final int goldUpgradeLevel = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'enemy_gold').currentLevel;

    // Load the random enemies that will be spawned in the world
    for (int i = 0; i < widget.level.bossTimer / widget.level.enemyFrequency; i++) {
      randomEnemy(
        enemies: widget.level.enemies,
        goldUpgradeLevel: goldUpgradeLevel,
        enemiesProvider: enemiesProvider,
      );
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Navigate to the next screen after loading
    Map<String, dynamic> extra = {
      'selectedCharacters': widget.selectedCharacters,
      'level': levels.first,
    };
    Navigator.of(context).pushReplacementNamed('/play', arguments: extra);
  }
}
