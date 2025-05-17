import '../models/monster.dart';

/// バトルロジック
class BattleLogic {
  final List<Monster> opponent;
  final List<Monster> own;

  BattleLogic({required this.opponent, required this.own});

  /// ターン制バトルシミュレーション
  BattleResult simulateBattle() {
    // モンスターを戦闘用クラスに変換
    var enemies =
        opponent.map((m) => _BattleMonster.from(m, 'opponent')).toList();
    var allies = own.map((m) => _BattleMonster.from(m, 'own')).toList();
    List<String> log = [];

    // 生存しているほうに攻撃を繰り返す
    while (enemies.any((m) => m.isAlive) && allies.any((m) => m.isAlive)) {
      // 行動順：素早さ降順
      var turnOrder = [...enemies, ...allies].where((m) => m.isAlive).toList()
        ..sort((a, b) => b.speed.compareTo(a.speed));

      for (var actor in turnOrder) {
        if (!actor.isAlive) continue;
        var targets = (actor.team == 'own' ? enemies : allies)
            .where((m) => m.isAlive)
            .toList();
        if (targets.isEmpty) break;

        var target = targets.first;
        target.hp -= actor.attack;
        if (target.hp <= 0) {
          target.hp = 0;
          log.add('${actor.name} attacks ${target.name} and defeats it');
        } else {
          log.add(
              '${actor.name} attacks ${target.name}, remaining HP: ${target.hp}');
        }
      }
    }

    bool win = enemies.every((m) => !m.isAlive);
    int opponentAlive = enemies.where((m) => m.isAlive).length;
    int ownAlive = allies.where((m) => m.isAlive).length;

    return BattleResult(
      win: win,
      opponentScore: opponentAlive,
      ownScore: ownAlive,
      log: log,
    );
  }

  int _calculateTeamPower(List<Monster> team) {
    // チームパワーは各モンスターのレベルとステータス合計の組み合わせ
    int power = 0;
    for (var m in team) {
      power += m.lv;
      power += m.hp;
      power += m.atk;
      power += m.spd;
    }
    return power;
  }
}

/// 戦闘用モンスター
class _BattleMonster {
  final String name;
  int hp;
  final int attack;
  final int speed;
  final String team;

  bool get isAlive => hp > 0;

  _BattleMonster.from(Monster m, this.team)
      : name = 'Monster ${m.no}',
        hp = m.hp,
        attack = m.atk,
        speed = m.spd;
}

/// バトル結果
class BattleResult {
  final bool win;
  final int opponentScore;
  final int ownScore;
  final List<String> log; // 戦闘ログ

  BattleResult({
    required this.win,
    required this.opponentScore,
    required this.ownScore,
    this.log = const [],
  });
}
