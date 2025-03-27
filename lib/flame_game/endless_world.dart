import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/flame_game/components/trap.dart';
import 'package:dungeon_run/flame_game/components/enemy.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/flame_game/components/collectable.dart';
import 'package:dungeon_run/flame_game/game_screen.dart';

/// The world is where you place all the components that should live inside of
/// the game, like the character, enemies, obstacles and points for example.
/// The world can be much bigger than what the camera is currently looking at,
/// but in this game all components that go outside of the size of the viewport
/// are removed, since the character can't interact with those anymore.
///
/// The [EndlessWorld] has two mixins added to it:
///  - The [TapCallbacks] that makes it possible to react to taps (or mouse
///  clicks) on the world.
///  - The [HasGameReference] that gives the world access to a variable called
///  `game`, which is a reference to the game class that the world is attached
///  to.
class EndlessWorld extends World with TapCallbacks, HasGameReference {
  EndlessWorld({
    required List<CharacterType?> selectedCharacters,
  }) : _selectedCharacters = selectedCharacters;

  /// The size of the game screen
  Vector2 get size => (parent as FlameGame).size;

  /// Define the positions for the three possible characters to show
  // These are late because they need the size of the screen
  late Vector2 frontCharacterPosition = Vector2(0, (size.y / 2) - (size.y / 10));
  late Vector2 leftCharacterPosition = Vector2(-(size.x / 2) + (size.x / 5), (size.y / 2) - (size.y / 20));
  late Vector2 rightCharacterPosition = Vector2((size.x / 2) - (size.x / 5), (size.y / 2) - (size.y / 20));

  /// This is used to measure the duration of the effects
  late final DateTime timeStarted;

  /// List of characters selected from the player
  final List<CharacterType?> _selectedCharacters;

  /// List to keep track of [Character] in the world.
  final List<Character> characters = [];

  /// List to keep track of dead [Character]
  final List<Character> deadCharacters = [];

  /// List to keep track of [Collectable] in the world.
  final List<Collectable> collectables = [];

  /// List to keep track of enemies in the world.
  final List<Enemy> enemies = [];

  /// List to keep track of traps in the world.
  final List<Trap> traps = [];

  /// The [Character] that is in the front slot.
  Character? frontCharacter;

  /// The [Character] that is in the left slot.
  Character? leftCharacter;

  /// The [Character] that is in the right slot.
  Character? rightCharacter;

  /// The base speed at which every elements move.
  int speed = 200;

  /// The amount of money that the player collected
  int money = 0;

  @override
  Future<void> onLoad() async {
    // If the player selected a leftCharacter initialize id and add id to the screen
    if (_selectedCharacters[0] != null) {
      leftCharacter = createCharacter(
        _selectedCharacters[0]!,
        leftCharacterPosition,
      );
      add(leftCharacter!);
      characters.add(leftCharacter!);
    }

    // If the player selected a frontCharacter initialize id and add id to the screen
    if (_selectedCharacters[1] != null) {
      frontCharacter = createCharacter(
        _selectedCharacters[1]!,
        frontCharacterPosition,
      );
      add(frontCharacter!);
      characters.add(frontCharacter!);
    }

    // If the player selected a rightCharacter initialize id and add id to the screen
    if (_selectedCharacters[2] != null) {
      rightCharacter = createCharacter(
        _selectedCharacters[2]!,
        rightCharacterPosition,
      );
      add(rightCharacter!);
      characters.add(rightCharacter!);
    }

    // Spawning random enemies in the world at a fixed interval
    add(
      SpawnComponent(
        factory: (_) {
          final Enemy enemy = Enemy.random();
          enemies.add(enemy);
          return enemy;
        },
        period: 2,
      ),
    );

    // Schedule the goblinKing to spawn after 5 minutes
    add(
      TimerComponent(
        period: 300, // 5 minutes in seconds
        repeat: false, // Spawn only once
        onTick: () {
          final Enemy goblinKing = Enemy.goblinKing();
          enemies.add(goblinKing);
          add(goblinKing);
        },
      ),
    );

    // Spawning traps in the world at a random interval between fixed values
    add(
      SpawnComponent.periodRange(
        factory: (_) {
          final Trap trap = Trap.random();
          traps.add(trap);
          return trap;
        },
        minPeriod: 5.0,
        maxPeriod: 7.0,
      ),
    );

    // Spawning [Collectable] in the world at a random interval between fixed values
    add(
      SpawnComponent.periodRange(
        factory: (_) {
          Collectable collectable = Collectable.random();
          collectables.add(collectable);
          return collectable;
        },
        minPeriod: 3.0,
        maxPeriod: 6.0,
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    // When the world is mounted in the game we add a back button widget as an
    // overlay so that the character can go back to the previous screen.
    game.overlays.add(GameScreen.backButtonKey);
  }

  @override
  void onRemove() {
    game.overlays.remove(GameScreen.backButtonKey);
  }

  /// [onTapDown] is called when the character taps the screen
  @override
  void onTapDown(TapDownEvent event) {
    // If the player taps on a character, we make it attack.
    if (frontCharacter != null && characters.contains(frontCharacter) && frontCharacter!.toRect().contains(event.localPosition.toOffset())) {
      frontCharacter!.attack();
      return;
    } else if (leftCharacter != null && characters.contains(leftCharacter) && leftCharacter!.toRect().contains(event.localPosition.toOffset())) {
      leftCharacter!.attack();
      return;
    } else if (rightCharacter != null && characters.contains(rightCharacter) && rightCharacter!.toRect().contains(event.localPosition.toOffset())) {
      rightCharacter!.attack();
      return;
    }

    // If the player taps on a [Collectable], we apply its effect and remove it from the world
    for (final collectable in collectables) {
      if (collectable.toRect().contains(event.localPosition.toOffset())) {
        collectable.effect();
        collectable.opacity = 0.0;
        collectables.remove(collectable);
        break;
      }
    }

    // If the player taps on a trap, we remove it from the world
    for (final Trap trap in traps) {
      if (trap.toRect().contains(event.localPosition.toOffset())) {
        trap.disable();
        break;
      }
    }
  }

  /// When the player loose stop the game and shows the relative dialog
  void loose() {
    // Stop the game and remove the back button
    game.pauseEngine();
    game.overlays.remove(GameScreen.backButtonKey);

    // Show the loose dialog
    game.overlays.add(GameScreen.looseDialogKey);

    // Save the accumulated money
    Persistence persistence = Persistence();
    persistence.saveMoney(money);
  }

  /// When the player wins stop the game and shows the relative dialog
  void win() {
    // Stop the game and remove the back button
    game.pauseEngine();
    game.overlays.remove(GameScreen.backButtonKey);

    // Show the win dialog
    game.overlays.add(GameScreen.winDialogKey);

    // Save the accumulated money
    Persistence persistence = Persistence();
    persistence.saveMoney(money);
  }
}
