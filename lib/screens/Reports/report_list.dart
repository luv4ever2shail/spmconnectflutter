import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/Resource/images_repository.dart';
import 'package:spmconnectapp/Resource/reports_repository.dart';
import 'package:spmconnectapp/Resource/tasks_repository.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/Reports/report_preview.dart';
import 'package:spmconnectapp/screens/home.dart';
import 'package:spmconnectapp/screens/Reports/reportdetailtabs.dart';

class ReportList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportList();
  }
}

class _ReportList extends State<ReportList> with TickerProviderStateMixin {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Box _box;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  String empId;

  AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    animationController..forward();
    _box = Hive.box('myBox');
    super.initState();
    getUserInfoSF();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyReports myReports = Provider.of<MyReports>(context);
    ReportTasks reportTasks = Provider.of<ReportTasks>(context);
    ReportImages reportImages = Provider.of<ReportImages>(context);
    return Scaffold(
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
        onRefresh: () => _handleRefresh(myReports),
        child: getReportListView(
          myReports.getReports,
          myReports,
          animationController,
          reportTasks,
          reportImages,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (empId != null) {
            debugPrint('FAB clicked');
            //getReportmapId();
            await myReports.setReportMapId(0);
            await myReports.fetchReportmapId();
            int mapid = 0;
            if (myReports.getCount == 0) {
              mapid = 1001;
            } else {
              if (myReports.getReportMapId.toString().length > 3 &&
                  myReports.getReportMapId != 0)
                mapid = myReports.getReportMapId + 1;
              else
                return;
            }
            navigateToDetail(
              Report(
                  '$empId${mapid.toString()}',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  mapid,
                  0,
                  0,
                  '',
                  '',
                  '',
                  '',
                  ''),
              'Add New Report',
              myReports,
              databaseHelper,
              reportTasks,
              reportImages,
            );
          } else {
            _showAlertDialog('Employee Id not found',
                'Please contact the admin to have your employee id setup in order to create service reports.');
          }
        },
        tooltip: 'Create New Report',
        icon: Icon(Icons.add),
        label: Text('Create New Report'),
      ),
    );
  }

  Widget getReportListView(
    List<Report> reportlist,
    MyReports myReports,
    AnimationController animationController,
    ReportTasks reportTasks,
    ReportImages reportImages,
  ) {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: animationController,
              child: new Transform(
                  transform: new Matrix4.translationValues(
                      0.0, 40 * (1.0 - animationController.value), 0.0),
                  child: ListView.builder(
                    itemCount: reportlist.length,
                    itemBuilder: (BuildContext context, int position) {
                      return Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Card(
                          elevation: 10.0,
                          child: ListTile(
                            isThreeLine: true,
                            leading: CircleAvatar(
                              backgroundColor:
                                  reportlist[position].reportsigned == 0
                                      ? Colors.blue
                                      : Colors.green,
                              child: Icon(
                                Icons.receipt,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              'Report No - ' + reportlist[position].reportno,
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .apply(fontSizeFactor: 1.5),
                            ),
                            subtitle: Text(
                              'Project - ' +
                                  reportlist[position].projectno +
                                  " ( " +
                                  reportlist[position].customer +
                                  ' )' +
                                  '\nCreated On (' +
                                  reportlist[position].date +
                                  ')',
                              style: titleStyle,
                            ),
                            trailing: GestureDetector(
                              child: reportlist[position].reportsigned == 0 ||
                                      empId == '73'
                                  ? Icon(
                                      Icons.delete,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : reportlist[position].reportpublished == 0
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
                                _neverSatisfied(context, position,
                                    myReports.getReports, myReports);
                              },
                            ),
                            onTap: () {
                              debugPrint("ListTile Tapped");
                              navigateToDetail(
                                reportlist[position],
                                'Edit Report',
                                myReports,
                                databaseHelper,
                                reportTasks,
                                reportImages,
                              );
                            },
                            onLongPress: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ReportPreview(reportlist[position]);
                              }));
                            },
                          ),
                        ),
                      );
                    },
                  )));
        });
  }

  Future<Null> _handleRefresh(MyReports myReports) async {
    refreshKey.currentState?.show(atTop: false);
    await new Future.delayed(new Duration(seconds: 1));
    await myReports.fetchReports();
    return null;
  }

  void movetolastscreen() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Myhome(null);
    }));
  }

  Future<void> _delete(Report report, MyReports myReports) async {
    int result = await databaseHelper.deleteReport(report.id);
    if (result != 0) {
      debugPrint('deleted report');
      // updateListView();
      await myReports.fetchReports();
      await myReports.setReportMapId(0);
      await myReports.fetchReportmapId();
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

  void navigateToDetail(
    Report report,
    String title,
    MyReports myReports,
    DatabaseHelper helper,
    ReportTasks reportTasks,
    ReportImages reportImages,
  ) async {
    await reportTasks.fetchTasks(report.reportno);
    await reportImages.fetchImages(report.reportno);
    if (report.reportsigned == 1 && empId != '73') {
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ReportPreview(report);
      }));
    } else {
      bool result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ReportDetTab(report, title, helper);
      }));
      if (result == true) {
        await myReports.fetchReports();
      }
      await myReports.fetchReportmapId();
    }
  }

  Future<void> _neverSatisfied(BuildContext contex, int position,
      List<Report> reportlist, MyReports myReports) async {
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
                _delete(reportlist[position], myReports);
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
    setState(() {
      empId = _box.get('EmpId');
    });
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
