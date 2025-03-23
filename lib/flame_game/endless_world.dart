import 'dart:math';

import 'package:dungeon_run/flame_game/components/characters/archer.dart';
import 'package:dungeon_run/flame_game/components/characters/assassin.dart';
import 'package:dungeon_run/flame_game/components/characters/berserk.dart';
import 'package:dungeon_run/flame_game/components/characters/warrior.dart';
import 'package:dungeon_run/flame_game/components/characters/wizard.dart';
import 'package:dungeon_run/flame_game/components/trap.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import 'components/enemy.dart';
import 'components/characters/character.dart';
import 'components/potion.dart';
import 'game_screen.dart';

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
    Random? random,
  }) : _random = random ?? Random();

  late Vector2 frontCharacterPosition = Vector2(0, (size.y / 2) - (size.y / 10));
  late Vector2 leftCharacterPosition = Vector2(-(size.x / 2) + (size.x / 5), (size.y / 2) - (size.y / 20));
  late Vector2 rightCharacterPosition = Vector2((size.x / 2) - (size.x / 5), (size.y / 2) - (size.y / 20));

  late final DateTime timeStarted;
  Vector2 get size => (parent as FlameGame).size;

  /// The random number generator that is used to spawn periodic components.
  final Random _random;

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

  @override
  Future<void> onLoad() async {
    // Initialize `leftCharacter` based on the first element of `selectedCharacters`
    if (selectedCharacters[0] != null) {
      leftCharacter = _createCharacter(
        selectedCharacters[0]!,
        leftCharacterPosition,
      );
      add(leftCharacter!);
    }

    // Initialize `frontCharacter` based on the second element of `selectedCharacters`
    if (selectedCharacters[1] != null) {
      frontCharacter = _createCharacter(
        selectedCharacters[1]!,
        frontCharacterPosition,
      );
      add(frontCharacter!);
    }

    // Initialize `rightCharacter` based on the third element of `selectedCharacters`
    if (selectedCharacters[2] != null) {
      rightCharacter = _createCharacter(
        selectedCharacters[2]!,
        rightCharacterPosition,
      );
      add(rightCharacter!);
    }

    // Spawning enemies in the world
    add(
      SpawnComponent(
        factory: (_) {
          Enemy enemy = Enemy.random(random: _random);
          enemies.add(enemy);
          return enemy;
        },
        period: 2,
        area: Rectangle.fromPoints(
          Vector2(-(size.x / 2), -(size.y / 2)),
          Vector2((size.x / 2), -(size.y / 2)),
        ),
        random: _random,
      ),
    );

    // Schedule the goblinKing to spawn after 5 minutes
    // add(
    //   TimerComponent(
    //     period: 300, // 5 minutes in seconds
    //     repeat: false, // Spawn only once
    //     onTick: () {
    //       final goblinKing = Enemy.goblinKing(position: Vector2(0, -(size.y / 2)));
    //       enemies.add(goblinKing);
    //       add(goblinKing);
    //     },
    //   ),
    // );

    // Spawning traps in the world
    add(
      SpawnComponent.periodRange(
        factory: (_) {
          Trap trap = Trap.random(random: _random);
          traps.add(trap);
          return trap;
        },
        minPeriod: 5.0,
        maxPeriod: 7.0,
        area: Rectangle.fromPoints(
          Vector2(-(size.x / 2), -(size.y / 2)),
          Vector2((size.x / 2), -(size.y / 2)),
        ),
        random: _random,
      ),
    );

    // Spawning potions in the world
    add(
      SpawnComponent.periodRange(
        factory: (_) {
          Potion potion = Potion.random(random: _random);
          potions.add(potion);
          return potion;
        },
        minPeriod: 3.0,
        maxPeriod: 6.0,
        area: Rectangle.fromPoints(
          Vector2(-(size.x / 2), -(size.y / 2)),
          Vector2((size.x / 2), (size.y / 2) - (size.y / 5)),
        ),
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
    print("DR: ${frontCharacter?.damage}");
    print("DR: ${leftCharacter?.damage}");
    print("DR: ${rightCharacter?.damage}");

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

    // If the player taps on a potion, we remove it from the world
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

  void loose() {
    game.pauseEngine();
    game.overlays.remove(GameScreen.backButtonKey);
    game.overlays.add(GameScreen.looseDialogKey);
  }

  void win() {
    game.pauseEngine();
    game.overlays.remove(GameScreen.backButtonKey);
    game.overlays.add(GameScreen.winDialogKey);
  }
}

/// Helper method to create a character based on its type
Character _createCharacter(CharacterType type, Vector2 position) {
  switch (type) {
    case CharacterType.warrior:
      return Warrior(position: position);
    case CharacterType.archer:
      return Archer(position: position);
    case CharacterType.wizard:
      return Wizard(position: position);
    case CharacterType.assassin:
      return Assassin(position: position);
    case CharacterType.berserk:
      return Berserk(position: position);
  }
}
