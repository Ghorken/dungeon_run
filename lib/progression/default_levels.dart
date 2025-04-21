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
    message: "I dintorni del castello erano pieni di goblin, ma sei riuscito a farti strada tra i nemici e raggiungere l'entrata.\nUn profondo fossato circonda il castello e l'unico passaggio sembra essere il ponte levatotoio abbassato.",
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
    enemyFrequency: 0.5,
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
    message: "Superato il fossato hai trovato una sorpresa, un arciere, ultimo rimasto di un gruppo che ha tentato l'ingresso prima di te. Ha deciso di darti una mano e insieme siete entrati nel castello.\nAlla vostra sinistra vedete l'accesso alle cucine, alla vostra destra riuscite a vedere il corpo di guardia che appare deserto mentre dritto davanti a voi la torre del mago, sulla cui cima brilla un turbinio di energia magica."
  ),
  (
    id: "servants-1",
    name: "Cucine",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.zombie,
      EnemyType.zombieDog,
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
    message: "Le cucine erano piene di zombie, la servitù rimasta fedele al castello.\nNonostante la pizza di marcio sei riuscito ad attraversarle e a raggiungere la posteria",
  ),
  (
    id: "firstFloor-1",
    name: "Torre del mago",
    completed: false,
    dependency: [
      "Fossato",
    ],
    enemies: [
      EnemyType.imp,
      EnemyType.elemental,
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
    message: "Qualcosa deve essere andato storto con l'ultimo incantesimo del mago di corte e si è aperto un portale da cui è fuoriuscita un'orda di demoni.\nIl mago ha cercato di fermarli ma senza il tuo aiuto non ce l'avrebbe fatta e per questo ti è riconoscente.",
  ),
  (
    id: "guards-1",
    name: "Corpo di guardia",
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
    message: "Il corpo di guardia è stato facile da superare, gli scheletri cadevano come una torre del jenga, ma hai trovato un tesoro inaspettato: in una delle celle era rinchiuso un nano che ha deciso di affiancarti nella tua avventura.",
  ),
];
