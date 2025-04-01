import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/store/store_screen.dart';
import 'package:go_router/go_router.dart';

import 'package:dungeon_run/settings/instruction_screen.dart';
import 'package:dungeon_run/settings/select_characters_screen.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/flame_game/game_screen.dart';
import 'package:dungeon_run/main_menu/main_menu_screen.dart';
import 'package:dungeon_run/settings/settings_screen.dart';
import 'package:dungeon_run/style/page_transition.dart';

/// The router describes the game's navigational hierarchy
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(),
      routes: [
        GoRoute(
          path: 'instructions',
          builder: (context, state) => const InstructionScreen(),
        ),
        GoRoute(
          path: 'selectCharacters',
          builder: (context, state) => SelectCharactersScreen(
            unlockedCharacters: state.extra as List<CharacterType>,
          ),
        ),
        GoRoute(
          path: 'play',
          pageBuilder: (context, state) => buildPageTransition<void>(
            color: Palette().backgroundMain.color,
            child: GameScreen(
              selectedCharacters: state.extra as List<CharacterType?>,
            ),
          ),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'store',
          builder: (context, state) => const StoreScreen(),
        ),
      ],
    ),
  ],
);
