import 'package:dungeon_run/style/palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/wobbly_button.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

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
                    const Text(
                      'Impostazioni',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 30,
                        height: 1,
                      ),
                    ),
                    _gap,
                    ValueListenableBuilder<bool>(
                      valueListenable: settings.soundsOn,
                      builder: (context, soundsOn, child) => _SettingsLine(
                        'Effetti sonori',
                        Icon(soundsOn ? Icons.graphic_eq : Icons.volume_off),
                        onSelected: () => settings.toggleSoundsOn(),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: settings.musicOn,
                      builder: (context, musicOn, child) => _SettingsLine(
                        'Musica',
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
                GoRouter.of(context).pop();
              },
              child: const Text('Indietro'),
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
