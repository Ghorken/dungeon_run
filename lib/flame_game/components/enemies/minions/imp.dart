import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:dungeon_run/utils/commons.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Imp extends Enemy {
  Imp({
    required super.goldUpgradeLevel,
  })  : maxLifePoints = 5,
        super(
          enemyGold: 1,
          isBoss: false,
          damage: 1,
          actualSpeed: 2,
          speed: 2,
          lifePoints: 5,
          enemyType: EnemyType.imp,
        );

  /// The max lifePoints of the enemy
  final int maxLifePoints;

  @override
  Future<void> onLoad() async {
    // Load the sprite of the enemy
    animations = {
      EnemyState.running: await game.loadSpriteAnimation(
        'enemies/imp.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(250, 277),
          stepTime: 0.15,
        ),
      ),
      EnemyState.attacking: await game.loadSpriteAnimation(
        'enemies/imp.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(250, 277),
          stepTime: 0.15,
        ),
      ),
    };

    size = Vector2.all(150);

    // Position the enemy in a random spot at the top of the screen
    position = Vector2(randomInRange((-world.size.x / 2 + size.x / 2).toInt(), (world.size.x / 2 - size.x / 2).toInt()), -world.size.y / 2);

    current = EnemyState.running;

    // Add the hitbox to the enemy
    add(
      CircleHitbox(
        isSolid: true,
        radius: 50,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );

    // Add the lifebar to display the lifepoints
    add(
      LifeBar(
        segmentWidth: size.x / maxLifePoints,
        color: Colors.red,
      ),
    );
  }
}
