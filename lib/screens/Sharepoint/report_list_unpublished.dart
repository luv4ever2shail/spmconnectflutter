import 'dart:async';
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
  int list = 0;

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
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.sync,
                color: Colors.white,
                size: 38,
              ),
              onPressed: () {
                if (count > 0) {
                  print('sync tapped');
                  setState(() {
                    _saving = true;
                  });
                  for (final i in reportlist) {
                    postItemToSharepoint(
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
          list = 0;
          _saving = false;
        });
      });
    });
  }

  String getReportToJSON(Report report) {
    String reporttojson =
        ('{"__metadata": { "type": "SP.Data.TestListListItem" },"ReportNo": "${report.projectno}","Title": "${report.customer}"}');
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

  Future postItemToSharepoint(
      Report report, String accesstoken, var _body, int count) async {
    await new Future.delayed(new Duration(seconds: 3));
    try {
      http.Response response = await http.post(
          Uri.encodeFull(
              "https://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('TestList')/items"),
          headers: {
            "Authorization": "Bearer " + accesstoken,
            "Content-Type": "application/json;odata=verbose",
            "Accept": "application/json"
          },
          body: _body);
      print(response.statusCode);
      new Future.delayed(new Duration(seconds: 2), () {
        if (response.statusCode == 201) {
          _save(report, count);
        } else {
          setState(() {
            _saving = false;
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _save(Report report, int count) async {
    int result;
    if (report.id != null) {
      report.reportpublished = 1;
      result = await databaseHelper.updateReport(report);
    }
    if (result != 0) {
      list++;
      print('Success');
      if (list == count) {
        updateListView();
      }
    } else {
      print('failure');
    }
  }
}
