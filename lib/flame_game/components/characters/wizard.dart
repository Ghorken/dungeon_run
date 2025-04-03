import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/wizard_attack_effect.dart';

/// The class that handles the attack and the damage of the Wizard
/// The Wizard attacks a random enemy in the middle area of the screen
/// and damages near enemies
class Wizard extends Character {
  Wizard({
    super.position,
    required super.maxLifePoints,
    required super.damage,
    required super.cooldownTimer,
  }) : super(
          srcImage: 'characters/wizard.png',
          lifePoints: maxLifePoints,
        );

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
      add(WizardAttackEffect(destination: closestEnemy.position));
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
        add(WizardAttackEffect(destination: enemy.position));

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
