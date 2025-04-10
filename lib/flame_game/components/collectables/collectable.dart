import 'dart:math';

import 'package:dungeon_run/flame_game/components/collectables/collectable_type.dart';
import 'package:dungeon_run/flame_game/components/collectables/damage.dart';
import 'package:dungeon_run/flame_game/components/collectables/heal.dart';
import 'package:dungeon_run/flame_game/components/collectables/invincibility.dart';
import 'package:dungeon_run/flame_game/components/collectables/resurrection.dart';
import 'package:dungeon_run/flame_game/components/collectables/slow.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/flame_game/endless_world.dart';

/// The [Collectable] components are the components that the Player could collect to obtain various effects.
abstract class Collectable extends SpriteComponent with HasWorldReference<EndlessWorld> {
  Collectable({
    required this.srcImage,
    required super.size,
    required super.anchor,
  }) : super(
          priority: 1,
        );

  /// Generates a random [Collectable].
  factory Collectable.random({required List<Upgrade> upgrades}) {
    final CollectableType collectableType = CollectableType.values.random();

    switch (collectableType) {
      case CollectableType.heal:
        Upgrade collectableHeal = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_heal');

        final int healing = collectableHeal.currentLevel;
        final double healingStep = collectableHeal.step!;

        return Heal(
          healing: (healing + 1) * healingStep,
        );
      case CollectableType.damage:
        Upgrade collectableDamageDuration = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_damage_duration');
        Upgrade collectableDamage = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_damage');

        final double duration = collectableDamageDuration.currentLevel.toDouble();
        final double durationStep = collectableDamageDuration.step!;
        final int damage = collectableDamage.currentLevel;
        final double damageStep = collectableDamage.step!;

        return Damage(
          duration: (duration + 1) * durationStep,
          damage: (damage + 1) * damageStep,
        );
      case CollectableType.slow:
        Upgrade collectableSlowDuration = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_slow_duration');
        Upgrade collectableSlow = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_slow');

        final double duration = collectableSlowDuration.currentLevel.toDouble();
        final double durationStep = collectableSlowDuration.step!;
        final int slow = collectableSlow.currentLevel;
        final double slowStep = collectableSlow.step!;

        return Slow(
          duration: (duration + 1) * durationStep,
          velocity: (slow + 1) * slowStep,
        );
      case CollectableType.invincibility:
        Upgrade collectableInvincibilityDuration = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_invincibility_duration');

        final double duration = collectableInvincibilityDuration.currentLevel.toDouble();
        final double durationStep = collectableInvincibilityDuration.step!;

        return Invincibility(
          duration: (duration + 1) * durationStep,
        );
      case CollectableType.resurrection:
        Upgrade collectableResurrectionFull = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'collectable_resurrection_full');

        final bool fullHealt = collectableResurrectionFull.currentLevel > 0;

        return Resurrection(
          fullHealt: fullHealt,
        );
    }
  }

  /// When the [Collectable] has been collected
  late final DateTime timeStarted;

  /// The path of the image to load
  final String srcImage;

  @override
  Future<void> onLoad() async {
    // Start the timer
    timeStarted = DateTime.now();

    // Load the sprite of the [Collectable]
    sprite = await Sprite.load(
      srcImage,
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
  void effect();
}
