import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:dungeon_run/flame_game/components/trap.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/potion.dart';
import 'package:dungeon_run/flame_game/game_screen.dart';
import 'package:flutter/material.dart';

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
  });

  /// The size of the game screen
  Vector2 get size => (parent as FlameGame).size;

  /// Define the positions for the three possible characters to show
  // These are late because they need the size of the screen
  late Vector2 frontCharacterPosition = Vector2(0, (size.y / 2) - (size.y / 10));
  late Vector2 leftCharacterPosition = Vector2(-(size.x / 2) + (size.x / 5), (size.y / 2) - (size.y / 20));
  late Vector2 rightCharacterPosition = Vector2((size.x / 2) - (size.x / 5), (size.y / 2) - (size.y / 20));

  /// This is used to measure the duration of the effects
  late final DateTime timeStarted;

  /// List of characters selected from the player
  final List<CharacterType?> selectedCharacters;

  /// List to keep track of potions int the world.
  final List<Potion> potions = [];

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
  int speed = 200;

  /// The max lifePoints of the player
  final int maxLifePoints = 20;

  /// The current lifePoints of the player
  int lifePoints = 20;

  @override
  Future<void> onLoad() async {
    // If the player selected a leftCharacter initialize id and add id to the screen
    if (selectedCharacters[0] != null) {
      leftCharacter = createCharacter(
        selectedCharacters[0]!,
        leftCharacterPosition,
      );
      add(leftCharacter!);
    }

    // If the player selected a frontCharacter initialize id and add id to the screen
    if (selectedCharacters[1] != null) {
      frontCharacter = createCharacter(
        selectedCharacters[1]!,
        frontCharacterPosition,
      );
      add(frontCharacter!);
    }

    // If the player selected a rightCharacter initialize id and add id to the screen
    if (selectedCharacters[2] != null) {
      rightCharacter = createCharacter(
        selectedCharacters[2]!,
        rightCharacterPosition,
      );
      add(rightCharacter!);
    }

    // The player lifebar to the screen
    // The dimension of every segment depends from the screen and how many max lifepoint the player has
    add(
      LifeBar(
        segmentWidth: size.x / maxLifePoints,
        color: Colors.green,
      ),
    );

    // Spawning random enemies in the world at a fixed interval
    add(
      SpawnComponent(
        factory: (_) {
          Enemy enemy = Enemy.random();
          enemies.add(enemy);
          return enemy;
        },
        period: 2,
      ),
    );

    // Schedule the goblinKing to spawn after 5 minutes
    add(
      TimerComponent(
        period: 300, // 5 minutes in seconds
        repeat: false, // Spawn only once
        onTick: () {
          final goblinKing = Enemy.goblinKing();
          enemies.add(goblinKing);
          add(goblinKing);
        },
      ),
    );

    // Spawning traps in the world at a random interval between fixed values
    add(
      SpawnComponent.periodRange(
        factory: (_) {
          Trap trap = Trap.random();
          traps.add(trap);
          return trap;
        },
        minPeriod: 5.0,
        maxPeriod: 7.0,
      ),
    );

    // Spawning potions in the world at a random interval between fixed values
    add(
      SpawnComponent.periodRange(
        factory: (_) {
          Potion potion = Potion.random();
          potions.add(potion);
          return potion;
        },
        minPeriod: 3.0,
        maxPeriod: 6.0,
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
  }

  /// [onTapDown] is called when the character taps the screen
  @override
  void onTapDown(TapDownEvent event) {
    // If the player taps on a character, we make it attack.
    if (frontCharacter != null && frontCharacter!.toRect().contains(event.localPosition.toOffset())) {
      frontCharacter!.attack();
      return;
    } else if (leftCharacter != null && leftCharacter!.toRect().contains(event.localPosition.toOffset())) {
      leftCharacter!.attack();
      return;
    } else if (rightCharacter != null && rightCharacter!.toRect().contains(event.localPosition.toOffset())) {
      rightCharacter!.attack();
      return;
    }

    // If the player taps on a potion, we apply its effect and remove it from the world
    for (final potion in potions) {
      if (potion.toRect().contains(event.localPosition.toOffset())) {
        potion.effect();
        potion.removeFromParent();
        potions.remove(potion);
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
  void loose() {
    game.pauseEngine();
    game.overlays.remove(GameScreen.backButtonKey);
    game.overlays.add(GameScreen.looseDialogKey);
  }

  /// When the player wins stop the game and shows the relative dialog
  void win() {
    game.pauseEngine();
    game.overlays.remove(GameScreen.backButtonKey);
    game.overlays.add(GameScreen.winDialogKey);
  }
}
