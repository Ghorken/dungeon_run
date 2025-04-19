import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable_type.dart';
import 'package:dungeon_run/navigation/endless_world.dart';
import 'package:flame/components.dart';

/// The class that handles the invincibility effect of the [Collectable]
class Invincibility extends Collectable {
  Invincibility({
    required this.duration,
  }) : super(
          srcImage: 'collectables/invincibility.png',
          size: Vector2.all(150),
          anchor: Anchor.center,
          type: CollectableType.invincibility,
        );

  /// How many seconds the effect should last
  final double duration;

  @override
  void effect() {
    // Capture the world reference to access it in the onTick callback
    final EndlessWorld currentWorld = world;

    for (Character character in currentWorld.characters.nonNulls) {
      character.invincible = true;
    }

    // Schedule the reversal of the effect after the duration
    currentWorld.add(
      TimerComponent(
        period: duration,
        repeat: false,
        onTick: () {
          // Revert the invincible effect
          for (Character character in currentWorld.characters.nonNulls) {
            character.invincible = false;
          }
          removeFromParent();
        },
      ),
    );
  }
}
