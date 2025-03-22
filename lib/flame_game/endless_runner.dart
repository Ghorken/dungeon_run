import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../audio/audio_controller.dart';
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
    required this.audioController,
    required this.selectedCharacters,
  }) : super(
          world: EndlessWorld(selectedCharacters: selectedCharacters),
          camera: CameraComponent.withFixedResolution(width: 720, height: 1600),
        );

  /// A helper for playing sound effects and background audio.
  final AudioController audioController;

  final List<CharacterType?> selectedCharacters;

  /// In the [onLoad] method you load different type of assets and set things
  /// that only needs to be set once when the level starts up.
  @override
  Future<void> onLoad() async {
    // The backdrop is a static layer behind the world that the camera is
    // looking at, so here we add our parallax background.
    camera.backdrop.add(Background());
  }
}
