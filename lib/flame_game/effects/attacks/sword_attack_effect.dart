import 'dart:math';

import 'package:dungeon_run/flame_game/components/characters/warrior.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

/// The [SwordAttackEffect] is an effect that is composed of multiple different effects
/// that are added to the [Warrior] when it attacks.
/// It spins the sword.
class SwordAttackEffect extends Component with ParentIsA<Warrior> {
  final effectTime = 0.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('attacks/sword.png');

    final sword = SpriteComponent(
      sprite: sprite,
      size: Vector2(166, 180),
      anchor: Anchor.bottomCenter,
      angle: -pi / 2,
    );

    sword.position = Vector2(parent.size.x / 2, 0);

    parent.add(sword);

    sword.add(
      RotateEffect.by(
        tau / 2,
        EffectController(
          duration: effectTime,
          curve: Curves.easeInOut,
        ),
        onComplete: () => sword.removeFromParent(),
      ),
    );
  }
}
