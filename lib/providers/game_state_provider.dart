import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/monster.dart';

class GameStateProvider extends ChangeNotifier {
  List<Monster> ownMonsters = [];
  List<Monster?> combineMonsters = [null, null];
  List<Monster> searchedMonsters = [];
  String infoMessage = '';
  int maxHpPower = 0;
  int actionPoints = 1000;
  int totalScore = 0;

  GameStateProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // モンスターデータの読み込み
    final jsonString = prefs.getString('monsters');
    if (jsonString != null) {
      List<dynamic> jsonList = json.decode(jsonString);
      ownMonsters =
          jsonList.map((jsonItem) => Monster.fromJson(jsonItem)).toList();
    } else {
      // 初期モンスター
      ownMonsters = [Monster(no: 0, hp: 10, atk: 10, spd: 10, lv: 1)];
    }

    // 行動力の読み込み
    actionPoints = prefs.getInt('action_points') ?? 1000;

    // スコアの読み込み
    totalScore = prefs.getInt('total_score') ?? 0;

    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // モンスターデータの保存
    List<Map<String, dynamic>> jsonMonsters =
        ownMonsters.map((monster) => monster.toJson()).toList();
    await prefs.setString('monsters', jsonEncode(jsonMonsters));

    // 行動力の保存
    await prefs.setInt('action_points', actionPoints);

    // スコアの保存
    await prefs.setInt('total_score', totalScore);
  }

  void setInfoMessage(String message) {
    infoMessage = message;
    notifyListeners();
  }

  void addMonsterToOwn(Monster monster) {
    if (ownMonsters.length < 5) {
      ownMonsters.add(monster);
      if (searchedMonsters.contains(monster)) {
        searchedMonsters.remove(monster);
      }
      setInfoMessage('モンスターを仲間に加えた！');
      saveData();
    }
  }

  void selectMonsterForCombine(Monster monster) {
    if (combineMonsters[0] != monster) {
      // モンスターがスロット1に既に存在する場合
      if (combineMonsters[1] == monster) {
        // スロット0に移動し、スロット1を空にする
        combineMonsters[0] = monster;
        combineMonsters[1] = null;
      } else if (combineMonsters[0] == null) {
        // モンスターがスロット1におらず、スロット0が空の場合
        // スロット0に設定
        combineMonsters[0] = monster;
      } else {
        // モンスターがスロット1におらず、スロット0も既に他のモンスターで埋まっている場合
        // スロット1に設定
        combineMonsters[1] = monster;
      }
    }
    saveData();
    notifyListeners();
  }

  void cancelCombine() {
    combineMonsters = [null, null];
    notifyListeners();
  }

  void swapMonsters(Monster draggedMonster, Monster targetMonster) {
    // ドラッグ元／ドロップ先のリストを判定
    final List<Monster> draggedList =
        ownMonsters.contains(draggedMonster) ? ownMonsters : searchedMonsters;
    final List<Monster> targetList =
        ownMonsters.contains(targetMonster) ? ownMonsters : searchedMonsters;

    final draggedIndex = draggedList.indexOf(draggedMonster);
    final targetIndex = targetList.indexOf(targetMonster);

    if (draggedIndex != -1 && targetIndex != -1) {
      // 2つのリスト要素を入れ替え
      _swapElements(draggedList, draggedIndex, targetList, targetIndex);
      saveData();
      notifyListeners();
    }
  }

  /// 汎用的に2つのリスト要素を入れ替える
  void _swapElements<T>(List<T> listA, int idxA, List<T> listB, int idxB) {
    final temp = listA[idxA];
    listA[idxA] = listB[idxB];
    listB[idxB] = temp;
  }

  HighestStatus getHighestStatus() {
    return HighestStatus(monsters: ownMonsters);
  }

  Future<bool> resetGame() async {
    // 現在のスコアを保存
    if (totalScore != 0) {
      int maxHpPower = ownMonsters
          .map((monster) => monster.lv)
          .reduce((a, b) => a > b ? a : b);

      Map<String, dynamic> result = {
        'party': ownMonsters.map((monster) => monster.toJson()).toList(),
        'score': totalScore,
        'maxHpPower': maxHpPower,
      };

      await _saveResult(result);
      await _saveHighScore(result);
    }

    // ゲーム状態のリセット
    totalScore = 0;
    actionPoints = 1000;
    ownMonsters = [Monster(no: 0, hp: 10, atk: 10, spd: 10, lv: 1)];
    combineMonsters = [null, null];
    searchedMonsters = [];
    infoMessage = '';

    await saveData();
    notifyListeners();
    return true;
  }

  Future<void> _saveResult(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? results = prefs.getStringList('results') ?? [];
    if (results.length >= 100) {
      results.removeAt(99); // 最も古い結果を削除
    }
    results.insert(0, jsonEncode(result));
    prefs.setStringList('results', results);
  }

  Future<void> _saveHighScore(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? highScores = prefs.getStringList('high_scores') ?? [];

    // 新しいスコアを追加
    highScores.add(jsonEncode(result));

    // JSONをデコードしてmaxHpPowerでソート
    List<Map<String, dynamic>> decodedHighScores =
        highScores.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    decodedHighScores
        .sort((a, b) => b['maxHpPower'].compareTo(a['maxHpPower']));

    // 上位5つのスコアだけを保存
    List<String> topHighScores =
        decodedHighScores.take(5).map((e) => jsonEncode(e)).toList();

    prefs.setStringList('high_scores', topHighScores);
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? results = prefs.getStringList('results') ?? [];
    return results.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? highScores = prefs.getStringList('high_scores') ?? [];
    return highScores
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  void addScore(int points) {
    totalScore += points;
    saveData();
    notifyListeners();
  }

  void useActionPoints(int points) {
    if (actionPoints >= points) {
      actionPoints -= points;
    } else {
      actionPoints = 0;
    }
    saveData();
    notifyListeners();
  }

  void setMonsterInCombineSlot(int index, Monster monster) {
    combineMonsters[index] = monster;
    notifyListeners();
  }
}
