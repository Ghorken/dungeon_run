import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/dagger_attack_effect.dart';
import 'package:flame/extensions.dart';

class Assassin extends Character {
  Assassin({
    super.position,
  }) : super(
          srcImage: 'characters/assassin.png',
          damage: 1,
        );

  @override
  void attack() {
    // When the character attacks it should flash its sword and check if it hits any enemies.
    // Create a list of enemies and relative position to the character
    final List<MapEntry<Enemy, double>> enemies = world.enemies.map((Enemy enemy) => MapEntry(enemy, enemy.position.distanceTo(position))).toList();
    // Choose one random enemy to attack
    if (enemies.isEmpty) {
      return;
    }
    final enemy = enemies.random();

    add(DaggerAttackEffect(destination: enemy.key.position));
    enemy.key.hitted(damage);
    game.audioController.playSfx(SfxType.score);
  }
}
