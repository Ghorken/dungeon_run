import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';

/// Enums of the type of the [Collectable]
enum CollectableType {
  potionHeal,
  potionDamage,
  parchmentSlow,
  parchmentResurrection,
  shieldInvincibility,
}

/// The [Collectable] components are the components that the Player could collect to obtain various effects.
class Collectable extends SpriteComponent with HasWorldReference<EndlessWorld> {
  // Constructor for every type of [Collectable]
  Collectable.heal()
      : _collectableType = CollectableType.potionHeal,
        _srcImage = 'collectables/heal.png',
        _duration = 0,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  Collectable.damage()
      : _collectableType = CollectableType.potionDamage,
        _srcImage = 'collectables/damage.png',
        _duration = 3.0,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  Collectable.slow()
      : _collectableType = CollectableType.parchmentSlow,
        _srcImage = 'collectables/slow.png',
        _duration = 3.0,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  Collectable.invincibility()
      : _collectableType = CollectableType.shieldInvincibility,
        _srcImage = 'collectables/invincibility.png',
        _duration = 3.0,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  Collectable.resurrection()
      : _collectableType = CollectableType.parchmentResurrection,
        _srcImage = 'collectables/resurrection.png',
        _duration = 3.0,
        super(
          size: Vector2.all(150),
          anchor: Anchor.center,
        );

  /// Generates a random [Collectable].
  factory Collectable.random() {
    final CollectableType collectableType = CollectableType.values.random();
    return switch (collectableType) {
      CollectableType.potionHeal => Collectable.heal(),
      CollectableType.potionDamage => Collectable.damage(),
      CollectableType.parchmentSlow => Collectable.slow(),
      CollectableType.shieldInvincibility => Collectable.invincibility(),
      CollectableType.parchmentResurrection => Collectable.resurrection(),
    };
  }

  /// When the [Collectable] has been collected
  late final DateTime timeStarted;

  /// The type of the [Collectable]
  final CollectableType _collectableType;

  /// The path of the image to load
  final String _srcImage;

  /// How many seconds the effect should last
  final double _duration;

  @override
  Future<void> onLoad() async {
    // Start the timer
    timeStarted = DateTime.now();

    // Load the sprite of the [Collectable]
    sprite = await Sprite.load(
      _srcImage,
    );

    // Position the [Collectable] in a random spot in the game screen
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

    // If it has been passed 3 seconds since the [Collectable] was created, remove it.
    if (DateTime.now().millisecondsSinceEpoch - timeStarted.millisecondsSinceEpoch > 3000) {
      removeFromParent();
    }
  }

  /// Determine a random number between the min and max
  double _randomInRange(int min, int max) {
    final random = Random();
    return (min + random.nextInt(max - min + 1)).toDouble();
  }

  /// The effect that the [Collectable] should apply
  void effect() {
    switch (_collectableType) {
      // The heal potion heal the player
      case CollectableType.potionHeal:
        for (Character character in world.characters) {
          character.lifePoints += 10;
          if (character.lifePoints > character.maxLifePoints) {
            character.lifePoints = character.maxLifePoints;
          }
        }
        break;
      // The damage potion double the damage dealed by the characters
      case CollectableType.potionDamage:
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
      // The slow parchment half the speed of the world so it slows down enemies and traps
      case CollectableType.parchmentSlow:
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
      // The invicibility shield avoid that the characters takes any damage
      case CollectableType.shieldInvincibility:
        for (Character character in world.characters) {
          character.invincible = true;
        }

        // Schedule the reversal of the effect after the duration
        world.add(
          TimerComponent(
            period: _duration,
            repeat: false,
            onTick: () {
              // Revert the damage boost
              for (Character character in world.characters) {
                character.invincible = false;
              }
            },
          ),
        );
        break;
      // The resurrection parchment resurrect one dead character
      case CollectableType.parchmentResurrection:
        // Retrieve one of the dead and remove from the list
        Character resurrectedCharacter = world.deadCharacters.random();
        world.deadCharacters.remove(resurrectedCharacter);
        // Add it to the alive list with half life points
        resurrectedCharacter.lifePoints = (resurrectedCharacter.maxLifePoints / 2).toInt();
        world.characters.add(resurrectedCharacter);
        break;
    }
  }
}
