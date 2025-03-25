import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:dungeon_run/flame_game/components/characters/archer.dart';

/// The BowAttackEffect is an effect that is composed of multiple different effects
/// that are added to the Archer when it attacks.
/// It moves the arrow from the Archer to the enemy.
class BowAttackEffect extends Component with ParentIsA<Archer> {
  /// The duration of the effect
  final effectTime = 0.5;

  /// The destination of the movement
  final Vector2 destination;

  BowAttackEffect({
    required this.destination,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the sprite
    final sprite = await Sprite.load(
      'attacks/arrow.png',
    );

    // Instantiate the arrow
    final arrow = SpriteComponent(
      sprite: sprite,
      size: Vector2(40, 45),
      anchor: Anchor.center,
    );

    // The arrow should start from the character
    arrow.position = parent.position;

    // Add the arrow to the parent's world
    parent.world.add(arrow);

    // Move the arrow to the destination and remove from the world when it reaches it
    arrow.add(
      MoveToEffect(
        destination,
        EffectController(
          duration: effectTime,
        ),
        onComplete: () => arrow.removeFromParent(),
      ),
    );
  }
}
