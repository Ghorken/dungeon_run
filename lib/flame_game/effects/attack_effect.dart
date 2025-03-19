import 'dart:math';

import 'package:dungeon_run/flame_game/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

/// The [AttackEffect] is an effect that is composed of multiple different effects
/// that are added to the [Player] when it attacks.
/// It spins the sword.
class AttackEffect extends Component with ParentIsA<Player> {
  final effectTime = 0.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final swordSprite = await Sprite.load('sword.png');

    final sword = SpriteComponent(
      sprite: swordSprite,
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
      ),
    );

    Future.delayed(Duration(milliseconds: (effectTime * 1000).toInt()), () {
      sword.removeFromParent();
    });
  }

  @override
  void onMount() {
    super.onMount();
    // parent.addAll(
    //   [
    //     RotateEffect.by(
    //       pi * 2,
    //       EffectController(
    //         duration: effectTime,
    //         curve: Curves.easeInOut,
    //       ),
    //     ),
    //   ],
    // );
  }
}
