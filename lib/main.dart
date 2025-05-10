import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state_provider.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';

void main() => runApp(MyApp());

// 画面の状態を表すenum
enum ScreenState { home, game, result }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameStateProvider(),
      child: MaterialApp(
        title: 'スクランブルモンスター',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WillPopScope(
          onWillPop: () async {
            // ここでfalseを返すことで、戻る動作をキャンセルします。
            return false;
          },
          child: MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 現在の画面の状態を保持するフィールド
  ScreenState _screenState = ScreenState.game;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Provider初期化後にロード完了
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('リセット確認'),
          content: Text('ゲームをリセットして次のゲームを行いますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              child: Text('リセット'),
              onPressed: () async {
                final gameState =
                    Provider.of<GameStateProvider>(context, listen: false);
                await gameState.resetGame(); // ゲームをリセット
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }

  void _showGameDescription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ゲームの説明'),
          content: Text('・モンスターの発見と合体を繰り返して強いモンスターを作るゲームです。\n'
              '・魔力が高いモンスターを持っていると、たくさんモンスターを発見できます。\n'
              '・精神が高いモンスターを持っていると、精神が高いモンスターを発見できます。\n'
              '・知力が高いモンスターを持っていると、Lv.が高いモンスターを発見できます。\n'
              '・Lvはモンスターの総合的な強さです。'),
          actions: [
            TextButton(
              child: Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // ローディングインジケータを表示
      );
    }

    // ゲーム画面
    return Scaffold(
      appBar: AppBar(
        title: Text('スクランブルモンスター'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // ハンバーガーメニューのアイコン
              onPressed: () {
                Scaffold.of(context).openDrawer(); // ドロワーを開く
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              _showGameDescription(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('メニュー'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('リザルト画面'),
              onTap: () {
                setState(() {
                  _screenState = ScreenState.result;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('ゲームに戻る'),
              onTap: () {
                setState(() {
                  _screenState = ScreenState.game;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('ゲームをリセット'),
              onTap: () {
                Navigator.pop(context);
                _showResetConfirmation();
              },
            ),
          ],
        ),
      ),
      body: _screenState == ScreenState.game ? GameScreen() : ResultScreen(),
    );
  }
}
