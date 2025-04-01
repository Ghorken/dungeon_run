import 'dart:convert';

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

  Future<Map<String, dynamic>> getUpgrades() async {
    final prefs = await instanceFuture;

    String encodedMap = prefs.getString('upgrades') ?? '{}';
    Map<String, dynamic> decodedMap = json.decode(encodedMap) as Map<String, dynamic>;

    return decodedMap;
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

  Future<void> saveUpgrades(Map<String, dynamic> value) async {
    final prefs = await instanceFuture;
    String encodedMap = json.encode(value);

    await prefs.setString('upgrades', encodedMap);
  }
}
