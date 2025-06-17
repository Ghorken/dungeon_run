import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:dungeon_run/flame_game/effects/special_attacks/warrior_special_attack_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// The class that handles the attack and the damage of the Warrior
/// The Warrior attacks the closest enemy in the bottom area of the screen
class Warrior extends Character {
  Warrior({
    super.position,
    required super.maxLifePoints,
    required super.damage,
    required super.cooldownTimer,
    required super.artboard,
  }) : super(
          lifePoints: maxLifePoints,
        );

  /// The input for the attack animation
  SMITrigger? _attackInput;

  /// The input for the hitted animation
  SMITrigger? _hittedInput;

  @override
  Future<void> onLoad() async {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "Warrior",
    );

    _attackInput = controller?.getTriggerInput('Attack');
    _hittedInput = controller?.getTriggerInput('Hitted');

    artboard.addController(controller!);

    size = Vector2.all(100);

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
      _attackInput?.fire();

      // Apply damage to the closest enemy
      closestEnemy.hitted(damage);

      // Play the attack sound effect
      game.audioController.playSfx(SfxType.score);
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

  @override
  void hit(int damage) {
    super.hit(damage);

    _hittedInput?.fire();
  }
}
