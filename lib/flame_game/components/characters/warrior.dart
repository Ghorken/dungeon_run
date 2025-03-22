import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/sword_attack_effect.dart';

class Warrior extends Character {
  Warrior({
    super.position,
  }) : super(srcImage: 'characters/warrior.png');

  @override
  void attack() {
    // When the character attacks it should flash its sword and check if it hits any enemies.
    // Create a list of enemies and relative position to the character
    final List<MapEntry<Enemy, double>> enemies = world.enemies.map((Enemy enemy) => MapEntry(enemy, enemy.position.distanceTo(position))).toList();
    // Sort the enemies by distance to the character
    enemies.sort((a, b) => a.value.compareTo(b.value));

    for (final enemy in enemies) {
      // The warrior can only hit enemies that are in short range
      if (enemy.value < 300) {
        add(SwordAttackEffect());
        enemy.key.hitted();
        game.audioController.playSfx(SfxType.score);
        break;
      }
    }
  }
}
