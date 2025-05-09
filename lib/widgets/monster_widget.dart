import 'package:flutter/material.dart';
import '../models/monster.dart';

class MonsterWidget extends StatelessWidget {
  final Monster monster;
  final Color magicColor;
  final Color willColor;
  final Color intelColor;
  final Color backColor;
  final Color borderColor;
  final FontWeight fontWeight;
  final FontWeight magicFontWeight;
  final FontWeight willFontWeight;
  final FontWeight intelFontWeight;

  const MonsterWidget({
    Key? key,
    required this.monster,
    this.magicColor = Colors.black,
    this.willColor = Colors.black,
    this.intelColor = Colors.black,
    this.backColor = Colors.transparent,
    this.borderColor = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.magicFontWeight = FontWeight.normal,
    this.willFontWeight = FontWeight.normal,
    this.intelFontWeight = FontWeight.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // 背景用のContainer
            Container(
              width: 60,
              height: 60,
              color: backColor,
            ),
            // アイコン用のImage.asset
            Positioned.fill(
              child: Image.asset('assets/images/${monster.no}.png',
                  fit: BoxFit.cover),
            ),
            // 縁取り用のContainer
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: borderColor, width: 3.0),
                ),
              ),
            ),
          ],
        ),
        Text(
          'Lv.${monster.lv}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: fontWeight,
          ),
        ),
        Text(
          '魔力:${monster.magic}',
          style: TextStyle(
            color: magicColor,
            fontWeight: magicFontWeight,
          ),
        ),
        Text(
          '精神:${monster.will}',
          style: TextStyle(
            color: willColor,
            fontWeight: willFontWeight,
          ),
        ),
        Text(
          '知力:${monster.intel}',
          style: TextStyle(
            color: intelColor,
            fontWeight: intelFontWeight,
          ),
        ),
      ],
    );
  }
}

class OwnMonsterBox extends StatelessWidget {
  final Monster monster;
  final Function(Monster) onDragComplete;
  final Function(Monster, Monster) onSwap;

  const OwnMonsterBox({
    Key? key,
    required this.monster,
    required this.onDragComplete,
    required this.onSwap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<Monster>(
      data: monster,
      child: DragTarget<Monster>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: 60,
            height: 142,
            child: MonsterWidget(monster: monster),
          );
        },
        onWillAccept: (data) => true,
        onAccept: (data) {
          onSwap(data, monster);
        },
      ),
      feedback: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 60,
          height: 142,
          child: MonsterWidget(monster: monster),
        ),
      ),
      childWhenDragging: Container(
        width: 60,
        height: 142,
        child: MonsterWidget(monster: monster),
      ),
      onDragCompleted: () => onDragComplete(monster),
    );
  }
}

class ExpectMonsterWidget extends StatelessWidget {
  final Monster monster;
  final Monster? selectedMonster;
  final Function(int, int, int) calculateGrowth;

  const ExpectMonsterWidget({
    Key? key,
    required this.monster,
    required this.selectedMonster,
    required this.calculateGrowth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedMonster == null) {
      return MonsterWidget(monster: monster);
    }

    // 各ステータスの成長率を計算
    int growM = calculateGrowth(selectedMonster!.magic, monster.magic, selectedMonster!.lv);
    int growW = calculateGrowth(selectedMonster!.will, monster.will, selectedMonster!.lv);
    int growI = calculateGrowth(selectedMonster!.intel, monster.intel, selectedMonster!.lv);

    // borderColorを決定
    Color borderColor = _determineBorderColor(growM, growW, growI);

    // MonsterWidgetを返却
    return MonsterWidget(
      monster: monster,
      borderColor: borderColor,
    );
  }

  Color _determineBorderColor(int growM, int growW, int growI) {
    if (monster == selectedMonster) {
      return Colors.black; // 選択されたモンスターの色
    }

    // 成長率に基づいてborderColorを決定するロジック
    if (growM >= 72 || growW >= 72 || growI >= 72) {
      return Colors.redAccent; // 高成長率の色
    } else if (growM >= 65 || growW >= 65 || growI >= 65) {
      return Colors.orangeAccent; // 中成長率の色
    } else {
      return Colors.grey; // 低成長率の色
    }
  }
}

class CombineMonsterSlot extends StatelessWidget {
  final int index;
  final Monster? monster;
  final Function(Monster) onAccept;

  const CombineMonsterSlot({
    Key? key,
    required this.index,
    required this.monster,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<Monster>(
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 105,
          height: 142,
          child: monster == null
              ? Placeholder() // モンスターが選択されていない場合、プレースホルダーを表示
              : MonsterWidget(monster: monster!),
        );
      },
    );
  }
}
