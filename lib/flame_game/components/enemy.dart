import 'dart:math';

import 'package:dungeon_run/audio/sounds.dart';
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
}

/// The [Enemy] component can represent three different types of enemies
/// that the character can run into.
class Enemy extends SpriteComponent with HasWorldReference<EndlessWorld>, HasGameReference<EndlessRunner> {
  // Timer to control the application of HurtEffect
  double _hurtEffectTimer = 0.0;

  Enemy.goblin({super.position})
      : _srcSize = Vector2(250, 386),
        _srcImage = 'enemies/goblin.png',
        _hitPoints = 1,
        _speed = 1,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.troll({super.position})
      : _srcSize = Vector2(250, 309),
        _srcImage = 'enemies/troll.png',
        _hitPoints = 2,
        _speed = 1,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Enemy.elementale({super.position})
      : _srcSize = Vector2(215, 386),
        _srcImage = 'enemies/elementale.png',
        _hitPoints = 3,
        _speed = 2,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  /// Generates a random obstacle of type [EnemyType].
  factory Enemy.random({
    Vector2? position,
    Random? random,
  }) {
    final enemyType = EnemyType.values.random(random);
    return switch (enemyType) {
      EnemyType.goblin => Enemy.goblin(position: position),
      EnemyType.troll => Enemy.troll(position: position),
      EnemyType.elementale => Enemy.elementale(position: position),
    };
  }

  final Vector2 _srcSize;
  final String _srcImage;
  int _hitPoints;
  int _speed;

  @override
  Future<void> onLoad() async {
    // Since all the obstacles reside in the same image, srcSize and srcPosition
    // are used to determine what part of the image that should be used.
    sprite = await Sprite.load(
      _srcImage,
      srcSize: _srcSize,
    );
    // When adding a RectangleHitbox without any arguments it automatically
    // fills up the size of the component.
    add(RectangleHitbox());
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
      position.y += (400 * _speed) * dt;
    } else {
      // Apply HurtEffect only if 1 second has passed since the last application
      if (_hurtEffectTimer >= 1.0) {
        _hurtEffectTimer = 0.0; // Reset the timer
        world.frontCharacter!.add(HurtEffect());
        game.audioController.playSfx(SfxType.damage);
      }
    }

    // When the component is no longer visible on the screen anymore, we
    // remove it.
    // The position is defined from the upper left corner of the component (the
    // anchor) and the center of the world is in (0, 0), so when the components
    // position minus its size in Y-axis is outside of minus half the world size
    // we know that it is no longer visible and it can be removed.
    if (position.y - size.y > world.size.y / 2) {
      world.enemies.remove(this);
      removeFromParent();
    }
  }

  /// When the enemy is hit by the character we reduce the hit points and
  /// if the hit points are less than or equal to 0 we remove the enemy.
  void hitted() {
    _hitPoints--;
    if (_hitPoints <= 0) {
      die();
    } else {
      add(EnemyHurtEffect());
    }
  }

  /// When the enemy is hit by the character we remove the enemy.
  void die() {
    _speed = 0;
    // We remove the enemy from the list so that it is no longer hittable even if still present on the screen.
    world.enemies.remove(this);
    DeathEffect deathEffect = DeathEffect();
    add(deathEffect);

    // We remove the enemy from the screen after the effect has been played.
    Future.delayed(Duration(milliseconds: (deathEffect.effectTime * 1000).toInt()), () => removeFromParent());
  }
}
