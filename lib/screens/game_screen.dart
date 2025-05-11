import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../services/game_logic.dart';
import '../widgets/monster_widget.dart';
import '../models/monster.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final gameLogic = GameLogic(gameState: gameState);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // スコアと行動力の表示
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('スコア: ${gameState.totalScore}'),
            Text('行動力: ${gameState.actionPoints}'),
          ],
        ),

        // 合体のUI
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CombineMonsterSlot(
              index: 0,
              monster: gameState.combineMonsters[0],
              onAccept: (selectedMonster) {
                if (!gameState.combineMonsters.contains(selectedMonster)) {
                  gameState.setMonsterInCombineSlot(
                    0,
                    selectedMonster,
                  );
                }
              },
            ),
            Icon(Icons.add), // `+` アイコンを表示
            CombineMonsterSlot(
              index: 1,
              monster: gameState.combineMonsters[1],
              onAccept: (selectedMonster) {
                if (!gameState.combineMonsters.contains(selectedMonster)) {
                  gameState.setMonsterInCombineSlot(
                    1,
                    selectedMonster,
                  );
                }
              },
            ),
            // 合体後のモンスターを表示
            if (gameState.combineMonsters[0] != null &&
                gameState.combineMonsters[1] != null) ...[
              Icon(Icons.arrow_forward), // `→` アイコンを表示
              _buildNewCombinedMonsterWidget(
                gameState.combineMonsters[0]!,
                gameState.combineMonsters[1]!,
                gameLogic,
              ),
            ],
          ],
        ),

        // 合体ボタンとキャンセルボタン
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: gameState.combineMonsters[0] != null ||
                      gameState.combineMonsters[1] != null
                  ? () {
                      gameState.cancelCombine();
                    }
                  : null,
              child: Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: (gameState.actionPoints > 0 &&
                      (gameState.combineMonsters[0] != null &&
                          gameState.combineMonsters[1] != null))
                  ? () async {
                      bool result = await gameLogic.combineMonsters();
                      if (!result) {
                        gameState.setInfoMessage('行動力がなくなりました');
                      }
                    }
                  : null,
              child: Text(
                  '合体 (-${gameState.actionPoints < 10 ? gameState.actionPoints : 10})'),
            ),
          ],
        ),

        // 所持モンスター
        _buildMonsterLine(
          gameState.ownMonsters,
          gameState,
          gameLogic,
        ),

        // 画面メッセージ
        Text(
          gameState.infoMessage,
          style: TextStyle(
            color: gameState.infoMessage.contains('なくなりました')
                ? Colors.red
                : Colors.black,
          ),
        ),

        // 捜索結果
        _buildMonsterLine(
          gameState.searchedMonsters,
          gameState,
          gameLogic,
        ),

        // 捜索ボタン
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: gameState.actionPoints > 0
                  ? () async {
                      bool result = await gameLogic.searchMonsters(1);
                      if (!result) {
                        gameState.setInfoMessage('行動力がなくなりました');
                      }
                    }
                  : null,
              child: Text('捜索 (-1)'),
            ),
            if (gameState.actionPoints < 1)
              ElevatedButton(
                onPressed: () => gameState.resetGame(),
                child: Text('リトライ', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonsterLine(
    List<Monster> monsters,
    GameStateProvider gameState,
    GameLogic gameLogic,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: monsters
          .map((monster) => OwnMonsterBox(
                monster: monster,
                onTap: (tappedMonster) {
                  if (gameState.searchedMonsters.contains(tappedMonster)) {
                    if (gameState.ownMonsters.length < 5) {
                      gameState.addMonsterToOwn(tappedMonster);
                      gameState.selectMonsterForCombine(tappedMonster);
                    }
                  } else if (gameState.ownMonsters.contains(tappedMonster)) {
                    gameState.selectMonsterForCombine(tappedMonster);
                  }
                },
                onSwap: (draggedMonster, targetMonster) {
                  // 通常の入れ替え処理のみ
                  gameState.swapMonsters(draggedMonster, targetMonster);
                },
                onDragComplete: (_) {
                  // ドラッグ完了時の処理（必要に応じて）
                  // この場合は何もしないでOK
                },
              ))
          .toList(),
    );
  }

  Widget _buildNewCombinedMonsterWidget(
    Monster monster1,
    Monster monster2,
    GameLogic gameLogic,
  ) {
    // 各属性の成長率を計算する
    int growM = gameLogic.calculateGrowth(monster1, monster2);
    int growW = gameLogic.calculateGrowth(monster1, monster2);
    int growI = gameLogic.calculateGrowth(monster1, monster2);

    // 合体後のモンスターを生成
    Monster combinedMonster = gameLogic.newCombinedMonster(monster1, monster2);

    // 各属性のスタイルを決定する
    Map<String, dynamic> magicStyle = gameLogic.determineStyle(growM);
    Map<String, dynamic> willStyle = gameLogic.determineStyle(growW);
    Map<String, dynamic> intelStyle = gameLogic.determineStyle(growI);

    // MonsterWidgetを生成する
    return Container(
      width: 115,
      height: 142,
      child: MonsterWidget(
        monster: combinedMonster,
        magicColor: magicStyle['color'],
        willColor: willStyle['color'],
        intelColor: intelStyle['color'],
        backColor: Colors.black, // 背景色は黒に固定
        borderColor: Colors.black, // 枠線色は黒に固定
        fontWeight: FontWeight.normal, // デフォルトのフォントウェイト
        magicFontWeight: magicStyle['fontWeight'],
        willFontWeight: willStyle['fontWeight'],
        intelFontWeight: intelStyle['fontWeight'],
      ),
    );
  }
}
