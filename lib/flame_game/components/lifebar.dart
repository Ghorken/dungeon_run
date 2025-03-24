import 'package:dungeon_run/flame_game/endless_world.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LifeBar extends PositionComponent with HasWorldReference<EndlessWorld> {
  double segmentWidth;
  final double segmentHeight;
  final int spacing;
  final Color color;

  LifeBar({
    required this.segmentWidth,
    this.segmentHeight = 40.0,
    this.spacing = 2,
    this.color = Colors.green,
    super.anchor = Anchor.bottomLeft,
  });

  @override
  void onLoad() {
    // Position the life bar at the bottom-right of the screen
    position = Vector2(-world.size.x / 2, world.size.y / 2);
    segmentWidth -= spacing;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw the life bar segments
    for (int i = 0; i < world.lifePoints; i++) {
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
      (world.lifePoints * (segmentWidth + spacing)).toDouble(),
      segmentHeight.toDouble(),
    );
  }
}
