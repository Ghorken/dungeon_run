import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:dungeon_run/flame_game/endless_world.dart';

/// The class that handles the lifebar of the player and of the enemies
class LifeBar extends PositionComponent with HasWorldReference<EndlessWorld> {
  /// The width of every segment
  double segmentWidth;

  /// The height of the bar
  double barHeight;

  /// The spacing between every segment
  final int spacing = 1;

  /// The color of the bar
  final Color color;

  /// The optional parent enemy
  Enemy? parentEnemy;

  LifeBar({
    required this.segmentWidth,
    required this.color,
    this.parentEnemy,
    this.barHeight = 40.0,
  });

  @override
  void onLoad() {
    // Determine the position in different way if it's the enemy's or the player's
    if (parentEnemy != null) {
      // Position the life bar slightly over the position of the enemy
      position = Vector2(position.x, position.y - 10);
    } else {
      // Position the life bar at the bottom-right of the screen
      position = Vector2(-world.size.x / 2, world.size.y / 2);
      anchor = Anchor.bottomLeft;
    }

    // Every segment width should be reduced by the spacing to adapt the total width to the screen
    segmentWidth -= spacing;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the life bar segments
    int lifePoints = (parentEnemy != null) ? parentEnemy!.lifePoints : world.lifePoints;
    for (int i = 0; i < lifePoints; i++) {
      final double x = i * (segmentWidth + spacing);
      canvas.drawRect(
        Rect.fromLTWH(x, 0, segmentWidth.toDouble(), barHeight.toDouble()),
        Paint()..color = color,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the size of the life bar based on the number of life points
    int lifePoints = (parentEnemy != null) ? parentEnemy!.lifePoints : world.lifePoints;
    size = Vector2(
      (lifePoints * (segmentWidth + spacing)).toDouble(),
      barHeight.toDouble(),
    );
  }
}
