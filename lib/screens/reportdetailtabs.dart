import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/report_detail_pg1.dart';
import 'package:spmconnectapp/screens/task_list.dart';
import 'package:spmconnectapp/screens/report_detail_pg3.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:intl/intl.dart';

class ReportDetTab extends StatefulWidget {
  final String appBarTitle;
  final Report report;

  ReportDetTab(this.report, this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetTabState(this.report, this.appBarTitle);
  }
}

class _ReportDetTabState extends State<ReportDetTab> {
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Report report;
  _ReportDetTabState(this.report, this.appBarTitle);
  int _selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [
      ReportDetail(report),
      TaskList(report.projectno),
      ReportDetail3(report),
    ];
    //TextStyle textStyle = Theme.of(context).textTheme.title;
    return  Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle + ' - ' + report.projectno),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _save();
              //Navigator.pop(context,true);
            },
          ),
        ),
        body: _children[_selectedTab],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (int index) {
            setState(() {
              _selectedTab = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              title: Text('Customer'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes),
              title: Text('Tasks'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.done),
              title: Text('Comments/Approval'),
            ),
          ],
        ),
      );    
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  void _save() async {
    movetolastscreen();
    report.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (report.id != null) {
      // Case 1: Update operation
      result = await helper.updateReport(report);
    } else {
      // Case 2: Insert Operation
      result = await helper.inserReport(report);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('SPM Connect', 'Report Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('SPM Connect', 'Problem Saving Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
