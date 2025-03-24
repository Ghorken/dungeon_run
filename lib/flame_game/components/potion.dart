import 'dart:math';

import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

enum PotionType {
  heal,
  damage,
  slow,
}

/// The [Potion] components are the components that the [Character] could collect.
class Potion extends SpriteAnimationComponent with HasGameReference, HasWorldReference<EndlessWorld> {
  Potion.heal({super.position})
      : _potionType = PotionType.heal,
        _srcImage = 'potions/heal.png',
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Potion.damage({super.position})
      : _potionType = PotionType.damage,
        _srcImage = 'potions/damage.png',
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  Potion.slow({super.position})
      : _potionType = PotionType.slow,
        _srcImage = 'potions/slow.png',
        super(
          size: Vector2.all(150),
          anchor: Anchor.bottomCenter,
        );

  /// Generates a random obstacle of type [EnemyType].
  factory Potion.random({
    Vector2? position,
    Random? random,
  }) {
    final PotionType trapType = PotionType.values.random(random);
    return switch (trapType) {
      PotionType.heal => Potion.heal(position: position),
      PotionType.damage => Potion.damage(position: position),
      PotionType.slow => Potion.slow(position: position),
    };
  }

  static final Vector2 spriteSize = Vector2.all(100);
  late final DateTime timeStarted;
  final PotionType _potionType;
  final String _srcImage;

  @override
  Future<void> onLoad() async {
    timeStarted = DateTime.now();

    animation = await game.loadSpriteAnimation(
      _srcImage,
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2(150, 249),
        stepTime: 0.15,
      ),
    );
    position = Vector2(_randomInRange((-world.size.x / 2 + size.x / 2).toInt(), (world.size.x / 2 - size.x / 2).toInt()), _randomInRange((-world.size.y / 2 + size.y / 2).toInt(), (world.size.y / 2 - world.size.y / 5 - size.y / 2).toInt()));

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing
    // it.
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If it has passed 3 seconds since the potion was created, we remove it.
    if (DateTime.now().millisecondsSinceEpoch - timeStarted.millisecondsSinceEpoch > 3000) {
      removeFromParent();
    }
  }

  void effect() {
    switch (_potionType) {
      case PotionType.heal:
        world.lifePoints += 10;
        if (world.lifePoints > world.maxLifePoints) {
          world.lifePoints = world.maxLifePoints;
        }
        break;
      case PotionType.damage:
        final Character? frontCharacter = world.frontCharacter;
        final Character? leftCharacter = world.leftCharacter;
        final Character? rightCharacter = world.rightCharacter;
        frontCharacter?.damage += 2;
        leftCharacter?.damage += 2;
        rightCharacter?.damage += 2;

        // Schedule the reversal of the effect after 3 seconds
        world.add(
          TimerComponent(
            period: 3.0,
            repeat: false,
            onTick: () {
              // Revert the damage boost
              frontCharacter?.damage -= 2;
              leftCharacter?.damage -= 2;
              rightCharacter?.damage -= 2;
            },
          ),
        );
        break;
      case PotionType.slow:
        final EndlessWorld currentWorld = world;
        currentWorld.speed = (world.speed / 2).toInt();

        // Schedule the reversal of the effect after 3 seconds
        world.add(
          TimerComponent(
            period: 3.0,
            repeat: false,
            onTick: () {
              currentWorld.speed *= 2; // Revert the speed boost
            },
          ),
        );
        break;
    }
  }

  double _randomInRange(int min, int max) {
    final random = Random();
    return (min + random.nextInt(max - min + 1)).toDouble();
  }
}
