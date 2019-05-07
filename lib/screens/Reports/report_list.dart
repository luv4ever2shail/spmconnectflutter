import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spmconnectapp/screens/Reports/reportdetailtabs.dart';
import 'package:flushbar/flushbar.dart';

class ReportList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportList();
  }
}

class _ReportList extends State<ReportList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Report> reportlist;
  List<Report> reportmapid;
  int count = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  String userId;

  @override
  void initState() {
    super.initState();
    getUserInfoSF();
  }

  @override
  Widget build(BuildContext context) {
    if (reportlist == null) {
      reportlist = List<Report>();
      updateListView();
    }

    if (reportmapid == null) {
      reportmapid = List<Report>();
      getReportmapId();
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
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _handleRefresh,
          child: getReportListView(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            debugPrint('FAB clicked');
            getReportmapId();
            int mapid = 0;
            if (count == 0) {
              mapid = 1001;
            } else {
              mapid = reportmapid[0].reportmapid + 1;
            }
            navigateToDetail(Report('', '', '', '', '', '', '', '', mapid, 0),
                'Add New Report');
          },
          tooltip: 'Create New Report',
          icon: Icon(Icons.add),
          label: Text('Create New Report'),
        ),
      ),
    );
  }

  ListView getReportListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Padding(
          padding: EdgeInsets.all(5.0),
          child: Card(
            elevation: 10.0,
            child: ListTile(
              isThreeLine: true,
              leading: CircleAvatar(
                child: Icon(Icons.receipt),
              ),
              title: Text(
                'Report No - ' +
                    this.reportlist[position].reportmapid.toString(),
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 1.5),
              ),
              subtitle: Text(
                'Project - ' +
                    this.reportlist[position].projectno +
                    " ( " +
                    this.reportlist[position].customer +
                    ' )' +
                    '\nCreated On (' +
                    this.reportlist[position].date +
                    ')',
                style: titleStyle,
              ),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  size: 40,
                  color: Colors.grey,
                ),
                onTap: () {
                  //_delete(context, reportlist[position]);
                  _neverSatisfied(
                    position,
                  );
                },
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                navigateToDetail(this.reportlist[position], 'Edit Report');
              },
            ),
          ),
        );
      },
    );
  }

  Future<Null> _handleRefresh() async {
    refreshKey.currentState?.show(atTop: false);
    await new Future.delayed(new Duration(seconds: 1));
    updateListView();
    return null;
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  void _delete(BuildContext context, Report report) async {
    int result = await databaseHelper.deleteReport(report.id);
    if (result != 0) {
      debugPrint('deleted report');
      updateListView();
      reportmapid.clear();
      getReportmapId();
    }
    int result2 = await databaseHelper.deleteAllTasks(report.reportmapid);
    if (result2 != 0) {
      debugPrint('deleted all tasks');
    }
  }

  void navigateToDetail(Report report, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportDetTab(report, title);
    }));
    if (result == true) {
      updateListView();
    }
    getReportmapId();
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

  void getReportmapId() {
    Future<List<Report>> reportListFuture = databaseHelper.getNewreportid();
    reportListFuture.then((reportlist) {
      setState(() {
        this.reportmapid = reportlist;
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
                _delete(context, reportlist[position]);
                Navigator.of(context).pop();
                Flushbar(
                  title: "Report Deleted Successfully",
                  message: "All tasks associated with report got trashed.",
                  duration: Duration(seconds: 3),
                  icon: Icon(
                    Icons.delete_forever,
                    size: 28.0,
                    color: Colors.red,
                  ),
                  aroundPadding: EdgeInsets.all(8),
                  borderRadius: 8,
                  leftBarIndicatorColor: Colors.red,
                ).show(context);
              },
            ),
          ],
        );
      },
    );
  }

  getUserInfoSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('Id');
    setState(() {});
  }
}
