import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable.dart';
import 'package:dungeon_run/navigation/endless_world.dart';
import 'package:flame/components.dart';

/// The class that handles the damage boost effect of the [Collectable]
class Damage extends Collectable {
  Damage({
    required this.duration,
    required this.damage,
  }) : super(
          srcImage: 'collectables/damage.png',
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  /// How many seconds the effect should last
  final double duration;

  /// The amount of damage that the [Collectable] add to the characters
  final double damage;

  @override
  void effect() {
    // Capture the world reference to access it in the onTick callback
    final EndlessWorld currentWorld = world;

    for (Character character in currentWorld.characters.nonNulls) {
      character.damage *= damage;
    }

    // Schedule the reversal of the effect after the duration
    currentWorld.add(
      TimerComponent(
        period: duration,
        repeat: false,
        onTick: () {
          // Revert the damage boost
          for (Character character in currentWorld.characters.nonNulls) {
            character.damage = character.damage / damage;
          }

          removeFromParent();
        },
      ),
    );
  }
}
