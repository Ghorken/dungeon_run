import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/traps/trap_type.dart';
import 'package:dungeon_run/progression/level.dart';

/// Default levels for the game
const List<Level> defaultLevels = [
  (
    name: "Esterno",
    completed: false,
    dependency: null,
    enemies: [
      EnemyType.goblin,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 10.0,
    traps: [],
    trapMinPeriod: 5.0,
    trapMaxPeriod: 10.0,
    collectableMinPeriod: 1.0,
    collectableMaxPeriod: 10.0,
    map: "dungeon_corridor",
    rewards: {
      "gold": 100,
    },
  ),
  (
    name: "Fossato",
    completed: false,
    dependency: [
      "Esterno",
    ],
    enemies: [
      EnemyType.elementale,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 300.0,
    traps: [
      TrapType.spikedPit,
    ],
    trapMinPeriod: 5.0,
    trapMaxPeriod: 10.0,
    collectableMinPeriod: 1.0,
    collectableMaxPeriod: 10.0,
    map: "dungeon_corridor",
    rewards: {
      "gold": 100,
    },
  ),
  (
    name: "Corpo di guardia",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.goblin,
      EnemyType.elementale,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 300.0,
    traps: [
      TrapType.spikedPit,
    ],
    trapMinPeriod: 5.0,
    trapMaxPeriod: 10.0,
    collectableMinPeriod: 1.0,
    collectableMaxPeriod: 10.0,
    map: "dungeon_corridor",
    rewards: {
      "gold": 100,
    },
  ),
  (
    name: "Corte",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.troll,
      EnemyType.elementale,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 300.0,
    traps: [
      TrapType.spikedPit,
    ],
    trapMinPeriod: 5.0,
    trapMaxPeriod: 10.0,
    collectableMinPeriod: 1.0,
    collectableMaxPeriod: 10.0,
    map: "dungeon_corridor",
    rewards: {
      "gold": 100,
    },
  ),
  (
    name: "Campo di addestramento",
    completed: false,
    dependency: [
      "Corte",
      "Corpo di guardia",
    ],
    enemies: [
      EnemyType.goblin,
      EnemyType.troll,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 300.0,
    traps: [
      TrapType.spikedPit,
    ],
    trapMinPeriod: 5.0,
    trapMaxPeriod: 10.0,
    collectableMinPeriod: 1.0,
    collectableMaxPeriod: 10.0,
    map: "dungeon_corridor",
    rewards: {
      "gold": 100,
    },
  ),
];
