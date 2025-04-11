import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';

/// The [DeathEffect] is an effect that is composed of multiple different effects
/// that are added to the [Enemy] when it is killed.
/// It fades the enemy and makes it blink in red.
class DeathEffect extends Component {
  /// The duration of the effect
  final effectTime = 0.5;

  @override
  void onMount() {
    super.onMount();
    parent!.addAll(
      [
        // Make the enemy scale down to 0.0
        OpacityEffect.to(
          0.0,
          EffectController(
            duration: effectTime,
            curve: Curves.easeInOut,
          ),
        ),
        // Make the enemy blinks in red
        ColorEffect(
          Colors.red,
          EffectController(
            duration: effectTime / 8,
            alternate: true,
            repeatCount: 2,
          ),
          opacityTo: 0.9,
        ),
      ],
    );
  }
}
