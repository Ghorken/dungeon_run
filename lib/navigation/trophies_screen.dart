import 'package:dungeon_run/trophies/trophy_provider.dart';
import 'package:dungeon_run/trophies/trophy.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/utils/wobbly_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrophiesScreen extends StatefulWidget {
  static const String routeName = "/trophies";

  const TrophiesScreen({super.key});

  @override
  State<TrophiesScreen> createState() => _TrophiesScreenState();
}

class _TrophiesScreenState extends State<TrophiesScreen> {
  /// The gap between elements
  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final List<Trophy> trophies = Provider.of<TrophyProvider>(context).trophies;
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: Center(
        child: Column(
          children: [
            _gap,
            Text(
              Strings.trophies,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Press Start 2P',
                fontSize: 30,
                height: 1,
              ),
            ),
            _gap,
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: ListView(
                  children: [
                    ...trophies.map(
                      (Trophy entry) {
                        /// An element is not visible if is not unlocked
                        if (entry.unlocked == false) {
                          return const SizedBox.shrink();
                        }

                        return Card(
                          elevation: 10.0,
                          color: Palette().backgroundSecondary.color,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/${entry.iconPath}",
                                  width: 30,
                                  height: 30,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.name,
                                        style: TextStyle(
                                          fontFamily: 'Press Start 2P',
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        entry.description,
                                        style: TextStyle(
                                          fontFamily: 'Press Start 2P',
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _gap,
            WobblyButton(
              onPressed: () {
                navigator.pop();
              },
              child: Text(Strings.back),
            ),
            _gap,
          ],
        ),
      ),
    );
  }
}
