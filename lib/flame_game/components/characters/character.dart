import 'package:dungeon_run/flame_game/components/characters/archer.dart';
import 'package:dungeon_run/flame_game/components/characters/assassin.dart';
import 'package:dungeon_run/flame_game/components/characters/berserk.dart';
import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/components/characters/warrior.dart';
import 'package:dungeon_run/flame_game/components/characters/wizard.dart';
import 'package:dungeon_run/flame_game/components/trap.dart';
import 'package:dungeon_run/flame_game/effects/hurt_effect.dart';
import 'package:dungeon_run/flame_game/endless_runner.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:dungeon_run/audio/sounds.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// The [Character] is the component that the player controls by tapping on it to make it attack
/// It's abstract so that could not be instantiated and the single characters can extends it
abstract class Character extends SpriteAnimationGroupComponent<CharacterState> with CollisionCallbacks, HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner> {
  Character({
    required this.srcImage,
    required this.damage,
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          priority: 1,
        );

  /// The image to show
  final String srcImage;

  /// The amount of damage that the attack does
  int damage;

  @override
  Future<void> onLoad() async {
    // This defines the different animation states that the character can be in.
    animations = {
      CharacterState.running: await game.loadSpriteAnimation(
        srcImage,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(250, 346),
          stepTime: 0.15,
        ),
      ),
    };

    /// The starting state will be that the character is running.
    current = CharacterState.running;

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing it.
    add(CircleHitbox());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // When the character collides with an obstacle it should receive damage.
    if (other is Trap && world.traps.contains(other)) {
      game.audioController.playSfx(SfxType.damage);
      world.lifePoints -= other.damage;
      add(HurtEffect());
    }
  }

  /// The abstract attack function that every character should implement
  void attack();
}

/// The possible states of the character
enum CharacterState {
  running,
}

/// Create a character based on its type
Character createCharacter(CharacterType type, Vector2 position) {
  switch (type) {
    case CharacterType.warrior:
      return Warrior(position: position);
    case CharacterType.archer:
      return Archer(position: position);
    case CharacterType.wizard:
      return Wizard(position: position);
    case CharacterType.assassin:
      return Assassin(position: position);
    case CharacterType.berserk:
      return Berserk(position: position);
  }
}
