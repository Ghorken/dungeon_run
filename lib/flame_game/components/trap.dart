import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/effects/disable_effect.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';

// Enums of the type of the traps
enum TrapType {
  spikedRoller,
  spikedPit,
  rotatingBlades,
}

/// The [Trap] component can represent three different types of obstacles
/// that the character can run into.
class Trap extends SpriteComponent with HasWorldReference<EndlessWorld>, CollisionCallbacks {
  // Constructor for every type of trap
  Trap.spikedRoller()
      : _srcImage = 'traps/spiked_roller.png',
        _speed = 1,
        _trapType = TrapType.spikedRoller,
        damage = 1,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  Trap.spikedPit()
      : _srcImage = 'traps/spiked_pit.png',
        _speed = 1,
        _trapType = TrapType.spikedPit,
        _yPosition = 0.0,
        damage = 1,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  Trap.rotatingBlades()
      : _srcImage = 'traps/rotating_blades.png',
        _speed = 1,
        _trapType = TrapType.rotatingBlades,
        damage = 1,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  /// Generates a random trap.
  factory Trap.random() {
    final TrapType trapType = TrapType.values.random();
    return switch (trapType) {
      TrapType.spikedRoller => Trap.spikedRoller(),
      TrapType.spikedPit => Trap.spikedPit(),
      TrapType.rotatingBlades => Trap.rotatingBlades(),
    };
  }

  /// The type of the trap
  final TrapType _trapType;

  /// The path of the image to load
  final String _srcImage;

  /// The speed of the trap
  int _speed;

  /// The starting y posion of the trap
  double? _yPosition;

  /// The damage that the trap deal
  final int damage;

  @override
  Future<void> onLoad() async {
    // Load the sprite of the trap
    sprite = await Sprite.load(
      _srcImage,
    );

    // Position the trap in a random spot at the top of the screen
    // or in a specific spot if specified
    position = Vector2(_randomInRange((-world.size.x / 2 + size.x / 2).toInt(), (world.size.x / 2 - size.x / 2).toInt()), _yPosition ?? -world.size.y / 2);

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
    // We need to move the component to the bottom of the screen together with
    // the speed that we have set for the world.
    // `dt` here stands for delta time and it is the time, in seconds, since the
    // last update ran. We need to multiply the speed by `dt` to make sure that
    // the speed of the obstacles are the same no matter the refresh rate/speed
    // of your device.
    position.y += (world.speed * _speed) * dt;

    // When the component is no longer visible on the screen anymore, remove it.
    if (position.y - size.y / 2 > world.size.y / 2) {
      world.traps.remove(this);
      removeFromParent();
    }
  }

  /// When the [Trap] collides with a [Character] it should make damage.
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent character,
  ) {
    super.onCollisionStart(intersectionPoints, character);

    if (character is Character && world.characters.contains(character)) {
      character.hit(damage);
    }
  }

  /// Determine a random number between the min and max
  double _randomInRange(int min, int max) {
    final random = Random();
    return (min + random.nextInt(max - min + 1)).toDouble();
  }

  /// When the [Trap] is hit by the player stop it and remove it.
  void disable() {
    _speed = 0;

    // We remove the trap from the list so that it is no longer hittable even if still present on the screen.
    world.traps.remove(this);
    DisableEffect disableEffect = DisableEffect();
    add(disableEffect);

    // We remove the trap from the screen after the effect has been played.
    Future.delayed(
      Duration(
        milliseconds: (disableEffect.effectTime * 1000).toInt(),
      ),
      () => removeFromParent(),
    );
  }
}
