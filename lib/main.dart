import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './myGridView.dart';

void main() => runApp(MyApp());
const scoreTitleStyle = TextStyle(
    fontWeight: FontWeight.bold, color: const Color(0xFFeee4da), fontSize: 13);

const scoreNumberStyle =
    TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold);

class MyContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyContainerState();
  }
}

class MyContainerState extends State<MyContainer> {
  int _score = 0;
  bool _isGameOver = false;
  int _bestScore = 0;
  bool _initialed = false;

  _initialScore() {
    setState(() {
      _score = 0;
    });
  }

  _newGame() {
    saveBestScore(_score).then((res) {
      _updateBestScore();
    });
    _initialScore();
    setState(() {
      _initialed = false;
      _isGameOver = false;
    });
  }
  _resetInitialed() {
    setState(() {
      _initialed = true;
    });
  }

  _gameOver() {
    saveBestScore(_score).then((res) {
      _updateBestScore();
    });
    setState(() {
      _isGameOver = true;
    });
  }

  void updateScore(increment) {
    setState(() {
      _score = _score + increment;
    });
  }

  Future<int> getBestScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var bestScore = prefs.getInt('bestScore');
    print('getBestScore:' + bestScore.toString());

    return bestScore == null ? 0 : bestScore;
  }
  _updateBestScore() {
    getBestScore().then((int bestScore) {
      setState(() {
        this._bestScore = bestScore == null ? 0 : bestScore;
      });
    });
  }
  Future saveBestScore(score) async{
      SharedPreferences prefs = await SharedPreferences.getInstance();

      getBestScore().then((oldBestScore) {
        if(score > oldBestScore) {
          prefs.setInt('bestScore', score);
        }
      });
  }

  @override
  void initState() {
    super.initState();

    _updateBestScore();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 330,
        padding: const EdgeInsets.only(top: 36),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Container(
                    padding: EdgeInsets.only(top: 10.0),
                    height: 38,
                    child: new Text(
                      '2048',
                      style: TextStyle(
                          color: const Color(0xFF776e65),
                          fontSize: 27,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  new Row(children: [
                    new Container(
                        margin: EdgeInsets.only(right: 5),
                        padding: EdgeInsets.only(top: 5),
                        width: 95,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                            color: const Color(0xFFbbada0)),
                        child: Column(
                          children: [
                            Text('SCORE', style: scoreTitleStyle),
                            Text(_score.toString(), style: scoreNumberStyle)
                          ],
                        )),
                    new Container(
                        padding: EdgeInsets.only(top: 5),
                        width: 95,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                            color: const Color(0xFFbbada0)),
                        child: Column(
                          children: [
                            Text('BEST', style: scoreTitleStyle),
                            Text(_bestScore.toString(), style: scoreNumberStyle)
                          ],
                        ))
                  ]),
                ],
              ),
            ),
            Container(
                height: 48,
                margin: EdgeInsets.only(top: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: 154,
                          height: 48,
                          child: Text(
                            'Join the numbers and get to the 2048 tile!',
                            style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: const Color(0xFF776e65)),
                          )),
                      GestureDetector(
                        onTap: _newGame,
                        child: Container(
                            margin: EdgeInsets.only(top: 4),
                            width: 118,
                            height: 40,
                            decoration: BoxDecoration(
                                color: const Color(0xFF8f7a66),
                                borderRadius: BorderRadius.circular(3.0)),
                            child: new Align(
                              alignment: FractionalOffset.center,
                              child: Text('New Game',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: const Color(0xFFf9f6f2),
                                      fontWeight: FontWeight.bold)),
                            )),
                      )
                    ])),
            Container(
              margin: EdgeInsets.only(top: 32),
              padding: EdgeInsets.all(10),
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                  color: const Color(0xFFbbada0),
                  borderRadius: BorderRadius.circular(6.0)),
              child: Stack(
                fit: StackFit.passthrough,
                children: _buildGameCenter(),
              ),
            )
          ],
        ));
  }

  _buildGameCenter() {
    var result = [
      Container(
        child: GridView.count(
          physics: new NeverScrollableScrollPhysics(),
          primary: false,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          crossAxisCount: 4,
          children: _buildBackgroundSquares(),
        ),
      ),
      new MyGridView(
          updateScore: updateScore,
          initialed: _initialed,
          gameoverCallback: _gameOver,
          initialedCallBack: _resetInitialed)
    ];

    if (_isGameOver) {
      result.add(Positioned(
          child: Container(
        decoration: BoxDecoration(color: const Color(0xbaeee4da)),
        child: Center(
          child: Text('Game over!',
              style: TextStyle(
                  color: const Color(0xFF776e65),
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
        ),
      )));
    }

    return result;
  }

  _buildBackgroundSquares() {
    return List.filled(
        16,
        Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: const Color(0x59eee4da),
                borderRadius: BorderRadius.circular(3.0))));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      home: Scaffold(
          appBar: AppBar(
            title: Text('2048'),
          ),
          backgroundColor: const Color(0xFFfaf8ef),
          body: Center(
            child: MyContainer(),
          )),
    );
  }
}
