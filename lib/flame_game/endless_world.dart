import 'dart:math';

import 'package:dungeon_run/flame_game/components/archer.dart';
import 'package:dungeon_run/flame_game/components/assassin.dart';
import 'package:dungeon_run/flame_game/components/warrior.dart';
import 'package:dungeon_run/flame_game/components/wizard.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

import '../level_selection/levels.dart';
import 'components/enemy.dart';
import 'components/character.dart';
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
    required this.level,
    Random? random,
  }) : _random = random ?? Random();

  /// The properties of the current level.
  final GameLevel level;

  /// The speed is used for determining how fast the background should pass by
  /// and how fast the enemies and obstacles should move.
  late double speed = _calculateSpeed(level.number);

  late final Character frontCharacter;
  late final Character leftCharacter;
  late final Character rightCharacter;
  late final DateTime timeStarted;
  Vector2 get size => (parent as FlameGame).size;

  /// The random number generator that is used to spawn periodic components.
  final Random _random;

  /// Where the ground is located in the world and things should stop falling.
  late final Vector2 frontCharacterPosition = Vector2(0, (size.y / 2) - (size.y / 10));
  late final Vector2 leftCharacterPosition = Vector2(-(size.x / 2) + (size.x / 5), (size.y / 2) - (size.y / 20));
  late final Vector2 rightCharacterPosition = Vector2((size.x / 2) - (size.x / 5), (size.y / 2) - (size.y / 20));

  /// List to keep track of potions int the world.
  final List<Potion> potions = [];

  /// List to keep track of enemies in the world.
  final List<Enemy> enemies = [];

  @override
  Future<void> onLoad() async {
    // The character is the component that we control when we tap the screen
    // frontCharacter = Warrior(
    //   position: frontCharacterPosition,
    // );
    frontCharacter = Assassin(
      position: frontCharacterPosition,
    );
    add(frontCharacter);

    leftCharacter = Archer(
      position: leftCharacterPosition,
    );
    add(leftCharacter);

    rightCharacter = Wizard(
      position: rightCharacterPosition,
    );
    add(rightCharacter);

    // Spawning enemies in the world
    add(
      SpawnComponent(
        factory: (_) {
          Enemy enemy = Enemy.random(random: _random);
          enemies.add(enemy);
          return enemy;
        },
        period: 1,
        area: Rectangle.fromPoints(
          Vector2(-(size.x / 2), -(size.y / 2)),
          Vector2((size.x / 2), -(size.y / 2) + (size.y / 5)),
        ),
        random: _random,
      ),
    );

    // Spawning potions in the world
    add(
      SpawnComponent.periodRange(
        factory: (_) {
          Potion potion = Potion();
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
    // If the player taps on a character, we make it attack.
    if (frontCharacter.toRect().contains(event.localPosition.toOffset())) {
      frontCharacter.attack();
      return;
    } else if (leftCharacter.toRect().contains(event.localPosition.toOffset())) {
      leftCharacter.attack();
      return;
    } else if (rightCharacter.toRect().contains(event.localPosition.toOffset())) {
      rightCharacter.attack();
      return;
    }

    // If the player taps on a potion, we remove it from the world and increment
    // the potion count.
    for (final potion in potions) {
      if (potion.toRect().contains(event.localPosition.toOffset())) {
        potion.removeFromParent();
        potions.remove(potion);
        break;
      }
    }
  }

  /// A helper function to define how fast a certain level should be.
  static double _calculateSpeed(int level) => 200 + (level * 200);
}
