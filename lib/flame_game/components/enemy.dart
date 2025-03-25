import 'dart:math';

import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/effects/death_effect.dart';
import 'package:dungeon_run/flame_game/effects/enemy_hurt_effect.dart';
import 'package:dungeon_run/flame_game/effects/hurt_effect.dart';
import 'package:dungeon_run/flame_game/endless_runner.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:flutter/material.dart';

/// Enums of the type of enemies
enum EnemyType {
  goblin,
  troll,
  elementale,
  goblinKing,
}

/// The [Enemy] component can represent the different types of enemies
/// that the character can run into.
class Enemy extends SpriteComponent with HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner> {
  /// Timer to control the application of HurtEffect
  double _hurtEffectTimer = 0.0;

  // Constructors for every tipe of enemy
  Enemy.goblin()
      : _srcImage = 'enemies/goblin.png',
        _maxLifePoints = 5,
        lifePoints = 5,
        _speed = 2,
        _damage = 1,
        _enemyType = EnemyType.goblin,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.troll()
      : _srcImage = 'enemies/troll.png',
        _maxLifePoints = 10,
        lifePoints = 10,
        _speed = 2,
        _damage = 1,
        _enemyType = EnemyType.troll,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.elementale()
      : _srcImage = 'enemies/elementale.png',
        _maxLifePoints = 15,
        lifePoints = 15,
        _speed = 4,
        _damage = 2,
        _enemyType = EnemyType.elementale,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.goblinKing()
      : _srcImage = 'enemies/goblin_king.png',
        _maxLifePoints = 30,
        lifePoints = 30,
        _speed = 2,
        _damage = 5,
        _enemyType = EnemyType.goblinKing,
        _xPosition = 0.0,
        super(
          size: Vector2.all(250),
          anchor: Anchor.bottomCenter,
        );

  /// Generates a random enemy.
  factory Enemy.random() {
    final enemyType = EnemyType.values.random();
    return switch (enemyType) {
      EnemyType.goblin => Enemy.goblin(),
      EnemyType.troll => Enemy.troll(),
      EnemyType.elementale => Enemy.elementale(),
      EnemyType.goblinKing => Enemy.goblin(),
    };
  }

  /// The path of the image to load
  final String _srcImage;

  /// The max lifePoints of the enemy
  final int _maxLifePoints;

  /// The current lifePoints of the enemy
  int lifePoints;

  /// The speed of the enemy
  int _speed;

  /// The damage that the enemy deal
  final int _damage;

  /// The type of the enemy
  final EnemyType _enemyType;

  /// The starting x position of the enemy
  double? _xPosition;

  @override
  Future<void> onLoad() async {
    // Load the sprite of the enemy
    sprite = await Sprite.load(
      _srcImage,
    );

    // Position the enemy in a random spot at the top of the screen
    // or in a specific spot at the top of the screen if specified
    position = Vector2(_xPosition ?? _randomInRange((-world.size.x / 2 + size.x / 2).toInt(), (world.size.x / 2 - size.x / 2).toInt()), -world.size.y / 2);

    // When adding a RectangleHitbox without any arguments it automatically
    // fills up the size of the component.
    add(
      RectangleHitbox(),
    );

    // Add the lifebar to display the lifepoints
    add(
      LifeBar(
        segmentWidth: size.x / _maxLifePoints,
        color: Colors.red,
        parentEnemy: this,
        barHeight: 10.0,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the timer
    _hurtEffectTimer += dt;

    // We need to move the component to the bottom together with the speed that we
    // have set for the world.
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    if (position.y < world.frontCharacterPosition.y) {
      position.y += (world.speed * _speed) * dt;
    } else {
      // When the enemy reach the character's position attacks the player immediately and every 1 second
      if (_hurtEffectTimer >= 1.0) {
        _hurtEffectTimer = 0.0; // Reset the timer
        world.lifePoints -= _damage;
        world.frontCharacter!.add(HurtEffect());
        game.audioController.playSfx(SfxType.damage);
      }
    }
  }

  /// Determine a random number between the min and max
  double _randomInRange(int min, int max) {
    final random = Random();
    return (min + random.nextInt(max - min + 1)).toDouble();
  }

  /// When the enemy is hit by the character we reduce the lifePoints and
  /// if the lifePoints are less than or equal to 0 we remove the enemy.
  void hitted(int damage) {
    lifePoints -= damage;
    if (lifePoints > 0) {
      add(EnemyHurtEffect());
    } else {
      die();
      // When the goblinKing is defeated the player wins
      if (_enemyType == EnemyType.goblinKing) {
        world.win();
      }
    }
  }

  /// When the enemy is killed by the character we remove the enemy.
  void die() {
    _speed = 0;
    // We remove the enemy from the list so that it is no longer hittable even if still present on the screen.
    world.enemies.remove(this);
    DeathEffect deathEffect = DeathEffect();
    add(deathEffect);

    // We remove the enemy from the screen after the effect has been played.
    Future.delayed(
      Duration(
        milliseconds: (deathEffect.effectTime * 1000).toInt(),
      ),
      () => removeFromParent(),
    );
  }
}
