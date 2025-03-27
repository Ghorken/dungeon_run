import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/berserk_attack_effect.dart';

/// The class that handles the attack and the damage of the Berserk
/// The Berserk attacks the closest enemy in the middle area of the screen
class Berserk extends Character {
  Berserk({
    super.position,
  }) : super(
          srcImage: 'characters/berserk.png',
          damage: 3,
          maxLifePoints: 20,
          lifePoints: 20,
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
      add(BerserkAttackEffect(destination: closestEnemy.position));
      closestEnemy.hitted(damage);
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
        add(BerserkAttackEffect(destination: enemy.position));
      }

      game.audioController.playSfx(SfxType.score);
    }
  }
}
