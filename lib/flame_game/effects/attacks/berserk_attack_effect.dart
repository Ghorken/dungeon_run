import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:dungeon_run/flame_game/components/characters/berserk.dart';

/// The [BerserkAttackEffect] is an effect that is composed of multiple different effects
/// that are added to the [Berserk] when it attacks.
/// It launch the axe toward the [Enemy] and spin it.
class BerserkAttackEffect extends Component with ParentIsA<Berserk> {
  /// The duration of the effect
  final effectTime = 0.5;

  /// The destination of the movement
  final Vector2 destination;

  BerserkAttackEffect({
    required this.destination,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the sprite
    final sprite = await Sprite.load(
      'attacks/axe.png',
    );

    // Instantiate the axe component
    final axe = SpriteComponent(
      sprite: sprite,
      size: Vector2(40, 45),
      anchor: Anchor.center,
    );

    // The axe should start from the character
    axe.position = parent.position;

    // Add the axe to the world
    parent.world.add(axe);

    // Move the axe to the destination and remove from the world when it reaches it
    axe.addAll(
      [
        // Rotate the axe by 360°
        RotateEffect.by(
          pi * 2,
          EffectController(
            duration: effectTime,
          ),
        ),
        // Move the axe from the Berserk to the enemy
        MoveToEffect(
          destination,
          EffectController(
            duration: effectTime,
          ),
          onComplete: () => axe.removeFromParent(),
        ),
      ],
    );
  }
}
