import 'dart:math';

import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/flame_game/effects/death_effect.dart';
import 'package:dungeon_run/flame_game/effects/enemy_hurt_effect.dart';
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
class Enemy extends SpriteComponent with HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner>, CollisionCallbacks {
  // Constructors for every tipe of enemy
  Enemy.goblin({
    required this.moneyValue,
  })  : _srcImage = 'enemies/goblin.png',
        _maxLifePoints = 5,
        lifePoints = 5,
        _speed = 2,
        _actualSpeed = 2,
        damage = 1,
        _enemyType = EnemyType.goblin,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.troll({
    required this.moneyValue,
  })  : _srcImage = 'enemies/troll.png',
        _maxLifePoints = 10,
        lifePoints = 10,
        _speed = 2,
        _actualSpeed = 2,
        damage = 1,
        _enemyType = EnemyType.troll,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.elementale({
    required this.moneyValue,
  })  : _srcImage = 'enemies/elementale.png',
        _maxLifePoints = 15,
        lifePoints = 15,
        _speed = 4,
        _actualSpeed = 4,
        damage = 2,
        _enemyType = EnemyType.elementale,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.goblinKing({
    required this.moneyValue,
  })  : _srcImage = 'enemies/goblin_king.png',
        _maxLifePoints = 30,
        lifePoints = 30,
        _speed = 2,
        _actualSpeed = 2,
        damage = 5,
        _enemyType = EnemyType.goblinKing,
        _xPosition = 0.0,
        super(
          size: Vector2.all(250),
          anchor: Anchor.bottomCenter,
        );

  /// Generates a random enemy.
  factory Enemy.random({required int value}) {
    final enemyType = EnemyType.values.random();
    return switch (enemyType) {
      EnemyType.goblin => Enemy.goblin(moneyValue: value),
      EnemyType.troll => Enemy.troll(moneyValue: value),
      EnemyType.elementale => Enemy.elementale(moneyValue: value),
      EnemyType.goblinKing => Enemy.goblin(moneyValue: value),
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

  /// The actual speed of the enemy
  int _actualSpeed;

  /// The damage that the enemy deal
  final int damage;

  /// The type of the enemy
  final EnemyType _enemyType;

  /// The starting x position of the enemy
  double? _xPosition;

  /// The money value of the enemy
  final int moneyValue;

  /// The timer for periodic attacks
  TimerComponent? attackTimer;

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
        parentComponent: this,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // We need to move the component to the bottom together with the speed that we
    // have set for the world.
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    position.y += (world.speed * _actualSpeed) * dt;

    // When the component is no longer visible on the screen anymore, remove it.
    if (position.y - size.y > world.size.y / 2) {
      world.enemies.remove(this);
      removeFromParent();
    }
  }

  /// When the [Enemy] collides with a [Character] it should make damage
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent character,
  ) {
    super.onCollisionStart(intersectionPoints, character);

    // The [Enemy] should stop and the [Character] should receive periodic damage.
    if (character is Character && world.characters.contains(character)) {
      // Set the speed of the enemy to 0 to stop it
      _actualSpeed = 0;

      // Start a timer to attack the character every second
      attackTimer = TimerComponent(
        period: 1.0, // Attack every second
        repeat: true,
        tickWhenLoaded: true,
        onTick: () {
          if (world.characters.contains(character)) {
            character.hit(damage);
          }
        },
      );
      add(attackTimer!);
    }
  }

  /// When the [Enemy] ends the collision with the [Character]
  @override
  void onCollisionEnd(
    PositionComponent character,
  ) {
    super.onCollisionEnd(character);

    // When the [Enemy] is not colliding with the [Character] because the [Character] died
    // The enemy should start move again
    _actualSpeed = _speed;
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
    _actualSpeed = 0;
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

    // Add the moneyValue to the total collected
    world.money += moneyValue;
  }
}
