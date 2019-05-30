import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharepoint_auth/model/config.dart';
import 'package:sharepoint_auth/sharepoint_auth.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flare_flutter/flare_actor.dart';

const directoryName = 'Connect_Signatures';

class ReportListUnpublished extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportListUnpublishedState();
  }
}

class _ReportListUnpublishedState extends State<ReportListUnpublished> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Report> reportlist;
  List<Tasks> tasklist;
  int reportcount = 0;
  int taskcount = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _saving = false;
  int listreportcount = 0;
  int listtaskcount = 0;
  String path = '';
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
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    loadDocument();
    getUserInfoSF();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
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
          ),
          body: ModalProgressHUD(
            inAsyncCall: _saving,
            child: RefreshIndicator(
              key: refreshKey,
              onRefresh: _handleRefresh,
              child: _connectionStatus == 'ConnectivityResult.none'
                  ? FlareActor(
                      "assets/no_wifi.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: 'Untitled',
                    )
                  : getReportListView(),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _connectionStatus != 'ConnectivityResult.none'
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    setState(() {
                      _saving = true;
                    });
                    await synctasks();
                  },
                  tooltip: 'Sync reports to cloud',
                  icon: Icon(
                    Icons.sync,
                    color: Colors.white,
                  ),
                  label: Text('Sync Reports'),
                )
              : Offstage()),
    );
  }

  Future<void> synctasks() async {
    if (reportcount > 0) {
      await getSharepointToken();
      if (accessToken == null) {
        _showAlertDialog('SPM Connect',
            'Unable to retrieve access token. Please check your network connections.');
        setState(() {
          _saving = false;
        });
        return;
      }

      if (taskcount > 0) {
        print('No of tasks found to be uploaded : $taskcount');
        print('sync started for tasks');
        listtaskcount = taskcount;
        for (final i in tasklist) {
          await postTasksToSharepoint(
              i, accessToken, getTaskToJSON(i), taskcount);
        }
      }
      if (_saving) {
        if (reportcount > 0) {
          print('sync started for reports');
          listreportcount = reportcount;
          for (final i in reportlist) {
            await postReportsToSharepoint(
                i, accessToken, getReportToJSON(i), reportcount);
          }
        }
      }
    } else {
      setState(() {
        _saving = false;
      });
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
    //removeSharepointToken();
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
            '"ProjectNo": "${report.projectno}","Customer": "${report.customer.replaceAll('"', '\\"')}","PlantLoc": "${report.plantloc.replaceAll('"', '\\"')}","ContactName": "${report.contactname.replaceAll('"', '\\"')}",'
            '"Authorizedby": "${report.authorby.replaceAll('"', '\\"')}","Equipment": "${report.equipment.replaceAll('"', '\\"')}","TechName": "${report.techname.replaceAll('"', '\\"')}","DateCreated": "${report.date}",'
            '"FurtherActions": "${report.furtheractions == null ? '' : report.furtheractions.replaceAll('"', '\\"')}","CustComments": "${report.custcomments == null ? '' : report.custcomments.replaceAll('"', '\\"')}","CustRep": "${report.custrep == null ? '' : report.custrep.replaceAll('"', '\\"')}","CustEmail": "${report.custemail == null ? '' : report.custemail.replaceAll('"', '\\"')}",'
            '"CustContact": "${report.custcontact}","Published": "${report.reportpublished}","Signed": "${report.reportsigned}","Uploadedby": "$empName"}');
    // print(reporttojson);
    return reporttojson;
  }

  String getTaskToJSON(Tasks task) {
    String tasktojson =
        ('{"__metadata": { "type": "SP.Data.ConnectTasksListItem" },"Title": "${task.reportid} - ${task.id}","ReportId": "${task.reportid}","Taskid": "${task.id}",'
            '"ItemNo": "${task.item.replaceAll('"', '\\"')}","Starttime": "${task.starttime}","Endtime": "${task.endtime}","Hours": "${task.hours}",'
            '"WorkPerformed": "${task.workperformed == null ? '' : task.workperformed.replaceAll('"', '\\"')}","Datecreated": "${task.date}","Uploadedby": "$empName"}');
    //print(tasktojson);
    return tasktojson;
  }

  Future<void> getSharepointToken() async {
    await restapi.login();
    accessToken = await restapi.getAccessToken();
    //print('Access Token Sharepoint $accessToken');
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
      Map<String, dynamic> resJson = json.decode(response.body);
      print('Token Type : ' + resJson["Id"].toString());
      if (response.statusCode == 201) {
        print(path);
        File file = File('$path${report.reportmapid.toString()}.png');
        print(file);
        int result =
            await postAttachment(resJson["Id"].toString(), accesstoken, file);
        if (result != 0) {
          await _saveReport(report);
        } else {
          _showAlertDialog('SPM Connect',
              'Error occured while trying to sync signature png to cloud.');
        }
      } else {
        _showAlertDialog('SPM Connect',
            'Error occured while trying to sync Reports to cloud.');
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
        _showAlertDialog('SPM Connect',
            'Error occured while trying to sync Tasks to cloud.');
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
      _showAlertDialog(
          'SPM Connect', 'Error occured saving Report to database.');
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
      _showAlertDialog('SPM Connect', 'Error occured saving Task to database.');
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
      actions: <Widget>[
        FlatButton(
          child: Text(''),
          onPressed: () {},
        )
      ],
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future<int> postAttachment(String id, String accesstoken, File file) async {
    try {
      String fileName = file.path.split("/").last;
      print(fileName);
      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('ConnectReportBase')/items($id)/AttachmentFiles/ add(FileName='$fileName')"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Accept": "application/json"
          },
          body: file.readAsBytesSync());
      print(response.statusCode);
      return response.statusCode;
    } catch (e) {
      print(e);
    }
    return 0;
  }

  Future loadDocument() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String _path = directory.path;
      print("$_path/$directoryName/");
      path = "$_path/$directoryName/";
    } catch (e) {
      print(e);
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          wifiName = await _connectivity.getWifiName();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          wifiBSSID = await _connectivity.getWifiBSSID();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }
}
