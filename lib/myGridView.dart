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
  List<int> _matrix = [];
  List<int> newSquareIndex = [];
  List<int> combineSquareIndex = [];
  List<int> _combineSquareIndex = [];
  List<List<int>> movingArray = [];
  bool moving = false;
  String direction = '';
  List<Animation<double>> offsetXList = [];
  List<Animation<double>> offsetYList = [];
  List<Tween<double>> horizontalTweens = [
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0)
  ];

  List<Tween<double>> verticalTweens = [
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0),
    Tween<double>(begin: 0, end: 0)
  ];

  @override
  void initState() {
    super.initState();
    initialSquare();
    // List.copyRange(_matrix, 0, widget.matrix);
    controller = AnimationController(
        duration: const Duration(milliseconds: 80), vsync: this);
    new CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    horizontalTween = Tween<double>(begin: 0, end: 240);
    for (var i = 0; i < horizontalTweens.length; i++) {
      offsetXList.add(horizontalTweens[i].animate(controller)..addListener(((){setState(() {
        
      });})));
    }
    for (var i = 0; i < verticalTweens.length; i++) {
      offsetYList.add(verticalTweens[i].animate(controller)..addListener(((){setState(() {
        
      });})));
    }
    for (var i = 0; i < this._matrix.length; i++) {
      if(_matrix[i] == 0) {
        continue;
      }
      this.verticalTweens[i].begin = this.verticalTweens[i].end = (i ~/ 4) * 80.0;
      this.horizontalTweens[i].begin = this.horizontalTweens[i].end = (i % 4) * 80.0;
    }
  }

  @override
  void didUpdateWidget(MyGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget:' + _matrix.toString());
    if (!widget.initialed) {
      initialSquare();
      for (var i = 0; i < this._matrix.length; i++) {
        if(_matrix[i] == 0) {
          continue;
        }
        this.verticalTweens[i].begin = this.verticalTweens[i].end = (i ~/ 4) * 80.0;
        this.horizontalTweens[i].begin = this.horizontalTweens[i].end = (i % 4) * 80.0;
      }
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
        onVerticalDragStart: (dragStartDetails) {
          _pointerStartY = dragStartDetails.globalPosition.dy;
        },
        onVerticalDragUpdate: (dragUpdateDetails) {
          _pointerEndY = dragUpdateDetails.globalPosition.dy;
        },
        onHorizontalDragStart: (dragStartDetails) {
          _pointerStartX = dragStartDetails.globalPosition.dx;
        },
        onHorizontalDragUpdate: (dragUpdateDetails) {
          _pointerEndX = dragUpdateDetails.globalPosition.dx;
        },
        onVerticalDragEnd: (dragEndDetails) {
          if (_pointerEndY - _pointerStartY > 10) {
            print('从上往下');
            _moveSquares('bottom');
          } else if (_pointerStartY - _pointerEndY > 10) {
            print('从下往上');
            _moveSquares('top');
          }
        },
        onHorizontalDragEnd: (dragEndDetails) {
          if (_pointerEndX - _pointerStartX > 10) {
            print('从左往右');
            _moveSquares('right');
          } else if (_pointerStartX - _pointerEndX > 10) {
            print('从右往左');
            _moveSquares('left');
          }
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0x00000000), width: 0)),
          child: Stack(
            children: _buildSquares()
          ),
        ));
  }

  /*
   * direction: left, right, bottom, top
   */
  _moveSquares(String direction) {
    List<List<int>> movingArray = [];
    List<List<int>> map1,map2,map3,map4;
    combineSquareIndex.clear();
    newSquareIndex.clear();
    setState(() {
      this.direction=direction;
      this.newSquareIndex=newSquareIndex;
      this._combineSquareIndex = [];
    });
    if (direction == 'top') {
      map1 = _moveColumnSquares2([_matrix[0], _matrix[4], _matrix[8], _matrix[12]],
          _matrix, [0, 4, 8, 12]);
      map2 = _moveColumnSquares2([_matrix[1], _matrix[5], _matrix[9], _matrix[13]],
          _matrix, [1, 5, 9, 13]);
      map3 = _moveColumnSquares2([_matrix[2], _matrix[6], _matrix[10], _matrix[14]],
          _matrix, [2, 6, 10, 14]);
      map4 = _moveColumnSquares2([_matrix[3], _matrix[7], _matrix[11], _matrix[15]],
          _matrix, [3, 7, 11, 15]);
      movingArray.addAll(map1);
      movingArray.addAll(map2);
      movingArray.addAll(map3);
      movingArray.addAll(map4);
    } else if (direction == 'bottom') {
      map1 = _moveColumnSquares2([_matrix[12], _matrix[8], _matrix[4], _matrix[0]],
          _matrix, [12, 8, 4, 0]);
      map2 = _moveColumnSquares2([_matrix[13], _matrix[9], _matrix[5], _matrix[1]],
          _matrix, [13, 9, 5, 1]);
      map3 = _moveColumnSquares2([_matrix[14], _matrix[10], _matrix[6], _matrix[2]],
          _matrix, [14, 10, 6, 2]);
      map4 = _moveColumnSquares2([_matrix[15], _matrix[11], _matrix[7], _matrix[3]],
          _matrix, [15, 11, 7, 3]);    
      movingArray.addAll(map1);
      movingArray.addAll(map2);
      movingArray.addAll(map3);
      movingArray.addAll(map4);
    } else if (direction == 'left') {
      map1 = _moveColumnSquares2([_matrix[0], _matrix[1], _matrix[2], _matrix[3]],
          _matrix, [0, 1, 2, 3]);
      map2 = _moveColumnSquares2([_matrix[4], _matrix[5], _matrix[6], _matrix[7]],
          _matrix, [4, 5, 6, 7]);
      map3 = _moveColumnSquares2([_matrix[8], _matrix[9], _matrix[10], _matrix[11]],
          _matrix, [8, 9, 10, 11]);
      map4 = _moveColumnSquares2([_matrix[12], _matrix[13], _matrix[14], _matrix[15]],
          _matrix, [12, 13, 14, 15]);
      movingArray.addAll(map1);
      movingArray.addAll(map2);
      movingArray.addAll(map3);
      movingArray.addAll(map4);
    }else if (direction == 'right') {
      map1 = _moveColumnSquares2([_matrix[3], _matrix[2], _matrix[1], _matrix[0]],
          _matrix, [3, 2, 1, 0]);
      map2 = _moveColumnSquares2([_matrix[7], _matrix[6], _matrix[5], _matrix[4]],
          _matrix, [7, 6, 5, 4]);
      map3 = _moveColumnSquares2([_matrix[11], _matrix[10], _matrix[9], _matrix[8]],
          _matrix, [11, 10, 9, 8]);
      map4 = _moveColumnSquares2([_matrix[15], _matrix[14], _matrix[13], _matrix[12]],
          _matrix, [15, 14, 13, 12]);
      movingArray.addAll(map1);
      movingArray.addAll(map2);
      movingArray.addAll(map3);
      movingArray.addAll(map4);
    }
    if (movingArray.length == 0) {
      // 滑动之后无变化，不更新视图
      newSquareIndex = [];
      combineSquareIndex = [];
      return;
    }
    print('结束移动:' + movingArray.toString());
    print('结束移动合并数组:' + combineSquareIndex.toString());
    // setState(() {
    //   this.movingArray = movingArray;
    // });
    
    for (int i = 0; i < _matrix.length; i++) {
      if (_matrix[i] == 0) {
        continue;
      }
      this.verticalTweens[i].begin = this.verticalTweens[i].end = (i ~/ 4) * 80.0;
      this.horizontalTweens[i].begin = this.horizontalTweens[i].end = (i % 4) * 80.0;
    }

    for (var i = 0; i < movingArray.length; i++) {
      int from = movingArray[i][0];
      int to = movingArray[i][1];
      double start, end;
      Tween<double> tween;
      // 更新数据
      // _matrix[from] = _matrix[to];
      // 设置tween
      if (this.direction == 'bottom' || this.direction == 'top') {
        tween = this.verticalTweens[from];
        // 垂直方向
        start = (from ~/ 4) * 80.0;
        end = (to ~/ 4) * 80.0;
 
        tween.begin = start;
        tween.end = end;
        // print('垂直方向设置tween:' + from.toString()+'||'+tween.toString());
      } else {
        tween = this.horizontalTweens[from];
        // 水平方向
        start = (from % 4) * 80.0;
        end = (to % 4) * 80.0;

        tween.begin = start;
        tween.end = end;
        // print('水平方向设置tween:' + from.toString()+'||'+tween.toString());
      }
    }
    controller.reset();
    controller.forward().whenComplete(() {
      // 动画结束设置最终状态
      // 将方块从起始位置移动到终点位置
      for (var i = 0; i < movingArray.length; i++) {
        Tween<double> verticalTween;
        Tween<double> horizontalTween;
        int from = movingArray[i][0];
        int to = movingArray[i][1];

        verticalTween = this.verticalTweens[to];
        verticalTween.begin = (to ~/ 4) * 80.0;
        verticalTween.end = (to ~/ 4) * 80.0;
        // print('重置垂直状态坐标:' + to.toString()+','+ verticalTween.begin.toString());
        horizontalTween = this.horizontalTweens[to];
        horizontalTween.begin = (to % 4) * 80.0;
        horizontalTween.end = (to % 4) * 80.0;
        // print('重置水平状态坐标:' + to.toString()+','+ horizontalTween.begin.toString());

        if(combineSquareIndex.contains(to)) {
          _matrix[to] = _matrix[from] * 2;
          widget.updateScore(_matrix[from] * 2);
        } else {
          _matrix[to] = _matrix[from];
        }
        _matrix[from] = 0;
      }
      setState(() {
        _matrix = _matrix;
        _combineSquareIndex = combineSquareIndex;
      });
      _generateSquare();
      setState(() {
        _matrix = _matrix;
      });
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
    // int first = 3;
    int first = Random().nextInt(16);
    // int second = 1;
    int second = Random().nextInt(16);
    // 如果相等重新生成
    while (first == second) {
      second = Random().nextInt(16);
    }
    _matrix[first] = (Random().nextInt(100)) < 90 ? 2 : 4;
    _matrix[second] = (Random().nextInt(100)) < 90 ? 2 : 4;

    setState(() {
      _matrix = _matrix;
      // _matrix = [0,0,0,0,16,16,16,16,0,0,8,0,2,8,8,4];
      newSquareIndex = [first, second];
      _combineSquareIndex = [];
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
    int newIndex = emptySquareIndexList[randomIndex];
    // 设置数字
    _matrix[newIndex] = randomNumber;
    // 设置坐标
    this.verticalTweens[newIndex].begin = this.verticalTweens[newIndex].end = (newIndex ~/ 4) * 80.0;
    this.horizontalTweens[newIndex].begin = this.horizontalTweens[newIndex].end = (newIndex % 4) * 80.0;

    // 只剩一个空格，检查游戏是否结束的标志
    if (emptySquareIndexList.length == 1) {
      print('check game over');
      if (_checkWhetherGameOver()) {
        print('game over');
        widget.gameoverCallback();
      }
    }
    setState(() {
      newSquareIndex = [newIndex];
    });
  }
  // forth -> third -> second -> first
  _moveColumnSquares2(List<int> list, targetList, targetIndex) {
    List<List<int>> movingMap = [];
    int first = list[0];
    int second = list[1];
    int third = list[2];
    int forth = list[3];
    // print(first.toString() + ',' + second.toString() + ',' + third.toString() + ',' + forth.toString());
    int firstIndex =targetIndex[0];
    int secondIndex =targetIndex[1];
    int thirdIndex =targetIndex[2];
    int forthIndex =targetIndex[3];
    // 全是0的情况
    if (first == 0 && second == 0 && third == 0 && forth == 0) {
      return movingMap;
    }
    // 都没有0的情况
    if (first != 0 && second != 0 && third != 0 && forth != 0) {
      if(first == second) {
        movingMap.add([secondIndex,firstIndex]); // 从坐标2移动到1
        combineSquareIndex.add(firstIndex);
        if(third ==forth) {
          movingMap.add([thirdIndex,secondIndex]);
          movingMap.add([forthIndex,secondIndex]); // 从坐标4移动到2
          combineSquareIndex.add(secondIndex);
        } else {
          movingMap.add([thirdIndex,secondIndex]);
          movingMap.add([forthIndex,thirdIndex]);
        }
      } else if(second == third) {
        movingMap.add([thirdIndex,secondIndex]); // 从坐标3移动到2
        combineSquareIndex.add(secondIndex);
        movingMap.add([forthIndex,thirdIndex]);
      } else if(third == forth) {
        movingMap.add([forthIndex,thirdIndex]); // 从坐标4移动到3
        combineSquareIndex.add(thirdIndex);
      }
      return movingMap;
    }

    if (first == 0) { // 第一个数为0
      if (second != 0) { // 第二个数不为0
        movingMap.add([secondIndex,firstIndex]); // 从坐标1移动到0
        if (third == 0) {
          if(forth ==second) {
            movingMap.add([forthIndex,firstIndex]);
            combineSquareIndex.add(firstIndex);
          } else {
            movingMap.add([forthIndex,secondIndex]);
          }
        } else if(third ==second) {
          movingMap.add([thirdIndex,firstIndex]); // 第三和第二相等，在位置1合并
          combineSquareIndex.add(firstIndex);
          if(forth!= 0) {
            movingMap.add([forthIndex,secondIndex]);  // 如果第四不等于0，则移动到位置2
          }
        } else {
          movingMap.add([thirdIndex,secondIndex]); // 二三不等
          if(forth!= 0) {
            if(forth ==third) {
              movingMap.add([forthIndex,secondIndex]);
              combineSquareIndex.add(secondIndex);
            } else {
              movingMap.add([forthIndex,thirdIndex]);  // 如果第四不等于0，则移动到位置三
            }
          }
        }
      } else if (third != 0) { // 第二个数为0，第三个数不为0
        // print('第二个数为0，第三个数不为0:' + secondIndex.toString() + '=>' + firstIndex.toString());
        movingMap.add([thirdIndex,firstIndex]); 
        if(forth!= 0) {
          if(forth ==third) {
            movingMap.add([forthIndex,firstIndex]); // 四等于三，合并在位置一
            combineSquareIndex.add(firstIndex);
          } else {
            movingMap.add([forthIndex,secondIndex]); 
          }
        }
      } else if (forth != 0) { // 一二三为0，第四个数不为0
        movingMap.add([forthIndex,firstIndex]); 
      }
    } else if(second == 0) { // 第一个数不等于0，第二个数等于0
      if (third != 0) { // 第三个数不为0
        if(third == first) { // 一三相等合并
          movingMap.add([thirdIndex,firstIndex]);
          combineSquareIndex.add(firstIndex);
          if(forth!= 0) {
            movingMap.add([forthIndex,secondIndex]);  // 如果第四不等于0，则移动到二
          }
        } else { // 一三不相等
          movingMap.add([thirdIndex,secondIndex]);
          if(forth!= 0) {
            if(forth == third) {
              movingMap.add([forthIndex,secondIndex]); // 四等于三，合并在位置二
              combineSquareIndex.add(secondIndex);
            } else {
              movingMap.add([forthIndex,thirdIndex]);
            }
          }
        }
      } else if (third == 0) { // 第三个数为0, 第四个数不为0
        if (forth != 0) {
          if(forth == first) { // 一四相等合并
            movingMap.add([forthIndex,firstIndex]);
            combineSquareIndex.add(firstIndex);
          } else { // 一四不相等
            movingMap.add([forthIndex,secondIndex]);
          }
        }
      } else {  // 三四都为0
        // 无需移动
      }
    } else if(third == 0) { // 一二不为0，三为0
      if(first == second) {
        movingMap.add([secondIndex, firstIndex]);  // 一二合并在位置1
        combineSquareIndex.add(firstIndex);
        if(forth!= 0) {
          movingMap.add([forthIndex, secondIndex]);  // 如果第四不等于0，则移动到位置1
        }
      } else if(second ==forth) {
        movingMap.add([forthIndex, secondIndex]);  // 二四合并在位置二
        combineSquareIndex.add(secondIndex);
      } else { // 一二四都不相等
        if(forth != 0) {
          movingMap.add([forthIndex, thirdIndex]);
        }
      }
    } else if (forth == 0) { // 一二三不为0，4为0
      if(first == second) {
        movingMap.add([secondIndex, firstIndex]);  // 一二合并在位置1
        combineSquareIndex.add(firstIndex);
        movingMap.add([thirdIndex, secondIndex]);  // 三前移到位置2
      } else if(second ==third) {
        movingMap.add([thirdIndex, secondIndex]);
        combineSquareIndex.add(secondIndex);
      }
    }
    

    return movingMap;
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
        // print('合并的坐标:' + targetIndex[pointer].toString());
        // combineSquareIndex.add(targetIndex[pointer]);
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
    print('_buildSquares -> newSquareIndex:' + this.newSquareIndex.toString());
    
    var result = <Widget>[];
    for (int i = 0; i < _matrix.length; i++) {
      if (_matrix[i] == 0) {
        continue;
      }
      result.add(this._buildAnimateSquare(i));
    }
    return result;
  }

  _buildAnimateSquare(int index) {
    var number = _matrix[index];
    // print(index.toString()+ ':_buildAnimateSquare->X,Y:' + this.offsetXList[index].value.toString()+','+this.offsetYList[index].value.toString());
    // print('_buildAnimateSquare index->' + index.toString());

    return Positioned(
        top: this.offsetYList[index].value,
        left: this.offsetXList[index].value,
        width: 70,
        height: 70,
        child: new Square(
          number: number,
          isNew: newSquareIndex.contains(index),
          needCombine: _combineSquareIndex.contains(index)
        ));
  }

  _buildSquare(int index) {
    var number = _matrix[index];
    
    return Positioned(
        // top: offsetX.value,
        top: (index ~/ 4) * 80.0,
        // left: offsetY.value,
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
