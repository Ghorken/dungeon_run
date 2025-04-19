import 'dart:convert';

/// Definition of the Trophy type
typedef Trophy = ({
  String id,
  String name,
  String description,
  String iconPath,
  bool unlocked,
});

/// Function to convert a Trophy to a string
String trophiesToString(Trophy trophy) {
  return json.encode({
    "id": trophy.id,
    "name": trophy.name,
    "description": trophy.description,
    "iconPath": trophy.iconPath,
    "unlocked": trophy.unlocked,
  });
}

/// Function to convert a string to a Trophy
Trophy stringToTrophy(String trophyString) {
  final Map<String, dynamic> jsonMap = json.decode(trophyString) as Map<String, dynamic>;

  return (
    id: jsonMap["id"] as String,
    name: jsonMap["name"] as String,
    description: jsonMap["description"] as String,
    iconPath: jsonMap["iconPath"] as String,
    unlocked: jsonMap["unlocked"] as bool,
  );
}
