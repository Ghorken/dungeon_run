import 'dart:convert';

import 'package:dungeon_run/flame_game/components/characters/character_type.dart';

/// Definition of the Upgrade type
typedef Upgrade = ({
  String name,
  String description,
  int subMenu,
  bool? unlocked,
  String? dependency,
  CharacterType? characterType,
  int cost,
  double costFactor,
  int currentLevel,
  int maxLevel,
  int? baseCooldown,
  double? step,
});

/// Function to convert an Upgrade to a string
String upgradeToString(Upgrade upgrade) {
  return json.encode({
    "name": upgrade.name,
    "description": upgrade.description,
    "subMenu": upgrade.subMenu,
    "unlocked": upgrade.unlocked,
    "dependency": upgrade.dependency,
    "characterType": upgrade.characterType?.toString(),
    "cost": upgrade.cost,
    "costFactor": upgrade.costFactor,
    "currentLevel": upgrade.currentLevel,
    "maxLevel": upgrade.maxLevel,
    "baseCooldown": upgrade.baseCooldown,
    "step": upgrade.step,
  });
}

/// Function to convert a string to an Upgrade
Upgrade stringToUpgrade(String upgradeString) {
  final Map<String, dynamic> jsonMap = json.decode(upgradeString) as Map<String, dynamic>;

  return (
    name: jsonMap["name"] as String,
    description: jsonMap["description"] as String,
    subMenu: jsonMap["subMenu"] as int,
    unlocked: jsonMap["unlocked"] as bool?,
    dependency: jsonMap["dependency"] as String?,
    characterType: jsonMap["characterType"] != null
        ? CharacterType.values.firstWhere(
            (CharacterType type) => type.toString() == jsonMap["characterType"],
          )
        : null,
    cost: jsonMap["cost"] as int,
    costFactor: jsonMap["costFactor"] as double,
    currentLevel: jsonMap["currentLevel"] as int,
    maxLevel: jsonMap["maxLevel"] as int,
    baseCooldown: jsonMap["baseCooldown"] as int?,
    step: jsonMap["step"] as double?,
  );
}
