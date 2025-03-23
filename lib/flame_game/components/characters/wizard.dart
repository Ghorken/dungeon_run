import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/magic_attack_effect.dart';

class Wizard extends Character {
  Wizard({
    super.position,
  }) : super(
          srcImage: 'characters/wizard.png',
          damage: 2,
        );

  @override
  void attack() {
    // When the character attacks it should cast its magic and check if it hits any enemies.
    // Create a list of enemies and relative position to the character
    final List<MapEntry<Enemy, double>> enemies = world.enemies.map((Enemy enemy) => MapEntry(enemy, enemy.position.distanceTo(position))).toList();
    // Sort the enemies by distance to the character
    enemies.sort((a, b) => a.value.compareTo(b.value));

    for (final MapEntry<Enemy, double> enemy in enemies) {
      if (enemy.value > 500 && enemy.value < 1000) {
        add(MagicAttackEffect(destination: enemy.key.position));
        enemy.key.hitted(damage);

        // Find all enemies near the target enemy (distance < 100)
        final List<Enemy> nearEnemies = enemies
            .where((MapEntry<Enemy, double> entry) =>
                entry.key != enemy.key && // Exclude the target enemy itself
                entry.key.position.distanceTo(enemy.key.position) < 200)
            .map((MapEntry<Enemy, double> entry) => entry.key)
            .toList();

        // Apply damage to all nearby enemies
        for (final Enemy nearEnemy in nearEnemies) {
          nearEnemy.hitted(damage);
        }

        game.audioController.playSfx(SfxType.score);
        break;
      }
    }
  }
}
