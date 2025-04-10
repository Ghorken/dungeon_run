/// Enums of available [CharacterType]
enum CharacterType {
  warrior,
  archer,
  mage,
  assassin,
  berserk,
}

/// Return the string value of the enum
String getCharacterTypeString(CharacterType characterType) => switch (characterType) {
      CharacterType.warrior => 'warrior',
      CharacterType.archer => 'archer',
      CharacterType.mage => 'mage',
      CharacterType.assassin => 'assassin',
      CharacterType.berserk => 'berserk',
    };

/// Get the label for each character
String getLabel(CharacterType characterType) => switch (characterType) {
      CharacterType.warrior => 'Guerriero',
      CharacterType.archer => 'Arciere',
      CharacterType.mage => 'Mago',
      CharacterType.assassin => 'Assassino',
      CharacterType.berserk => 'Berserk',
    };

/// Get the type from label
CharacterType getCharacterType(String label) {
  switch (label) {
    case 'warrior':
      return CharacterType.warrior;
    case 'archer':
      return CharacterType.archer;
    case 'mage':
      return CharacterType.mage;
    case 'berserk':
      return CharacterType.berserk;
    case 'assassin':
      return CharacterType.assassin;
    default:
      return CharacterType.warrior;
  }
}
