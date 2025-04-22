import 'dart:convert';

import 'package:dungeon_run/progression/default_levels.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/trophies/default_trophies.dart';
import 'package:dungeon_run/store/default_upgrades.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/trophies/trophy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An implementation of [Persistence] that uses
/// `package:shared_preferences`.
class Persistence {
  final Future<SharedPreferences> instanceFuture = SharedPreferences.getInstance();

  /// Retrieve the saved state of the audio
  Future<bool> getAudioOn({required bool defaultValue}) async {
    final prefs = await instanceFuture;
    return prefs.getBool('audioOn') ?? defaultValue;
  }

  /// Retrieve the saved state of the music
  Future<bool> getMusicOn({required bool defaultValue}) async {
    final prefs = await instanceFuture;
    return prefs.getBool('musicOn') ?? defaultValue;
  }

  /// Retrieve the saved state of the sounds
  Future<bool> getSoundsOn({required bool defaultValue}) async {
    final prefs = await instanceFuture;
    return prefs.getBool('soundsOn') ?? defaultValue;
  }

  /// Retrieve the saved state of the gold
  Future<int> getGold() async {
    final prefs = await instanceFuture;
    return prefs.getInt('gold') ?? 0;
  }

  /// Retrieve the saved state of the upgrades
  Future<List<Upgrade>> getUpgrades() async {
    final prefs = await instanceFuture;

    List<String>? encodedList = prefs.getStringList('upgrades');
    List<Upgrade> recoveredUpgrades = [];
    if (encodedList != null) {
      // If the list is not null, decode each string to an Upgrade object
      for (String upgradeString in encodedList) {
        final Upgrade upgrade = stringToUpgrade(upgradeString);
        recoveredUpgrades.add(upgrade);
      }
    } else {
      // If no upgrades are found, return the default upgrades
      recoveredUpgrades = defaultUpgrades;
    }

    return recoveredUpgrades;
  }

  /// Retrieve the saved state of the levels
  Future<List<Level>> getLevels() async {
    final prefs = await instanceFuture;
    List<String>? encodedList = prefs.getStringList('levels');
    List<Level> recoveredLevels = [];

    if (encodedList != null) {
      // If the list is not null, decode each string to a Level object
      for (String levelString in encodedList) {
        final Level level = stringToLevel(levelString);
        recoveredLevels.add(level);
      }
    } else {
      // If no levels are found, return the default levels
      recoveredLevels = List.from(defaultLevels);
    }

    return recoveredLevels;
  }

  /// Retrieve the saved state of the trophies
  Future<List<Trophy>> getTrophies() async {
    final prefs = await instanceFuture;
    List<String>? encodedList = prefs.getStringList('trophies');
    List<Trophy> recoveredTrophies = [];

    if (encodedList != null) {
      // If the list is not null, decode each string to a Trophy object
      for (String trophyString in encodedList) {
        final Trophy trophy = stringToTrophy(trophyString);
        recoveredTrophies.add(trophy);
      }
    } else {
      // If no trophies are found, return an empty list
      recoveredTrophies = defaultTrophies;
    }
    return recoveredTrophies;
  }

  /// Retrieve the trophies stats
  Future<Map<String, dynamic>> getTrophiesStats() async {
    final prefs = await instanceFuture;
    String? encodedString = prefs.getString('trophiesStats');
    Map<String, dynamic> recoveredTrophiesStats = {};

    if (encodedString != null) {
      // If the string is not null, decode it to a Map object
      recoveredTrophiesStats = jsonDecode(encodedString) as Map<String, dynamic>;
    }
    return recoveredTrophiesStats;
  }

  /// Save the state of the audio
  Future<void> saveAudioOn(bool value) async {
    final prefs = await instanceFuture;
    await prefs.setBool('audioOn', value);
  }

  /// Save the state of the music
  Future<void> saveMusicOn(bool value) async {
    final prefs = await instanceFuture;
    await prefs.setBool('musicOn', value);
  }

  /// Save the state of the sounds
  Future<void> saveSoundsOn(bool value) async {
    final prefs = await instanceFuture;
    await prefs.setBool('soundsOn', value);
  }

  /// Save the state of the gold
  Future<void> saveGold(int value) async {
    final prefs = await instanceFuture;

    await prefs.setInt('gold', value);
  }

  /// Save the state of the upgrades
  Future<void> saveUpgrades(List<String> value) async {
    final prefs = await instanceFuture;

    await prefs.setStringList('upgrades', value);
  }

  /// Save the state of the levels
  Future<void> saveLevels(List<String> value) async {
    final prefs = await instanceFuture;

    await prefs.setStringList('levels', value);
  }

  /// Save the state of the trophies
  Future<void> saveTrophies(List<String> value) async {
    final prefs = await instanceFuture;

    await prefs.setStringList('trophies', value);
  }

  /// Save the trophies stats
  Future<void> saveTrophiesStats(Map<String, dynamic> value) async {
    final prefs = await instanceFuture;

    await prefs.setString('trophiesStats', jsonEncode(value));
  }
}
