import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/trap.dart';
import 'package:dungeon_run/flame_game/effects/hurt_effect.dart';
import 'package:dungeon_run/flame_game/endless_runner.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// The [Character] is the component that the physical character of the game is
/// controlling.
abstract class Character extends SpriteAnimationGroupComponent<CharacterState> with CollisionCallbacks, HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner> {
  Character({
    required this.srcImage,
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          priority: 1,
        );

  final String srcImage;
  int lifePoints = 10;

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
    // The starting state will be that the character is running.
    current = CharacterState.running;

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing
    // it.
    add(CircleHitbox());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // When the character collides with an obstacle it should increment the hitted counter.
    if (other is Trap && world.traps.contains(other)) {
      game.audioController.playSfx(SfxType.damage);
      add(HurtEffect(damage: other.damage));
    }
  }

  void attack();
}

enum CharacterState {
  running,
}

enum CharacterType {
  warrior,
  archer,
  wizard,
  assassin,
  berserk,
}
