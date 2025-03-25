import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';

/// Enums of the type of the potions
enum PotionType {
  heal,
  damage,
  slow,
}

/// The [Potion] components are the components that the Player could collect to obtain various effects.
class Potion extends SpriteComponent with HasWorldReference<EndlessWorld> {
  // Constructor for every type of potion
  Potion.heal({super.position})
      : _potionType = PotionType.heal,
        _srcImage = 'potions/heal.png',
        _duration = 0,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  Potion.damage({super.position})
      : _potionType = PotionType.damage,
        _srcImage = 'potions/damage.png',
        _duration = 3.0,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  Potion.slow({super.position})
      : _potionType = PotionType.slow,
        _srcImage = 'potions/slow.png',
        _duration = 3.0,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  /// Generates a random potion.
  factory Potion.random() {
    final PotionType potionType = PotionType.values.random();
    return switch (potionType) {
      PotionType.heal => Potion.heal(),
      PotionType.damage => Potion.damage(),
      PotionType.slow => Potion.slow(),
    };
  }

  /// When the potion has been collected
  late final DateTime timeStarted;

  /// The type of the potion
  final PotionType _potionType;

  /// The path of the image to load
  final String _srcImage;

  /// How many seconds the effect should last
  final double _duration;

  @override
  Future<void> onLoad() async {
    // Start the timer
    timeStarted = DateTime.now();

    // Load the sprite of the potion
    sprite = await Sprite.load(
      _srcImage,
    );

    // Position the potion in a random spot in the game screen
    position = Vector2(
      _randomInRange((-world.size.x / 2 + size.x / 2).toInt(), (world.size.x / 2 - size.x / 2).toInt()),
      _randomInRange((-world.size.y / 2 + size.y / 2).toInt(), (world.size.y / 2 - world.size.y / 5 - size.y / 2).toInt()),
    );

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing it.
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If it has been passed 3 seconds since the potion was created, remove it.
    if (DateTime.now().millisecondsSinceEpoch - timeStarted.millisecondsSinceEpoch > 3000) {
      removeFromParent();
    }
  }

  /// Determine a random number between the min and max
  double _randomInRange(int min, int max) {
    final random = Random();
    return (min + random.nextInt(max - min + 1)).toDouble();
  }

  /// The effect that the potion should apply
  void effect() {
    switch (_potionType) {
      // The heal potion heal the player
      case PotionType.heal:
        for (Character character in world.characters) {
          character.lifePoints += 10;
          if (character.lifePoints > character.maxLifePoints) {
            character.lifePoints = character.maxLifePoints;
          }
        }
        break;
      // The damage potion double the damage dealed by the characters
      case PotionType.damage:
        for (Character character in world.characters) {
          character.damage *= 2;
        }

        // Schedule the reversal of the effect after the duration
        world.add(
          TimerComponent(
            period: _duration,
            repeat: false,
            onTick: () {
              // Revert the damage boost
              for (Character character in world.characters) {
                character.damage = (character.damage / 2).toInt();
              }
            },
          ),
        );
        break;
      // The slow potion half the speed of the world so it slows down enemies and traps
      case PotionType.slow:
        final EndlessWorld currentWorld = world;
        currentWorld.speed = (world.speed / 2).toInt();

        // Schedule the reversal of the effect after the duration
        world.add(
          TimerComponent(
            period: _duration,
            repeat: false,
            onTick: () {
              currentWorld.speed *= 2; // Revert the speed boost
            },
          ),
        );
        break;
    }
  }
}
