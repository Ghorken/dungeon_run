import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemies/minions/animated_armour.dart';
import 'package:dungeon_run/flame_game/components/enemies/bosses/balor.dart';
import 'package:dungeon_run/flame_game/components/enemies/bosses/bridge_guardian.dart';
import 'package:dungeon_run/flame_game/components/enemies/minions/elemental.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/enemies/minions/goblin.dart';
import 'package:dungeon_run/flame_game/components/enemies/bosses/goblin_king.dart';
import 'package:dungeon_run/flame_game/components/enemies/minions/imp.dart';
import 'package:dungeon_run/flame_game/components/enemies/minions/skeleton.dart';
import 'package:dungeon_run/flame_game/components/enemies/bosses/skeleton_executioner.dart';
import 'package:dungeon_run/flame_game/components/enemies/minions/troll.dart';
import 'package:dungeon_run/flame_game/components/enemies/minions/zombie.dart';
import 'package:dungeon_run/flame_game/components/enemies/bosses/zombie_chef.dart';
import 'package:dungeon_run/flame_game/components/enemies/minions/zombie_dog.dart';
import 'package:dungeon_run/utils/enemies_provider.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/flame_game/effects/death_effect.dart';
import 'package:dungeon_run/navigation/endless_runner.dart';
import 'package:dungeon_run/navigation/endless_world.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

/// The [Enemy] component can represent the different types of enemies
/// that the character can run into.
abstract class Enemy extends RiveComponent with HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner>, CollisionCallbacks {
  // Constructors for every tipe of enemy
  Enemy({
    required this.enemyGold,
    required this.isBoss,
    required this.damage,
    required this.actualSpeed,
    required this.speed,
    required this.lifePoints,
    required this.goldUpgradeLevel,
    required super.artboard,
    this.enemyType,
    this.bossType,
    this.targetCharacterIndex,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

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

  /// The current target of the boss
  int? targetCharacterIndex;

  @override
  void onLoad() {
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    targetCharacterIndex ??=
        world.characters.asMap().entries.where((MapEntry<int, Character?> entry) => entry.value != null).map((MapEntry<int, Character?> entry) => entry.key).toList().random();

    // If the enemy is a boss, we need to move towards the target character
    // If the enemy is not a boss, we need to move down

    // For the movement we need to calculate the speed based on the speed of the world
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    if (world.characters[targetCharacterIndex!] != null) {
      // If the enemy is a boss and has a target character, move towards it
      final Vector2 targetPosition = world.characters[targetCharacterIndex!]!.position;
      final Vector2 direction = (targetPosition - position).normalized();
      position += direction * (world.speed * actualSpeed) * dt;
    } else {
      // If the target character is null and there are other available targets, we need to find a new target
      if (world.characters.nonNulls.isNotEmpty) {
        targetCharacterIndex =
            world.characters.asMap().entries.where((MapEntry<int, Character?> entry) => entry.value != null).map((MapEntry<int, Character?> entry) => entry.key).toList().random();
      } else {
        // If there are no characters, we can just move down
        position.y += (world.speed * actualSpeed) * dt;
      }
    }

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

    // When the [Enemy] is not colliding with the [Character] because the [Character] died
    // The enemy should start move again
    actualSpeed = speed;
  }

  /// When the enemy is hit by the character we reduce the lifePoints and
  /// if the lifePoints are less than or equal to 0 we remove the enemy.
  void hitted(double damage) {
    lifePoints -= damage;

    // Define the floating damage number
    final TextComponent damageText = TextComponent(
      text: '$damage',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );

    // Add an effect to make the text float upwards and fade out
    damageText.add(
      MoveEffect.by(
        Vector2(0, -20), // Move upwards by 20 pixels
        EffectController(duration: 0.5),
        onComplete: () {
          // Remove the text after the effect is complete
          damageText.removeFromParent();
        },
      ),
    );

    // Add the damageText to the Enemy
    add(damageText);

    if (lifePoints <= 0) {
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

/// Factory method to create a random enemy.
// Future<Enemy>
void randomEnemy({
  required int goldUpgradeLevel,
  required List<EnemyType> enemies,
  required EnemiesProvider enemiesProvider,
}) async {
  final EnemyType enemyType = enemies.random();
  switch (enemyType) {
    case EnemyType.goblin:
      enemiesProvider.addEnemy(Goblin(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      ));
    case EnemyType.troll:
      enemiesProvider.addEnemy(Troll(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      ));
    case EnemyType.elemental:
      enemiesProvider.addEnemy(Elemental(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      ));
    case EnemyType.animatedArmour:
      enemiesProvider.addEnemy(AnimatedArmour(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      ));
    case EnemyType.imp:
      enemiesProvider.addEnemy(Imp(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      ));
    case EnemyType.zombie:
      enemiesProvider.addEnemy(Zombie(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      ));
    case EnemyType.zombieDog:
      enemiesProvider.addEnemy(ZombieDog(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      ));
    case EnemyType.skeleton:
      enemiesProvider.addEnemy(Skeleton(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      ));
  }
}

// Factory method to create an enemy boss based on its type
Future<Enemy> spawnBoss({
  required int goldUpgradeLevel,
  required BossType type,
}) async {
  switch (type) {
    case BossType.goblinKing:
      return GoblinKing(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      );
    case BossType.bridgeGuardian:
      return BridgeGuardian(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      );
    case BossType.balor:
      return Balor(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      );
    case BossType.zombieChef:
      return ZombieChef(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      );
    case BossType.skeletonExecutioner:
      return SkeletonExecutioner(
        goldUpgradeLevel: goldUpgradeLevel,
        artboard: await loadArtboard(RiveFile.asset('assets/animations/goblin.riv')),
      );
  }
}
