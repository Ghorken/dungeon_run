import 'package:dungeon_run/flame_game/components/enemies/enemy.dart';
import 'package:flutter/material.dart';

class EnemiesProvider with ChangeNotifier {
  // This class will manage the enemies in the game.
  // It will provide methods to add, remove, and retrieve enemies.

  final Set<Enemy> _enemies = {};

  void addEnemy(Enemy enemy) {
    _enemies.add(enemy);
  }

  void removeEnemy(Enemy enemy) {
    _enemies.remove(enemy);
  }

  void clearEnemies() {
    _enemies.clear();
  }

  Set<Enemy> getEnemies() {
    return _enemies;
  }
}
