import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/components/traps/trap.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable.dart';
import 'package:dungeon_run/flame_game/game_screen.dart';

/// The world is where you place all the components that should live inside of
/// the game, like the character, enemies, obstacles and points for example.
/// The world can be much bigger than what the camera is currently looking at,
/// but in this game all components that go outside of the size of the viewport
/// are removed, since the character can't interact with those anymore.
///
/// The [EndlessWorld] has two mixins added to it:
///  - The [TapCallbacks] that makes it possible to react to taps (or mouse
///  clicks) on the world.
///  - The [HasGameReference] that gives the world access to a variable called
///  `game`, which is a reference to the game class that the world is attached
///  to.
class EndlessWorld extends World with TapCallbacks, HasGameReference {
  EndlessWorld({
    required this.selectedCharacters,
    required this.upgrades,
    required this.level,
  });

  /// The size of the game screen
  Vector2 get size => (parent as FlameGame).size;

  /// The state of the upgrades
  final List<Upgrade> upgrades;

  /// Define the positions for the three possible characters to show
  // These are late because they need the size of the screen
  late Vector2 frontCharacterPosition = Vector2(0, (size.y / 2) - (size.y / 10));
  late Vector2 leftCharacterPosition = Vector2(-(size.x / 2) + (size.x / 5), (size.y / 2) - (size.y / 20));
  late Vector2 rightCharacterPosition = Vector2((size.x / 2) - (size.x / 5), (size.y / 2) - (size.y / 20));

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

  @override
  Future<void> onLoad() async {
    // If the player selected a leftCharacter initialize id and add id to the screen
    if (selectedCharacters[0] != null) {
      leftCharacter = createCharacter(
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
      frontCharacter = createCharacter(
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
      rightCharacter = createCharacter(
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

    // Spawning random enemies in the world at a fixed interval
    add(
      SpawnComponent(
        factory: (_) {
          final int enemyGold = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'enemy_gold').currentLevel;
          final Enemy enemy = Enemy.random(
            enemies: level.enemies,
            rewards: {
              "gold": enemyGold,
            },
          );
          enemies.add(enemy);
          return enemy;
        },
        period: level.enemyFrequency,
      ),
    );

    // Schedule the goblinKing to spawn after 5 minutes
    add(
      TimerComponent(
        period: level.bossTimer,
        repeat: false, // Spawn only once
        onTick: () {
          final Enemy boss = Enemy.boss(
            type: level.boss,
            rewards: level.rewards,
          );
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
    if (level.collectables.isNotEmpty) {
      add(
        SpawnComponent.periodRange(
          factory: (_) {
            Collectable collectable = Collectable.random(
              upgrades: upgrades,
              collectables: level.collectables,
            );
            collectables.add(collectable);
            return collectable;
          },
          minPeriod: level.collectableMinPeriod,
          maxPeriod: (level.collectableMaxPeriod - (upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_frequency').currentLevel).toDouble()),
        ),
      );
    }
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

  /// [onTapDown] is called when the character taps the screen
  @override
  void onTapDown(TapDownEvent event) {
    // If the player taps on a character, we make it attack.
    if (frontCharacter != null && characters.contains(frontCharacter) && frontCharacter!.toRect().contains(event.localPosition.toOffset())) {
      frontCharacter!.attack();
      return;
    } else if (leftCharacter != null && characters.contains(leftCharacter) && leftCharacter!.toRect().contains(event.localPosition.toOffset())) {
      leftCharacter!.attack();
      return;
    } else if (rightCharacter != null && characters.contains(rightCharacter) && rightCharacter!.toRect().contains(event.localPosition.toOffset())) {
      rightCharacter!.attack();
      return;
    }

    // If the player taps on a [Collectable], we apply its effect and remove it from the world
    for (final collectable in collectables) {
      if (collectable.toRect().contains(event.localPosition.toOffset())) {
        collectable.effect();
        collectable.opacity = 0.0;
        collectables.remove(collectable);
        break;
      }
    }

    // If the player taps on a trap, we remove it from the world
    for (final Trap trap in traps) {
      if (trap.toRect().contains(event.localPosition.toOffset())) {
        trap.disable();
        break;
      }
    }
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
    Persistence persistence = Persistence();
    int storedGold = await persistence.getGold();
    persistence.saveGold(gold + storedGold);
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

    // Save the accumulated gold
    Persistence persistence = Persistence();
    int storedGold = await persistence.getGold();
    persistence.saveGold(gold + storedGold);

    // Save the level completed
    persistence.getLevels().then((List<Level> levels) {
      for (int i = 0; i < levels.length; i++) {
        if (levels[i].name == level.name) {
          levels[i] = (
            name: level.name,
            completed: true,
            dependency: level.dependency,
            enemies: level.enemies,
            enemyFrequency: level.enemyFrequency,
            boss: level.boss,
            bossTimer: level.bossTimer,
            traps: level.traps,
            trapMinPeriod: level.trapMinPeriod,
            trapMaxPeriod: level.trapMaxPeriod,
            collectables: level.collectables,
            collectableMinPeriod: level.collectableMinPeriod,
            collectableMaxPeriod: level.collectableMaxPeriod,
            map: level.map,
            rewards: level.rewards,
          );
          persistence.saveLevels(levels);
          break;
        }
      }
    });
  }
}
