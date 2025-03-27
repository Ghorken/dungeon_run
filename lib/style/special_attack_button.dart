import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';

import 'package:dungeon_run/flame_game/components/characters/archer.dart';
import 'package:dungeon_run/flame_game/components/characters/assassin.dart';
import 'package:dungeon_run/flame_game/components/characters/berserk.dart';
import 'package:dungeon_run/flame_game/components/characters/warrior.dart';
import 'package:dungeon_run/flame_game/components/characters/wizard.dart';
import 'package:dungeon_run/flame_game/components/characters/character.dart';

/// Class that handles the special attack buttonf of the characters in the game screen
class SpecialAttackButton extends StatefulWidget {
  final Character character;
  final double topPosition;

  const SpecialAttackButton({
    required this.character,
    required this.topPosition,
    super.key,
  });

  @override
  State<SpecialAttackButton> createState() => _SpecialAttackButtonState();
}

class _SpecialAttackButtonState extends State<SpecialAttackButton> {
  /// Specify if the button should be disabled
  bool isDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPosition,
      right: 10,
      child: NesButton(
        type: NesButtonType.normal,
        onPressed: isDisabled ? null : handleButtonClick,
        child: NesIcon(iconData: getButtonIcon(widget.character)),
      ),
    );
  }

  /// Make the character attacks and disable the button
  void handleButtonClick() {
    widget.character.specialAttack();
    setState(() {
      isDisabled = true; // Disable the button
    });

    // Re-enable the button after the cooldown time has passed
    Future.delayed(
      Duration(
        seconds: widget.character.cooldownTimer,
      ),
      () {
        if (mounted) {
          setState(
            () {
              isDisabled = false;
            },
          );
        }
      },
    );
  }

  /// Retrieve the button icon based on the character
  NesIconData getButtonIcon(Character character) {
    if (character is Warrior) {
      return NesIcons.sword;
    }
    if (character is Archer) {
      return NesIcons.arrow;
    }
    if (character is Wizard) {
      return NesIcons.hourglassMiddle;
    }
    if (character is Assassin) {
      return NesIcons.keyHole;
    }
    if (character is Berserk) {
      return NesIcons.axe;
    }
    return NesIcons.add;
  }
}
