import 'package:flutter/material.dart';
import 'dart:math';
import './square.dart';

class MyGridView extends StatefulWidget {
  MyGridView(
      {this.updateScore,
      this.initialedCallBack,
      this.initialed,
      this.gameoverCallback});
  final updateScore;
  final gameoverCallback;
  bool initialed;
  final initialedCallBack;

  @override
  MyGridViewState createState() {
    return new MyGridViewState();
  }
}

class MyGridViewState extends State<MyGridView> with TickerProviderStateMixin {
  double _pointerStartX = 0.0;
  double _pointerStartY = 0.0;
  double _pointerEndX = 0.0;
  double _pointerEndY = 0.0;
  Animation<double> offsetX;
  Animation<double> offsetY;
  Tween<double> horizontalTween;
  Tween<double> verticalTween;
  AnimationController controller;
  AnimationController verticalController;
  List<int> _matrix = [];
  List<int> newSquareIndex = [];
  List<int> combineSquareIndex = [];

  @override
  void initState() {
    super.initState();
    initialSquare();
    // List.copyRange(_matrix, 0, widget.matrix);
    controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    verticalController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    horizontalTween = Tween<double>(begin: 0, end: 0);
    offsetX = horizontalTween.animate(controller)
      ..addListener(() {
        // #enddocregion addListener
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
        // #docregion addListener
      });
    verticalTween = Tween<double>(begin: 0, end: 0);
    offsetY = verticalTween.animate(verticalController)
      ..addListener(() {
        // #enddocregion addListener
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
        // #docregion addListener
      });
  }

  @override
  void didUpdateWidget(MyGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget:' + _matrix.toString());
    if (!widget.initialed) {
      initialSquare();
      new Future(() {
        widget.initialedCallBack();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onVerticalDragStart: (DragStartDetails) {
          _pointerStartY = DragStartDetails.globalPosition.dy;
        },
        onVerticalDragUpdate: (DragUpdateDetails) {
          _pointerEndY = DragUpdateDetails.globalPosition.dy;
        },
        onHorizontalDragStart: (DragStartDetails) {
          _pointerStartX = DragStartDetails.globalPosition.dx;
        },
        onHorizontalDragUpdate: (DragUpdateDetails) {
          _pointerEndX = DragUpdateDetails.globalPosition.dx;
        },
        onVerticalDragEnd: (DragEndDetails) {
          if (_pointerEndY - _pointerStartY > 10) {
            print('从上往下:' +
                _pointerStartY.toString() +
                '-->' +
                _pointerEndY.toString());
            _moveSquares('bottom');
          } else if (_pointerStartY - _pointerEndY > 10) {
            print('从下往上:' +
                _pointerStartY.toString() +
                '-->' +
                _pointerEndY.toString());
            _moveSquares('top');
          }
        },
        onHorizontalDragEnd: (DragEndDetails) {
          if (_pointerEndX - _pointerStartX > 10) {
            print('从左往右:' +
                _pointerStartX.toString() +
                '-->' +
                _pointerEndX.toString());
            _moveSquares('right');
          } else if (_pointerStartX - _pointerEndX > 10) {
            print('从右往左:' +
                _pointerStartX.toString() +
                '-->' +
                _pointerEndX.toString());
            _moveSquares('left');
          }
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0x00000000), width: 0)),
          child: Stack(
            children: _buildSquares(),
            // children: <Widget>[
            //   Positioned(
            //       top: offsetY.value,
            //       left: offsetX.value,
            //       child: _buildSquareText(2))
            // ],
          ),
        ));
  }

  /*
   * direction: left, right, bottom, top
   */
  _moveSquares(String direction) {
    String before = _matrix.toString();
    combineSquareIndex.clear();
    if (direction == 'top') {
      _moveColumnSquares([_matrix[0], _matrix[4], _matrix[8], _matrix[12]],
          _matrix, [0, 4, 8, 12]);
      _moveColumnSquares([_matrix[1], _matrix[5], _matrix[9], _matrix[13]],
          _matrix, [1, 5, 9, 13]);
      _moveColumnSquares([_matrix[2], _matrix[6], _matrix[10], _matrix[14]],
          _matrix, [2, 6, 10, 14]);
      _moveColumnSquares([_matrix[3], _matrix[7], _matrix[11], _matrix[15]],
          _matrix, [3, 7, 11, 15]);
    }
    if (direction == 'bottom') {
      _moveColumnSquares([_matrix[12], _matrix[8], _matrix[4], _matrix[0]],
          _matrix, [12, 8, 4, 0]);
      _moveColumnSquares([_matrix[13], _matrix[9], _matrix[5], _matrix[1]],
          _matrix, [13, 9, 5, 1]);
      _moveColumnSquares([_matrix[14], _matrix[10], _matrix[6], _matrix[2]],
          _matrix, [14, 10, 6, 2]);
      _moveColumnSquares([_matrix[15], _matrix[11], _matrix[7], _matrix[3]],
          _matrix, [15, 11, 7, 3]);
    }
    if (direction == 'left') {
      _moveColumnSquares([_matrix[0], _matrix[1], _matrix[2], _matrix[3]],
          _matrix, [0, 1, 2, 3]);
      _moveColumnSquares([_matrix[4], _matrix[5], _matrix[6], _matrix[7]],
          _matrix, [4, 5, 6, 7]);
      _moveColumnSquares([_matrix[8], _matrix[9], _matrix[10], _matrix[11]],
          _matrix, [8, 9, 10, 11]);
      _moveColumnSquares([_matrix[12], _matrix[13], _matrix[14], _matrix[15]],
          _matrix, [12, 13, 14, 15]);
    }
    if (direction == 'right') {
      _moveColumnSquares([_matrix[3], _matrix[2], _matrix[1], _matrix[0]],
          _matrix, [3, 2, 1, 0]);
      _moveColumnSquares([_matrix[7], _matrix[6], _matrix[5], _matrix[4]],
          _matrix, [7, 6, 5, 4]);
      _moveColumnSquares([_matrix[11], _matrix[10], _matrix[9], _matrix[8]],
          _matrix, [11, 10, 9, 8]);
      _moveColumnSquares([_matrix[15], _matrix[14], _matrix[13], _matrix[12]],
          _matrix, [15, 14, 13, 12]);
    }

    String after = _matrix.toString();
    if (before == after) {
      // 滑动之后无变化，不更新视图
      newSquareIndex = [];
      return;
    }
    setState(() {
      _matrix = _matrix;
    });
    _generateSquare();
    setState(() {
      _matrix = _matrix;
    });
  }

  bool _checkWhetherGameOver() {
    for (var i = 0; i < _matrix.length; i++) {
      if (i == 15) {
        continue;
      }
      if (i ~/ 4 == 3) {
        // 最后一行
        if (_matrix[i] == _matrix[i + 1]) {
          return false;
        }
      } else if (i % 4 == 3) {
        // 最后一列
        if (_matrix[i] == _matrix[i + 4]) {
          return false;
        }
      } else if (_matrix[i] == _matrix[i + 1] || _matrix[i] == _matrix[i + 4]) {
        return false;
      }
    }
    return true;
  }

  initialSquare() {
    _matrix = List.filled(16, 0);
    int first = Random().nextInt(16);
    int second = Random().nextInt(16);
    // 如果相等重新生成
    while (first == second) {
      second = Random().nextInt(16);
    }
    _matrix[first] = (Random().nextInt(100)) < 90 ? 2 : 4;
    _matrix[second] = (Random().nextInt(100)) < 90 ? 2 : 4;

    setState(() {
      _matrix = _matrix;
      newSquareIndex = [first, second];
    });
  }

  _generateSquare() {
    var emptySquareIndexList = [];
    for (var i = 0; i < _matrix.length; i++) {
      if (_matrix[i] == 0) {
        emptySquareIndexList.add(i);
      }
    }

    int randomIndex = Random().nextInt(emptySquareIndexList.length);
    int randomNumber = Random().nextInt(100) <= 90 ? 2 : 4;

    _matrix[emptySquareIndexList[randomIndex]] = randomNumber;
    // 只剩一个空格，检查游戏是否结束的标志
    if (emptySquareIndexList.length == 1) {
      print('check game over');
      if (_checkWhetherGameOver()) {
        print('game over');
        widget.gameoverCallback();
      }
    }
    setState(() {
      newSquareIndex = [emptySquareIndexList[randomIndex]];
    });
  }

  // forth -> third -> second -> first
  _moveColumnSquares(List<int> list, targetList, targetIndex) {
    int pointer = 0;
    // 过滤掉0
    list.removeWhere((item) {
      return item == 0;
    });

    for (var i = 0; i < list.length; i++) {
      // 最后一个数字不处理
      if (i == list.length - 1) {
        targetList[targetIndex[pointer]] = list[i];
        pointer++;
      }
      // 两个数字相同合并，跳过下一个
      else if (list[i] == list[i + 1]) {
        targetList[targetIndex[pointer]] = list[i] * 2;
        print('合并的坐标:' + targetIndex[pointer].toString());
        combineSquareIndex.add(targetIndex[pointer]);
        // 合并加分
        widget.updateScore(list[i] * 2);
        pointer++;
        i++;
      } else if (list[i] != list[i + 1]) {
        targetList[targetIndex[pointer]] = list[i];
        pointer++;
      }
    }

    while (pointer < 4) {
      targetList[targetIndex[pointer]] = 0;
      pointer++;
    }
    setState(() {
      combineSquareIndex = combineSquareIndex;
    });
  }

  _buildSquares() {
    var result = <Widget>[];
    for (int i = 0; i < _matrix.length; i++) {
      if (_matrix[i] == 0) {
        continue;
      }
      result.add(this._buildSquare(i));
    }
    return result;
  }

  _buildSquare(int index) {
    var number = _matrix[index];

    return Positioned(
        top: (index ~/ 4) * 80.0,
        left: (index % 4) * 80.0,
        width: 70,
        height: 70,
        child: new Square(
          number: number,
          isNew: newSquareIndex.contains(index),
          needCombine: combineSquareIndex.contains(index)
        ));
  }
}
