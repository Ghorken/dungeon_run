import 'package:dungeon_run/flame_game/components/characters/character.dart';
import 'package:dungeon_run/settings/instruction_screen.dart';
import 'package:dungeon_run/settings/select_characters_screen.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'flame_game/game_screen.dart';
import 'main_menu/main_menu_screen.dart';
import 'settings/settings_screen.dart';
import 'style/page_transition.dart';

/// The router describes the game's navigational hierarchy, from the main
/// screen through settings screens all the way to each individual level.
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(key: Key('main menu')),
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
                    child: GameScreen(selectedCharacters: [
                      _parseCharacterType((state.extra as Map<String, String?>)['sx']),
                      _parseCharacterType((state.extra as Map<String, String?>)['front']),
                      _parseCharacterType((state.extra as Map<String, String?>)['dx']),
                    ]),
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

/// Helper function to parse a string into a CharacterType
CharacterType? _parseCharacterType(String? type) {
  switch (type) {
    case 'warrior':
      return CharacterType.warrior;
    case 'archer':
      return CharacterType.archer;
    case 'wizard':
      return CharacterType.wizard;
    case 'assassin':
      return CharacterType.assassin;
    case 'berserk':
      return CharacterType.berserk;
    default:
      return null; // Return null if the type is invalid or not provided
  }
}
