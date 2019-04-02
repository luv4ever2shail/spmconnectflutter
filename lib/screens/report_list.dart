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
    return Scaffold(
      appBar: AppBar(
        title: Text('SPM Connect Service Reports'),
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
                _delete(context, reportlist[position]);
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

  void _delete(BuildContext context, Report report) async {
    int result = await databaseHelper.deleteReport(report.id);
    if (result != 0) {
      _showSnackBar(context, 'Report Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

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
  
}
