import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:dungeon_run/flame_game/components/characters/character.dart';

/// The [HurtEffect] is an effect that is composed of multiple different effects
/// that are added to the [Character] when it is hurt.
/// It spins the character and makes it blinks in white.
class HurtEffect extends Component with ParentIsA<Character> {
  /// The duration of the effect
  final double effectTime = 0.5;

  @override
  void onMount() {
    super.onMount();

    // When the lifePoints of the player goes to 0 or less the player loose
    //TODO: ha senso che ogni effetto faccia il controllo invece che il mondo stesso?
    if (parent.world.lifePoints <= 0) {
      parent.world.loose();
    } else {
      parent.addAll(
        [
          // Rotate the character by 360°
          RotateEffect.by(
            pi * 2,
            EffectController(
              duration: effectTime,
              curve: Curves.easeInOut,
            ),
          ),
          // Make che character blinks in white
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
}
