import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

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
  TextEditingController starttimeController = TextEditingController();
  TextEditingController endtimeController = TextEditingController();
  TextEditingController workperfrmController = TextEditingController();
  MaskedTextController hoursController = MaskedTextController(mask: '00:00');

  _ReportDetail2(this.task, this.appBarTitle, this.reportid);

  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    itemController.text = task.item;
    starttimeController.text = task.starttime;
    endtimeController.text = task.endtime;
    workperfrmController.text = task.workperformed;
    hoursController.text = task.hours;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            //_save(reportid);
            movetolastscreen();
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
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: DateTimePickerFormField(
                      inputType: InputType.time,
                      controller: starttimeController,
                      editable: false,
                      format: formats[InputType.time],
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        icon: Icon(Icons.date_range),
                      ),
                      onChanged: (value) {
                        setState(() {
                          updateStartTime();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: DateTimePickerFormField(
                      controller: endtimeController,
                      inputType: InputType.time,
                      editable: false,
                      format: formats[InputType.time],
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        icon: Icon(Icons.date_range),
                      ),
                      onChanged: (dt) {
                        setState(() {
                          updateEndTime();
                        });
                      },
                    ),
                  )
                ],
              ),
            ),

            // Third Element - Work Performed
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                controller: workperfrmController,
                style: textStyle,
                //focusNode: wrkperfrmFocusNode,
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
                    hintText: '00\:00',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        tooltip: "Save Task Performed",
        onPressed: () {
          _save(reportid);
        },
      ),
    );
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  void _save(int reportid) async {
    movetolastscreen();
    task.reportid = reportid;
    int result = 0;
    if (task.id != null) {
      // Case 1: Update operation
      result = await helper.updateTask(task);
    } else {
      // Case 2: Insert Operation
      if (task.item.length > 0) {
        task.date = DateFormat('yyyy-MM-dd h:m:ss').format(DateTime.now());
        result = await helper.inserTask(task);
      }
    }

    if (result != 0) {
      // Success
      String message = 'Task added To ' + reportid.toString();
      if (appBarTitle == 'Edit Item')
        message = 'Task Updated To ' + reportid.toString();
      _showAlertDialog('SPM Connect', message);
    } else {
      // Failure
      // _showAlertDialog(
      //     'SPM Connect', 'Problem Saving Task To ' + reportid.toString());
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
      animationDuration: Duration(seconds: 1),
      duration: Duration(seconds: 2),
      icon: Icon(
        Icons.info_outline,
        size: 35.0,
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
  void updateStartTime() {
    task.starttime = starttimeController.text;
  }

  void updateEndTime() {
    task.endtime = endtimeController.text;
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
