import 'dart:math';

import 'package:dungeon_run/flame_game/components/characters/wizard.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// The [MagicAttackEffect] is an effect that is composed of multiple different effects
/// that are added to the [Wizard] when it attacks.
/// It spins the sword.
class MagicAttackEffect extends Component with ParentIsA<Wizard> {
  final effectTime = 0.5;
  final Vector2 destination;

  MagicAttackEffect({
    required this.destination,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('attacks/fireball.png');

    final magic = SpriteComponent(
      sprite: sprite,
      size: Vector2(20, 30),
      anchor: Anchor.bottomCenter,
      angle: pi,
    );

    magic.position = parent.position + Vector2(0, -parent.size.y / 2);

    parent.parent?.add(magic);

    magic.addAll([
      SizeEffect.to(
        Vector2(200, 197),
        EffectController(
          duration: effectTime,
        ),
      ),
      MoveToEffect(
        destination,
        EffectController(
          duration: effectTime,
        ),
        onComplete: () => magic.removeFromParent(),
      ),
    ]);
  }
}
