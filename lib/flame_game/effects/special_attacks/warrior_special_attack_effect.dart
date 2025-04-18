import 'package:dungeon_run/flame_game/components/characters/warrior.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';

/// The [WarriorSpecialAttackEffect] is an effect that is composed of multiple different effects
/// that are added to the [Enemy] when the [Warrior] makes the special attack.
/// It stab every [Enemy] with the sword.
class WarriorSpecialAttackEffect extends Component with ParentIsA<Warrior> {
  // with ParentIsA<Enemy> {
  /// The duration of the effect
  final effectTime = 0.5;

  final Enemy enemy;

  WarriorSpecialAttackEffect({
    required this.enemy,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the sprite
    final sprite = await Sprite.load(
      'attacks/sword.png',
    );

    // Instantiate the sword component
    final sword = SpriteComponent(
      sprite: sprite,
      size: Vector2(166, 180),
      anchor: Anchor.bottomCenter,
    );

    // Set the position under the enemy
    sword.position = Vector2(enemy.position.x, enemy.position.y + enemy.size.y);

    // Add the sword to the world
    parent.world.add(sword);

    // Add the effect to the sword
    sword.add(
      // Move the sword up
      MoveByEffect(
        Vector2(0, -100),
        EffectController(
          duration: effectTime,
          curve: Curves.easeInOut,
        ),
        onComplete: () => sword.removeFromParent(),
      ),
    );
  }
}
