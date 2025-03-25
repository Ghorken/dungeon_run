import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/magic_attack_effect.dart';

/// The class that handles the attack and the damage of the Wizard
/// The Wizard attacks a random enemy in the middle area of the screen
/// and damages near enemies
class Wizard extends Character {
  Wizard({
    super.position,
  }) : super(
          srcImage: 'characters/wizard.png',
          damage: 2,
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
      add(MagicAttackEffect(destination: closestEnemy.position));
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
}
