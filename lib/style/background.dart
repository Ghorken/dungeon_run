import 'dart:math';

import 'package:dungeon_run/progression/level.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

/// The [Background] is a component that is composed of multiple scrolling
/// images which form a parallax, a way to simulate movement and depth in the
/// background.
class Background extends ParallaxComponent {
  Background({
    required this.level,
  });

  /// The level of the game
  final Level level;

  @override
  Future<void> onLoad() async {
    final layers = [
      ParallaxImageData('scenery/${level.map}.png'),
    ];

    // The base velocity sets the speed of the layer the farthest to the back.
    // Since the speed in our game is defined as the speed of the layer in the
    // front, where the character is, we have to calculate what speed the layer in
    // the back should have and then the parallax will take care of setting the
    // speeds for the rest of the layers.
    final baseVelocity = Vector2(0, 400 / pow(2, layers.length));

    // The multiplier delta is used by the parallax to multiply the speed of
    // each layer compared to the last, starting from the back. Since we only
    // want our layers to move in the Y-axis, we multiply by a value here
    // so that the speed of each layer is higher the closer to the screen it is.
    final velocityMultiplierDelta = Vector2(0.0, -1.0);

    parallax = await game.loadParallax(
      layers,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      filterQuality: FilterQuality.none,
      repeat: ImageRepeat.repeatY,
    );
  }
}
