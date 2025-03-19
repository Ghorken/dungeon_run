import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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

    // With the `TextPaint` we define what properties the text that we are going
    // to render will have, like font family, size and color in this instance.
    final textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
        fontFamily: 'Press Start 2P',
      ),
    );

    final potionText = 'Pozioni: 0';
    final hitText = 'Colpito: 0';
    final killText = 'Uccisioni: 0';

    // The component that is responsible for rendering the text.
    final potionComponent = TextComponent(
      text: potionText,
      position: Vector2(30, 30),
      textRenderer: textRenderer,
    );
    final hitComponent = TextComponent(
      text: hitText,
      position: Vector2(30, 70),
      textRenderer: textRenderer,
    );
    final killComponent = TextComponent(
      text: killText,
      position: Vector2(30, 110),
      textRenderer: textRenderer,
    );

    // The text components are added to the viewport, which means that even if the
    // camera's viewfinder move around and looks at different positions in the
    // world, the test are always static to the viewport.
    camera.viewport.add(potionComponent);
    camera.viewport.add(hitComponent);
    camera.viewport.add(killComponent);

    // Here we add a listener to the notifiers that are updated when the player
    // gets a new potion, is hitted or kill an enemy, in the callback we update the text of the
    // relative components.
    world.potionNotifier.addListener(() {
      potionComponent.text = 'Pozioni: ${world.potionNotifier.value}';
    });
    world.hitNotifier.addListener(() {
      hitComponent.text = 'Colpito: ${world.hitNotifier.value}';
    });
    world.killNotifier.addListener(() {
      killComponent.text = 'Uccisioni: ${world.killNotifier.value}';
    });
  }
}
