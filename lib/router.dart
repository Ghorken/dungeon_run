import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/select_level_screen.dart';
import 'package:dungeon_run/store/store_screen.dart';
import 'package:go_router/go_router.dart';

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
          path: 'selectCharacters',
          builder: (context, state) => SelectCharactersScreen(),
        ),
        GoRoute(
          path: 'selectLevel',
          builder: (context, state) => SelectLevelScreen(
            selectedCharacters: (state.extra as Map)['selectedCharacters'] as List<CharacterType?>,
          ),
        ),
        GoRoute(
            path: 'play',
            pageBuilder: (context, state) {
              return buildPageTransition<void>(
                color: Palette().backgroundMain.color,
                child: GameScreen(
                  selectedCharacters: (state.extra as Map)['selectedCharacters'] as List<CharacterType?>,
                  level: (state.extra as Map)['level'] as Level,
                ),
              );
            }),
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
