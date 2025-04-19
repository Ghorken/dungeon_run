import 'package:dungeon_run/flame_game/components/collectables/collectable.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable_type.dart';
import 'package:dungeon_run/navigation/endless_world.dart';
import 'package:flame/components.dart';

/// The class that handles the skow effect of the [Collectable]
class Slow extends Collectable {
  Slow({
    required this.duration,
    required this.velocity,
  }) : super(
          srcImage: 'collectables/slow.png',
          size: Vector2.all(150),
          anchor: Anchor.center,
          type: CollectableType.slow,
        );

  /// How many seconds the effect should last
  final double duration;

  /// The amount of velocity that the [Collectable] remove from the enemies
  final double velocity;

  @override
  void effect() {
    // Capture the world reference to access it in the onTick callback
    final EndlessWorld currentWorld = world;

    currentWorld.speed = currentWorld.speed / velocity;

    // Schedule the reversal of the effect after the duration
    currentWorld.add(
      TimerComponent(
        period: duration,
        repeat: false,
        onTick: () {
          currentWorld.speed *= velocity; // Revert the speed boost

          removeFromParent();
        },
      ),
    );
  }
}
