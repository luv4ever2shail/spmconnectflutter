import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/Reports/report_preview.dart';
import 'package:spmconnectapp/screens/home.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spmconnectapp/screens/Reports/reportdetailtabs.dart';

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
  String empId;
  String sfEmail;
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
            if (empId != null) {
              debugPrint('FAB clicked');
              getReportmapId();
              int mapid = 0;
              if (count == 0) {
                mapid = 1001;
              } else {
                mapid = reportmapid[0].reportmapid + 1;
              }
              navigateToDetail(
                  Report('$empId${mapid.toString()}', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', mapid, 0, 0),
                  'Add New Report');
            } else {
              _showAlertDialog('Employee Id not found',
                  'Please contact the admin to have your employee id setup in order to create service reports.');
            }
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
                backgroundColor: this.reportlist[position].reportsigned == 0
                    ? Colors.blue
                    : Colors.green,
                child: Icon(
                  Icons.receipt,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Report No - ' + this.reportlist[position].reportno,
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
                child: this.reportlist[position].reportsigned == 0 ||
                        sfEmail == 'shail@spm-automation.com'
                    ? Icon(
                        Icons.delete,
                        size: 40,
                        color: Colors.grey,
                      )
                    : this.reportlist[position].reportpublished == 0
                        ? SizedBox(
                            width: 1,
                            height: 1,
                          )
                        : Icon(
                            Icons.check_circle,
                            size: 40,
                            color: Colors.green,
                          ),
                onTap: () {
                  _neverSatisfied(
                    context,
                    position,
                  );
                },
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                navigateToDetail(this.reportlist[position], 'Edit Report');
              },
              onLongPress: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return ReportPreview(this.reportlist[position]);
                }));
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

  void movetolastscreen() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Myhome(null);
    }));
  }

  Future<void> _delete(Report report) async {
    int result = await databaseHelper.deleteReport(report.id);
    if (result != 0) {
      debugPrint('deleted report');
      updateListView();
      reportmapid.clear();
      getReportmapId();
    }
    int result2 = await databaseHelper.deleteAllTasks(report.reportno);
    if (result2 != 0) {
      debugPrint('deleted all tasks');
    }
    int result3 = await databaseHelper.deleteAllImages(report.reportno);
    if (result3 != 0) {
      debugPrint('deleted all image references');
    }
  }

  void navigateToDetail(Report report, String title) async {
    if (report.reportsigned == 1 && sfEmail != 'shail@spm-automation.com') {
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ReportPreview(report);
      }));
    } else {
      bool result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ReportDetTab(report, title);
      }));
      if (result == true) {
        updateListView();
      }
      getReportmapId();
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

  void getReportmapId() {
    Future<List<Report>> reportListFuture = databaseHelper.getNewreportid();
    reportListFuture.then((reportlist) {
      setState(() {
        this.reportmapid = reportlist;
      });
    });
  }

  Future<void> _neverSatisfied(BuildContext contex, int position) async {
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
                _delete(reportlist[position]);
                Scaffold.of(contex).showSnackBar(SnackBar(
                  content: Text("Report Deleted Successfully."),
                ));
              },
            ),
          ],
        );
      },
    );
  }

  getUserInfoSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    empId = prefs.getString('EmpId');
    sfEmail = prefs.getString('Email');
    setState(() {});
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
