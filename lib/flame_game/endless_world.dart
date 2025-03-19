import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../level_selection/levels.dart';
import 'components/enemy.dart';
import 'components/player.dart';
import 'components/potion.dart';
import 'game_screen.dart';

/// The world is where you place all the components that should live inside of
/// the game, like the player, enemies, obstacles and points for example.
/// The world can be much bigger than what the camera is currently looking at,
/// but in this game all components that go outside of the size of the viewport
/// are removed, since the player can't interact with those anymore.
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

  /// In the [potionNotifier] we keep track of how many potions had been collected, and if
  /// other parts of the code is interested in when the score is updated they
  /// can listen to it and act on the updated value.
  final potionNotifier = ValueNotifier(0);
  final hitNotifier = ValueNotifier(0);
  final killNotifier = ValueNotifier(0);
  late final Player player;
  late final DateTime timeStarted;
  Vector2 get size => (parent as FlameGame).size;

  /// The random number generator that is used to spawn periodic components.
  final Random _random;

  /// Where the ground is located in the world and things should stop falling.
  late final double playerLevel = (size.y / 2) - (size.y / 10);

  /// List to keep track of potions int the world.
  final List<Potion> potions = [];

  /// List to keep track of enemies in the world.
  final List<Enemy> enemies = [];

  @override
  Future<void> onLoad() async {
    // The player is the component that we control when we tap the screen
    player = Player(
      position: Vector2(0, playerLevel),
      addPotion: addPotionCount,
      addHit: addHit,
      addKill: addKill,
    );
    add(player);

    // Spawning enemies in the world
    add(
      SpawnComponent(
        factory: (_) {
          Enemy enemy = Enemy.goblin();
          enemies.add(enemy);
          return enemy;
        },
        period: 1,
        area: Rectangle.fromPoints(
          Vector2(-(size.x / 2), -(size.y / 2)),
          Vector2((size.x / 2) - Enemy.goblin().size.x, -(size.y / 2) + (size.y / 5)),
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
    // overlay so that the player can go back to the previous screen.
    game.overlays.add(GameScreen.backButtonKey);
  }

  @override
  void onRemove() {
    game.overlays.remove(GameScreen.backButtonKey);
  }

  /// Increments the number of potions collected.
  void addPotionCount({int amount = 1}) {
    potionNotifier.value += amount;
  }

  /// Increments the number of hit received.
  void addHit({int amount = 1}) {
    hitNotifier.value += amount;
  }

  /// Increments the number of kill done.
  void addKill({int amount = 1}) {
    killNotifier.value += amount;
  }

  /// [onTapDown] is called when the player taps the screen
  @override
  void onTapDown(TapDownEvent event) {
    //TODO: make attack
    player.attack();

    // If the player taps on a potion, we remove it from the world and increment
    // the potion count.
    for (final potion in potions) {
      if (potion.toRect().contains(event.localPosition.toOffset())) {
        potion.removeFromParent();
        potions.remove(potion);
        addPotionCount();
        break;
      }
    }
  }

  /// A helper function to define how fast a certain level should be.
  static double _calculateSpeed(int level) => 200 + (level * 200);
}
