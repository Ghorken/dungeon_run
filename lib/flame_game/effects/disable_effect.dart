import 'package:dungeon_run/flame_game/components/trap.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// The [DisableEffect] is an effect that is composed of multiple different effects
/// that are added to the [Trap] when it is killed.
/// It spins the enemy and makes it blink in red.
class DisableEffect extends Component with ParentIsA<Trap> {
  final effectTime = 0.5;
  @override
  void onMount() {
    super.onMount();
    parent.addAll(
      [
        ColorEffect(
          Colors.grey,
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
