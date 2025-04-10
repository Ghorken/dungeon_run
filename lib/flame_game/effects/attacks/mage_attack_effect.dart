import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:dungeon_run/flame_game/components/characters/mage.dart';

/// The MagicAttackEffect is an effect that is composed of multiple different effects
/// that are added to the Wizard when it attacks.
/// It enlarge the magic while moving to the enemy.
class MageAttackEffect extends Component with ParentIsA<Mage> {
  /// The duration of the effect
  final effectTime = 0.5;

  /// The destination of the movement
  final Vector2 destination;

  MageAttackEffect({
    required this.destination,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the sprite
    final sprite = await Sprite.load(
      'attacks/fireball.png',
    );

    // Create the magic component
    final magic = SpriteComponent(
      sprite: sprite,
      size: Vector2(20, 30),
      anchor: Anchor.center,
      angle: pi,
    );

    // The magic should start from the character
    magic.position = parent.position;

    // Add the magic to the parent'sworld
    parent.world.add(magic);

    // Add the effect to the magic
    magic.addAll([
      // Enlarge the magic
      SizeEffect.to(
        Vector2(200, 197),
        EffectController(
          duration: effectTime,
        ),
      ),
      // Move to the enemy target
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
