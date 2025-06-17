import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/store/upgrade_provider.dart';
import 'package:dungeon_run/trophies/trophy_provider.dart';
import 'package:dungeon_run/utils/strings.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/utils/wobbly_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreScreen extends StatefulWidget {
  static const String routeName = "/store";

  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  /// The gap between elements
  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final List<Upgrade> upgrades = Provider.of<UpgradeProvider>(context).upgrades;
    final int gold = Provider.of<UpgradeProvider>(context).gold;
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: Center(
        child: Column(
          children: [
            _gap,
            Text(
              Strings.store,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Press Start 2P',
                fontSize: 30,
                height: 1,
              ),
            ),
            _gap,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      Strings.gold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    '$gold',
                    style: const TextStyle(
                      fontFamily: 'Press Start 2P',
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            _gap,
            Text(
              Strings.upgrades,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Press Start 2P',
                fontSize: 20,
                height: 1,
              ),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: ListView(
                  children: [
                    ...upgrades.map(
                      (Upgrade entry) {
                        /// An element is not visible if:
                        /// - it has no dependency (null) and is not unlocked
                        /// - it has a dependency and the dependency is not unlocked
                        if (entry.unlocked == false || (entry.dependency != null && upgrades.firstWhere((Upgrade upgrade) => upgrade.name == entry.dependency).unlocked == false)) {
                          return const SizedBox.shrink();
                        }

                        /// An element is buyable if the gold is enough to buy it
                        final bool isBuyable = gold >= entry.cost;

                        return SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: entry.subMenu * 20.0),
                                    child: Text(
                                      entry.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Press Start 2P',
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                // If the item has been buyed at least once show the current level
                                if (entry.currentLevel >= 1)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 10.0,
                                    ),
                                    child: Text(
                                      entry.currentLevel.toString(),
                                      style: TextStyle(
                                        fontFamily: 'Press Start 2P',
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                // If the item has no value it should not be available to buy
                                if (entry.cost > 0)
                                  // If it has a value show if it's already unlocked or if it's unlockable/upgradable
                                  (entry.currentLevel >= entry.maxLevel)
                                      ? Text(
                                          Strings.completed,
                                          style: TextStyle(
                                            fontFamily: 'Press Start 2P',
                                            fontSize: 15,
                                          ),
                                        )
                                      : WobblyButton(
                                          onPressed: isBuyable
                                              ? () {
                                                  Provider.of<TrophyProvider>(context, listen: false).incrementUpgrades();
                                                  Provider.of<UpgradeProvider>(context, listen: false).buyUpgrade(entry.name);
                                                  Provider.of<UpgradeProvider>(context, listen: false).setGold = gold - entry.cost;
                                                  Provider.of<UpgradeProvider>(context, listen: false).saveToMemory();
                                                }
                                              : null,
                                          child: Text('${entry.cost}'),
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
