import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:dungeon_run/flame_game/components/characters/warrior.dart';

/// The SwordAttackEffect is an effect that is composed of multiple different effects
/// that are added to the Warrior when it attacks.
/// It spins the sword in front of the Warrior.
class WarriorAttackEffect extends Component with ParentIsA<Warrior> {
  /// The duration of the effect
  final effectTime = 0.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the sprite
    final sprite = await Sprite.load(
      'attacks/sword.png',
    );

    // Instantiate the sword component, rotated by 90°
    final sword = SpriteComponent(
      sprite: sprite,
      size: Vector2(166, 180),
      anchor: Anchor.bottomCenter,
      angle: -pi / 2,
    );

    // Set the position relative to the parent
    sword.position = Vector2(parent.size.x / 2, 0);

    // Add the sword to the parent
    parent.add(sword);

    // Add the effect to the sword
    sword.add(
      // Rotate the sword by 180°
      RotateEffect.by(
        pi,
        EffectController(
          duration: effectTime,
          curve: Curves.easeInOut,
        ),
        onComplete: () => sword.removeFromParent(),
      ),
    );
  }
}
