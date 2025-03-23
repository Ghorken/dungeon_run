import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/axe_attack_effect.dart';

class Berserk extends Character {
  Berserk({
    super.position,
  }) : super(
          srcImage: 'characters/berserk.png',
          damage: 2,
        );

  @override
  void attack() {
    // When the character attacks it should launch his axe and check if it hits any enemies.
    // Create a list of enemies and relative position to the character
    final List<MapEntry<Enemy, double>> enemies = world.enemies.map((Enemy enemy) => MapEntry(enemy, enemy.position.distanceTo(position))).toList();
    // Sort the enemies by distance to the character
    enemies.sort((a, b) => a.value.compareTo(b.value));

    for (final enemy in enemies) {
      if (enemy.value > 500 && enemy.value < 1000) {
        add(AxeAttackEffect(destination: enemy.key.position));
        enemy.key.hitted(damage);
        game.audioController.playSfx(SfxType.score);
        break;
      }
    }
  }
}
