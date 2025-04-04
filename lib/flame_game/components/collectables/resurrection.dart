import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/collectables/collectable.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

/// The class that handles the resurrection effect of the [Collectable]
class Resurrection extends Collectable {
  Resurrection({
    required this.fullHealt,
  }) : super(
          srcImage: 'collectables/resurrection.png',
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  /// If the resurrected character should be at full health or half health
  final bool fullHealt;

  @override
  void effect() {
    // Retrieve one of the dead and remove from the list
    if (world.deadCharacters.nonNulls.isNotEmpty) {
      int resurrectedCharacterIndex = world.deadCharacters.indexOf((world.deadCharacters.nonNulls as List<Character>).random());
      Character resurrectedCharacter = world.deadCharacters[resurrectedCharacterIndex]!;
      world.deadCharacters[resurrectedCharacterIndex] = null;
      // Add it to the alive list with half life points or full life points
      resurrectedCharacter.lifePoints = fullHealt ? resurrectedCharacter.maxLifePoints : (resurrectedCharacter.maxLifePoints / 2).toInt();
      world.characters[resurrectedCharacterIndex] = resurrectedCharacter;

      world.add(resurrectedCharacter);
    }

    removeFromParent();
  }
}
