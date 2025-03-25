import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:flutter/material.dart';
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
      builder: (context, state) => const MainMenuScreen(
        key: Key('main menu'),
      ),
      routes: [
        GoRoute(
          path: 'instructions',
          builder: (context, state) => const InstructionScreen(
            key: Key('instructions'),
          ),
          routes: [
            GoRoute(
              path: 'selectCharacters',
              builder: (context, state) => const SelectCharactersScreen(
                key: Key('selectCharacters'),
              ),
              routes: [
                GoRoute(
                  path: 'play',
                  pageBuilder: (context, state) => buildPageTransition<void>(
                    key: const ValueKey('play'),
                    color: Palette().backgroundMain.color,
                    child: GameScreen(
                      selectedCharacters: state.extra as List<CharacterType?>,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(
            key: Key('settings'),
          ),
        ),
      ],
    ),
  ],
);
