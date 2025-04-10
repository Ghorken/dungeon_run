import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/warrior_attack_effect.dart';
import 'package:dungeon_run/flame_game/effects/attacks/warrior_special_attack_effect.dart';

/// The class that handles the attack and the damage of the Warrior
/// The Warrior attacks the closest enemy in the bottom area of the screen
class Warrior extends Character {
  Warrior({
    super.position,
    required super.maxLifePoints,
    required super.damage,
    required super.cooldownTimer,
  }) : super(
          srcImage: 'characters/warrior.png',
          lifePoints: maxLifePoints,
        );

  @override
  void attack() {
    Enemy? closestEnemy;
    double closestDistance = double.infinity;

    // Cycle through the enemies in the screen to find the nearest one in range
    for (final Enemy enemy in world.enemies) {
      if (enemy.position.y > 400) {
        final double distance = enemy.position.y;
        if (distance < closestDistance) {
          closestDistance = distance;
          closestEnemy = enemy;
        }
      }
    }

    // If there is one attack it
    if (closestEnemy != null) {
      add(WarriorAttackEffect());
      closestEnemy.hitted(damage);
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
}
