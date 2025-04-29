import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:dungeon_run/flame_game/effects/special_attacks/warrior_special_attack_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// The class that handles the attack and the damage of the Warrior
/// The Warrior attacks the closest enemy in the bottom area of the screen
class Warrior extends Character {
  Warrior({
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
        'characters/warrior_walk.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(192, 192),
          stepTime: 0.15,
        ),
      ),
      CharacterState.attacking: await game.loadSpriteAnimation(
        'characters/warrior_attack.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          amountPerRow: 3,
          textureSize: Vector2(192, 192),
          stepTime: 0.15,
        ),
      ),
    };

    size = Vector2.all(200);

    /// The starting state will be that the character is running.
    current = CharacterState.running;

    // Add the hitbox to the character
    add(
      CircleHitbox(
        isSolid: true,
        radius: 50,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2),
      ),
    );

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

    // Cycle through the enemies at the bottom of the screen to find the nearest one in range
    // (I'm not looking only at the distance from the character to avoid to not been able to attack enemies that
    // are in the bottom area but too distant from the character)
    for (final Enemy enemy in world.enemies) {
      final double distance = enemy.distance(this);
      // Check the distance between the character and the enemy
      if (enemy.distance(this) < 100) {
        if (distance < closestDistance) {
          closestDistance = distance;
          closestEnemy = enemy;
        }
      }
    }

    // If there is one attack it
    if (closestEnemy != null) {
      // Change the state to attacking
      current = CharacterState.attacking;

      // Apply damage to the closest enemy
      closestEnemy.hitted(damage);

      // Play the attack sound effect
      game.audioController.playSfx(SfxType.score);

      // Revert the state back to running after 0.5 seconds
      Future.delayed(const Duration(milliseconds: 500), () {
        current = CharacterState.running;
      });
    }
  }

  @override
  void specialAttack() {
    // Retrieve every enemy in range
    final List<Enemy> enemiesToAttack = List<Enemy>.from(world.enemies).where((Enemy enemy) => enemy.position.y > 400).toList();
    if (enemiesToAttack.isNotEmpty) {
      // Attack them
      for (final Enemy enemy in enemiesToAttack) {
        enemy.hitted(damage);
        add(WarriorSpecialAttackEffect(enemy: enemy));
      }

      game.audioController.playSfx(SfxType.score);
    }
  }
}
