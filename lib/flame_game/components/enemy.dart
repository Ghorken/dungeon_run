import 'dart:math';

import 'package:dungeon_run/flame_game/effects/death_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import '../endless_world.dart';

/// The [Enemy] component can represent three different types of obstacles
/// that the player can run into.
class Enemy extends SpriteComponent with HasWorldReference<EndlessWorld> {
  Enemy.goblin({super.position})
      : _srcSize = Vector2(250, 386),
        _srcPosition = Vector2.all(32),
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  /// Generates a random obstacle of type [EnemyType].
  factory Enemy.random({
    Vector2? position,
    Random? random,
    bool canSpawnTall = true,
  }) {
    final values = const [
      EnemyType.goblin
    ];
    final obstacleType = values.random(random);
    return switch (obstacleType) {
      EnemyType.goblin => Enemy.goblin(position: position),
    };
  }

  final Vector2 _srcSize;
  final Vector2 _srcPosition;
  int speed = 1;

  @override
  Future<void> onLoad() async {
    // Since all the obstacles reside in the same image, srcSize and srcPosition
    // are used to determine what part of the image that should be used.
    sprite = await Sprite.load(
      'enemies/goblin.png',
      srcSize: _srcSize,
      srcPosition: _srcPosition,
    );
    // When adding a RectangleHitbox without any arguments it automatically
    // fills up the size of the component.
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    // We need to move the component to the left together with the speed that we
    // have set for the world.
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    position.y += (world.speed * speed) * dt;

    // When the component is no longer visible on the screen anymore, we
    // remove it.
    // The position is defined from the upper left corner of the component (the
    // anchor) and the center of the world is in (0, 0), so when the components
    // position minus its size in Y-axis is outside of minus half the world size
    // we know that it is no longer visible and it can be removed.
    if (position.y - size.y > world.size.y / 2) {
      world.enemies.remove(this);
      removeFromParent();
    }
  }

  void die() {
    speed = 0;
    world.enemies.remove(this);
    DeathEffect deathEffect = DeathEffect();
    add(deathEffect);

    Future.delayed(Duration(milliseconds: 500), () => removeFromParent());
  }
}

enum EnemyType {
  goblin
}
