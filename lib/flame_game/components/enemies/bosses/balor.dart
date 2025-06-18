import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/lifebar.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';

class Balor extends Enemy {
  Balor({
    required super.goldUpgradeLevel,
    required super.artboard,
  })  : maxLifePoints = 30,
        super(
          enemyGold: 1,
          isBoss: true,
          damage: 5,
          actualSpeed: 2,
          speed: 2,
          lifePoints: 30,
          bossType: BossType.balor,
        );

  /// The max lifePoints of the enemy
  final int maxLifePoints;

  /// The input for the attack animation
  SMIBool? _attackInput;

  /// The input for the hitted animation
  SMITrigger? _hittedInput;

  @override
  Future<void> onLoad() async {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "Goblin",
    );

    _attackInput = controller?.getBoolInput('Attack');
    _hittedInput = controller?.getTriggerInput('Hit');

    artboard.addController(controller!);
    size = Vector2.all(250);

    // Position the enemy at the middlet of the top of the screen
    position = Vector2(0.0, -world.size.y / 2);

    // Add the hitbox to the enemy
    add(
      CircleHitbox(
        isSolid: true,
        radius: 50,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );

    // Add the lifebar to display the lifepoints
    add(
      LifeBar(
        segmentWidth: size.x / maxLifePoints,
        color: Colors.red,
      ),
    );
  }

  @override
  void hitted(double damage) {
    super.hitted(damage);
    _hittedInput?.fire();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent character,
  ) {
    super.onCollisionStart(intersectionPoints, character);
    if (character is Character && world.characters.contains(character)) {
      _attackInput?.value = true;
    }
  }

  @override
  void onCollisionEnd(
    PositionComponent character,
  ) {
    super.onCollisionEnd(character);
    _attackInput?.value = false;
  }
}
