import 'dart:math';
import '../models/monster.dart';

/// バトルロジック
class BattleLogic {
  final List<Monster> opponent;
  final List<Monster> own;

  BattleLogic({required this.opponent, required this.own});

  /// バトルシミュレーション
  BattleResult simulateBattle() {
    int opponentScore = _calculateTeamPower(opponent);
    int ownScore = _calculateTeamPower(own);

    bool win = ownScore >= opponentScore;
    return BattleResult(
      win: win,
      opponentScore: opponentScore,
      ownScore: ownScore,
    );
  }

  int _calculateTeamPower(List<Monster> team) {
    // チームパワーは各モンスターのレベルとステータス合計の組み合わせ
    int power = 0;
    for (var m in team) {
      power += m.lv * (m.magic + m.will + m.intel);
    }
    return power;
  }
}

/// バトル結果
class BattleResult {
  final bool win;
  final int opponentScore;
  final int ownScore;

  BattleResult(
      {required this.win, required this.opponentScore, required this.ownScore});
}
