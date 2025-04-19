import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemies/elemental.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/enemies/goblin.dart';
import 'package:dungeon_run/flame_game/components/enemies/goblin_king.dart';
import 'package:dungeon_run/flame_game/components/enemies/troll.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/flame_game/effects/death_effect.dart';
import 'package:dungeon_run/flame_game/effects/enemy_hurt_effect.dart';
import 'package:dungeon_run/navigation/endless_runner.dart';
import 'package:dungeon_run/navigation/endless_world.dart';

/// The [Enemy] component can represent the different types of enemies
/// that the character can run into.
abstract class Enemy extends SpriteAnimationGroupComponent with HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner>, CollisionCallbacks {
  // Constructors for every tipe of enemy
  Enemy({
    required this.enemyGold,
    required this.isBoss,
    required this.damage,
    required this.actualSpeed,
    required this.speed,
    required this.lifePoints,
    required this.goldUpgradeLevel,
    this.enemyType,
    this.bossType,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  /// Factory method to create a random enemy.
  factory Enemy.random({
    required int goldUpgradeLevel,
    required List<EnemyType> enemies,
  }) {
    final EnemyType enemyType = enemies.random();
    switch (enemyType) {
      case EnemyType.goblin:
        return Goblin(goldUpgradeLevel: goldUpgradeLevel);
      case EnemyType.troll:
        return Troll(goldUpgradeLevel: goldUpgradeLevel);
      case EnemyType.elemental:
        return Elemental(goldUpgradeLevel: goldUpgradeLevel);
    }
  }

  // Factory method to create an enemy boss based on its type
  factory Enemy.boss({
    required int goldUpgradeLevel,
    required BossType type,
  }) {
    switch (type) {
      case BossType.goblinKing:
        return GoblinKing(goldUpgradeLevel: goldUpgradeLevel);
    }
  }

  /// The current lifePoints of the enemy
  double lifePoints;

  /// The speed of the enemy
  int speed;

  /// The actual speed of the enemy
  int actualSpeed;

  /// The damage that the enemy deal
  final int damage;

  /// Determine if the enemy is a boss or not
  final bool isBoss;

  /// The timer for periodic attacks
  TimerComponent? attackTimer;

  /// The factor to multiply the gold reward based on the enemy
  final int enemyGold;

  /// The level of the gold upgrade
  final int goldUpgradeLevel;

  /// The type of the enemy
  final EnemyType? enemyType;

  /// The type of the boss
  final BossType? bossType;

  @override
  Future<void> onLoad();

  @override
  void update(double dt) {
    super.update(dt);

    // We need to move the component to the bottom together with the speed that we
    // have set for the world.
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    position.y += (world.speed * actualSpeed) * dt;

    // When the component is no longer visible on the screen anymore, remove it.
    if (position.y - size.y > world.size.y / 2) {
      world.enemies.remove(this);
      removeFromParent();
    }
  }

  /// When the [Enemy] collides with a [Character] it should make damage
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent character,
  ) {
    super.onCollisionStart(intersectionPoints, character);

    // The [Enemy] should stop and the [Character] should receive periodic damage.
    if (character is Character && world.characters.contains(character)) {
      // Set the speed of the enemy to 0 to stop it
      actualSpeed = 0;

      current = EnemyState.attacking;
      // Start a timer to attack the character every second
      attackTimer = TimerComponent(
        period: 1.0, // Attack every second
        repeat: true,
        tickWhenLoaded: true,
        onTick: () {
          if (world.characters.contains(character)) {
            character.hit(damage);
          }
        },
      );
      add(attackTimer!);
    }
  }

  /// When the [Enemy] ends the collision with the [Character]
  @override
  void onCollisionEnd(
    PositionComponent character,
  ) {
    super.onCollisionEnd(character);

    current = EnemyState.running;

    // When the [Enemy] is not colliding with the [Character] because the [Character] died
    // The enemy should start move again
    actualSpeed = speed;
  }

  /// When the enemy is hit by the character we reduce the lifePoints and
  /// if the lifePoints are less than or equal to 0 we remove the enemy.
  void hitted(double damage) {
    lifePoints -= damage;
    if (lifePoints > 0) {
      add(EnemyHurtEffect());
    } else {
      die();
      // When the boss is defeated the player wins
      if (isBoss) {
        world.win();

        // Increment the amount of enemies killed
        world.trophyProvider.incrementBossesKilled();
      } else {
        // We need to increment the number of enemies killed
        world.trophyProvider.incrementEnemiesKilled(enemyType!);
      }
    }
  }

  /// When the enemy is killed by the character we remove the enemy.
  void die() {
    actualSpeed = 0;
    // We remove the enemy from the list so that it is no longer hittable even if still present on the screen.
    world.enemies.remove(this);
    DeathEffect deathEffect = DeathEffect();
    add(deathEffect);

    // We remove the enemy from the screen after the effect has been played.
    Future.delayed(
      Duration(
        milliseconds: (deathEffect.effectTime * 1000).toInt(),
      ),
      () => removeFromParent(),
    );

    // Add the gold to the total collected
    world.gold += (goldUpgradeLevel + 1) * enemyGold;
  }
}

/// The possible states of the character
enum EnemyState {
  running,
  attacking,
}
