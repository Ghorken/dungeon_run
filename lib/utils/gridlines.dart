import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Shows a grid on the screen
/// Used to measure spaces
class GridLines extends Component with HasGameReference {
  final double lineSpacing; // Spacing between lines
  final Color lineColor; // Color of the lines
  final double lineWidth; // Width of the lines

  GridLines({
    this.lineSpacing = 100.0,
    this.lineColor = Colors.white,
    this.lineWidth = 1.0,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;

    // Draw horizontal lines across the screen
    for (double y = -game.size.y; y <= game.size.y; y += lineSpacing) {
      canvas.drawLine(
        Offset(-game.size.x, y), // Start point (top of the screen)
        Offset(game.size.x, y), // End point (bottom of the screen)
        paint,
      );
    }

    // Draw vertical lines across the screen
    for (double x = -game.size.x; x <= game.size.x; x += lineSpacing) {
      canvas.drawLine(
        Offset(x, -game.size.y), // Start point (top of the screen)
        Offset(x, game.size.y), // End point (bottom of the screen)
        paint,
      );
    }
  }
}
