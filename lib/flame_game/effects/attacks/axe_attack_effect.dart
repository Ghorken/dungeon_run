import 'dart:math';

import 'package:dungeon_run/flame_game/components/characters/berserk.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// The [AxeAttackEffect] is an effect that is composed of multiple different effects
/// that are added to the [Berserk] when it attacks.
/// It spins the sword.
class AxeAttackEffect extends Component with ParentIsA<Berserk> {
  final effectTime = 0.5;
  final Vector2 destination;

  AxeAttackEffect({
    required this.destination,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('attacks/axe.png');

    final arrow = SpriteComponent(
      sprite: sprite,
      size: Vector2(40, 45),
      anchor: Anchor.bottomCenter,
    );

    // The arrow should start at the bottom of the character
    arrow.position = parent.position + Vector2(0, -parent.size.y / 2);

    parent.parent?.add(arrow);

    // Move the arrow to the destination and remove from the world when it reaches it
    arrow.addAll(
      [
        RotateEffect.by(
          pi,
          EffectController(
            duration: effectTime,
          ),
        ),
        MoveToEffect(
          destination,
          EffectController(
            duration: effectTime,
          ),
          onComplete: () => arrow.removeFromParent(),
        ),
      ],
    );
  }
}
