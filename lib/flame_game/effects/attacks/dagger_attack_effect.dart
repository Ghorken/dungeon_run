import 'package:flame/components.dart';

import 'package:dungeon_run/flame_game/components/characters/assassin.dart';

/// The DaggerAttackEffect is an effect that is composed of multiple different effects
/// that are added to the Assassin when it attacks.
/// It teleport the Assassin to the enemy and back in the original position.
class DaggerAttackEffect extends Component with ParentIsA<Assassin> {
  // The duration of the effect
  final effectTime = 0.5;

  // The destination of the movement
  final Vector2 destination;

  DaggerAttackEffect({
    required this.destination,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Make the parent invisible
    parent.opacity = 0;

    // Load the sprite
    final sprite = await Sprite.load(
      'characters/assassin.png',
    );

    // Instantiate the image of the assassin to attack the enemy
    final assassin = SpriteComponent(
      sprite: sprite,
      size: Vector2(100, 150),
      anchor: Anchor.center,
    );

    // The assassin should appear at the enemy position
    assassin.position = destination;

    // Add the assassin to the parent's world
    parent.world.add(assassin);

    // When the effect is finished remove the attack image and make the original assassin reappear
    Future.delayed(
      Duration(
        milliseconds: (effectTime * 300).toInt(),
      ),
      () {
        assassin.removeFromParent();
        parent.opacity = 1;
      },
    );
  }
}
