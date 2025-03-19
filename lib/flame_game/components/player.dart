import 'package:dungeon_run/flame_game/effects/attack_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../audio/sounds.dart';
import '../effects/hurt_effect.dart';
import '../endless_runner.dart';
import '../endless_world.dart';
import 'enemy.dart';

/// The [Player] is the component that the physical player of the game is
/// controlling.
class Player extends SpriteAnimationGroupComponent<PlayerState> with CollisionCallbacks, HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner> {
  Player({
    required this.addPotion,
    required this.addHit,
    required this.addKill,
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          priority: 1,
        );

  final void Function({int amount}) addPotion;
  final void Function({int amount}) addHit;
  final void Function({int amount}) addKill;

  @override
  Future<void> onLoad() async {
    // This defines the different animation states that the player can be in.
    animations = {
      PlayerState.running: await game.loadSpriteAnimation(
        'characters/warrior.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(250, 346),
          stepTime: 0.15,
        ),
      ),
    };
    // The starting state will be that the player is running.
    current = PlayerState.running;

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
    // When the player collides with an obstacle it should increment the hitted counter.
    if (other is Enemy && world.enemies.contains(other)) {
      game.audioController.playSfx(SfxType.damage);
      addHit();
      add(HurtEffect());
    }
  }

  void attack() {
    // When the player attacks it should flash its sword and check if it hits any enemies.
    add(AttackEffect());
    final enemies = world.enemies.where((enemy) => enemy.position.distanceTo(position) < 300);
    for (final enemy in enemies) {
      enemy.die();
      addKill();
      game.audioController.playSfx(SfxType.score);
      break;
    }
  }
}

enum PlayerState {
  running,
}
