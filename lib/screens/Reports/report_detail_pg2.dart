import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class ReportDetail2 extends StatefulWidget {
  final String appBarTitle;
  final Tasks task;
  final String reportid;
  final DatabaseHelper helper;

  ReportDetail2(this.task, this.appBarTitle, this.reportid, this.helper);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail2(this.task, this.appBarTitle, this.reportid);
  }
}

class _ReportDetail2 extends State<ReportDetail2> {
  String appBarTitle;
  String reportid;
  Tasks task;
  DateTime _starttime;
  DateTime _endtime;

  TextEditingController itemController;
  TextEditingController starttimeController;
  TextEditingController endtimeController;
  TextEditingController workperfrmController;
  MaskedTextController hoursController;
  FocusNode wrkperfrmFocusNode;
  FocusNode hoursFocusNode;

  @override
  void initState() {
    super.initState();
    wrkperfrmFocusNode = FocusNode();
    hoursFocusNode = FocusNode();
    itemController = TextEditingController();
    starttimeController = TextEditingController();
    endtimeController = TextEditingController();
    workperfrmController = TextEditingController();
    hoursController = MaskedTextController(mask: '00:00');

    itemController.text = task.item;
    starttimeController.text =
        task.starttime != null ? format.format(task.starttime).toString() : '';
    endtimeController.text =
        task.endtime != null ? format.format(task.endtime).toString() : '';
    workperfrmController.text = task.workperformed;
    hoursController.text = task.hours;
    _starttime = task.starttime != null ? task.starttime : null;
    _endtime = task.endtime != null ? task.endtime : null;
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    wrkperfrmFocusNode.dispose();
    hoursFocusNode.dispose();
    itemController.dispose();
    starttimeController.dispose();
    endtimeController.dispose();
    workperfrmController.dispose();
    hoursController.dispose();
    super.dispose();
  }

  bool _validate = false;
  bool _validateendtime = false;
  bool _validatestarttime = false;
  bool _hrsEnable = false;

  _ReportDetail2(this.task, this.appBarTitle, this.reportid);

  final format = DateFormat("yyyy-MM-dd HH:mm");

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
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
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
                textInputAction: TextInputAction.next,
                controller: itemController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Something changed in Item Text Field');
                  updateItem();
                },
                decoration: InputDecoration(
                    labelText: 'ID',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
              child: DateTimeField(
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
                readOnly: true,
                controller: starttimeController,
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2019),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          currentValue ?? DateTime.now()),
                    );
                    return DateTimeField.combine(date, time);
                  } else {
                    return currentValue;
                  }
                },
                format: format,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  errorText: _validatestarttime
                      ? 'Work start time cannot be empty '
                      : null,
                  hintText: 'HH:MM',
                  icon: Icon(Icons.date_range),
                ),
                onChanged: (value) {
                  setState(() {
                    _starttime = value;
                    updateStartTime(value);
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
              child: DateTimeField(
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
                controller: endtimeController,
                format: format,
                readOnly: true,
                enabled: starttimeController.text.length > 0,
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                      context: context,
                      firstDate:
                          _starttime != null ? _starttime : DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          currentValue ?? DateTime.now()),
                    );
                    return DateTimeField.combine(date, time);
                  } else {
                    return currentValue;
                  }
                },
                decoration: InputDecoration(
                  errorText: _validateendtime
                      ? 'Work end time cannot be empty '
                      : null,
                  labelText: 'End Time',
                  hintText: 'HH:MM',
                  icon: Icon(Icons.date_range),
                ),
                onChanged: (dt) {
                  setState(() {
                    _endtime = dt;
                    updateEndTime(dt);
                  });
                },
              ),
            ),
            // Third Element - Work Performed
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],

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
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
                enabled: _hrsEnable,
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
                    errorText:
                        _validate ? 'Hours can\'t be zero or less ' : null,
                    hintText: '00\:00',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.save),
        label: Text('Save'),
        tooltip: "Save task performed",
        onPressed: () async {
          await _save(reportid);
        },
      ),
    );
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  Future<void> _save(String reportid) async {
    if (!(starttimeController.text.length > 0 && _starttime != null)) {
      setState(() {
        _validatestarttime = true;
      });

      return;
    }
    if (!(endtimeController.text.length > 0 && _endtime != null)) {
      setState(() {
        _validateendtime = true;
      });

      return;
    }
    if (!(_validate)) {
      task.reportid = reportid;
      int result = 0;
      if (task.id != null) {
        // Case 1: Update operation
        result = await widget.helper.updateTask(task);
      } else {
        // Case 2: Insert Operation
        if (task.item.length > 0) {
          task.date = DateFormat('yyyy-MM-dd h:m:ss').format(DateTime.now());
          result = await widget.helper.insertTask(task);
        }
      }

      if (result != 0) {
        // Success
        String message = 'Task added To ' + reportid.toString();
        if (appBarTitle == 'Edit Item')
          message = 'Task Updated To ' + reportid.toString();
        print(message);
      } else {
        // Failure
        // _showAlertDialog(
        //     'SPM Connect', 'Problem Saving Task To ' + reportid.toString());
      }
      movetolastscreen();
    }
  }

// Update the project no.
  void updateItem() {
    task.item = itemController.text;
  }

  // Update the customer namme of Note object
  void updateStartTime(DateTime startime) {
    // task.starttime = starttimeController.text;
    task.starttime = startime;
    calculateHours();
  }

  void updateEndTime(DateTime endtime) {
    task.endtime = endtime;
    // task.endtime = endtimeController.text;
    calculateHours();
  }

  void calculateHours() {
    if (_starttime != null && _endtime != null) {
      final difference = _endtime.difference(_starttime).inMinutes;
      int hours = difference ~/ 60;
      int minutes = difference % 60;
      String _hours = hours.toString();
      String _mins = minutes.toString();
      if (hours >= 0 && hours < 10) {
        _hours = '0' + hours.toString();
      }
      if (minutes > 0 && minutes < 10) {
        _mins = '0' + minutes.toString();
      }
      if (minutes == 0) {
        _mins = '00';
      }
      if (hours <= 0) {
        _hours = '00';
      }
      if (minutes == 0 && hours == 0) {
        _hrsEnable = true;
        _validate = true;
      } else {
        _validate = false;
        _hrsEnable = false;
      }
      hoursController.text = '$_hours:$_mins';
      updateHours();
    }
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
