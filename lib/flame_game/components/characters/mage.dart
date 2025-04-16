import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:dungeon_run/flame_game/effects/attacks/mage_attack_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// The class that handles the attack and the damage of the Wizard
/// The Wizard attacks a random enemy in the middle area of the screen
/// and damages near enemies
class Mage extends Character {
  Mage({
    super.position,
    required super.maxLifePoints,
    required super.damage,
    required super.cooldownTimer,
  }) : super(
          lifePoints: maxLifePoints,
        );

  @override
  Future<void> onLoad() async {
    // This defines the different animation states that the character can be in.
    animations = {
      CharacterState.running: await game.loadSpriteAnimation(
        'characters/wizard.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(250, 394),
          stepTime: 0.15,
        ),
      ),
    };

    /// The starting state will be that the character is running.
    current = CharacterState.running;

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing it.
    add(CircleHitbox());

    // The player lifebar to the screen
    // The dimension of every segment depends from the screen and how many max lifepoint the player has
    add(
      LifeBar(
        segmentWidth: size.x / maxLifePoints,
        color: Colors.green,
        parentComponent: this,
      ),
    );
  }

  @override
  void attack() {
    Enemy? closestEnemy;
    double closestDistance = double.infinity;

    // Cycle through the enemies in the screen to find the nearest one in range
    for (final Enemy enemy in world.enemies) {
      if (enemy.position.y > -200 && enemy.position.y < 400) {
        final double distance = enemy.position.y;
        if (distance < closestDistance) {
          closestDistance = distance;
          closestEnemy = enemy;
        }
      }
    }

    // If there is one attack it
    if (closestEnemy != null) {
      add(MageAttackEffect(destination: closestEnemy.position));
      closestEnemy.hitted(damage);

      // Cycle through the enemies in the screen to find the ones that are near the target
      final List<Enemy> nearbyEnemies = world.enemies
          .where((Enemy enemy) =>
              enemy != closestEnemy && // Exclude the target enemy itself
              enemy.position.distanceTo(closestEnemy!.position) < 200)
          .toList();

      // Apply damage to all nearby enemies
      for (final Enemy nearEnemy in nearbyEnemies) {
        nearEnemy.hitted(damage);
      }

      game.audioController.playSfx(SfxType.score);
    }
  }

  @override
  void specialAttack() {
    // Retrieve every enemy in range
    final List<Enemy> enemiesToAttack = List<Enemy>.from(world.enemies).where((Enemy enemy) => enemy.position.y > -200 && enemy.position.y < 400).toList();
    if (enemiesToAttack.isNotEmpty) {
      // Attack them
      for (final Enemy enemy in enemiesToAttack) {
        enemy.hitted(damage);
        add(MageAttackEffect(destination: enemy.position));

        // Cycle through the enemies in the screen to find the ones that are near the target
        final List<Enemy> nearbyEnemies = world.enemies
            .where((Enemy nearEnemy) =>
                nearEnemy != enemy && // Exclude the target enemy itself
                nearEnemy.position.distanceTo(enemy.position) < 200)
            .toList();

        // Apply damage to all nearby enemies
        for (final Enemy nearEnemy in nearbyEnemies) {
          nearEnemy.hitted(damage);
        }
      }

      game.audioController.playSfx(SfxType.score);
    }
  }
}
