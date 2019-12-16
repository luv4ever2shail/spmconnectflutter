import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sharepoint_auth/model/config.dart';
import 'package:sharepoint_auth/sharepoint_auth.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/Resource/connectivity.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/Resource/images_repository.dart';
import 'package:spmconnectapp/Resource/reports_repository.dart';
import 'package:spmconnectapp/Resource/tasks_repository.dart';
import 'package:spmconnectapp/models/images.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:spmconnectapp/utils/progress_dialog.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:f_logs/model/flog/flog_config.dart';
import 'package:f_logs/model/flog/log_level.dart';
import 'package:f_logs/utils/timestamp/timestamp_format.dart';

const directoryName = 'Connect_Signatures';
ProgressDialog pr;

class ReportListUnpublished extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportListUnpublishedState();
  }
}

class _ReportListUnpublishedState extends State<ReportListUnpublished> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _saving = false;
  int listreportcount = 0;
  int listtaskcount = 0;
  int listimagecount = 0;

  String path = '';
  String empName;
  var percentage = 0.0;

  final PermissionGroup _permissionGroup = PermissionGroup.storage;

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
    getSignatureStoragePath();
    getUserInfoSF();
    requestPermission(_permissionGroup);
    LogsConfig config = FLog.getDefaultConfigurations()
      ..isDevelopmentDebuggingEnabled = true
      ..timestampFormat = TimestampFormat.TIME_FORMAT_FULL_2;

    FLog.applyConfigurations(config);
  }

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);
    print(permissionRequestResult);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyReports myReports = Provider.of<MyReports>(context);
    ReportTasks reportTasks = Provider.of<ReportTasks>(context);
    ReportImages reportImages = Provider.of<ReportImages>(context);
    ConnectivityStatus connectivity = Provider.of<ConnectivityStatus>(context);
    if (connectivity == ConnectivityStatus.Offline && _saving == true) {
      closeprudate();
    }
    return Scaffold(
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
          onRefresh: () => _handleRefresh(myReports),
          child: connectivity == ConnectivityStatus.Offline
              ? Center(
                  child: FlareActor(
                    "assets/no_wifi.flr",
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    animation: 'Untitled',
                  ),
                )
              : myReports.getCount > 0
                  ? getReportListView(myReports)
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                            'All Reports are synced to sharepoint. No Reports found to be synced to sharepoint.'),
                      ),
                    ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: connectivity != ConnectivityStatus.Offline
          ? myReports.getCount > 0
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    FLog.logThis(
                      className: "Sharepoint",
                      methodName: "Sync Button",
                      text: "Sync button pressed",
                      type: LogLevel.INFO,
                    );
                    setState(() {
                      _saving = true;
                    });
                    await syncAll(myReports, reportTasks, reportImages);
                  },
                  tooltip: 'Sync reports to cloud',
                  icon: Icon(
                    Icons.sync,
                    color: Colors.white,
                  ),
                  label: Text('Sync Reports'),
                )
              : Offstage()
          : Offstage(),
    );
  }

  ListView getReportListView(MyReports myReports) {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: myReports.getCount,
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
                'Report No - ' + myReports.getReports[position].reportno,
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 1.5),
              ),
              subtitle: Text(
                'Project - ' +
                    myReports.getReports[position].projectno +
                    " ( " +
                    myReports.getReports[position].customer +
                    ' )' +
                    '\nCreated On (' +
                    myReports.getReports[position].date +
                    ')',
                style: titleStyle,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Null> _handleRefresh(MyReports myReports) async {
    refreshKey.currentState?.show(atTop: false);
    await new Future.delayed(new Duration(seconds: 1));
    await myReports.getReportListUnpublished();
    return null;
  }

  void movetolastscreen() {
    //removeSharepointToken();
    Navigator.pop(context, true);
  }

// Making Post Request body for sharepoint Report and Tasks

  String getReportToJSON(Report report) {
    String reporttojson = ('{"__metadata": { "type": "SP.Data.ConnectReportBaseListItem" },"Title": "${report.reportno}","ReportMapId": "${report.reportmapid}","Report_Id": "${report.id}",'
        '"ProjectNo": "${report.projectno}","Customer": "${report.customer.replaceAll('"', '\\"')}","PlantLoc": "${report.plantloc.replaceAll('"', '\\"')}","ContactName": "${report.contactname.replaceAll('"', '\\"')}",'
        '"Authorizedby": "${report.authorby.replaceAll('"', '\\"')}","Equipment": "${report.equipment.replaceAll('"', '\\"')}","TechName": "${report.techname.replaceAll('"', '\\"')}","DateCreated": "${report.date}",'
        '"FurtherActions": "${report.furtheractions == null ? '' : report.furtheractions.replaceAll('"', '\\"')}","CustComments": "${report.custcomments == null ? '' : report.custcomments.replaceAll('"', '\\"')}",'
        '"RefJob": "${report.refjob == null ? '' : report.refjob.replaceAll('"', '\\"')}","ProjectManager": "${report.projectmanager == null ? '' : report.projectmanager.replaceAll('"', '\\"')}",'
        '"CustRep": "${report.custrep == null ? '' : report.custrep.replaceAll('"', '\\"')}","CustEmail": "${report.custemail == null ? '' : report.custemail.replaceAll('"', '\\"')}",'
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

  String getLogToJSON() {
    String reporttojson =
        ('{"__metadata": { "type": "SP.Data.LogsListItem" },"Title": "$empName"}');
    return reporttojson;
  }

// Get and remove sharepoint token

  Future<void> getSharepointToken() async {
    await restapi.login();
    accessToken = await restapi.getAccessToken();
    //print('Access Token Sharepoint $accessToken');
  }

  void removeSharepointToken() async {
    await restapi.logout();
  }

// Sync Method to control uploading data to sharepoint

  Future<void> syncAll(MyReports myReports, ReportTasks reportTasks,
      ReportImages reportImages) async {
    if (myReports.getCount > 0) {
      pr = new ProgressDialog(context, ProgressDialogType.Download);
      pr.setMessage('Access Token...');
      pr.show();

      await getSharepointToken();
      if (accessToken == null) {
        _showAlertDialog('SPM Connect',
            'Unable to retrieve access token. Please check your network connections.');
        FLog.logThis(
          className: "Sharepoint",
          methodName: "syncAll - Get Accesstoken",
          text: "access token null",
          type: LogLevel.ERROR,
        );
        setState(() {
          _saving = false;
        });
        return;
      }

      print(myReports.getCount);
      percentage += 10.0;
      pr.update(
          progress: percentage.roundToDouble(), message: 'Access Token...');

      if (_saving) {
        if (myReports.getCount > 0) {
          print('No of reports found to be uploaded : ${myReports.getCount}');
          listreportcount = myReports.getCount;
          FLog.logThis(
            className: "Sharepoint",
            methodName: "syncAll - Get Report List",
            text: 'No of reports found to be uploaded : ${myReports.getCount}',
            type: LogLevel.INFO,
          );
          pr.update(
              progress: percentage.roundToDouble(),
              message: 'Uploading Report..');
          await Future.delayed(Duration(seconds: 1));

          pr.update(
              progress: percentage.roundToDouble(),
              message: 'Report Count ${myReports.getCount}');
          await Future.delayed(Duration(seconds: 1));

          for (final i in myReports.getReports) {
            percentage += 10.0 / myReports.getCount;
            pr.update(
                progress: percentage.roundToDouble(),
                message: 'Report ${i.reportno}');
            await Future.delayed(Duration(seconds: 2));

            listtaskcount = 0;
            // tasklist.clear();
            await reportTasks.getTaskListUnpublished(i.reportno);

            print(
                'No of task found in report ${i.reportno} to be uploaded is ${reportTasks.getCount}');

            FLog.logThis(
              className: "Sharepoint",
              methodName: "syncAll - Get Task List",
              text:
                  'No of task found in report ${i.reportno} to be uploaded is ${reportTasks.getCount}',
              type: LogLevel.INFO,
            );

            pr.update(
                progress: percentage.roundToDouble(),
                message: 'Task Count ${reportTasks.getCount}');
            await Future.delayed(Duration(seconds: 1));

            var taskpercent = 0.0;
            taskpercent = 25 / myReports.getCount;
            int taskResult = 0;
            if (reportTasks.getCount > 0) {
              listtaskcount = reportTasks.getCount;
              for (final i in reportTasks.getTasks) {
                print(
                    'Uploading task ${reportTasks.getTasks.indexOf(i) + 1} for report ${i.reportid}');

                FLog.logThis(
                  className: "Sharepoint",
                  methodName: "syncAll - Uploading Task",
                  text:
                      'Uploading task ${reportTasks.getTasks.indexOf(i) + 1} for report ${i.reportid}',
                  type: LogLevel.INFO,
                );

                percentage += taskpercent / reportTasks.getCount;
                pr.update(
                    progress: percentage.roundToDouble(),
                    message: 'Task No. ${reportTasks.getTasks.indexOf(i) + 1}');

                taskResult = await postTasksToSharepoint(
                  i,
                  accessToken,
                  getTaskToJSON(i),
                  reportTasks.getCount,
                  myReports,
                );
                if (taskResult == 0) {
                  FLog.logThis(
                    className: "Sharepoint",
                    methodName: "syncAll - Uploading Task Failed",
                    text:
                        'Uploading task ${reportTasks.getTasks.indexOf(i) + 1} for report ${i.reportid} failed. task result == 0',
                    type: LogLevel.ERROR,
                  );
                  break;
                } else {
                  FLog.logThis(
                    className: "Sharepoint",
                    methodName: "syncAll - task uploaded",
                    text:
                        'Task ${reportTasks.getTasks.indexOf(i) + 1} for report ${i.reportid} successfully uploaded.',
                    type: LogLevel.INFO,
                  );
                }
              }

              FLog.logThis(
                className: "Sharepoint",
                methodName: "syncAll - Uploading Task",
                text: 'All tasks uploaded for report ${i.reportno}.',
                type: LogLevel.INFO,
              );
            } else {
              taskResult = 1;
              percentage += taskpercent;
              pr.update(
                  progress: percentage.roundToDouble(),
                  message: 'Tasks Uploaded');
              FLog.logThis(
                className: "Sharepoint",
                methodName: "syncAll - No tasks to upload",
                text: 'no task to upload for report ${i.reportno}.',
                type: LogLevel.INFO,
              );
            }
            if (taskResult == 0) {
              FLog.logThis(
                className: "Sharepoint",
                methodName: "syncAll - Uploading Task Failed",
                text:
                    'Error occured in uploading task loop for repot ${i.reportno}. exiting from loop.',
                type: LogLevel.ERROR,
              );
              break;
            }

            pr.update(
                progress: percentage.roundToDouble(),
                message: 'Tasks Uploaded');

            listimagecount = 0;

            await reportImages.fetchImages(i.reportno);
            print(
                'No of images found in report ${i.reportno} to be uploaded is ${reportImages.getCount}');

            FLog.logThis(
              className: "Sharepoint",
              methodName: "syncAll - Get Image Attachments List",
              text:
                  'No of images found in report ${i.reportno} to be uploaded is ${reportImages.getCount}',
              type: LogLevel.INFO,
            );

            int resultreport = await postReportsToSharepoint(
              i,
              accessToken,
              getReportToJSON(i),
              myReports.getCount,
              myReports,
              reportImages,
            );

            if (resultreport == 0) {
              FLog.logThis(
                className: "Sharepoint",
                methodName: "syncAll - uploading",
                text:
                    'Report no ${i.reportno} error occured. Breaking the loop of uploading all reports',
                type: LogLevel.INFO,
              );
              break;
            }
          }
        }
      }
      await closeUpload(myReports);
    } else {
      setState(() {
        _saving = false;
      });
    }
  }

  Future<void> closeUpload(MyReports myReports) async {
    await prepareLogFile(myReports);
    await myReports.getReportListUnpublished();
    await closeprudate();
  }

  Future<void> closeprudate() async {
    percentage = 0.0;
    pr.update(progress: percentage.roundToDouble(), message: '');
    pr.hide();
    setState(() {
      _saving = false;
    });
  }

// Logs

  Future<void> prepareLogFile(MyReports myReports) async {
    final logdir = await _localPath + "/FLogs";
    final dir = Directory(logdir);

    var file = File("$logdir/flog.txt");
    var isExist = await file.exists();

    //check to see if file exist
    if (isExist) {
      print('File exists------------------>_getLocalFile()');
      dir.deleteSync(recursive: true);
    } else {
      print('file does not exist---------->_getLocalFile()');
    }
    FLog.exportLogs();
    await postLogFile(accessToken, getLogToJSON(), myReports.getCount, file);
    FLog.clearLogs();
  }

  Future<void> postLogFile(
      String accesstoken, var _body, int count, File file) async {
    try {
      print('Uploading report no  to sharepoint');

      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('Logs')/items"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Content-Type": "application/json;odata=verbose",
            "Accept": "application/json"
          },
          body: _body);

      Map<String, dynamic> resJson = json.decode(response.body);

      if (response.statusCode == 201) {
        print('Log item is created ${response.statusCode}');
        print('Token id : ' + resJson["Id"].toString());
        await postLogToSharepoint(resJson, accesstoken, file);
      } else {
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<int> postLogToSharepoint(
      Map<String, dynamic> resJson, String accesstoken, File file) async {
    int resultpost = 0;
    print('log File Name : $file');

    int result =
        await postLogCloud(resJson["Id"].toString(), accesstoken, file);

    if (result != 0) {
      resultpost = 1;
    }
    return resultpost;
  }

  Future<int> postLogCloud(String id, String accesstoken, File file) async {
    int result = 0;
    try {
      String fileName = file.path.split("/").last;
      print(fileName);
      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('Logs')/items($id)/AttachmentFiles/add(FileName='$fileName')"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Accept": "application/json"
          },
          body: file.readAsBytesSync());
      print('log file uploaded with status code : ${response.statusCode}');
      result = 1;
    } catch (e) {
      print(e);
      result = 0;
    }
    return result;
  }

// Uploading Report to sharepoint

  Future<int> postReportsToSharepoint(
      Report report,
      String accesstoken,
      var _body,
      int count,
      MyReports myReports,
      ReportImages reportImages) async {
    int result = 0;
    try {
      print('Uploading report no ${report.reportno} to sharepoint');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postReportsToSharepoint",
        text: 'Uploading report no ${report.reportno} to sharepoint',
        type: LogLevel.INFO,
      );

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
        FLog.logThis(
          className: "Sharepoint",
          methodName: "postReportsToSharepoint",
          text:
              'Report no ${report.reportno} is uploaded ${response.statusCode}',
          type: LogLevel.INFO,
        );

        FLog.logThis(
          className: "Sharepoint",
          methodName: "postReportsToSharepoint",
          text: 'Token ID  : ${resJson["Id"].toString()}',
          type: LogLevel.INFO,
        );
        percentage += 20.0 / myReports.getCount;
        pr.update(
            progress: percentage.roundToDouble(), message: 'Report Uploaded');

        print('Posting Signature to Sharepoint');
        int postsign = await postSignatureToSharepoint(
            resJson, report, accesstoken, myReports);

        if (postsign == 1) {
          print('Posting Images to Sharepoint');
          int postattach = await postAttachmentsToSharepoint(
              resJson, report, accesstoken, myReports, reportImages);
          if (postattach == 1) {
            result = 1;
          } else {
            result = 0;
          }
        } else {
          result = 0;
        }
      } else {
        FLog.logThis(
          className: "Sharepoint",
          methodName: "postReportsToSharepoint",
          text:
              'Report no ${report.reportno} is not uploaded with response code ${response.statusCode}',
          type: LogLevel.ERROR,
        );
        await closeUpload(myReports);
        _showAlertDialog('SPM Connect',
            'Error occured while trying to sync Reports to cloud.');
        result = 0;
      }
      print('ended');
    } catch (e) {
      result = 0;
      print(e);
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postReportsToSharepoint - catch error",
        text: e,
        type: LogLevel.ERROR,
      );
    }
    return result;
  }

// Uploading Task to sharepoint

  Future<int> postTasksToSharepoint(Tasks task, String accesstoken, var _body,
      int count, MyReports myReports) async {
    int result = 0;
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
        FLog.logThis(
          className: "Sharepoint",
          methodName: "postTasksToSharepoint",
          text: 'Task Uploaded with status code : ${response.statusCode}',
          type: LogLevel.INFO,
        );
        int res = await _saveTask(task, myReports);
        if (res != 0) {
          result = 1;
        } else {
          result = 0;
        }
      } else {
        await closeUpload(myReports);
        _showAlertDialog('SPM Connect',
            'Error occured while trying to sync Tasks to cloud.');
        FLog.logThis(
          className: "Sharepoint",
          methodName: "postTasksToSharepoint",
          text: 'Error occured while trying to sync Tasks to cloud.',
          type: LogLevel.ERROR,
        );
      }
      print('ended');
    } catch (e) {
      print(e);
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postTasksToSharepoint catch error",
        text: e,
        type: LogLevel.ERROR,
      );
      result = 0;
    }
    return result;
  }

// Uploading signature to sharepoint

  Future<int> postSignatureToSharepoint(Map<String, dynamic> resJson,
      Report report, String accesstoken, MyReports myReports) async {
    int resultpost = 0;
    print(path);
    File file = File('$path${report.reportmapid.toString()}.png');
    print('Signature File Name : $file');
    FLog.logThis(
      className: "Sharepoint",
      methodName: "postSignatureToSharepoint",
      text: 'Uploading signature : Signature File Name : $file',
      type: LogLevel.INFO,
    );
    int result =
        await postSignatureCloud(resJson["Id"].toString(), accesstoken, file);

    if (result != 0) {
      percentage += 10.0 / myReports.getCount;
      pr.update(
          progress: percentage.roundToDouble(), message: 'Signature Uploaded');
      await Future.delayed(Duration(seconds: 2));

      FLog.logThis(
        className: "Sharepoint",
        methodName: "postSignatureToSharepoint",
        text: 'Uploaded signature for report ${report.reportno}',
        type: LogLevel.INFO,
      );

      resultpost = 1;
    } else {
      await closeUpload(myReports);
      _showAlertDialog('SPM Connect',
          'Error occured while trying to sync signature png to cloud.');
      resultpost = 0;

      FLog.logThis(
        className: "Sharepoint",
        methodName: "postSignatureToSharepoint",
        text: 'Uploading signature failed for report ${report.reportno}',
        type: LogLevel.ERROR,
      );
    }
    return resultpost;
  }

  Future<int> postSignatureCloud(
      String id, String accesstoken, File file) async {
    int result = 0;
    try {
      String fileName = file.path.split("/").last;
      print('Signature file name to be uploaded is : $fileName');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postAttachment",
        text:
            'Post request to sharepoint for uploading signature :Signature file name to be uploaded is : $fileName ',
        type: LogLevel.INFO,
      );
      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('ConnectReportBase')/items($id)/AttachmentFiles/ add(FileName='$fileName')"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Accept": "application/json"
          },
          body: file.readAsBytesSync());
      print('Signature uploaded with status code : ${response.statusCode}');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postAttachment",
        text: 'Signature uploaded with status code : ${response.statusCode}',
        type: LogLevel.INFO,
      );
      result = 1;
    } catch (e) {
      print(e);
      result = 0;
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postAttachment - catch error",
        text: e,
        type: LogLevel.ERROR,
      );
    }
    return result;
  }

// Posting Image Attachment to sharepoint

  Future<int> postAttachmentsToSharepoint(
      Map<String, dynamic> resJson,
      Report report,
      String accesstoken,
      MyReports myReports,
      ReportImages reportImages) async {
    int resultupload = 0;
    pr.update(
        progress: percentage.roundToDouble(),
        message: 'Attachments ${reportImages.getCount}');
    FLog.logThis(
      className: "Sharepoint",
      methodName: "postAttachmentsToSharepoint",
      text: 'Posting Attachments, attachment count ${reportImages.getCount}',
      type: LogLevel.INFO,
    );

    await Future.delayed(Duration(seconds: 2));
    var percent = 0.0;
    percent = 25.0 / myReports.getCount;
    if (reportImages.getCount > 0) {
      print('sync started for images report ${report.reportno}');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postAttachmentsToSharepoint",
        text: 'sync started for images report ${report.reportno}',
        type: LogLevel.INFO,
      );

      listimagecount = reportImages.getCount;

      print(
          'No of images found for ${report.reportno} - is ${reportImages.getCount}');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postAttachmentsToSharepoint - imagecount > 0",
        text:
            'No of images found for ${report.reportno} - is ${reportImages.getCount}',
        type: LogLevel.INFO,
      );

      for (final i in reportImages.getImages) {
        resultupload = 0;
        print('uploading image count ${reportImages.getImages.indexOf(i) + 1}');

        FLog.logThis(
          className: "Sharepoint",
          methodName: "postAttachmentsToSharepoint - in the loop",
          text:
              'uploading image count ${reportImages.getImages.indexOf(i) + 1}',
          type: LogLevel.INFO,
        );

        percentage += percent / reportImages.getCount;
        pr.update(
            progress: percentage.roundToDouble(),
            message: 'Attch. No. ${reportImages.getImages.indexOf(i) + 1}');

        Asset resultList;
        resultList = Asset(i.identifier, i.name, i.width, i.height);
        ByteData byteData = await resultList.getByteData(quality: 100);
        List<int> imageData = byteData.buffer.asUint8List();
        int result = await postImageSharepoint(
          resJson["Id"].toString(),
          accesstoken,
          i.name,
          imageData,
        );

        if (result != 0) {
          print('saving image');
          int res = await _saveImage(i, myReports);
          if (res != 0) {
            FLog.logThis(
              className: "Sharepoint",
              methodName: "postAttachmentsToSharepoint",
              text:
                  'Success uploading the attachment ${i.name},  Attch. No. ${reportImages.getImages.indexOf(i) + 1}',
              type: LogLevel.INFO,
            );
            resultupload = 1;
          } else {
            resultupload = 0;
          }
        } else {
          //await closeUpload(myReports);
          _showAlertDialog('SPM Connect',
              'Error occured while trying to sync attachment ${i.name} Attch. No. ${reportImages.getImages.indexOf(i) + 1} to cloud.');
          resultupload = 0;
          FLog.logThis(
            className: "Sharepoint",
            methodName: "postAttachmentsToSharepoint",
            text:
                'Error uploading the attachment ${i.name}. Attch. No. ${reportImages.getImages.indexOf(i) + 1}',
            type: LogLevel.ERROR,
          );
          //break;
        }
      }

      print(
          'Completed uploading images for ${report.reportno}. Saving report.');
      if (resultupload == 1) {
        FLog.logThis(
          className: "Sharepoint",
          methodName: "postAttachmentsToSharepoint",
          text:
              'Completed uploading images for ${report.reportno}. Saving report.',
          type: LogLevel.INFO,
        );
        await _saveReport(report, myReports);
        pr.update(progress: percentage.roundToDouble(), message: 'Completed');
        await Future.delayed(Duration(seconds: 2));
      }
    } else {
      percentage += percent;
      pr.update(
          progress: percentage.roundToDouble(), message: 'Attch. uploaded');
      print(
          'No attachments found to be uploaded for ${report.reportno}. Saving report.');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postAttachmentsToSharepoint",
        text:
            'No attachments found to be uploaded for ${report.reportno}. Saving report.',
        type: LogLevel.INFO,
      );
      await _saveReport(report, myReports);
      pr.update(progress: percentage.roundToDouble(), message: 'Completed');
      await Future.delayed(Duration(seconds: 2));
      resultupload = 1;
    }
    return resultupload;
  }

  Future<int> postImageSharepoint(
    String id,
    String accesstoken,
    String file,
    List<int> imageData,
  ) async {
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
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postImages",
        text:
            'image uploaded to sharepoint response coded ${response.statusCode} ',
        type: LogLevel.INFO,
      );
    } catch (e) {
      print(e);
      FLog.logThis(
        className: "Sharepoint",
        methodName: "postImages",
        text: e,
        type: LogLevel.ERROR,
      );
    }
    return result;
  }

// Set all three modules published to one : Report Task Images - Saving to local Database

  Future<int> _saveReport(Report report, MyReports myReports) async {
    int result;
    if (report.id != null) {
      report.reportpublished = 1;
      result = await databaseHelper.updateReport(report);
    }
    if (result != 0) {
      listreportcount--;
      print('Success Saving Report to database');
      print('Report to be uploaded count is : $listreportcount');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "_saveReport",
        text: 'Success Saving Report ${report.reportno} to database',
        type: LogLevel.INFO,
      );
    } else {
      await closeUpload(myReports);
      _showAlertDialog(
          'SPM Connect', 'Error occured while saving Report to database.');
      print('failure saving report');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "_saveReport",
        text: 'Failure Saving Report ${report.reportno} to database',
        type: LogLevel.ERROR,
      );
    }
    return result;
  }

  Future<int> _saveImage(Images image, MyReports myReports) async {
    int result;
    if (image.reportid != null) {
      image.published = 1;
      result = await databaseHelper.updateImage(image);
    }
    if (result != 0) {
      listimagecount--;
      print('Success Saving image to database');
      print('list image count to be uploaded is : $listimagecount');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "_saveImage",
        text: 'Success Saving image to database',
        type: LogLevel.INFO,
      );
    } else {
      await closeUpload(myReports);
      _showAlertDialog(
          'SPM Connect', 'Error occured while saving attachments to database.');
      print('failure saving images');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "_saveImage",
        text: 'Failure Saving image to database',
        type: LogLevel.ERROR,
      );
    }
    return result;
  }

  Future<int> _saveTask(Tasks task, MyReports myReports) async {
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
      await closeUpload(myReports);
      _showAlertDialog(
          'SPM Connect', 'Error occured while saving Task to database.');
      print('failure saving task');
      FLog.logThis(
        className: "Sharepoint",
        methodName: "_saveTask to db",
        text: 'Error occured while saving Task to database.',
        type: LogLevel.ERROR,
      );
    }
    return result;
  }

//Getting User Info
  getUserInfoSF() async {
    Box _box = Hive.box('myBox');
    empName = _box.get('Name');
    setState(() {});
  }

// Alert Dialogs

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

//Get Signature Storage Path

  Future getSignatureStoragePath() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String _path = directory.path;
      path = "$_path/$directoryName/";
      print("Signature path retrieved $_path");
    } catch (e) {
      print(e);
    }
  }

// Get Log File

  Future<String> get _localPath async {
    var directory;

    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getExternalStorageDirectory();
    }

    return directory.path;
  }
}
