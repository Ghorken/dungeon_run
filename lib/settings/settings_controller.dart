import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:dungeon_run/settings/persistence.dart';

/// A class that holds settings
/// and saves them to an injected persistence store.
class SettingsController {
  static final _log = Logger('SettingsController');

  /// The persistence store that is used to save settings.
  final Persistence _store;

  /// Whether or not the audio is on at all. This overrides both music
  /// and sounds (sfx).
  ValueNotifier<bool> audioOn = ValueNotifier(true);

  /// Whether or not the sound effects (sfx) are on.
  ValueNotifier<bool> soundsOn = ValueNotifier(true);

  /// Whether or not the music is on.
  ValueNotifier<bool> musicOn = ValueNotifier(true);

  /// Creates a new instance of [SettingsController] backed by [store].
  ///
  /// By default, settings are persisted using [LocalStorageSettingsPersistence]
  /// (i.e. NSUserDefaults on iOS, SharedPreferences on Android or
  /// local storage on the web).
  SettingsController() : _store = Persistence() {
    _loadStateFromPersistence();
  }

  void toggleAudioOn() {
    audioOn.value = !audioOn.value;
    _store.saveAudioOn(audioOn.value);
  }

  void toggleMusicOn() {
    musicOn.value = !musicOn.value;
    _store.saveMusicOn(musicOn.value);
  }

  void toggleSoundsOn() {
    soundsOn.value = !soundsOn.value;
    _store.saveSoundsOn(soundsOn.value);
  }

  /// Asynchronously loads values from the injected persistence store.
  Future<void> _loadStateFromPersistence() async {
    final loadedValues = await Future.wait([
      _store.getAudioOn(defaultValue: true).then((value) => audioOn.value = value),
      _store.getSoundsOn(defaultValue: true).then((value) => soundsOn.value = value),
      _store.getMusicOn(defaultValue: true).then((value) => musicOn.value = value),
    ]);

    _log.fine(() => 'Loaded settings: $loadedValues');
  }
}
