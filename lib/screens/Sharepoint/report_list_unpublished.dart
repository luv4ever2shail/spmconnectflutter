import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharepoint_auth/model/config.dart';
import 'package:sharepoint_auth/sharepoint_auth.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ReportListUnpublished extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportListUnpublishedState();
  }
}

class _ReportListUnpublishedState extends State<ReportListUnpublished> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Report> reportlist;
  List<Tasks> tasklist;
  int reportcount = 0;
  int taskcount = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _saving = false;
  int listreportcount = 0;
  int listtaskcount = 0;
  String empName;

  static final SharepointConfig _config = new SharepointConfig(
      Apikeys.sharepointClientId,
      Apikeys.sharepointClientSecret,
      Apikeys.sharepointResource,
      Apikeys.sharepointSite,
      Apikeys.sharepointTenanttId);

  final Sharepointauth restapi = Sharepointauth(_config);
  String accessToken;

  @override
  void initState() {
    super.initState();
    _saving = true;
    getSharepointToken();
    getUserInfoSF();
  }

  @override
  Widget build(BuildContext context) {
    if (reportlist == null) {
      reportlist = List<Report>();
      updateReportListView();
      updateTaskListView();
    }

    return WillPopScope(
      onWillPop: () {
        movetolastscreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload Service Reports'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              movetolastscreen();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.sync,
                color: Colors.white,
                size: 38,
              ),
              onPressed: () async {
                await synctasks();
              },
            )
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: RefreshIndicator(
            key: refreshKey,
            onRefresh: _handleRefresh,
            child: getReportListView(),
          ),
        ),
      ),
    );
  }

  Future<void> synctasks() async {
    if (accessToken == null) {
      _showAlertDialog('SPM Connect',
          'Error occured while trying to sync data to cloud. Please check your network connections.');
      return;
    }
    if (taskcount > 0) {
      print('No of tasks found to be uploaded : $taskcount');
      print('sync started for tasks');
      setState(() {
        listtaskcount = taskcount;
        _saving = true;
      });
      for (final i in tasklist) {
        await postTasksToSharepoint(
            i, accessToken, getTaskToJSON(i), taskcount);
      }
    }
    if (_saving) {
      if (reportcount > 0) {
        print('sync started for reports');
        setState(() {
          listreportcount = reportcount;
          _saving = true;
        });
        for (final i in reportlist) {
          await postReportsToSharepoint(
              i, accessToken, getReportToJSON(i), reportcount);
        }
      }
    }
  }

  ListView getReportListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: reportcount,
      itemBuilder: (BuildContext context, int position) {
        return Padding(
          padding: EdgeInsets.all(5.0),
          child: Card(
            elevation: 10.0,
            child: ListTile(
              isThreeLine: true,
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.receipt,
                  color: Colors.white,
                ),
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
            ),
          ),
        );
      },
    );
  }

  Future<Null> _handleRefresh() async {
    refreshKey.currentState?.show(atTop: false);
    await new Future.delayed(new Duration(seconds: 1));
    updateReportListView();
    return null;
  }

  void movetolastscreen() {
    removeSharepointToken();
    Navigator.pop(context, true);
  }

  Future<void> updateReportListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    await dbFuture.then((database) {
      Future<List<Report>> reportListFuture =
          databaseHelper.getReportListUnpublished();
      reportListFuture.then((reportlist) {
        setState(() {
          this.reportlist = reportlist;
          this.reportcount = reportlist.length;
        });
        if (listreportcount <= 0) {
          setState(() {
            listreportcount = 0;
            _saving = false;
          });
        }
      });
    });
  }

  Future<void> updateTaskListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    await dbFuture.then((database) {
      Future<List<Tasks>> taskListFuture =
          databaseHelper.getTaskListUnpublished();
      taskListFuture.then((tasklist) {
        setState(() {
          this.tasklist = tasklist;
          this.taskcount = tasklist.length;
        });
        if (listreportcount <= 0) {
          print('finished syncing all tasks');
        }
      });
    });
  }

  String getReportToJSON(Report report) {
    String reporttojson =
        ('{"__metadata": { "type": "SP.Data.ConnectReportBaseListItem" },"Title": "${report.reportno}","ReportMapId": "${report.reportmapid}","Report_Id": "${report.id}",'
            '"ProjectNo": "${report.projectno}","Customer": "${report.customer}","PlantLoc": "${report.plantloc}","ContactName": "${report.contactname}",'
            '"Authorizedby": "${report.authorby}","Equipment": "${report.equipment}","TechName": "${report.techname}","DateCreated": "${report.date}",'
            '"FurtherActions": "${report.furtheractions}","CustComments": "${report.custcomments}","CustRep": "${report.custrep}","CustEmail": "${report.custemail}",'
            '"CustContact": "${report.custcontact}","Published": "${report.reportpublished}","Signed": "${report.reportsigned}","Uploadedby": "$empName"}');
    // print(reporttojson);
    return reporttojson;
  }

  String getTaskToJSON(Tasks task) {
    String tasktojson =
        ('{"__metadata": { "type": "SP.Data.ConnectTasksListItem" },"Title": "${task.reportid - task.id}","ReportId": "${task.reportid}","Taskid": "${task.id}",'
            '"ItemNo": "${task.item}","Starttime": "${task.starttime}","Endtime": "${task.endtime}","Hours": "${task.hours}",'
            '"WorkPerformed": "${task.workperformed}","Datecreated": "${task.date}","Uploadedby": "$empName"}');
    //print(tasktojson);
    return tasktojson;
  }

  void getSharepointToken() async {
    await restapi.login();
    accessToken = await restapi.getAccessToken();
    print('Access Token Sharepoint $accessToken');
  }

  void removeSharepointToken() async {
    await restapi.logout();
  }

  Future<void> postReportsToSharepoint(
      Report report, String accesstoken, var _body, int count) async {
    try {
      print('post started : list value $listreportcount');

      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('ConnectReportBase')/items"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Content-Type": "application/json;odata=verbose",
            "Accept": "application/json"
          },
          body: _body);

      print(response.statusCode);
      print('started');
      if (response.statusCode == 201) {
        await _saveReport(report);
      } else {
        setState(() {
          _saving = false;
        });
      }
      print('ended');
    } catch (e) {
      print(e);
    }
  }

  Future<void> postTasksToSharepoint(
      Tasks task, String accesstoken, var _body, int count) async {
    try {
      print('post started : list value $listtaskcount');

      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('ConnectTasks')/items"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Content-Type": "application/json;odata=verbose",
            "Accept": "application/json"
          },
          body: _body);

      print(response.statusCode);
      print('started');
      if (response.statusCode == 201) {
        await _saveTask(task);
      } else {
        setState(() {
          _saving = false;
        });
      }
      print('ended');
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveReport(Report report) async {
    int result;
    if (report.id != null) {
      report.reportpublished = 1;
      result = await databaseHelper.updateReport(report);
    }
    if (result != 0) {
      listreportcount--;
      print(listreportcount);
      print('Success Saving');
      updateReportListView();
    } else {
      print('failure saving report');
    }
  }

  Future<void> _saveTask(Tasks task) async {
    int result;
    if (task.id != null) {
      task.published = 1;
      result = await databaseHelper.updateTask(task);
    }
    if (result != 0) {
      listtaskcount--;
      print(listtaskcount);
      print('Success Saving task');
      updateTaskListView();
    } else {
      print('failure saving task');
    }
  }

  getUserInfoSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    empName = prefs.getString('Name');
    setState(() {});
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
