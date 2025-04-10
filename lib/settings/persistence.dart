import 'package:dungeon_run/store/default_upgrades.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An implementation of [Persistence] that uses
/// `package:shared_preferences`.
class Persistence {
  final Future<SharedPreferences> instanceFuture = SharedPreferences.getInstance();

  Future<bool> getAudioOn({required bool defaultValue}) async {
    final prefs = await instanceFuture;
    return prefs.getBool('audioOn') ?? defaultValue;
  }

  Future<bool> getMusicOn({required bool defaultValue}) async {
    final prefs = await instanceFuture;
    return prefs.getBool('musicOn') ?? defaultValue;
  }

  Future<bool> getSoundsOn({required bool defaultValue}) async {
    final prefs = await instanceFuture;
    return prefs.getBool('soundsOn') ?? defaultValue;
  }

  Future<int> getMoney() async {
    final prefs = await instanceFuture;
    return prefs.getInt('money') ?? 0;
  }

  Future<List<Upgrade>> getUpgrades() async {
    final prefs = await instanceFuture;

    List<String>? encodedList = prefs.getStringList('upgrades');
    List<Upgrade> recoveredUpgrades = [];
    if (encodedList != null) {
      for (String upgradeString in encodedList) {
        final Upgrade upgrade = stringToUpgrade(upgradeString);
        recoveredUpgrades.add(upgrade);
      }
    } else {
      recoveredUpgrades = defaultUpgrades;
    }

    return recoveredUpgrades;
  }

  Future<void> saveAudioOn(bool value) async {
    final prefs = await instanceFuture;
    await prefs.setBool('audioOn', value);
  }

  Future<void> saveMusicOn(bool value) async {
    final prefs = await instanceFuture;
    await prefs.setBool('musicOn', value);
  }

  Future<void> saveSoundsOn(bool value) async {
    final prefs = await instanceFuture;
    await prefs.setBool('soundsOn', value);
  }

  Future<void> saveMoney(int value) async {
    final prefs = await instanceFuture;

    await prefs.setInt('money', value);
  }

  Future<void> saveUpgrades(List<Upgrade> value) async {
    final prefs = await instanceFuture;
    List<String> encodedList = [];
    for (Upgrade upgrade in value) {
      final String upgradeString = upgradeToString(upgrade);
      encodedList.add(upgradeString);
    }

    await prefs.setStringList('upgrades', encodedList);
  }
}
