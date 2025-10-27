import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/traps/trap_type.dart';
import 'package:dungeon_run/progression/level.dart';

/// Default levels for the game
const List<Level> defaultLevels = [
  (
    id: "external-1",
    name: "Esterno",
    completed: false,
    dependency: null,
    enemies: [
      EnemyType.goblin,
    ],
    enemyFrequency: 1,
    boss: BossType.goblinKing,
    bossTimer: 20.0,
    traps: [],
    trapMinPeriod: 5.0,
    trapMaxPeriod: 10.0,
    collectableMinPeriod: 1.0,
    collectableMaxPeriod: 10.0,
    map: "esterno",
    rewards: {
      "gold": 100,
      "upgrades": [
        "collectable_damage",
      ],
    },
    message:
        "Ho varcato le terre oltre le mura e mi sono fatto strada tra orde di goblin.\nEppure, il castello non mostra segni di rovina: torri dritte, finestre illuminate, arazzi al vento.\nNon sembra un luogo conquistato, ma custodito.",
  ),
  (
    id: "external-2",
    name: "Fossato",
    completed: false,
    dependency: [
      "Esterno",
    ],
    enemies: [
      EnemyType.animatedArmour,
    ],
    enemyFrequency: 1,
    boss: BossType.bridgeGuardian,
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
    message:
        "Nel fossato ho incontrato un arciere imprigionato dalla paura e dall’acqua nera.\nMi ha confidato che non tutto ciò che vive qui resiste controvoglia.\nMolti, a suo dire, hanno scelto questa condizione."
  ),
  (
    id: "servants-1",
    name: "Stalle",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.zombie,
    ],
    enemyFrequency: 0.5,
    boss: BossType.zombieChef,
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
        "collectable_resurrection",
      ],
    },
    message: "Le stalle odorano ancora di fieno fresco, nonostante siano abitate da carcasse e bestie distorte.\nCom’è possibile che qui la putrefazione non attecchisca?",
  ),
  (
    id: "firstFloor-1",
    name: "Corpo di guardia",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.imp,
    ],
    enemyFrequency: 0.5,
    boss: BossType.balor,
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
        "wizard",
      ],
    },
    message: "Qui avrei dovuto trovare soldati pronti a difendere.\nHo trovato resti di guardie e prigionieri, indistinguibili ormai.\nUn carcere senza innocenti.",
  ),
  (
    id: "guards-1",
    name: "Corte",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.skeleton,
    ],
    enemyFrequency: 0.5,
    boss: BossType.skeletonExecutioner,
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
    message: "La corte, cuore del castello, è viva di una vita che non è più umana.\nEppure tutto appare perfetto.\nLa perfezione qui è la vera menzogna.",
  ),
];
