import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyLifeBar extends PositionComponent with HasWorldReference<EndlessWorld> {
  double segmentWidth;
  final double segmentHeight;
  final int spacing;
  final Color color;
  final Enemy parentEnemy;

  EnemyLifeBar({
    required this.segmentWidth,
    required this.parentEnemy,
    this.segmentHeight = 10.0,
    this.spacing = 2,
    this.color = Colors.red,
  });

  @override
  void onLoad() {
    // Position the life bar slightly over the position of the enemy
    position = Vector2(position.x, position.y - 10);
    segmentWidth -= spacing;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the life bar segments
    for (int i = 0; i < parentEnemy.hitPoints; i++) {
      final double x = i * (segmentWidth + spacing);
      canvas.drawRect(
        Rect.fromLTWH(x, 0, segmentWidth.toDouble(), segmentHeight.toDouble()),
        Paint()..color = color,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the size of the life bar based on the number of life points
    size = Vector2(
      (parentEnemy.hitPoints * (segmentWidth + spacing)).toDouble(),
      segmentHeight.toDouble(),
    );
  }
}
