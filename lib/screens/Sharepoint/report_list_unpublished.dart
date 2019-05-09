import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharepoint_auth/model/config.dart';
import 'package:sharepoint_auth/sharepoint_auth.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/models/report.dart';
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
  int count = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _saving = false;
  int list = 0;
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
    getSharepointToken();
    getUserInfoSF();
  }

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
                if (count > 0) {
                  print('sync tapped');
                  setState(() {
                    list = count;
                    _saving = true;
                  });
                  for (final i in reportlist) {
                    await postItemToSharepoint(
                        i, accessToken, getReportToJSON(i), count);
                  }
                }
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
    updateListView();
    return null;
  }

  void movetolastscreen() {
    removeSharepointToken();
    Navigator.pop(context, true);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Report>> reportListFuture =
          databaseHelper.getReportListUnpublished();
      reportListFuture.then((reportlist) {
        setState(() {
          this.reportlist = reportlist;
          this.count = reportlist.length;
        });
        if (list <= count) {
          setState(() {
            list = 0;
            _saving = false;
          });
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

  void getSharepointToken() async {
    await restapi.login();
    accessToken = await restapi.getAccessToken();
    print('Access Token Sharepoint $accessToken');
  }

  void removeSharepointToken() async {
    await restapi.logout();
  }

  Future<void> postItemToSharepoint(
      Report report, String accesstoken, var _body, int count) async {
    try {
      print('post started : list value $list');

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

  Future<void> _saveReport(Report report) async {
    int result;
    if (report.id != null) {
      report.reportpublished = 1;
      result = await databaseHelper.updateReport(report);
    }
    if (result != 0) {
      list--;
      print(list);
      print('Success Saving');
      updateListView();
    } else {
      print('failure');
    }
  }

  getUserInfoSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    empName = prefs.getString('Name');
    setState(() {});
  }
}
