import 'package:dungeon_run/flame_game/components/collectables/collectable_type.dart';
import 'package:dungeon_run/flame_game/components/collectables/damage.dart';
import 'package:dungeon_run/flame_game/components/collectables/heal.dart';
import 'package:dungeon_run/flame_game/components/collectables/invincibility.dart';
import 'package:dungeon_run/flame_game/components/collectables/resurrection.dart';
import 'package:dungeon_run/flame_game/components/collectables/slow.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/utils/commons.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';

import 'package:dungeon_run/navigation/endless_world.dart';

/// The [Collectable] components are the components that the Player could collect to obtain various effects.
abstract class Collectable extends SpriteComponent with HasWorldReference<EndlessWorld>, TapCallbacks {
  Collectable({
    required this.srcImage,
    required super.size,
    required super.anchor,
  }) : super(
          priority: 1,
        );

  /// Generates a random [Collectable].
  factory Collectable.random({
    required List<Upgrade> upgrades,
    required List<CollectableType> collectables,
  }) {
    final CollectableType collectableType = collectables.random();

    switch (collectableType) {
      case CollectableType.heal:
        Upgrade augmentHeal = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'augment_heal');

        final int healing = augmentHeal.currentLevel;
        final double healingStep = augmentHeal.step!;

        return Heal(
          healing: (healing + 1) * healingStep,
        );
      case CollectableType.damage:
        Upgrade augmentDamageDuration = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'augment_damage_duration');
        Upgrade augmentDamage = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'augment_damage');

        final double duration = augmentDamageDuration.currentLevel.toDouble();
        final double durationStep = augmentDamageDuration.step!;
        final int damage = augmentDamage.currentLevel;
        final double damageStep = augmentDamage.step!;

        return Damage(
          duration: (duration + 1) * durationStep,
          damage: (damage + 1) * damageStep,
        );
      case CollectableType.slow:
        Upgrade augmentSlowDuration = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'augment_slow_duration');
        Upgrade augmentSlow = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'augment_slow');

        final double duration = augmentSlowDuration.currentLevel.toDouble();
        final double durationStep = augmentSlowDuration.step!;
        final int slow = augmentSlow.currentLevel;
        final double slowStep = augmentSlow.step!;

        return Slow(
          duration: (duration + 1) * durationStep,
          velocity: (slow + 1) * slowStep,
        );
      case CollectableType.invincibility:
        Upgrade augmentInvincibilityDuration = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'augment_invincibility_duration');

        final double duration = augmentInvincibilityDuration.currentLevel.toDouble();
        final double durationStep = augmentInvincibilityDuration.step!;

        return Invincibility(
          duration: (duration + 1) * durationStep,
        );
      case CollectableType.resurrection:
        Upgrade augmentResurrection = upgrades.firstWhere((Upgrade upgrade) => upgrade.name == 'augment_resurrection');

        final bool fullHealt = augmentResurrection.currentLevel > 0;

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
      randomInRange((-world.size.x / 2 + size.x / 2).toInt(), (world.size.x / 2 - size.x / 2).toInt()),
      randomInRange((-world.size.y / 2 + size.y / 2).toInt(), (world.size.y / 2 - world.size.y / 5 - size.y / 2).toInt()),
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

  /// The effect that the [Collectable] should apply
  void effect();

  // If the player taps on a [Collectable], we apply its effect and remove it from the world
  @override
  void onTapDown(TapDownEvent event) {
    effect();
    opacity = 0.0;
    world.collectables.remove(this);
  }
}
