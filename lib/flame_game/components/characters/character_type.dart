/// Enums of available [CharacterType]
enum CharacterType {
  warrior,
  archer,
  wizard,
  assassin,
  berserk,
}

/// Get the label for each character
String getLabel(CharacterType characterType) => switch (characterType) {
      CharacterType.warrior => 'Guerriero',
      CharacterType.archer => 'Arciere',
      CharacterType.wizard => 'Mago',
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
    case 'wizard':
      return CharacterType.wizard;
    case 'berserk':
      return CharacterType.berserk;
    case 'assassin':
      return CharacterType.assassin;
    default:
      return CharacterType.warrior;
  }
}
