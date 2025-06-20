import 'package:dungeon_run/utils/strings.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/utils/wobbly_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dungeon_run/settings/settings_controller.dart';

/// The page that handles the settings of the game
class SettingsScreen extends StatelessWidget {
  static const String routeName = "/settings";

  const SettingsScreen({super.key});

  /// The gap between elements
  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: ListView(
                  children: [
                    _gap,
                    Text(
                      Strings.settings,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 30,
                        height: 1,
                      ),
                    ),
                    _gap,
                    // The sounds effects
                    ValueListenableBuilder<bool>(
                      valueListenable: settings.soundsOn,
                      builder: (context, soundsOn, child) => _SettingsLine(
                        Strings.sounds,
                        Icon(soundsOn ? Icons.graphic_eq : Icons.volume_off),
                        onSelected: () => settings.toggleSoundsOn(),
                      ),
                    ),
                    // The base music
                    ValueListenableBuilder<bool>(
                      valueListenable: settings.musicOn,
                      builder: (context, musicOn, child) => _SettingsLine(
                        Strings.music,
                        Icon(musicOn ? Icons.music_note : Icons.music_off),
                        onSelected: () => settings.toggleMusicOn(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _gap,
            WobblyButton(
              onPressed: () {
                navigator.pop();
              },
              child: Text(Strings.back),
            ),
            _gap,
          ],
        ),
      ),
    );
  }
}

class _SettingsLine extends StatelessWidget {
  final String title;

  final Widget icon;

  final VoidCallback? onSelected;

  const _SettingsLine(this.title, this.icon, {this.onSelected});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Press Start 2P',
                  fontSize: 20,
                ),
              ),
            ),
            icon,
          ],
        ),
      ),
    );
  }
}
