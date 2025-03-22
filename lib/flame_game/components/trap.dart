import 'dart:math';

import 'package:dungeon_run/flame_game/effects/disable_effect.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';

enum TrapType {
  spikedRoller,
  spikedPit,
  rotatingBlades,
}

/// The [Trap] component can represent three different types of obstacles
/// that the character can run into.
class Trap extends SpriteComponent with HasWorldReference<EndlessWorld> {
  Trap.spikedRoller({super.position})
      : _srcSize = Vector2(150, 154),
        _srcImage = 'traps/spiked_roller.png',
        _speed = 1,
        _trapType = TrapType.spikedRoller,
        damage = 1,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Trap.spikedPit({super.position})
      : _srcSize = Vector2(150, 140),
        _srcImage = 'traps/spiked_pit.png',
        _speed = 1,
        _trapType = TrapType.spikedPit,
        damage = 1,
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Trap.rotatingBlades({super.position})
      : _srcSize = Vector2(150, 143),
        _srcImage = 'traps/rotating_blades.png',
        _speed = 1,
        _trapType = TrapType.rotatingBlades,
        damage = 1,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  /// Generates a random obstacle of type [EnemyType].
  factory Trap.random({
    Vector2? position,
    Random? random,
  }) {
    final TrapType trapType = TrapType.values.random(random);
    return switch (trapType) {
      TrapType.spikedRoller => Trap.spikedRoller(position: position),
      TrapType.spikedPit => Trap.spikedPit(position: position),
      TrapType.rotatingBlades => Trap.rotatingBlades(position: position),
    };
  }

  final TrapType _trapType;
  final Vector2 _srcSize;
  final String _srcImage;
  int _speed;
  final int damage;

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

    // If the trap is a rotating blade we add a rotation effect to it.
    if (_trapType == TrapType.rotatingBlades) {
      add(
        RotateEffect.by(
          -(2 * pi),
          EffectController(
            duration: 0.5,
            infinite: true,
          ),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    // We need to move the component to the left together with the speed that we
    // have set for the world.
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    position.y += (400 * _speed) * dt;

    // When the component is no longer visible on the screen anymore, we
    // remove it.
    // The position is defined from the upper left corner of the component (the
    // anchor) and the center of the world is in (0, 0), so when the components
    // position minus its size in Y-axis is outside of minus half the world size
    // we know that it is no longer visible and it can be removed.
    if (position.y - size.y > world.size.y / 2) {
      world.traps.remove(this);
      removeFromParent();
    }
  }

  /// When the enemy is hit by the character we remove the enemy.
  void disable() {
    _speed = 0;
    // We remove the enemy from the list so that it is no longer hittable even if still present on the screen.
    world.traps.remove(this);
    DisableEffect disableEffect = DisableEffect();
    add(disableEffect);

    // We remove the enemy from the screen after the effect has been played.
    Future.delayed(Duration(milliseconds: (disableEffect.effectTime * 1000).toInt()), () => removeFromParent());
  }
}
