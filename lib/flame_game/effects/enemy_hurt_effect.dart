import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';

/// The [EnemyHurtEffect] is an effect that is composed of multiple different effects
/// that are added to the [Enemy] when it is hurt.
/// It makes it blink in red.
class EnemyHurtEffect extends Component with ParentIsA<Enemy> {
  /// The duration of the effect
  final double effectTime = 0.5;

  @override
  void onMount() {
    super.onMount();

    // Make the enemy blink in red
    parent.add(
      ColorEffect(
        Colors.red,
        EffectController(
          duration: effectTime / 8,
          alternate: true,
          repeatCount: 2,
        ),
        opacityTo: 0.9,
      ),
    );
  }
}
