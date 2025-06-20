import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/trophies/trophy_provider.dart';
import 'package:dungeon_run/utils/enemies_provider.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/components/traps/trap.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable.dart';
import 'package:dungeon_run/navigation/game_screen.dart';

/// The world is where you place all the components that should live inside of
/// the game, like the character, enemies, obstacles and points for example.
/// The world can be much bigger than what the camera is currently looking at,
/// but in this game all components that go outside of the size of the viewport
/// are removed, since the character can't interact with those anymore.
///
/// The [EndlessWorld] has two mixins added to it:
///  - The [HasGameReference] that gives the world access to a variable called
///  `game`, which is a reference to the game class that the world is attached
///  to.
class EndlessWorld extends World with HasGameReference {
  EndlessWorld({
    required this.selectedCharacters,
    required this.level,
    required this.upgradeProvider,
    required this.enemiesProvider,
    required this.levelProvider,
    required this.trophyProvider,
  });

  /// The size of the game screen
  Vector2 get size => (parent as FlameGame).size;

  /// The state of the upgrades
  final UpgradeProvider upgradeProvider;

  /// The state of the enemies
  final EnemiesProvider enemiesProvider;

  /// The state of the levels
  final LevelProvider levelProvider;

  /// The state of the trophies
  final TrophyProvider trophyProvider;

  /// Define the positions for the three possible characters to show
  // These are late because they need the size of the screen
  late Vector2 frontCharacterPosition = Vector2(0, (size.y / 2) - (size.y / 10));
  late Vector2 leftCharacterPosition = Vector2(-(size.x / 2) + (size.x / 5), (size.y / 2) - (size.y / 20));
  late Vector2 rightCharacterPosition = Vector2((size.x / 2) - (size.x / 5), (size.y / 2) - (size.y / 20));

  /// Define the boundaries for the three areas
  late final double topAreaEnd = -size.y / 3;
  late final double bottomAreaStart = size.y / 3;

  /// This is used to measure the duration of the effects
  late final DateTime timeStarted;

  /// List of characters selected from the player
  final List<CharacterType?> selectedCharacters;

  /// List to keep track of [Character] in the world.
  final List<Character?> characters = List<Character?>.filled(3, null);

  /// List to keep track of dead [Character]
  final List<Character?> deadCharacters = List<Character?>.filled(3, null);

  /// List to keep track of [Collectable] in the world.
  final List<Collectable> collectables = [];

  /// List to keep track of enemies in the world.
  final List<Enemy> enemies = [];

  /// List to keep track of traps in the world.
  final List<Trap> traps = [];

  /// The [Character] that is in the front slot.
  Character? frontCharacter;

  /// The [Character] that is in the left slot.
  Character? leftCharacter;

  /// The [Character] that is in the right slot.
  Character? rightCharacter;

  /// The base speed at which every elements move.
  double speed = 200.0;

  /// The amount of gold that the player collected
  int gold = 0;

  /// The level of the game
  Level level;

  /// Control if the boss is already spawned or not
  bool bossSpawned = false;

  /// A set of enemies that are loaded and ready to be spawned.
  Set<Enemy> loadedEnemies = {};

  /// The boss of the level
  late Enemy boss;

  @override
  Future<void> onLoad() async {
    final List<Upgrade> upgrades = upgradeProvider.upgrades;

    loadedEnemies = enemiesProvider.getEnemies();

    // Retrieve the level of the gold upgrade
    final int goldUpgradeLevel = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'enemy_gold').currentLevel;

    // If the player selected a leftCharacter initialize id and add id to the screen
    if (selectedCharacters[0] != null) {
      leftCharacter = await createCharacter(
        selectedCharacters[0]!,
        leftCharacterPosition,
        upgrades,
      );
      add(leftCharacter!);
      characters[0] = (leftCharacter!);

      final int special = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == '${getCharacterTypeString(selectedCharacters[0]!)}_special').currentLevel;
      if (special > 0) {
        game.overlays.add(GameScreen.leftSpecialAttackKey);
      }
    }

    // If the player selected a frontCharacter initialize id and add id to the screen
    if (selectedCharacters[1] != null) {
      frontCharacter = await createCharacter(
        selectedCharacters[1]!,
        frontCharacterPosition,
        upgrades,
      );
      add(frontCharacter!);
      characters[1] = (frontCharacter!);

      final int special = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == '${getCharacterTypeString(selectedCharacters[1]!)}_special').currentLevel;
      if (special > 0) {
        game.overlays.add(GameScreen.frontSpecialAttackKey);
      }
    }

    // If the player selected a rightCharacter initialize id and add id to the screen
    if (selectedCharacters[2] != null) {
      rightCharacter = await createCharacter(
        selectedCharacters[2]!,
        rightCharacterPosition,
        upgrades,
      );
      add(rightCharacter!);
      characters[2] = (rightCharacter!);

      final int special = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == '${getCharacterTypeString(selectedCharacters[2]!)}_special').currentLevel;
      if (special > 0) {
        game.overlays.add(GameScreen.rightSpecialAttackKey);
      }
    }

    // Spawning enemies in the world at a fixed interval
    add(
      TimerComponent(
        period: level.enemyFrequency,
        repeat: true,
        onTick: () {
          if (!bossSpawned) {
            enemies.add(loadedEnemies.first);
            add(loadedEnemies.first);
            loadedEnemies.remove(loadedEnemies.first);
          }
        },
      ),
    );

    // Schedule the boss to spawn after the boss timer
    // Load the boss enemy
    boss = await spawnBoss(
      goldUpgradeLevel: goldUpgradeLevel,
      type: level.boss,
    );
    add(
      TimerComponent(
        period: level.bossTimer,
        repeat: false, // Spawn only once
        onTick: () async {
          // Stop spawning enemies
          bossSpawned = true;
          enemies.add(boss);
          add(boss);
        },
      ),
    );

    // Spawning [Trap] in the world at a random interval between fixed values
    if (level.traps.isNotEmpty) {
      add(
        SpawnComponent.periodRange(
          factory: (_) {
            final Trap trap = Trap.random(
              traps: level.traps,
            );
            traps.add(trap);
            return trap;
          },
          minPeriod: level.trapMinPeriod,
          maxPeriod: level.trapMaxPeriod,
        ),
      );
    }

    // Spawning [Collectable] in the world at a random interval between fixed values
    add(
      SpawnComponent.periodRange(
        factory: (_) {
          Collectable collectable = Collectable.random(
            upgrades: upgrades,
            collectables:
                upgrades.where((Upgrade upgrade) => upgrade.collectableType != null && upgrade.unlocked == true).map((Upgrade upgrade) => upgrade.collectableType!).toList(),
          );
          collectables.add(collectable);
          return collectable;
        },
        minPeriod: level.collectableMinPeriod,
        maxPeriod: (level.collectableMaxPeriod - (upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_frequency').currentLevel).toDouble()),
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    // When the world is mounted in the game we add a back button widget as an
    // overlay so that the character can go back to the previous screen.
    game.overlays.add(GameScreen.backButtonKey);
  }

  @override
  void onRemove() {
    game.overlays.remove(GameScreen.backButtonKey);
    game.overlays.remove(GameScreen.leftSpecialAttackKey);
    game.overlays.remove(GameScreen.frontSpecialAttackKey);
    game.overlays.remove(GameScreen.rightSpecialAttackKey);
  }

  /// When the player loose stop the game and shows the relative dialog
  Future<void> loose() async {
    // Stop the game and remove the back button
    game.pauseEngine();
    game.overlays.remove(GameScreen.backButtonKey);
    game.overlays.remove(GameScreen.leftSpecialAttackKey);
    game.overlays.remove(GameScreen.frontSpecialAttackKey);
    game.overlays.remove(GameScreen.rightSpecialAttackKey);

    // Show the loose dialog
    game.overlays.add(GameScreen.looseDialogKey);

    // Save the accumulated gold
    upgradeProvider.setGold = gold + upgradeProvider.gold;
    upgradeProvider.saveToMemory();

    // Save the trophies
    trophyProvider.saveToMemory();

    // Count the number of deaths
    trophyProvider.incrementDeaths();
  }

  /// When the player wins stop the game and shows the relative dialog
  Future<void> win() async {
    // Stop the game and remove the back button
    game.pauseEngine();
    game.overlays.remove(GameScreen.backButtonKey);
    game.overlays.remove(GameScreen.leftSpecialAttackKey);
    game.overlays.remove(GameScreen.frontSpecialAttackKey);
    game.overlays.remove(GameScreen.rightSpecialAttackKey);

    // Show the win dialog
    game.overlays.add(GameScreen.winDialogKey);

    // Set the level as completed
    levelProvider.setLevelCompleted(level.name);
    levelProvider.saveToMemory();

    // Save the accumulated gold
    if (level.rewards["gold"] != null) {
      gold += level.rewards["gold"] as int;
    }
    upgradeProvider.setGold = gold + upgradeProvider.gold;

    // Unlock the upgrades and save the state of the upgrades
    if (level.rewards["upgrades"] != null) {
      for (String unlockedUpgrade in level.rewards["upgrades"] as List<String>) {
        upgradeProvider.unlockUpgrade(unlockedUpgrade);
      }
    }
    upgradeProvider.saveToMemory();

    // Unlock the trophies for the characters unlocked
    if (upgradeProvider.upgrades.where((Upgrade upgrade) => upgrade.characterType != null && upgrade.unlocked == true).length == 3) {
      trophyProvider.unlockTrophy("allies-1");
    }

    // Unlock the trophies for the level completed
    trophyProvider.unlockLevelsTrophy(level);

    // Save the trophies
    trophyProvider.saveToMemory();
  }
}
