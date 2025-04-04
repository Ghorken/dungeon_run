import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/store/default_upgrades.dart';
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

  /// The amount of money the player has
  int _money = 0;

  /// Map that store every purchase made
  Map<String, dynamic> _upgrades = {};

  @override
  void initState() {
    super.initState();
    _loadItemsFromPersistence();
  }

  /// Load the money and the buyed item from persistence
  Future<void> _loadItemsFromPersistence() async {
    final int fetchedMoney = await _persistence.getMoney();
    final Map<String, dynamic> fetchedUpgrades = await _persistence.getUpgrades();
    setState(() {
      _money = fetchedMoney;
      _upgrades = fetchedUpgrades;
    });
  }

  /// Try to buy an item and advice the user if there aren't enough money
  void buy(String item) {
    if (_money >= (_upgrades[item]!["value"] as int)) {
      setState(() {
        _money -= _upgrades[item]!["value"] as int;
        _upgrades[item]!["unlocked"] += 1;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Non ci sono abbastanza soldi",
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
    return Scaffold(
      backgroundColor: Palette().backgroundMain.color,
      body: Center(
        child: Column(
          children: [
            _gap,
            const Text(
              'Negozio',
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
                  const Expanded(
                    child: Text(
                      "Monete:",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Press Start 2P',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    "$_money",
                    style: const TextStyle(
                      fontFamily: 'Press Start 2P',
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            _gap,
            const Text(
              'Potenziamenti',
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
                    ..._upgrades.entries.map(
                      (entry) {
                        final String key = entry.key;
                        final Map<String, dynamic> upgrade = entry.value as Map<String, dynamic>;
                        final String? dependency = upgrade["dependency"] as String?;
                        final bool isBuyable = dependency == null || (_upgrades[dependency]!["unlocked"] as int) > 0;

                        return SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: (upgrade["sub_menu"] as int) * 20.0),
                                    child: Text(
                                      upgrade["string"] as String,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Press Start 2P',
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                if ((upgrade["value"] as int > 0) && (upgrade["unlocked"] as int) >= 1 && (upgrade["upgradable"] as bool))
                                  Text(
                                    (upgrade["unlocked"] as int).toString(),
                                    style: TextStyle(
                                      fontFamily: 'Press Start 2P',
                                      fontSize: 15,
                                    ),
                                  ),
                                // If the item has no value it should not be available to buy
                                if (upgrade["value"] as int > 0)
                                  // If it has a value show if it's already unlocked or if it's unlockable/upgradable
                                  ((upgrade["unlocked"] as int) > 0 && !(upgrade["upgradable"] as bool))
                                      ? const Text(
                                          'Sbloccato',
                                          style: TextStyle(
                                            fontFamily: 'Press Start 2P',
                                            fontSize: 15,
                                          ),
                                        )
                                      : WobblyButton(
                                          onPressed: isBuyable
                                              ? () {
                                                  buy(key);
                                                }
                                              : null,
                                          child: Text('${upgrade["value"]}'),
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
                          const Expanded(
                            child: Text(
                              "Resetta potenziamenti e soldi",
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
                                _money = 0;
                                _upgrades = defaultUpgrades;
                              });
                            },
                            child: Text('Resetta'),
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
                _persistence.saveMoney(_money);
                _persistence.saveUpgrades(_upgrades);
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
