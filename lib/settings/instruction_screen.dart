import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/style/wobbly_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({
    super.key,
  });

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: ListView(
                  children: [
                    _gap,
                    const Text(
                      'Istruzioni',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 30,
                        height: 1,
                      ),
                    ),
                    _gap,
                    const Text(
                      'Componi il tuo party con un minimo di uno e un massimo di 3 personaggi e scegli la loro posizione.\n Più personaggi metti più aumenterà la difficoltà.\n Clicca su un personaggio per farlo attaccare.\n Il guerriero fa molti danni ma a corta distanza, l\' arciere fa pochi danni ma a lunga distanza, il mago fa pochi danni a media distanza ma ad area, l\'assassino fa pochi danni ma a qualunque distanza, il berserk fa molti danni a media distanza.\n Clicca sulle trappole per disattivarle prima che ti colpiscano.\n Clicca sulle pozioni prima che scompaiano per attiverne i benefici.\n Riuscirai a raggiungere il re dei goblin e ucciderlo?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WobblyButton(
              onPressed: () {
                // Handle button press

                GoRouter.of(context).go('/instructions/selectCharacters');
              },
              child: const Text('Gioca'),
            ),
            _gap,
            WobblyButton(
              onPressed: () {
                GoRouter.of(context).pop();
              },
              child: const Text('Indietro'),
            ),
            _gap,
          ],
        ),
      ),
    );
  }
}
