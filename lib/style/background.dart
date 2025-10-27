import 'package:dungeon_run/progression/level.dart';
import 'package:flame/components.dart';

/// The [Background] is a component that is composed of multiple scrolling
/// images which form a parallax, a way to simulate movement and depth in the
/// background.
class Background extends SpriteComponent with HasGameReference {
  Background({required this.level}) : super(priority: -1);

  final Level level;
  double scrollSpeed = 100; // pixel per second
  bool scrolling = true;

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('scenery/${level.map}.png');
    // Scale background to fill the width of the screen
    final scale = game.size.x / sprite!.srcSize.x;
    size = Vector2(
      game.size.x,
      sprite!.srcSize.y * scale,
    );

    // Align bottom
    position = Vector2(0, game.size.y - size.y);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!scrolling) {
      return;
    } else {
      // Move the background upwards
      y += scrollSpeed * dt;

      // If the top edge of the background has reached the top of the screen → stop
      if (y >= 0) {
        y = 0;
        scrolling = false;
      }
    }
  }
}
