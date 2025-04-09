import 'package:dungeon_run/flame_game/components/characters/archer.dart';
import 'package:dungeon_run/flame_game/components/characters/assassin.dart';
import 'package:dungeon_run/flame_game/components/characters/berserk.dart';
import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/components/characters/warrior.dart';
import 'package:dungeon_run/flame_game/components/characters/wizard.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:dungeon_run/flame_game/effects/death_effect.dart';
import 'package:dungeon_run/flame_game/effects/hurt_effect.dart';
import 'package:dungeon_run/flame_game/effects/invincible_effect.dart';
import 'package:dungeon_run/flame_game/endless_runner.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:dungeon_run/audio/sounds.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// The [Character] is the component that the player controls by tapping on it to make it attack
/// It's abstract so that could not be instantiated and the single characters can extends it
abstract class Character extends SpriteAnimationGroupComponent<CharacterState> with CollisionCallbacks, HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner> {
  Character({
    required this.srcImage,
    required this.damage,
    required this.maxLifePoints,
    required this.lifePoints,
    required this.cooldownTimer,
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          priority: 1,
        );

  /// The image to show
  final String srcImage;

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
  Future<void> onLoad() async {
    // This defines the different animation states that the character can be in.
    animations = {
      CharacterState.running: await game.loadSpriteAnimation(
        srcImage,
        SpriteAnimationData.sequenced(
          amount: 1,
          textureSize: Vector2(250, 346),
          stepTime: 0.15,
        ),
      ),
    };

    /// The starting state will be that the character is running.
    current = CharacterState.running;

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing it.
    add(CircleHitbox());

    // The player lifebar to the screen
    // The dimension of every segment depends from the screen and how many max lifepoint the player has
    add(
      LifeBar(
        segmentWidth: size.x / maxLifePoints,
        color: Colors.green,
        parentComponent: this,
      ),
    );
  }

  /// Handles the character being hitted
  /// [damage] is the amount of damage that the character should take
  /// If the character is invincible it will not take damage and the invincible effect will be played
  /// If the character is not invincible it will take damage and the hurt effect will be played
  /// If the character lifePoints go to 0 the die function will be called
  void hit(int damage) {
    if (invincible) {
      game.audioController.playSfx(SfxType.damage);
      add(InvincibleEffect());
    } else {
      game.audioController.playSfx(SfxType.damage);
      lifePoints -= damage;
      add(HurtEffect());

      // When the character lifePoints go to 0 kill the character
      if (lifePoints <= 0) {
        die();
      }
    }
  }

  /// Apply the death effect and then remove the character from the screen
  void die() {
    DeathEffect deathEffect = DeathEffect();
    add(deathEffect);
    // Remove the character from the list and add it to the new list
    final int index = world.characters.indexOf(this);
    if (index != -1) {
      world.characters[index] = null;
    }
    world.deadCharacters[index] = this;

    // We remove the enemy from the screen after the effect has been played.
    Future.delayed(
      Duration(
        milliseconds: (deathEffect.effectTime * 1000).toInt(),
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
}

/// The possible states of the character
enum CharacterState {
  running,
}

/// Create a character based on its type and on the upgrades that the player has bought
/// [type] is the type of the character to create
/// [position] is the position of the character in the screen
/// [upgrades] is the map of the upgrades that the player has bought
Character createCharacter(CharacterType type, Vector2 position, Map<String, dynamic> upgrades) {
  switch (type) {
    case CharacterType.warrior:
      final int life = upgrades['warrior_life']['current_level'] as int;
      final double lifeStep = upgrades['warrior_life']['step'] as double;
      final int damage = upgrades['warrior_damage']['current_level'] as int;
      final double damageStep = upgrades['warrior_damage']['step'] as double;
      final int baseCooldown = upgrades['warrior_special']['base_cooldown'] as int;
      final int special = upgrades['warrior_special']['current_level'] as int;
      final double specialStep = upgrades['warrior_special']['step'] as double;

      return Warrior(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
      );
    case CharacterType.archer:
      final int life = upgrades['archer_life']['current_level'] as int;
      final double lifeStep = upgrades['archer_life']['step'] as double;
      final int damage = upgrades['archer_damage']['current_level'] as int;
      final double damageStep = upgrades['archer_damage']['step'] as double;
      final int baseCooldown = upgrades['archer_special']['base_cooldown'] as int;
      final int special = upgrades['archer_special']['current_level'] as int;
      final double specialStep = upgrades['archer_special']['step'] as double;

      return Archer(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
      );
    case CharacterType.wizard:
      final int life = upgrades['wizard_life']['current_level'] as int;
      final double lifeStep = upgrades['wizard_life']['step'] as double;
      final int damage = upgrades['wizard_damage']['current_level'] as int;
      final double damageStep = upgrades['wizard_damage']['step'] as double;
      final int baseCooldown = upgrades['wizard_special']['base_cooldown'] as int;
      final int special = upgrades['wizard_special']['current_level'] as int;
      final double specialStep = upgrades['wizard_special']['step'] as double;

      return Wizard(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
      );
    case CharacterType.assassin:
      final int life = upgrades['assassin_life']['current_level'] as int;
      final double lifeStep = upgrades['assassin_life']['step'] as double;
      final int damage = upgrades['assassin_damage']['current_level'] as int;
      final double damageStep = upgrades['assassin_damage']['step'] as double;
      final int baseCooldown = upgrades['assassin_special']['base_cooldown'] as int;
      final int special = upgrades['assassin_special']['current_level'] as int;
      final double specialStep = upgrades['assassin_special']['step'] as double;

      return Assassin(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
      );
    case CharacterType.berserk:
      final int life = upgrades['berserk_life']['current_level'] as int;
      final double lifeStep = upgrades['berserk_life']['step'] as double;
      final int damage = upgrades['berserk_damage']['current_level'] as int;
      final double damageStep = upgrades['berserk_damage']['step'] as double;
      final int baseCooldown = upgrades['berserk_special']['base_cooldown'] as int;
      final int special = upgrades['berserk_special']['current_level'] as int;
      final double specialStep = upgrades['berserk_special']['step'] as double;

      return Berserk(
        position: position,
        maxLifePoints: (life + 1) * lifeStep,
        damage: (damage + 1) * damageStep,
        cooldownTimer: baseCooldown - (special * specialStep).toInt(),
      );
  }
}
