import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:dungeon_run/flame_game/components/trap.dart';

/// The [DisableEffect] is an effect that is composed of multiple different effects
/// that are added to the [Trap] when it is disable.
/// It makes it blink in grey.
class DisableEffect extends Component with ParentIsA<Trap> {
  /// The duration of the effect
  final effectTime = 0.5;

  @override
  void onMount() {
    super.onMount();
    parent.addAll(
      [
        // Make the trap blink in grey
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
