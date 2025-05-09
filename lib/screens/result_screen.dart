import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../widgets/monster_widget.dart';
import '../models/monster.dart';

class ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);

    return Column(
      children: [
        Text('結果'),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: gameState.getResults(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    List<Monster> partyMonsters =
                        (snapshot.data![index]['party'] as List)
                            .map((json) => Monster.fromJson(json))
                            .toList();
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: partyMonsters
                            .map((monster) => MonsterWidget(monster: monster))
                            .toList(),
                      ),
                      subtitle: Text(
                          '最高Lv. ${snapshot.data![index]['maxMagicPower']} '
                          'スコア: ${snapshot.data![index]['score']} '),
                    );
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}
