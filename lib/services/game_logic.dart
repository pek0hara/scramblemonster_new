import 'dart:math';
import 'package:flutter/material.dart';

import '../models/monster.dart';
import '../providers/game_state_provider.dart';

class GameLogic {
  final GameStateProvider gameState;

  GameLogic({required this.gameState});

  // 合体ロジック
  Future<bool> combineMonsters() async {
    if (gameState.actionPoints <= 0) {
      return false;
    }

    if (gameState.combineMonsters[0] == null ||
        gameState.combineMonsters[1] == null) {
      return false;
    }

    for (var monster in gameState.combineMonsters) {
      if (monster != null &&
          !gameState.ownMonsters.contains(monster) &&
          !gameState.searchedMonsters.contains(monster)) {
        return true; // monsterが存在しない場合、trueを返す (nullチェック追加)
      }
    }

    // 合体後のモンスターを生成
    Monster newMonster = newCombinedMonster(
        gameState.combineMonsters[0]!, gameState.combineMonsters[1]!);

    int index0 = gameState.ownMonsters.indexOf(gameState.combineMonsters[0]!);
    int index1 = gameState.ownMonsters.indexOf(gameState.combineMonsters[1]!);

    if (index0 == -1 && index1 == -1) {
      gameState.searchedMonsters.remove(gameState.combineMonsters[0]!);
      gameState.searchedMonsters.remove(gameState.combineMonsters[1]!);
      gameState.searchedMonsters.add(newMonster);
    } else if (index0 == -1) {
      gameState.ownMonsters[index1] = newMonster;
      gameState.searchedMonsters.remove(gameState.combineMonsters[0]!);
    } else if (index1 == -1) {
      gameState.ownMonsters[index0] = newMonster;
      gameState.searchedMonsters.remove(gameState.combineMonsters[1]!);
    } else {
      // 入れ替える場合、小さい方のindexに新しいモンスターを配置し、大きい方のindexを削除
      if (index0 < index1) {
        gameState.ownMonsters[index0] = newMonster;
        gameState.ownMonsters.removeAt(index1);
      } else {
        gameState.ownMonsters[index1] = newMonster;
        gameState.ownMonsters.removeAt(index0);
      }
    }

    gameState.combineMonsters = [null, null]; // gameState経由で更新
    gameState.setInfoMessage('新しいモンスターが生まれた！'); // gameState経由で更新

    int score = newMonster.lv;
    gameState.addScore(score); // gameState経由で更新

    await gameState.saveData(); // gameState経由で保存

    if (0 < gameState.actionPoints && gameState.actionPoints < 10) {
      gameState.useActionPoints(gameState.actionPoints); // gameState経由で更新
      return false;
    } else {
      gameState.useActionPoints(10); // gameState経由で更新
      return true;
    }
  }

  // 捜索ロジック
  Future<bool> searchMonsters(int cost) async {
    if (gameState.actionPoints < 1) {
      return false;
    }

    // 捜索中のモンスターが合体スロットにある場合、クリア
    for (int i = 0; i < gameState.combineMonsters.length; i++) {
      if (gameState.searchedMonsters.contains(gameState.combineMonsters[i])) {
        gameState.combineMonsters[i] = null;
      }
    }

    // 捜索結果をクリア
    gameState.searchedMonsters.clear();
    HighestStatus searchStatus = gameState.getHighestStatus();

    final random = Random();
    int randRetry;
    int count = 0;
    int successRetry = 0;

    do {
      Monster searchedMonster = createNewMonster();
      gameState.searchedMonsters.add(searchedMonster);

      randRetry = random.nextInt(searchStatus.magic + 1);
      successRetry += 60;
      count++;
    } while (randRetry > successRetry && count < 5);

    gameState.setInfoMessage('モンスターを発見した！');
    gameState.useActionPoints(cost);

    return gameState.actionPoints > 0;
  }

  // 新しいモンスターを生成
  Monster createNewMonster() {
    HighestStatus highestStatus = gameState.getHighestStatus();
    final random = Random();

    int max = 40 + highestStatus.lv ~/ 3;
    int newMagic = random.nextInt(max) + 1;
    int newWill = random.nextInt(max - newMagic + 1) + 1;
    int newIntel = random.nextInt(max - newMagic - newWill + 2) + 1;

    // 魔力補正
    int searchMagic = highestStatus.magic > 400 ? 400 : highestStatus.magic;
    int newNo = random.nextInt(searchMagic ~/ 4 + 1);

    // 精神補正
    newWill += random.nextInt(highestStatus.will ~/ 6 + 1);

    // レベル計算
    int newLv = (newMagic + newWill + newIntel) ~/ 6;

    // 知力補正
    max = highestStatus.intel ~/ 10 + 1;
    newIntel += random.nextInt(max) + 1;
    newWill += random.nextInt(max) + 1;
    newMagic += random.nextInt(max) + 1;

    return Monster(
        no: newNo, magic: newMagic, will: newWill, intel: newIntel, lv: newLv);
  }

  // 成長率計算
  int calculateGrowth(Monster monster1, Monster monster2) {
    int growthRate = 60;

    int value1 = monster1.magic + monster1.will + monster1.intel;
    int value2 = monster2.magic + monster2.will + monster2.intel;
    int sum = (value1 + value2) ~/ 7;

    if (sum % 7 == 0) {
      if (max(monster1.lv, monster2.lv) < 40) {
        growthRate = 90;
      } else if (max(monster1.lv, monster2.lv) < 100) {
        growthRate = 80;
      }
    } else if (sum % 3 == 0) {
      if (max(monster1.lv, monster2.lv) < 40) {
        growthRate = 80;
      } else {
        growthRate = 70;
      }
    } else {
      if (max(monster1.lv, monster2.lv) < 40) {
        growthRate = 70;
      } else {
        growthRate = 60;
      }
    }
    return growthRate;
  }

  // 合体モンスター生成
  Monster newCombinedMonster(Monster monster1, Monster monster2) {
    // 各属性の成長率を計算する
    int growM = calculateGrowth(monster1, monster2);
    int growW = calculateGrowth(monster1, monster2);
    int growI = calculateGrowth(monster1, monster2);

    // 合体後のモンスターのステータスを計算するロジック
    int newM = (monster1.magic + monster2.magic) * growM ~/ 100;
    int newW = (monster1.will + monster2.will) * growW ~/ 100;
    int newI = (monster1.intel + monster2.intel) * growI ~/ 100;

    // レベルとモンスター番号を計算するロジック
    int total = newM + newW + newI;
    int newLv;

    if (total <= 360) {
      newLv = total ~/ 6;
    } else {
      newLv = 60 + ((total - 360) ~/ 9);
    }
    int newNo = newLv;

    // モンスター番号が特定の範囲を超えないように制限する
    newNo = newNo > 177 ? 177 : newNo;

    return Monster(no: newNo, magic: newM, will: newW, intel: newI, lv: newLv);
  }

  // スタイル決定
  Map<String, dynamic> determineStyle(int growthRate) {
    Color color;
    FontWeight fontWeight;

    if (growthRate >= 72) {
      color = Colors.redAccent;
      fontWeight = FontWeight.bold; // 成長率が高い場合は太字
    } else if (growthRate >= 65) {
      color = Colors.orangeAccent;
      fontWeight = FontWeight.normal;
    } else {
      color = Colors.black;
      fontWeight = FontWeight.normal;
    }

    return {
      'color': color,
      'fontWeight': fontWeight,
    };
  }

  // ボーダーカラー決定
  Color determineBorderColor(int growthRate) {
    if (growthRate >= 72) return Colors.redAccent;
    if (growthRate >= 65) return Colors.orangeAccent;
    return Colors.black;
  }
}
