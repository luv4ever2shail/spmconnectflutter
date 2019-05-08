import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/Reports/report_list.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:spmconnectapp/utils/painter.dart';

class Signpad2 extends StatefulWidget {
  final String reportno;
  final Report report;

  Signpad2(this.reportno, this.report);
  @override
  _Signpad2State createState() => new _Signpad2State(reportno, report);
}

class _Signpad2State extends State<Signpad2> {
  DatabaseHelper helper = DatabaseHelper();
  Report report;
  bool _finished;
  PainterController _controller;
  String reportno;
  _Signpad2State(this.reportno, this.report);
  @override
  void initState() {
    super.initState();
    _finished = false;
    _controller = _newController();
  }

  PainterController _newController() {
    PainterController controller = new PainterController();
    controller.thickness = 5.0;
    controller.drawColor = Colors.red;
    controller.backgroundColor = Colors.white;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final barColor = const Color(0xFF192A56);
    List<Widget> actions;
    if (_finished) {
      actions = <Widget>[
        new IconButton(
          icon: new Icon(Icons.content_copy),
          tooltip: 'Customer Signature',
          onPressed: () => setState(() {
                _finished = false;
                _controller = _newController();
              }),
        ),
      ];
    } else {
      actions = <Widget>[
        new IconButton(
            icon: new Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _controller.undo),
        new IconButton(
            icon: new Icon(Icons.delete),
            tooltip: 'Clear',
            onPressed: _controller.clear),
        new IconButton(
            icon: new Icon(Icons.check),
            onPressed: () => _show(_controller.finish(), context)),
      ];
    }
    return new Scaffold(
      backgroundColor: Colors.grey,
      appBar: new AppBar(
          backgroundColor: barColor,
          title: const Text('Customer Signature'),
          actions: actions,
          bottom: new PreferredSize(
            child: new DrawBar(_controller),
            preferredSize: new Size(MediaQuery.of(context).size.width, 30.0),
          )),
      body: new Center(
          child: new AspectRatio(
              aspectRatio: 1.0, child: new Painter(_controller))),
    );
  }

  void _show(PictureDetails picture, BuildContext context) {
    setState(() {
      _finished = true;
    });
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () {
            _save();
          },
          child: Scaffold(
            appBar: new AppBar(
              title: const Text('View your image'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _save();
                },
              ),
            ),
            body: new Container(
                alignment: Alignment.center,
                child: new FutureBuilder<Uint8List>(
                  future: picture.toPNG('1001'),
                  builder: (BuildContext context,
                      AsyncSnapshot<Uint8List> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return new Text('Error: ${snapshot.error}');
                        } else {
                          return Image.memory(snapshot.data);
                        }
                        break;
                      default:
                        return new Container(
                            child: new FractionallySizedBox(
                          widthFactor: 0.1,
                          child: new AspectRatio(
                              aspectRatio: 1.0,
                              child: new CircularProgressIndicator()),
                          alignment: Alignment.center,
                        ));
                    }
                  },
                )),
          ));
    }));
  }

  void _save() async {
    int result;
    if (report.id != null) {
      report.reportsigned = 1;
      result = await helper.updateReport(report);
    }
    if (result != 0) {
      print('Success signed');
    } else {
      print('Failure signing');
    }
    navigateToReports();
  }

  void navigateToReports() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportList();
    }));
  }
}

class DrawBar extends StatelessWidget {
  final PainterController _controller;

  DrawBar(this._controller);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Flexible(child: new StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return new Container(
              child: new Slider(
            value: _controller.thickness,
            onChanged: (double value) => setState(() {
                  _controller.thickness = value;
                }),
            min: 1.0,
            max: 20.0,
            activeColor: Colors.white,
          ));
        })),
        new ColorPickerButton(_controller, false),
        new ColorPickerButton(_controller, true),
      ],
    );
  }
}

class ColorPickerButton extends StatefulWidget {
  final PainterController _controller;
  final bool _background;

  ColorPickerButton(this._controller, this._background);

  @override
  _ColorPickerButtonState createState() => new _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return new IconButton(
        icon: new Icon(_iconData, color: _color),
        tooltip: widget._background
            ? 'Change background color'
            : 'Change draw color',
        onPressed: _pickcolor);
  }

  void _pickcolor() {
    Color pickerColor = _color;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color c) => pickerColor = c,
              colorPickerWidth: 1000.0,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
              enableLabel: true,
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }

  Color get _color => widget._background
      ? widget._controller.backgroundColor
      : widget._controller.drawColor;

  IconData get _iconData =>
      widget._background ? Icons.format_color_fill : Icons.brush;

  set _color(Color color) {
    if (widget._background) {
      widget._controller.backgroundColor = color;
    } else {
      widget._controller.drawColor = color;
    }
  }
}
