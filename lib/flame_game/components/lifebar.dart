import 'package:dungeon_run/flame_game/components/characters/character.dart';
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

  /// The component whose lifebar should be attached to
  /// Should be an Enemy or a Character
  final dynamic parentComponent;

  LifeBar({
    required this.segmentWidth,
    required this.color,
    required this.parentComponent,
    this.barHeight = 10.0,
  });

  @override
  void onLoad() {
    // Determine the position in different way if it's the enemy's or the player's
    if (parentComponent is Enemy) {
      // Position the life bar slightly over the position of the enemy
      position = Vector2(position.x, position.y - 10);
    } else {
      // Position the life bar at the bottom-right of the screen
      position = Vector2(position.x, position.y + 10);
    }

    // Every segment width should be reduced by the spacing to adapt the total width to the screen
    segmentWidth -= spacing;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the life bar segments
    double lifePoints = (parentComponent is Enemy) ? (parentComponent as Enemy).lifePoints : (parentComponent as Character).lifePoints;
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
    double lifePoints = (parentComponent is Enemy) ? (parentComponent as Enemy).lifePoints : (parentComponent as Character).lifePoints;
    size = Vector2(
      (lifePoints * (segmentWidth + spacing)).toDouble(),
      barHeight.toDouble(),
    );
  }
}
