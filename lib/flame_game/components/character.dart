import 'package:dungeon_run/flame_game/effects/attack_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../audio/sounds.dart';
import '../effects/hurt_effect.dart';
import '../endless_runner.dart';
import '../endless_world.dart';
import '../components/enemy.dart';

/// The [Character] is the component that the physical character of the game is
/// controlling.
class Character extends SpriteAnimationGroupComponent<CharacterState> with CollisionCallbacks, HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner> {
  Character({
    required this.addPotion,
    required this.addHitted,
    required this.addBlow,
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          priority: 1,
        );

  final void Function({int amount}) addPotion;
  final void Function({int amount}) addHitted;
  final void Function({int amount}) addBlow;

  @override
  Future<void> onLoad() async {
    // This defines the different animation states that the character can be in.
    animations = {
      CharacterState.running: await game.loadSpriteAnimation(
        'characters/warrior.png',
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
    if (other is Enemy && world.enemies.contains(other)) {
      game.audioController.playSfx(SfxType.damage);
      addHitted();
      add(HurtEffect());
    }
  }

  void attack() {
    // When the character attacks it should flash its sword and check if it hits any enemies.
    add(AttackEffect());
    // Create a list of enemies and relative position to the character
    final List<MapEntry<Enemy, double>> enemies = world.enemies.map((Enemy enemy) => MapEntry(enemy, enemy.position.distanceTo(position))).toList();
    // Sort the enemies by distance to the character
    enemies.sort((a, b) => a.value.compareTo(b.value));

    for (final enemy in enemies) {
      if (enemy.value < 300) {
        enemy.key.hitted();
        addBlow();
        game.audioController.playSfx(SfxType.score);
        break;
      }
    }
  }
}

enum CharacterState {
  running,
}
