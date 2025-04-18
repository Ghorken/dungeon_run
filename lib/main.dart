import 'package:dungeon_run/progression/level_provider.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/trophies/trophy_provider.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import 'package:dungeon_run/navigation/app_lifecycle.dart';
import 'package:dungeon_run/audio/audio_controller.dart';
import 'package:dungeon_run/navigation/router.dart';
import 'package:dungeon_run/settings/settings_controller.dart';
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
              child: MaterialApp.router(
                title: Strings.appName,
                theme: flutterNesTheme().copyWith(
                  colorScheme: ColorScheme.dark(),
                ),
                routerConfig: router,
              ),
            );
          },
        ),
      ),
    );
  }
}
