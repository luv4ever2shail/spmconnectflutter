import 'package:flutter/widgets.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:sqflite/sqlite_api.dart';

class MyReports with ChangeNotifier {
  List<Report> reports;
  int reportmapid;
  int count;
  MyReports();

  MyReports.instance() : reports = new List<Report>() {
    reportmapid = 0;
    count = 0;
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
    final Future<Database> dbFuture = DBProvider.db.initializeDatabase();
    dbFuture.then((database) async {
      List<Report> reportListFuture = await DBProvider.db.getReportList();
      setReports(reportListFuture);
    });
  }

  Future<void> fetchReportmapId() async {
    List<Report> reportListFuture = await DBProvider.db.getNewreportid();
    if (reportListFuture.length > 0)
      setReportMapId(reportListFuture[0].getreportmapid);
    else
      setReportMapId(0);
  }

  Future<void> getReportListUnpublished() async {
    final Future<Database> dbFuture = DBProvider.db.initializeDatabase();
    dbFuture.then((database) async {
      List<Report> reportListFuture =
          await DBProvider.db.getReportListUnpublished();
      setReports(reportListFuture);
    });
  }
}
