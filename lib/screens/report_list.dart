import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/report_detail.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ReportList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportList();
  }
}

class _ReportList extends State<ReportList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Report> reportlist;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (reportlist == null) {
      reportlist = List<Report>();
      updateListView();
    }
    return WillPopScope(
      onWillPop: () {
        movetolastscreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('SPM Connect Service Reports'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              movetolastscreen();
            },
          ),
        ),
        body: getReportListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('FAB clicked');
            navigateToDetail(
                Report('', '', '', '', '', '', '', ''), 'Add New Report');
          },
          tooltip: 'Create New Report',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  ListView getReportListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            title: Text(
              this.reportlist[position].projectno +
                  " - " +
                  this.reportlist[position].customer,
              style: titleStyle,
            ),
            subtitle: Text(
              this.reportlist[position].date,
              style: titleStyle,
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                //_delete(context, reportlist[position]);
                _neverSatisfied(position);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.reportlist[position], 'Edit Report');
            },
          ),
        );
      },
    );
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  void _delete(BuildContext context, Report report) async {
    await databaseHelper.deleteReport(report.id);
    // if (result != 0) {
    //   debugPrint('delete cleared');
    //   _showSnackBar(context, 'Report Deleted Successfully');
    //   updateListView();
    // }
  }

  // void _showSnackBar(BuildContext context, String message) {
  //   final snackBar = SnackBar(content: Text(message));
  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  void navigateToDetail(Report report, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportDetail(report, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Report>> reportListFuture = databaseHelper.getReportList();
      reportListFuture.then((reportlist) {
        setState(() {
          this.reportlist = reportlist;
          this.count = reportlist.length;
        });
      });
    });
  }

  Future<void> _neverSatisfied(int position) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete report?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure want to discard this report?')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Discard'),
              onPressed: () {
                Navigator.of(context).pop();
                _delete(context, reportlist[position]);
                updateListView();
              },
            ),
          ],
        );
      },
    );
  }
}
