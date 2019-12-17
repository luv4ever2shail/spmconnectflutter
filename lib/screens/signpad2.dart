import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/Resource/reports_repository.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/Reports/report_list.dart';
import 'package:spmconnectapp/utils/painter.dart';

class Signpad2 extends StatefulWidget {
  final String reportno;
  final Report report;
  final DatabaseHelper helper;
  Signpad2(this.reportno, this.report, this.helper);
  @override
  _Signpad2State createState() => new _Signpad2State(reportno, report);
}

class _Signpad2State extends State<Signpad2> {
  Report report;
  bool _finished;
  PainterController _controller;
  String reportno;
  _Signpad2State(this.reportno, this.report);
  List<Widget> actions;

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
    MyReports myReports = Provider.of<MyReports>(context);
    return new Scaffold(
      backgroundColor: Colors.grey,
      appBar: new AppBar(
          backgroundColor: barColor,
          title: Text('Signature'),
          actions: _finished
              ? <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.content_copy),
                    tooltip: 'Customer Signature',
                    onPressed: () => setState(() {
                      _finished = false;
                      _controller = _newController();
                    }),
                  ),
                ]
              : <Widget>[
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
                      onPressed: () async {
                        if (_controller.isSigned()) {
                          await _neverSatisfied(myReports);
                        }
                      }),
                ]),
      body: new Center(
          child: new AspectRatio(
              aspectRatio: 1.0, child: new Painter(_controller))),
    );
  }

  void _show(
      PictureDetails picture, BuildContext context, MyReports myReports) {
    setState(() {
      _finished = true;
    });
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          appBar: new AppBar(
            title: const Text('Signed'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                navigateToReports();
              },
            ),
          ),
          body: new Container(
            alignment: Alignment.center,
            child: new FutureBuilder<Uint8List>(
              future: picture.toPNG('${report.reportmapid}'),
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
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
            ),
          ),
        );
      }),
    );
  }

  Future<void> _neverSatisfied(MyReports myReports) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit report?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure want to sign and submit this report? Once "Confirmed", report will not be available for edit or delete to the user.')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirm'),
              onPressed: () async {
                // Navigator.of(context).pop();
                //await _controller.finish().toPNG('${report.reportmapid}');
                await _save(myReports);
                _show(_controller.finish(), context, myReports);
              },
            ),
            FlatButton(
              child: Text('Discard'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _save(MyReports myReports) async {
    int result;
    report.reportsigned = 1;
    if (report.id != null) {
      // Case 1: Update operation
      result = await widget.helper.updateReport(report);
    } else {
      // Case 2: Insert Operation
      if (report.projectno.length > 0) {
        if (reportno ==
            ((myReports.getReportMapId != 0)
                ? (myReports.getReportMapId + 1).toString()
                : '1001')) {
          report.date =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
          result = await widget.helper.inserReport(report);
          await myReports.fetchReports();
          await myReports.fetchReportmapId();
        }
      }
    }
    if (result != 0) {
      print('Success signed');
    } else {
      print('Failure signing');
    }
    navigateToReports();
  }

  Future<void> navigateToReports() async {
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
