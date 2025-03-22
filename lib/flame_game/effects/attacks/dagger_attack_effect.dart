import 'package:dungeon_run/flame_game/components/characters/assassin.dart';
import 'package:flame/components.dart';

/// The [DaggerAttackEffect] is an effect that is composed of multiple different effects
/// that are added to the [Archer] when it attacks.
/// It spins the sword.
class DaggerAttackEffect extends Component with ParentIsA<Assassin> {
  final effectTime = 0.5;
  final Vector2 destination;

  DaggerAttackEffect({
    required this.destination,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    parent.opacity = 0;

    final sprite = await Sprite.load('characters/assassin.png');

    final assassin = SpriteComponent(
      sprite: sprite,
      size: Vector2(100, 150),
      anchor: Anchor.bottomCenter,
    );

    // The arrow should start at the bottom of the character
    assassin.position = destination;

    parent.parent?.add(assassin);

    Future.delayed(Duration(milliseconds: (effectTime * 300).toInt()), () {
      assassin.removeFromParent();
      parent.opacity = 1;
    });
  }
}
