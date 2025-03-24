import 'dart:math';

import 'package:dungeon_run/audio/sounds.dart';
import 'package:dungeon_run/flame_game/components/enemy_lifebar.dart';
import 'package:dungeon_run/flame_game/effects/death_effect.dart';
import 'package:dungeon_run/flame_game/effects/enemy_hurt_effect.dart';
import 'package:dungeon_run/flame_game/effects/hurt_effect.dart';
import 'package:dungeon_run/flame_game/endless_runner.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

enum EnemyType {
  goblin,
  troll,
  elementale,
  goblinKing,
}

/// The [Enemy] component can represent three different types of enemies
/// that the character can run into.
class Enemy extends SpriteComponent with HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner> {
  // Timer to control the application of HurtEffect
  double _hurtEffectTimer = 0.0;

  Enemy.goblin()
      : _srcSize = Vector2(250, 386),
        _srcImage = 'enemies/goblin.png',
        _maxHitPoints = 5,
        hitPoints = 5,
        speed = 2,
        _damage = 1,
        _enemyType = EnemyType.goblin,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.troll()
      : _srcSize = Vector2(250, 309),
        _srcImage = 'enemies/troll.png',
        _maxHitPoints = 10,
        hitPoints = 10,
        speed = 2,
        _damage = 1,
        _enemyType = EnemyType.troll,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.elementale()
      : _srcSize = Vector2(215, 386),
        _srcImage = 'enemies/elementale.png',
        _maxHitPoints = 15,
        hitPoints = 15,
        speed = 4,
        _damage = 2,
        _enemyType = EnemyType.elementale,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.goblinKing()
      : _srcSize = Vector2(250, 495),
        _srcImage = 'enemies/goblin_king.png',
        _maxHitPoints = 30,
        hitPoints = 30,
        speed = 2,
        _damage = 5,
        _enemyType = EnemyType.goblinKing,
        _xPosition = 0.0,
        super(
          size: Vector2.all(250),
          anchor: Anchor.bottomCenter,
        );

  /// Generates a random obstacle of type [EnemyType].
  factory Enemy.random({
    Random? random,
  }) {
    final enemyType = EnemyType.values.random(random);
    return switch (enemyType) {
      EnemyType.goblin => Enemy.goblin(),
      EnemyType.troll => Enemy.troll(),
      EnemyType.elementale => Enemy.elementale(),
      EnemyType.goblinKing => Enemy.goblin(),
    };
  }

  final Vector2 _srcSize;
  final String _srcImage;
  final int _maxHitPoints;
  int hitPoints;
  int speed;
  final int _damage;
  final EnemyType _enemyType;
  double? _xPosition;

  @override
  Future<void> onLoad() async {
    // Since all the obstacles reside in the same image, srcSize and srcPosition
    // are used to determine what part of the image that should be used.
    sprite = await Sprite.load(
      _srcImage,
      srcSize: _srcSize,
    );
    position = Vector2(_xPosition ?? _randomInRange((-world.size.x / 2 + size.x / 2).toInt(), (world.size.x / 2 - size.x / 2).toInt()), -world.size.y / 2);
    // When adding a RectangleHitbox without any arguments it automatically
    // fills up the size of the component.
    add(RectangleHitbox());

    add(EnemyLifeBar(
      segmentWidth: size.x / _maxHitPoints,
      parentEnemy: this,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the timer
    _hurtEffectTimer += dt;

    // We need to move the component to the left together with the speed that we
    // have set for the world.
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    if (position.y < world.frontCharacterPosition.y) {
      position.y += (world.speed * speed) * dt;
    } else {
      // Apply HurtEffect only if 1 second has passed since the last application
      if (_hurtEffectTimer >= 1.0) {
        _hurtEffectTimer = 0.0; // Reset the timer
        world.frontCharacter!.add(HurtEffect(damage: _damage));
        game.audioController.playSfx(SfxType.damage);
      }
    }
  }

  /// When the enemy is hit by the character we reduce the hit points and
  /// if the hit points are less than or equal to 0 we remove the enemy.
  void hitted(int damage) {
    hitPoints -= damage;
    if (hitPoints <= 0) {
      die();
      if (_enemyType == EnemyType.goblinKing) {
        world.win();
      }
    } else {
      add(EnemyHurtEffect());
    }
  }

  /// When the enemy is hit by the character we remove the enemy.
  void die() {
    speed = 0;
    // We remove the enemy from the list so that it is no longer hittable even if still present on the screen.
    world.enemies.remove(this);
    DeathEffect deathEffect = DeathEffect();
    add(deathEffect);

    // We remove the enemy from the screen after the effect has been played.
    Future.delayed(Duration(milliseconds: (deathEffect.effectTime * 1000).toInt()), () => removeFromParent());
  }

  double _randomInRange(int min, int max) {
    final random = Random();
    return (min + random.nextInt(max - min + 1)).toDouble();
  }
}
