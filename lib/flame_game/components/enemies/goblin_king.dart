import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GoblinKing extends Enemy {
  GoblinKing({
    required super.goldUpgradeLevel,
  })  : maxLifePoints = 30,
        super(
          enemyGold: 1,
          isBoss: true,
          damage: 5,
          actualSpeed: 2,
          speed: 2,
          lifePoints: 30,
        );

  /// The max lifePoints of the enemy
  final int maxLifePoints;

  @override
  Future<void> onLoad() async {
    // Load the sprite of the enemy
    animations = {
      EnemyState.running: await game.loadSpriteAnimation(
        'enemies/goblin_king.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(250, 495),
          stepTime: 0.15,
        ),
      ),
      EnemyState.attacking: await game.loadSpriteAnimation(
        'enemies/goblin_king.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(250, 495),
          stepTime: 0.15,
        ),
      ),
    };

    // Position the enemy at the middlet of the top of the screen
    position = Vector2(0.0, -world.size.y / 2);

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
        parentComponent: this,
      ),
    );
  }
}
