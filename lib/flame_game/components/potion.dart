import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../endless_world.dart';

/// The [Potion] components are the components that the [Player] could collect.
class Potion extends SpriteAnimationComponent with HasGameReference, HasWorldReference<EndlessWorld> {
  Potion() : super(size: spriteSize, anchor: Anchor.center);

  static final Vector2 spriteSize = Vector2.all(100);
  late final DateTime timeStarted;

  @override
  Future<void> onLoad() async {
    timeStarted = DateTime.now();

    animation = await game.loadSpriteAnimation(
      'potion.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2(150, 249),
        stepTime: 0.15,
      ),
    );

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing
    // it.
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If it has passed 3 seconds since the potion was created, we remove it.
    if (DateTime.now().millisecondsSinceEpoch - timeStarted.millisecondsSinceEpoch > 3000) {
      removeFromParent();
    }
  }
}
