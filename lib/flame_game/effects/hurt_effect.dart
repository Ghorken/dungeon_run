import 'dart:math';

import 'package:dungeon_run/flame_game/components/character.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// The [HurtEffect] is an effect that is composed of multiple different effects
/// that are added to the [Character] when it is hurt.
/// It spins the character and makes it blink in white.
class HurtEffect extends Component with ParentIsA<Character> {
  @override
  void onMount() {
    super.onMount();
    const effectTime = 0.5;
    parent.addAll(
      [
        RotateEffect.by(
          pi * 2,
          EffectController(
            duration: effectTime,
            curve: Curves.easeInOut,
          ),
        ),
        ColorEffect(
          Colors.white,
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
