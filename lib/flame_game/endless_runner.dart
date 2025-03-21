import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../audio/audio_controller.dart';
import '../level_selection/levels.dart';
import 'components/background.dart';
import 'endless_world.dart';

/// This is the base of the game which is added to the [GameWidget].
///
/// This class defines a few different properties for the game:
///  - That it should run collision detection, this is done through the
///  [HasCollisionDetection] mixin.
///  - That it should have a [FixedResolutionViewport] with a size of 720x1600,
///  this means that even if you resize the window, the game itself will keep
///  the defined virtual resolution.
///  - That the default world that the camera is looking at should be the
///  [EndlessWorld].
///
/// Note that both of the last are passed in to the super constructor, they
/// could also be set inside of `onLoad` for example.
class EndlessRunner extends FlameGame<EndlessWorld> with HasCollisionDetection {
  EndlessRunner({
    required this.level,
    required this.audioController,
  }) : super(
          world: EndlessWorld(level: level),
          camera: CameraComponent.withFixedResolution(width: 720, height: 1600),
        );

  /// What the properties of the level that is played has.
  final GameLevel level;

  /// A helper for playing sound effects and background audio.
  final AudioController audioController;

  /// In the [onLoad] method you load different type of assets and set things
  /// that only needs to be set once when the level starts up.
  @override
  Future<void> onLoad() async {
    // The backdrop is a static layer behind the world that the camera is
    // looking at, so here we add our parallax background.
    camera.backdrop.add(Background(speed: world.speed));
  }
}
