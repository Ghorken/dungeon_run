import 'dart:convert';

import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/traps/trap_type.dart';

/// Definition of the Level type
typedef Level = ({
  String name,
  bool completed,
  List<String>? dependency,
  List<EnemyType> enemies,
  double enemyFrequency,
  BossType boss,
  double bossTimer,
  List<TrapType> traps,
  double trapMinPeriod,
  double trapMaxPeriod,
  double collectableMinPeriod,
  double collectableMaxPeriod,
  String map,
  Map<String, dynamic> rewards,
  String message,
});

/// Function to convert a Level to a string
String levelToString(Level level) {
  return json.encode({
    "name": level.name,
    "completed": level.completed,
    "dependency": level.dependency?.join(','),
    "enemies": level.enemies.map((e) => e.toString()).join(','),
    "enemyFrequency": level.enemyFrequency,
    "boss": level.boss.toString(),
    "bossTimer": level.bossTimer,
    "traps": level.traps.map((e) => e.toString()).join(','),
    "trapMinPeriod": level.trapMinPeriod,
    "trapMaxPeriod": level.trapMaxPeriod,
    "collectableMaxPeriod": level.collectableMaxPeriod,
    "collectableMinPeriod": level.collectableMinPeriod,
    "map": level.map,
    "rewards": json.encode(level.rewards),
    "message": level.message,
  });
}

/// Function to convert a string to a Level
Level stringToLevel(String levelString) {
  final Map<String, dynamic> jsonMap = json.decode(levelString) as Map<String, dynamic>;
  final rewards = json.decode(jsonMap["rewards"] as String) as Map<String, dynamic>;

  // Make sure the rewards are in the correct format
  if (rewards["upgrades"] != null) {
    rewards["upgrades"] = (rewards["upgrades"] as List<dynamic>).cast<String>();
  }

  return (
    name: jsonMap["name"] as String,
    completed: jsonMap["completed"] as bool,
    dependency: (jsonMap["dependency"] as String?)?.split(','),
    enemies: (jsonMap["enemies"] as String).split(',').map((e) => EnemyType.values.firstWhere((EnemyType type) => type.toString() == e)).toList(),
    enemyFrequency: jsonMap["enemyFrequency"] as double,
    boss: BossType.values.firstWhere((BossType type) => type.toString() == jsonMap["boss"]),
    bossTimer: jsonMap["bossTimer"] as double,
    traps: (jsonMap["traps"] as String).isEmpty ? [] : (jsonMap["traps"] as String).split(',').map((e) => TrapType.values.firstWhere((TrapType type) => type.toString() == e)).toList(),
    trapMinPeriod: jsonMap["trapMinPeriod"] as double,
    trapMaxPeriod: jsonMap["trapMaxPeriod"] as double,
    collectableMinPeriod: jsonMap["collectableMinPeriod"] as double,
    collectableMaxPeriod: jsonMap["collectableMaxPeriod"] as double,
    map: jsonMap["map"] as String,
    rewards: rewards,
    message: jsonMap["message"] as String,
  );
}
