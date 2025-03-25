/// Enums of available character type
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
