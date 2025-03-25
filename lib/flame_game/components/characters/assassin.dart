import 'package:flame/extensions.dart';

import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/effects/attacks/dagger_attack_effect.dart';

/// The class that handles the attack and the damage of the Assassin
/// The Assassin attacks a random enemy in the whole screen
class Assassin extends Character {
  Assassin({
    super.position,
  }) : super(
          srcImage: 'characters/assassin.png',
          damage: 1,
          maxLifePoints: 10,
          lifePoints: 10,
        );

  @override
  void attack() {
    // Select a random enemy on the screen and attack it
    if (world.enemies.isNotEmpty) {
      final Enemy enemy = world.enemies.random();

      add(DaggerAttackEffect(destination: enemy.position));
      enemy.hitted(damage);
      game.audioController.playSfx(SfxType.score);
    }
  }
}
