import 'package:dungeon_run/flame_game/components/characters/archer.dart';
import 'package:dungeon_run/flame_game/components/characters/assassin.dart';
import 'package:dungeon_run/flame_game/components/characters/berserk.dart';
import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/components/characters/warrior.dart';
import 'package:dungeon_run/flame_game/components/characters/mage.dart';
import 'package:dungeon_run/navigation/endless_runner.dart';
import 'package:dungeon_run/navigation/endless_world.dart';
import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/store/upgrade.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_rive/flame_rive.dart';

/// The [Character] is the component that the player controls by tapping on it to make it attack
/// It's abstract so that could not be instantiated and the single characters can extends it
abstract class Character extends RiveComponent with CollisionCallbacks, HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner>, TapCallbacks {
  Character({
    required this.damage,
    required this.maxLifePoints,
    required this.lifePoints,
    required this.cooldownTimer,
    required super.artboard,
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  /// The max lifePoints of the character
  final double maxLifePoints;

  /// The current lifePoints of the player
  double lifePoints;

  /// The amount of damage that the attack does
  double damage;

  /// If the character can receive damage or not
  bool invincible = false;

  /// Cooldown for the special attack
  int cooldownTimer;

  @override
  Future<void> onLoad();

  /// Handles the character being hitted
  /// [damage] is the amount of damage that the character should take
  /// If the character is invincible it will not take damage and the invincible effect will be played
  /// If the character is not invincible it will take damage and the hurt effect will be played
  /// If the character lifePoints go to 0 the die function will be called
  void hit(int damage) {
    if (invincible) {
      game.audioController.playSfx(SfxType.damage);
    } else {
      game.audioController.playSfx(SfxType.damage);
      lifePoints -= damage;

      // When the character lifePoints go to 0 kill the character
      if (lifePoints <= 0) {
        die();
      }
    }
  }

  /// Apply the death effect and then remove the character from the screen
  void die() {
    // Remove the character from the list and add it to the new list
    final int index = world.characters.indexOf(this);
    if (index != -1) {
      world.characters[index] = null;
    }
    world.deadCharacters[index] = this;

    // We remove the enemy from the screen after the effect has been played.
    Future.delayed(
      Duration(
        milliseconds: 500,
      ),
      () => removeFromParent(),
    );

    if (world.characters.nonNulls.isEmpty) {
      world.loose();
    }
  }

  /// The abstract attack function that every character should implement
  void attack();

  /// The abstract special attack function that every character should implement
  void specialAttack();

  // If the player taps on a character, we make it attack.
  @override
  void onTapDown(TapDownEvent event) {
    attack();
  }
}

/// The possible states of the character
enum CharacterState {
  running,
  attacking,
}

/// Create a character based on its type and on the upgrades that the player has bought
/// [type] is the type of the character to create
/// [position] is the position of the character in the screen
/// [upgrades] is the map of the upgrades that the player has bought
Future<Character> createCharacter(CharacterType type, Vector2 position, List<Upgrade> upgrades) async {
  switch (type) {
    case CharacterType.warrior:
      Upgrade warriorLife = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'warrior_life');
      Upgrade warriorDamage = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'warrior_damage');
      Upgrade warriorSpecial = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'warrior_special');
      final int life = warriorLife.currentLevel;
      final double lifeStep = warriorLife.step!;
      final int damage = warriorDamage.currentLevel;
      final double damageStep = warriorDamage.step!;
      final int baseCooldown = warriorSpecial.baseCooldown!;
      final int special = warriorSpecial.currentLevel;
      final double specialStep = warriorSpecial.step!;

      return Warrior(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
        artboard: await loadArtboard(RiveFile.asset('assets/animations/warrior.riv')),
      );
    case CharacterType.archer:
      Upgrade archerLife = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'archer_life');
      Upgrade archerDamage = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'archer_damage');
      Upgrade archerSpecial = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'archer_special');
      final int life = archerLife.currentLevel;
      final double lifeStep = archerLife.step!;
      final int damage = archerDamage.currentLevel;
      final double damageStep = archerDamage.step!;
      final int baseCooldown = archerSpecial.baseCooldown!;
      final int special = archerSpecial.currentLevel;
      final double specialStep = archerSpecial.step!;

      return Archer(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
        artboard: await loadArtboard(RiveFile.asset('assets/animations/warrior.riv')),
      );
    case CharacterType.mage:
      Upgrade mageLife = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'mage_life');
      Upgrade mageDamage = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'mage_damage');
      Upgrade mageSpecial = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'mage_special');
      final int life = mageLife.currentLevel;
      final double lifeStep = mageLife.step!;
      final int damage = mageDamage.currentLevel;
      final double damageStep = mageDamage.step!;
      final int baseCooldown = mageSpecial.baseCooldown!;
      final int special = mageSpecial.currentLevel;
      final double specialStep = mageSpecial.step!;

      return Mage(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
        artboard: await loadArtboard(RiveFile.asset('assets/animations/warrior.riv')),
      );
    case CharacterType.assassin:
      Upgrade assassinLife = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'assassin_life');
      Upgrade assassinDamage = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'assassin_damage');
      Upgrade assassinSpecial = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'assassin_special');
      final int life = assassinLife.currentLevel;
      final double lifeStep = assassinLife.step!;
      final int damage = assassinDamage.currentLevel;
      final double damageStep = assassinDamage.step!;
      final int baseCooldown = assassinSpecial.baseCooldown!;
      final int special = assassinSpecial.currentLevel;
      final double specialStep = assassinSpecial.step!;

      return Assassin(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
        artboard: await loadArtboard(RiveFile.asset('assets/animations/warrior.riv')),
      );
    case CharacterType.berserk:
      Upgrade berserkLife = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'berserk_life');
      Upgrade berserkDamage = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'berserk_damage');
      Upgrade berserkSpecial = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'berserk_special');
      final int life = berserkLife.currentLevel;
      final double lifeStep = berserkLife.step!;
      final int damage = berserkDamage.currentLevel;
      final double damageStep = berserkDamage.step!;
      final int baseCooldown = berserkSpecial.baseCooldown!;
      final int special = berserkSpecial.currentLevel;
      final double specialStep = berserkSpecial.step!;

      return Berserk(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
        artboard: await loadArtboard(RiveFile.asset('assets/animations/warrior.riv')),
      );
  }
}
