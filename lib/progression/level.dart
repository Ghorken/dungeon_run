import 'dart:convert';

import 'package:dungeon_run/flame_game/components/collectables/collectable_type.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/traps/trap_type.dart';

/// Definition of the Level type
typedef Level = ({
  String name,
  bool completed,
  List<String>? dependency,
  List<EnemyType> enemies,
  double enemyFrequency,
  EnemyType boss,
  double bossTimer,
  List<TrapType> traps,
  double trapMinPeriod,
  double trapMaxPeriod,
  List<CollectableType> collectables,
  double collectableMinPeriod,
  double collectableMaxPeriod,
  String map,
  Map<String, dynamic> rewards,
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
    "collectables": level.collectables.map((e) => e.toString()).join(','),
    "collectableMaxPeriod": level.collectableMaxPeriod,
    "collectableMinPeriod": level.collectableMinPeriod,
    "map": level.map,
    "rewards": json.encode(level.rewards),
  });
}

/// Function to convert a string to a Level
Level stringToLevel(String levelString) {
  final Map<String, dynamic> jsonMap = json.decode(levelString) as Map<String, dynamic>;

  return (
    name: jsonMap["name"] as String,
    completed: jsonMap["completed"] as bool,
    dependency: (jsonMap["dependency"] as String?)?.split(','),
    enemies: (jsonMap["enemies"] as String).split(',').map((e) => EnemyType.values.firstWhere((EnemyType type) => type.toString() == e)).toList(),
    enemyFrequency: jsonMap["enemyFrequency"] as double,
    boss: EnemyType.values.firstWhere((EnemyType type) => type.toString() == jsonMap["boss"]),
    bossTimer: jsonMap["bossTimer"] as double,
    traps: (jsonMap["traps"] as String).isEmpty ? [] : (jsonMap["traps"] as String).split(',').map((e) => TrapType.values.firstWhere((TrapType type) => type.toString() == e)).toList(),
    trapMinPeriod: jsonMap["trapMinPeriod"] as double,
    trapMaxPeriod: jsonMap["trapMaxPeriod"] as double,
    collectables: (jsonMap["collectables"] as String).split(',').map((e) => CollectableType.values.firstWhere((CollectableType type) => type.toString() == e)).toList(),
    collectableMinPeriod: jsonMap["collectableMinPeriod"] as double,
    collectableMaxPeriod: jsonMap["collectableMaxPeriod"] as double,
    map: jsonMap["map"] as String,
    rewards: json.decode(jsonMap["rewards"] as String) as Map<String, dynamic>,
  );
}

/// function to set the level as completed
void setLevelCompleted(Level level) {
  level = (
    name: level.name,
    completed: true,
    dependency: level.dependency,
    enemies: level.enemies,
    enemyFrequency: level.enemyFrequency,
    boss: level.boss,
    bossTimer: level.bossTimer,
    traps: level.traps,
    trapMinPeriod: level.trapMinPeriod,
    trapMaxPeriod: level.trapMaxPeriod,
    collectables: level.collectables,
    collectableMinPeriod: level.collectableMinPeriod,
    collectableMaxPeriod: level.collectableMaxPeriod,
    map: level.map,
    rewards: level.rewards,
  );
}
