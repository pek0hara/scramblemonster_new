import 'package:flutter/material.dart';
import '../models/monster.dart';
import '../services/battle_logic.dart';
import '../widgets/monster_widget.dart';

/// 戦闘画面
class BattleScreen extends StatelessWidget {
  final List<Monster> opponentMonsters;
  final List<Monster> ownMonsters;

  const BattleScreen({
    Key? key,
    required this.opponentMonsters,
    required this.ownMonsters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // モック用: opponentMonstersが空の場合、自分のモンスターを相手モンスターとして使用
    final battleOpponents = opponentMonsters.isNotEmpty ? opponentMonsters : ownMonsters;
    final battleLogic = BattleLogic(
      opponent: battleOpponents,
      own: ownMonsters,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('バトル'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 相手のモンスターを横並びで表示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                opponentMonsters.map((m) => MonsterWidget(monster: m)).toList(),
          ),

          // VSアイコン
          Icon(
            Icons.flash_on,
            size: 48,
          ),

          // 自分のモンスターを横並びで表示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                ownMonsters.map((m) => MonsterWidget(monster: m)).toList(),
          ),

          // バトル開始ボタン
          ElevatedButton(
            onPressed: () {
              final result = battleLogic.simulateBattle();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(result.win ? '勝利！' : '敗北...'),
                  content: Text(
                      'あなた: ${result.ownScore} vs 相手: ${result.opponentScore}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Text('バトル開始'),
          ),
        ],
      ),
    );
  }
}
