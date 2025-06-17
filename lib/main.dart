import 'package:dungeon_run/flame_game/components/characters/character_type.dart';
import 'package:dungeon_run/navigation/game_screen.dart';
import 'package:dungeon_run/navigation/main_menu_screen.dart';
import 'package:dungeon_run/navigation/select_characters_screen.dart';
import 'package:dungeon_run/navigation/select_level_screen.dart';
import 'package:dungeon_run/navigation/settings_screen.dart';
import 'package:dungeon_run/navigation/store_screen.dart';
import 'package:dungeon_run/navigation/trophies_screen.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/trophies/trophy_provider.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import 'package:dungeon_run/navigation/app_lifecycle.dart';
import 'package:dungeon_run/audio/audio_controller.dart';
import 'package:dungeon_run/settings/settings_controller.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:toastification/toastification.dart';

GlobalKey<ScaffoldMessengerState> navigatorKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Set the device in portrait mode and in full screen
  await Flame.device.setPortraitUpOnly();
  await Flame.device.fullScreen();

  runApp(const DungeonRun());
}

class DungeonRun extends StatelessWidget {
  const DungeonRun({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          Provider(create: (context) => SettingsController()),
          // Set up audio.
          ProxyProvider2<SettingsController, AppLifecycleStateNotifier, AudioController>(
            // Ensures that music starts immediately.
            lazy: false,
            create: (context) => AudioController(),
            update: (context, settings, lifecycleNotifier, audio) {
              audio!.attachDependencies(lifecycleNotifier, settings);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
          ),
          ChangeNotifierProvider(create: (_) => UpgradeProvider()),
          ChangeNotifierProvider(create: (_) => LevelProvider()),
          ChangeNotifierProvider(create: (_) => TrophyProvider()),
        ],
        child: Builder(
          builder: (context) {
            return ToastificationWrapper(
              child: MaterialApp(
                title: Strings.appName,
                theme: flutterNesTheme().copyWith(
                  colorScheme: ColorScheme.dark(),
                ),
                // Use the splash screen as the initial screen then navigate to the main menu.
                home: SplashScreen.navigate(
                  name: 'assets/animations/anvil.riv',
                  next: (context) => MainMenuScreen(),
                  until: () => Future.delayed(const Duration(milliseconds: 1000)),
                  loopAnimation: 'Martellata',
                  backgroundColor: Palette().backgroundMainDark.color,
                  fit: BoxFit.contain,
                ),
                routes: {
                  MainMenuScreen.routeName: (BuildContext context) => const MainMenuScreen(),
                  SelectCharactersScreen.routeName: (BuildContext context) => const SelectCharactersScreen(),
                  SelectLevelScreen.routeName: (BuildContext context) => SelectLevelScreen(
                        selectedCharacters: (ModalRoute.of(context)?.settings.arguments as Map)['selectedCharacters'] as List<CharacterType?>,
                      ),
                  GameScreen.routeName: (BuildContext context) => GameScreen(
                        selectedCharacters: (ModalRoute.of(context)?.settings.arguments as Map)['selectedCharacters'] as List<CharacterType?>,
                        level: (ModalRoute.of(context)?.settings.arguments as Map)['level'] as Level,
                      ),
                  SettingsScreen.routeName: (BuildContext context) => const SettingsScreen(),
                  StoreScreen.routeName: (BuildContext context) => const StoreScreen(),
                  TrophiesScreen.routeName: (BuildContext context) => const TrophiesScreen(),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
