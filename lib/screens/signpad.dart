import 'package:flutter/material.dart';


class SignPad extends StatefulWidget {
  @override
  _SignPadState createState() => new _SignPadState();
}

class _SignPadState extends State<SignPad> {
  List<Offset> _points = <Offset>[];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title:Text('Cust. Signature'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {             
              Navigator.pop(context,true);
            },
          ),
      ),
      body: new Container(
        child: new GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              RenderBox object = context.findRenderObject();
              Offset _localPosition =
                  object.globalToLocal(details.globalPosition);
              _points = new List.from(_points)..add(_localPosition);
            });
          },
          onPanEnd: (DragEndDetails details) => _points.add(null),
          child: new CustomPaint(
            painter: new Signature(points: _points),
            size: Size.infinite,
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.clear),
        onPressed: () => _points.clear(),
      ),
    );
  }
}

class Signature extends CustomPainter {
  List<Offset> points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}

