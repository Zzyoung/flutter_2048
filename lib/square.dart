import 'package:flutter/material.dart';

const Map colorMapping = {
  // [文字颜色，背景颜色]
  '0': [0xFF776e65, 0x59eee4da],
  '2': [0xFF776e65, 0xFFeee4da],
  '4': [0xFF776e65, 0xFFede0c8],
  '8': [0xFFf9f6f2, 0xFFf2b179],
  '16': [0xFFf9f6f2, 0xFFf59563],
  '32': [0xFFf9f6f2, 0xFFf67c5f],
  '64': [0xFFf9f6f2, 0xFFf65e3b],
  '128': [0xFFf9f6f2, 0xFFedcf72],
  '256': [0xFFf9f6f2, 0xFFedcc61],
  '512': [0xFFf9f6f2, 0xFFedc850],
  '1024': [0xFFf9f6f2, 0xFFedc53f],
  '2048': [0xFFf9f6f2, 0xFFedc22e],
};

class Square extends StatefulWidget {
  int number;
  bool isNew = false;
  bool needCombine = false;
  Square({this.number, this.isNew, this.needCombine});

  @override
  State<StatefulWidget> createState() {
    return new SquareState();
  }
}

class SquareState extends State<Square> with TickerProviderStateMixin {
  Animation<double> scale;
  Animation<double> combineScale;
  AnimationController combineController;
  AnimationController controller;
  Tween<double> squareTween;
  Tween<double> combineTween;

  SquareState() {}

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    combineController = AnimationController(
        duration: const Duration(milliseconds: 40), vsync: this);
    if (widget.isNew) {
      squareTween = Tween<double>(begin: 0, end: 1);
    } else {
      squareTween = Tween<double>(begin: 1, end: 1);
    }
    // #docregion addListener
    scale = squareTween.animate(controller)
      ..addListener(() {
        // #enddocregion addListener
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
        // #docregion addListener
      });
    combineTween =Tween<double>(begin: 1, end: 1.3);
    combineScale =combineTween.animate(combineController)
          ..addListener(() {
            setState((){});
          });
    controller.forward();
  }

  @override
  void didUpdateWidget(Square oldWidget) {
    super.didUpdateWidget(oldWidget);
    // print('number:' + widget.number.toString() + ';needCombine:' + widget.needCombine.toString()+ ';isNew:' + widget.isNew.toString());
    combineController.reset();
    if (widget.isNew) {
      squareTween.begin = 0;
      squareTween.end = 1;
      controller.reset();
      controller.forward();
    } else if (widget.needCombine) {
      combineController.forward().whenComplete((){
        combineController.reverse();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    combineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var number = widget.number;
    var fontSize = 36.0;
    if (number >= 128 && number < 1024) {
      fontSize = 28.0;
    } else if (number >= 1024) {
      fontSize = 18.0;
    }
    return Center(
        child: Transform.scale(
      scale: scale.value,
      child: Transform.scale(
          scale: combineScale.value,
          child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: Color(colorMapping[number.toString()][1]),
                  borderRadius: BorderRadius.circular(3.0)),
              child: new Align(
                  alignment: FractionalOffset.center,
                  child: new Text(
                    number.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(colorMapping[number.toString()][0]),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  )))),
    ));
  }
}
