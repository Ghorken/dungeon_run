import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable_type.dart';
import 'package:flame/components.dart';

/// The class that handles the heal effect of the [Collectable]
class Heal extends Collectable {
  Heal({
    required this.healing,
  }) : super(
          srcImage: 'collectables/heal.png',
          size: Vector2.all(150),
          anchor: Anchor.center,
          type: CollectableType.heal,
        );

  /// The amount of healing that the [Collectable] does
  final double healing;

  @override
  void effect() {
    // Cycle through the characters in the screen to heal them
    for (Character character in world.characters.nonNulls) {
      character.lifePoints += healing;
      // If the lifePoints are greater than the maxLifePoints, set them to the maxLifePoints
      if (character.lifePoints > character.maxLifePoints) {
        character.lifePoints = character.maxLifePoints;
      }
    }

    removeFromParent();
  }
}
