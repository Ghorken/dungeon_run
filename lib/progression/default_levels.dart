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
    bossTimer: 20.0,
    traps: [],
    trapMinPeriod: 5.0,
    trapMaxPeriod: 10.0,
    collectableMinPeriod: 1.0,
    collectableMaxPeriod: 10.0,
    map: "map",
    rewards: {
      "gold": 100,
      "upgrades": [
        "collectable_damage",
      ],
    },
    message: "I dintorni del castello erano pien i di goblin, ma sei riuscito a farti strada tra i nemici e raggiungere l'entrata.\nUn profondo fossato circonda il castello e l'unico passaggio sembra essere il ponte levatotoio abbassato.",
  ),
  (
    name: "Fossato",
    completed: false,
    dependency: [
      "Esterno",
    ],
    enemies: [
      EnemyType.elemental,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 20.0,
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
      "upgrades": [
        "archer",
      ],
    },
    message: "Superato il fossato hai trovato una sorpresa, un arciere, ultimo rimasto di un gruppo che ha tentato l'ingresso prima di ha deciso di darti una mano e insieme siete riusciti a entrare nel castello.\nAlla vostra sinistra dei nitriti vi fanno presupporre la presenza delle stalle, alla vostra destra riuscite a vedere il corpo di guardia per fortuna deserto mentre dritto davanti a voi si apre la coorte del castello."
  ),
  (
    name: "Stalle",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.goblin,
      EnemyType.elemental,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 20.0,
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
    message: "Nelle stalle hai trovato svariati goblin intenti a mangiare fieno.\nNonostante il fetore del letame sei riuscito ad attraversarle e a raggiungere la posteria",
  ),
  (
    name: "Corte",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.troll,
      EnemyType.elemental,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 20.0,
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
    message: "La corte del castello sembrava silenziosa, ma tu eri pronto e non ti sei fatto soprendere dall'imboscata. È strano, è come se sapessero che saresti arrivato...",
  ),
  (
    name: "Corpo di guardia",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.goblin,
      EnemyType.elemental,
    ],
    enemyFrequency: 0.5,
    boss: BossType.goblinKing,
    bossTimer: 20.0,
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
      "upgrades": [
        "berserk",
      ],
    },
    message: "Il corpo di guardia è stato facile da superare, ma hai trovato un tesoro inaspettato: in una delle celle era rinchiuso un nano che ha deciso di affiancarti nella tua avventura.",
  ),
];
