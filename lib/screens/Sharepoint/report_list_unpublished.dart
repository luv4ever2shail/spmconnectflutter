import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharepoint_auth/model/config.dart';
import 'package:sharepoint_auth/sharepoint_auth.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/models/images.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:spmconnectapp/utils/progress_dialog.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flare_flutter/flare_actor.dart';

const directoryName = 'Connect_Signatures';
ProgressDialog pr;

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
  List<Images> imagelist;
  int reportcount = 0;
  int taskcount = 0;
  int imagecount = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _saving = false;
  int listreportcount = 0;
  int listtaskcount = 0;
  int listimagecount = 0;
  String path = '';
  String empName;
  var percentage = 0.0;
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
      tasklist = List<Tasks>();
      imagelist = List<Images>();
      updateReportListView();
    }

    return WillPopScope(
      onWillPop: () async {
        if (!_saving) {
          movetolastscreen();
        }
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Upload Service Reports'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                if (!_saving) {
                  movetolastscreen();
                }
                return false;
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
                  : reportcount > 0
                      ? getReportListView()
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                                'All Reports are synced to sharepoint. No Reports found to be synced to sharepoint.'),
                          ),
                        ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _connectionStatus != 'ConnectivityResult.none'
              ? reportcount > 0
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
                  : Offstage()
              : Offstage()),
    );
  }

  Future<void> synctasks() async {
    if (reportcount > 0) {
      pr = new ProgressDialog(context, ProgressDialogType.Download);
      pr.setMessage('Access Token...');
      pr.show();

      await getSharepointToken();
      if (accessToken == null) {
        _showAlertDialog('SPM Connect',
            'Unable to retrieve access token. Please check your network connections.');
        setState(() {
          _saving = false;
        });
        return;
      }
      percentage += 10.0;
      pr.update(
          progress: percentage.roundToDouble(), message: 'Access Token...');

      if (_saving) {
        if (reportcount > 0) {
          print('No of reports found to be uploaded : $reportcount');
          listreportcount = reportcount;

          pr.update(
              progress: percentage.roundToDouble(),
              message: 'Uploading Report..');
          await Future.delayed(Duration(seconds: 1));

          pr.update(
              progress: percentage.roundToDouble(),
              message: 'Report Count $reportcount');
          await Future.delayed(Duration(seconds: 1));

          for (final i in reportlist) {
            percentage += 10.0 / reportcount;
            pr.update(
                progress: percentage.roundToDouble(),
                message: 'Report ${i.reportno}');
            await Future.delayed(Duration(seconds: 2));

            listtaskcount = 0;
            tasklist.clear();
            await updateTaskListView(i.reportno);

            print(
                'No of task found in report ${i.reportno} to be uploaded is $taskcount');

            pr.update(
                progress: percentage.roundToDouble(),
                message: 'Task Count $taskcount');
            await Future.delayed(Duration(seconds: 1));

            var taskpercent = 0.0;
            taskpercent = 25 / reportcount;
            if (taskcount > 0) {
              listtaskcount = taskcount;
              for (final i in tasklist) {
                print(
                    'Uploading task ${tasklist.indexOf(i) + 1} for report ${i.reportid}');
                percentage += taskpercent / taskcount;
                pr.update(
                    progress: percentage.roundToDouble(),
                    message: 'Task No. ${tasklist.indexOf(i) + 1}');
                await postTasksToSharepoint(
                    i, accessToken, getTaskToJSON(i), taskcount);
              }
            }

            pr.update(
                progress: percentage.roundToDouble(),
                message: 'Tasks Uploaded');

            listimagecount = 0;
            imagelist.clear();

            await updateImagesListView(i.reportno);
            print(
                'No of images found in report ${i.reportno} to be uploaded is $imagecount');

            await postReportsToSharepoint(
                i, accessToken, getReportToJSON(i), reportcount);
          }
        }
      }
      await closeUpload();
    } else {
      setState(() {
        _saving = false;
      });
    }
  }

  Future<void> closeUpload() async {
    reportlist.clear();
    reportcount = 0;
    tasklist.clear();
    taskcount = 0;
    imagelist.clear();
    imagecount = 0;
    await updateReportListView();
    print('No reports found to be uploaded : $reportcount');
    percentage = 0.0;
    pr.update(progress: percentage.roundToDouble(), message: '');
    pr.hide();
    setState(() {
      _saving = false;
    });
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
                  Icons.sync,
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

// Retrieving list of all three modules : Report Task Images
  Future<void> updateReportListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    await dbFuture.then((database) async {
      Future<List<Report>> reportListFuture =
          databaseHelper.getReportListUnpublished();
      await reportListFuture.then((reportlist) {
        setState(() {
          this.reportlist = reportlist;
          this.reportcount = reportlist.length;
        });
        if (listreportcount <= 0) {
          listreportcount = 0;
        }
      });
    });
  }

  Future<void> updateTaskListView(String reportid) async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    await dbFuture.then((database) async {
      Future<List<Tasks>> taskListFuture =
          databaseHelper.getTaskListUnpublished(reportid);
      await taskListFuture.then((tasklist) {
        setState(() {
          this.tasklist = tasklist;
          this.taskcount = tasklist.length;
        });
        if (listtaskcount <= 0) {
          print('finished syncing all tasks');
        }
      });
    });
  }

  Future<void> updateImagesListView(String reportid) async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    await dbFuture.then((database) async {
      Future<List<Images>> taskListFuture =
          databaseHelper.getImageListUnpublished(reportid);
      await taskListFuture.then((tasklist) {
        setState(() {
          this.imagelist = tasklist;
          this.imagecount = tasklist.length;
        });
        if (listimagecount <= 0) {
          print('finished syncing all images');
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
// Uploading Report to sharepoint

  Future<void> postReportsToSharepoint(
      Report report, String accesstoken, var _body, int count) async {
    try {
      print('Uploading report no ${report.reportno} to sharepoint');

      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('ConnectReportBase')/items"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Content-Type": "application/json;odata=verbose",
            "Accept": "application/json"
          },
          body: _body);

      print('Report no ${report.reportno} is uploaded ${response.statusCode}');
      Map<String, dynamic> resJson = json.decode(response.body);
      print('Token Type : ' + resJson["Id"].toString());

      if (response.statusCode == 201) {
        percentage += 20.0 / reportcount;
        pr.update(
            progress: percentage.roundToDouble(), message: 'Report Uploaded');

        print('Posting Signature to Sharepoint');
        await postSignatureToSharepoint(resJson, report, accesstoken);
        print('Posting Images to Sharepoint');
        await postAttachmentsToSharepoint(resJson, report, accesstoken);
      } else {
        _showAlertDialog('SPM Connect',
            'Error occured while trying to sync Reports to cloud.');
        await closeUpload();
        return;
      }

      print('ended');
    } catch (e) {
      print(e);
    }
  }

// Uploading Task to sharepoint

  Future<void> postTasksToSharepoint(
      Tasks task, String accesstoken, var _body, int count) async {
    try {
      print('Uploading task no ${task.reportid} - ${task.id} to sharepoint');

      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('ConnectTasks')/items"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Content-Type": "application/json;odata=verbose",
            "Accept": "application/json"
          },
          body: _body);

      print('Task Uploaded with status code : ${response.statusCode}');
      if (response.statusCode == 201) {
        await _saveTask(task);
      } else {
        _showAlertDialog('SPM Connect',
            'Error occured while trying to sync Tasks to cloud.');
        await closeUpload();
        return;
      }
      print('ended');
    } catch (e) {
      print(e);
    }
  }

// Uploading signature to sharepoint

  Future<void> postSignatureToSharepoint(
      Map<String, dynamic> resJson, Report report, String accesstoken) async {
    print(path);
    File file = File('$path${report.reportmapid.toString()}.png');
    print('Signature File Name : $file');
    int result =
        await postAttachment(resJson["Id"].toString(), accesstoken, file);
    if (result != 0) {
      percentage += 10.0 / reportcount;
      pr.update(
          progress: percentage.roundToDouble(), message: 'Signature Uploaded');
      await Future.delayed(Duration(seconds: 2));
    } else {
      _showAlertDialog('SPM Connect',
          'Error occured while trying to sync signature png to cloud.');
    }
  }

  Future<int> postAttachment(String id, String accesstoken, File file) async {
    int result = 0;
    try {
      String fileName = file.path.split("/").last;
      print('Signature file name to be uploaded is : $fileName');
      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('ConnectReportBase')/items($id)/AttachmentFiles/ add(FileName='$fileName')"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Accept": "application/json"
          },
          body: file.readAsBytesSync());
      print('Signature uploaded with status code : ${response.statusCode}');
      result = response.statusCode;
    } catch (e) {
      print(e);
    }
    return result;
  }

  // Posting Image Attachment to sharepoint

  Future<void> postAttachmentsToSharepoint(
      Map<String, dynamic> resJson, Report report, String accesstoken) async {
    pr.update(
        progress: percentage.roundToDouble(),
        message: 'Attachments $imagecount');
    await Future.delayed(Duration(seconds: 2));
    var percent = 0.0;
    percent = 25.0 / reportcount;
    if (imagecount > 0) {
      print('sync started for images report ${report.reportno}');
      listimagecount = imagecount;

      print('No of images found for ${report.reportno} - is $imagecount');
      for (final i in imagelist) {
        print('uploading image count ${imagelist.indexOf(i) + 1}');

        percentage += percent / imagecount;
        pr.update(
            progress: percentage.roundToDouble(),
            message: 'Attch. No. ${imagelist.indexOf(i) + 1}');

        Asset resultList;
        resultList = Asset(i.identifier, i.name, i.width, i.height);
        ByteData byteData = await resultList.requestOriginal();
        List<int> imageData = byteData.buffer.asUint8List();
        int result = await postImages(
            resJson["Id"].toString(), accesstoken, i.name, imageData);
        if (result != 0) {
          print('saving image');
          await _saveImage(i);
        } else {
          _showAlertDialog('SPM Connect',
              'Error occured while trying to sync attachments to cloud.');
          await closeUpload();
        }
      }
      print(
          'Completed uploading images for ${report.reportno}. Saving report.');

      await _saveReport(report);
      pr.update(progress: percentage.roundToDouble(), message: 'Completed');
      await Future.delayed(Duration(seconds: 2));
    } else {
      print(
          'No attachments found to be uploaded for ${report.reportno}. Saving report.');
      await _saveReport(report);
      pr.update(progress: percentage.roundToDouble(), message: 'Completed');
      await Future.delayed(Duration(seconds: 2));
    }
  }

  Future<int> postImages(
      String id, String accesstoken, String file, List<int> imageData) async {
    int result = 0;
    try {
      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('ConnectReportBase')/items($id)/AttachmentFiles/ add(FileName='$file')"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Accept": "application/json"
          },
          body: imageData);
      //print(response.statusCode);
      result = response.statusCode;
    } catch (e) {
      print(e);
    }
    return result;
  }

// Set all three modules published to one : Report Task Images

  Future<void> _saveReport(Report report) async {
    int result;
    if (report.id != null) {
      report.reportpublished = 1;
      result = await databaseHelper.updateReport(report);
    }
    if (result != 0) {
      listreportcount--;
      print('Success Saving Report to database');
      print('Report to be uploaded count is : $listreportcount');
    } else {
      _showAlertDialog(
          'SPM Connect', 'Error occured while saving Report to database.');
      print('failure saving report');
    }
  }

  Future<void> _saveImage(Images image) async {
    int result;
    if (image.reportid != null) {
      image.published = 1;
      result = await databaseHelper.updateImage(image);
    }
    if (result != 0) {
      listimagecount--;
      print('Success Saving image to database');
      print('list image count to be uploaded is : $listimagecount');
    } else {
      _showAlertDialog(
          'SPM Connect', 'Error occured while saving attachments to database.');
      print('failure saving images');
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
      print('Success Saving task to database');
      print('Task to upload count is : $listtaskcount');
    } else {
      _showAlertDialog(
          'SPM Connect', 'Error occured while saving Task to database.');
      print('failure saving task');
    }
  }

//////////////////////////////////////////////////////////////
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
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future loadDocument() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String _path = directory.path;
      path = "$_path/$directoryName/";
      print("Signature path retrieved $_path");
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
