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
  final Function(Monster)? onTap;

  const MonsterWidget({
    Key? key,
    required this.monster,
    this.magicColor = Colors.black,
    this.willColor = Colors.black,
    this.intelColor = Colors.black,
    this.backColor = Colors.black,
    this.borderColor = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.magicFontWeight = FontWeight.normal,
    this.willFontWeight = FontWeight.normal,
    this.intelFontWeight = FontWeight.normal,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color currentBorderColor = borderColor; // 初期値として渡されたborderColorを使用

    return GestureDetector(
      // Wrapped with GestureDetector
      onTap: onTap != null ? () => onTap!(monster) : null,
      child: Column(
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
                        color: currentBorderColor,
                        width: 3.0), // 計算後のborderColorを使用
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
              fontSize: 11.0,
            ),
          ),
          Text(
            '魔力:${monster.magic}',
            style: TextStyle(
              color: magicColor,
              fontWeight: magicFontWeight,
              fontSize: 11.0,
            ),
          ),
          Text(
            '精神:${monster.will}',
            style: TextStyle(
              color: willColor,
              fontWeight: willFontWeight,
              fontSize: 11.0,
            ),
          ),
          Text(
            '知力:${monster.intel}',
            style: TextStyle(
              color: intelColor,
              fontWeight: intelFontWeight,
              fontSize: 11.0,
            ),
          ),
        ],
      ),
    );
  }
}

class OwnMonsterBox extends StatelessWidget {
  final Monster monster;
  final Color borderColor;
  final Function(Monster) onDragComplete;
  final Function(Monster, Monster) onSwap;
  final Function(Monster)? onTap;

  const OwnMonsterBox({
    Key? key,
    required this.monster,
    required this.borderColor,
    required this.onDragComplete,
    required this.onSwap,
    this.onTap,
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
            child: MonsterWidget(
              monster: monster,
              borderColor: borderColor,
              onTap: onTap,
            ),
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
          child: MonsterWidget(
            monster: monster,
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 60,
        height: 142,
        child: MonsterWidget(
          monster: monster,
        ),
      ),
      onDragCompleted: () => onDragComplete(monster),
    );
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
          decoration: BoxDecoration(
            // 枠線を追加
            border: Border.all(color: Colors.grey), // 枠線の色と太さを指定
          ),
          child: monster == null
              ? Center(
                  // 中央に配置
                  child: Icon(
                    // アイコンを表示
                    Icons.add,
                    color: Colors.grey,
                    size: 40.0,
                  ),
                )
              : MonsterWidget(
                  monster: monster!,
                ),
        );
      },
    );
  }
}
