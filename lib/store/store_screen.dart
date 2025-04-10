import 'dart:math';

import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/store/default_upgrades.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/strings.dart';
import 'package:dungeon_run/style/palette.dart';
import 'package:dungeon_run/style/wobbly_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  /// The gap between elements
  static const _gap = SizedBox(height: 60);

  /// The container of local saved data
  final Persistence _persistence = Persistence();

  /// The amount of gold the player has
  int _gold = 0;

  /// Map that store every purchase made
  List<Upgrade> _upgrades = [];

  /// Whether the data is still loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItemsFromPersistence();
  }

  /// Load the gold and the buyed item from persistence
  Future<void> _loadItemsFromPersistence() async {
    final int fetchedGold = await _persistence.getGold();
    final List<Upgrade> fetchedUpgrades = await _persistence.getUpgrades();
    setState(() {
      _gold = fetchedGold;
      _upgrades = fetchedUpgrades;
      _isLoading = false;
    });
  }

  /// Try to buy an item and advice the user if there aren't enough gold
  void buy(Upgrade item) {
    if (_gold >= item.cost) {
      setState(() {
        _gold -= item.cost;
        final int index = _upgrades.indexWhere((Upgrade upgrade) => upgrade.name == item.name);
        final int cost = (pow(item.costFactor, item.currentLevel + 1) * item.cost / 10).round() * 10;

        _upgrades[index] = (
          name: item.name,
          description: item.description,
          subMenu: item.subMenu,
          unlocked: item.unlocked,
          dependency: item.dependency,
          characterType: item.characterType,
          cost: cost,
          costFactor: item.costFactor,
          currentLevel: item.currentLevel + 1,
          maxLevel: item.maxLevel,
          baseCooldown: item.baseCooldown,
          step: item.step,
        );
      });
    } else {
      Fluttertoast.showToast(
        msg: Strings.notEnoughGold,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while data is being fetched
      return Scaffold(
        backgroundColor: Palette().backgroundMain.color,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                    '$_gold',
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
                    ..._upgrades.map(
                      (Upgrade entry) {
                        /// An element is not visible if:
                        /// - it has no dependency (null) and is not unlocked
                        /// - it has a dependency and the dependency is not unlocked
                        if ((entry.dependency == null && entry.unlocked == false) || (entry.dependency != null && _upgrades.firstWhere((Upgrade upgrade) => upgrade.name == entry.dependency).unlocked == false)) {
                          return const SizedBox.shrink();
                        }

                        /// An element is buyable if the gold is enough to buy it
                        final bool isBuyable = _gold >= entry.cost;

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
                                          Strings.unlocked,
                                          style: TextStyle(
                                            fontFamily: 'Press Start 2P',
                                            fontSize: 15,
                                          ),
                                        )
                                      : WobblyButton(
                                          onPressed: isBuyable
                                              ? () {
                                                  buy(entry);
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
                    _gap,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              Strings.resetExplanation,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Press Start 2P',
                                fontSize: 15,
                              ),
                            ),
                          ),
                          WobblyButton(
                            onPressed: () {
                              setState(() {
                                _gold = 0;
                                _upgrades = List.from(defaultUpgrades);
                              });
                            },
                            child: Text(Strings.reset),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _gap,
            WobblyButton(
              onPressed: () {
                _persistence.saveGold(_gold);
                _persistence.saveUpgrades(_upgrades);
                GoRouter.of(context).pop();
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
