import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/bow_attack_effect.dart';

class Archer extends Character {
  Archer({
    super.position,
  }) : super(
          srcImage: 'characters/archer.png',
          damage: 1,
        );

  @override
  void attack() {
    // When the character attacks it should launch its arrow and check if it hits any enemies.
    // Create a list of enemies and relative position to the character
    final List<MapEntry<Enemy, double>> enemies = world.enemies.map((Enemy enemy) => MapEntry(enemy, enemy.position.distanceTo(position))).toList();
    // Sort the enemies by distance to the character
    enemies.sort((a, b) => a.value.compareTo(b.value));

    for (final enemy in enemies) {
      // The archer can only hit enemies that are in mid range
      if (enemy.value > 1000) {
        add(BowAttackEffect(destination: enemy.key.position));
        enemy.key.hitted(damage);
        game.audioController.playSfx(SfxType.score);
        break;
      }
    }
  }
}
