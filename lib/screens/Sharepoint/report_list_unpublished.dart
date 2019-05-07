import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
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
                  Icons.cloud_upload,
                  size: 40,
                  color: Colors.grey,
                ),
                onTap: () {
                  print('tappedcloud');
                  setState(() {
                    _saving = true;
                  });

                  String reporttojson =
                      getReportToJSON(this.reportlist[position]);

                  postItemToSharepoint(
                      this.reportlist[position], accessToken, reporttojson);
                },
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
          _saving = false;
        });
      });
    });
  }

  String getReportToJSON(Report report) {
    String reporttojson =
        ('{"__metadata": { "type": "SP.Data.TestListListItem" },"ReportNo": "${report.projectno}","Title": "${report.customer}"}');
    print(reporttojson);
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

  Future postItemToSharepoint(
      Report report, String accesstoken, String _body) async {
    try {
      Map<String, String> data = {
        "ReportNo": "${report.projectno}",
        "Title": "${report.customer}"
      };
      var data1 = json.encode(data);
      print(data1);
      http.Response response = await http.post(
          Uri.encodeFull(Apikeys.sharepointListUrl),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            'Content-Type': "application/json"
          },
          body: data1);
      print(response.body);
    } catch (e) {
      print(e);
    }
    new Future.delayed(new Duration(seconds: 3), () {
      _save(report);
    });
  }

  void _save(Report report) async {
    int result;
    if (report.id != null) {
      report.reportpublished = 1;
      result = await databaseHelper.updateReport(report);
    }
    if (result != 0) {
      print('Success');
    } else {
      print('failure');
    }
  }
}
