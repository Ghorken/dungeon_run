import 'package:dungeon_run/flame_game/components/archer.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// The [BowAttackEffect] is an effect that is composed of multiple different effects
/// that are added to the [Archer] when it attacks.
/// It spins the sword.
class BowAttackEffect extends Component with ParentIsA<Archer> {
  final effectTime = 0.5;
  final Vector2 destination;

  BowAttackEffect({
    required this.destination,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('arrow.png');

    final arrow = SpriteComponent(
      sprite: sprite,
      size: Vector2(40, 45),
      anchor: Anchor.bottomCenter,
    );

    // The arrow should start at the bottom of the character
    arrow.position = parent.position + Vector2(0, -parent.size.y / 2);

    parent.parent?.add(arrow);

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
