import 'package:flutter/widgets.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:sqflite/sqlite_api.dart';

class MyReports with ChangeNotifier {
  List<Report> reports;
  int reportmapid;
  int count;
  MyReports();
  DatabaseHelper databaseHelper;

  MyReports.instance() : reports = new List<Report>() {
    reportmapid = 0;
    count = 0;
    databaseHelper = new DatabaseHelper();
  }
  @override
  void dispose() {
    super.dispose();
  }

  setReports(List<Report> _reports) async {
    reports.clear();
    reports = _reports;
    notifyListeners();
    setcount(_reports.length);
  }

  setReportMapId(int _mapid) async {
    reportmapid = _mapid;
    notifyListeners();
  }

  setcount(int reportCount) async {
    count = reportCount;
    notifyListeners();
  }

  List<Report> get getReports => reports;

  int get getReportMapId => reportmapid;

  int get getCount => count;

  Future<void> fetchReports() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) async {
      List<Report> reportListFuture = await databaseHelper.getReportList();
      setReports(reportListFuture);
    });
  }

  Future<void> fetchReportmapId() async {
    List<Report> reportListFuture = await databaseHelper.getNewreportid();
    if (reportListFuture.length > 0)
      setReportMapId(reportListFuture[0].reportmapid);
    else
      setReportMapId(0);
  }

  Future<void> getReportListUnpublished() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) async {
      List<Report> reportListFuture =
          await databaseHelper.getReportListUnpublished();
      setReports(reportListFuture);
    });
  }
}
