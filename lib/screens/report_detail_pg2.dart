import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:spmconnectapp/utils/database_helper.dart';

class ReportDetail2 extends StatefulWidget {
  final String appBarTitle;
  final Tasks task;
  final int reportid;

  ReportDetail2(this.task, this.appBarTitle, this.reportid);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail2(this.task, this.appBarTitle, this.reportid);
  }
}

class _ReportDetail2 extends State<ReportDetail2> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  int reportid;
  Tasks task;

  FocusNode timeFocusNode;
  FocusNode wrkperfrmFocusNode;
  FocusNode hoursFocusNode;

  @override
  void initState() {
    super.initState();
    timeFocusNode = FocusNode();
    wrkperfrmFocusNode = FocusNode();
    hoursFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    timeFocusNode.dispose();
    wrkperfrmFocusNode.dispose();
    hoursFocusNode.dispose();

    super.dispose();
  }

  TextEditingController itemController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController workperfrmController = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  _ReportDetail2(this.task, this.appBarTitle, this.reportid);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    itemController.text = task.item;
    timeController.text = task.time;
    workperfrmController.text = task.workperformed;
    hoursController.text = task.hours;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _save(reportid);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            // First Element - Item Number
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                textInputAction: TextInputAction.next,
                autofocus: true,
                controller: itemController,
                style: textStyle,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(timeFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Item Text Field');
                  updateItem();
                },
                decoration: InputDecoration(
                    labelText: 'Item No.',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Second Element - Time
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.datetime,
                controller: timeController,
                style: textStyle,
                focusNode: timeFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(wrkperfrmFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Time Text Field');
                  updateTime();
                },
                decoration: InputDecoration(
                    labelText: 'Time',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Third Element - Work Performed
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                controller: workperfrmController,
                style: textStyle,
                focusNode: wrkperfrmFocusNode,
                textInputAction: TextInputAction.newline,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(hoursFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Work Performed Text Field');
                  updateWorkperformed();
                },
                decoration: InputDecoration(
                    labelText: 'Work Performed',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            //Fourth Element - Hours
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: hoursController,
                keyboardType: TextInputType.numberWithOptions(),
                style: textStyle,
                focusNode: hoursFocusNode,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  debugPrint('Something changed in Hours Text Field');
                  updateHours();
                },
                decoration: InputDecoration(
                    labelText: 'Hours',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  void _save(int reportid) async {
    movetolastscreen();
    task.reportid = reportid;
    int result;
    if (task.id != null) {
      // Case 1: Update operation
      result = await helper.updateTask(task);
    } else {
      // Case 2: Insert Operation
      result = await helper.inserTask(task);
    }

    if (result != 0) {
      // Success
      String message = 'Task added To ' + reportid.toString();
      if (appBarTitle == 'Edit Item')
        message = 'Task Updated To ' + reportid.toString();
      _showAlertDialog('SPM Connect', message);
    } else {
      // Failure
      _showAlertDialog(
          'SPM Connect', 'Problem Saving Task To ' + reportid.toString());
    }
  }

  void _showAlertDialog(String title, String message) {
    // AlertDialog alertDialog = AlertDialog(
    //   title: Text(title),
    //   content: Text(message),
    // );
    // showDialog(context: context, builder: (_) => alertDialog);

    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 2),
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      aroundPadding: EdgeInsets.all(8),
      borderRadius: 8,
      leftBarIndicatorColor: Colors.blue[300],
    ).show(context);
  }

// Update the project no.
  void updateItem() {
    task.item = itemController.text;
  }

  // Update the customer namme of Note object
  void updateTime() {
    task.time = timeController.text;
  }

  // Update the plant location namme of Note object
  void updateWorkperformed() {
    task.workperformed = workperfrmController.text;
  }

  // Update the customer namme of Note object
  void updateHours() {
    task.hours = hoursController.text;
  }
}
