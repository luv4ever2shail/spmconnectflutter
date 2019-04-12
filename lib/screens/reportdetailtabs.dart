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
  PageController controller = PageController();
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        movetolastscreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle + ' - ' + report.reportmapid.toString()),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              movetolastscreen();
            },
          ),
        ),
        body: PageView(
          controller: controller,
          children: <Widget>[
             ReportDetail(report),
             TaskList(report.reportmapid),
             ReportDetail3(report),
          ],
          onPageChanged: (int index){
             if (report.projectno.length == 0 && index == 1) {
              _showAlertDialog('Project No', 'Cant be Empty');
              controller.jumpToPage(0);              
            } else {
              if (index == 1)
                this.appBarTitle = 'Edit Tasks';
              else if (index == 0) this.appBarTitle = 'Edit Report';
            }
          },
        ),
      ),
    );
  }

  void movetolastscreen() {
    _save();
    Navigator.pop(context, true);
  }

  void _save() async {
    //movetolastscreen();

    int result;
    if (report.id != null) {
      // Case 1: Update operation
      result = await helper.updateReport(report);
    } else {
      // Case 2: Insert Operation
      if (report.projectno.length > 0) {
        report.date = DateFormat('yyyy-MM-dd h:m:ss').format(DateTime.now());
        result = await helper.inserReport(report);
      }
    }
    if (result != 0) {
      // Success
      // _showAlertDialog('SPM Connect', 'Report Saved Successfully');
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
