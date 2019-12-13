import 'package:flutter/widgets.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:sqflite/sqlite_api.dart';

class ReportTasks with ChangeNotifier {
  List<Tasks> tasks;
  int count;
  ReportTasks();
  DatabaseHelper databaseHelper;

  ReportTasks.instance() : tasks = new List<Tasks>() {
    count = 0;
    databaseHelper = new DatabaseHelper();
  }
  @override
  void dispose() {
    super.dispose();
  }

  setTasks(List<Tasks> _tasks) async {
    tasks = _tasks;
    notifyListeners();
    setcount(_tasks.length);
  }

  setcount(int reportCount) async {
    count = reportCount;
    notifyListeners();
  }

  List<Tasks> get getTasks => tasks;

  int get getCount => count;

  Future<void> fetchTasks(String reportid) async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    await dbFuture.then((database) async {
      List<Tasks> taskListFuture = await databaseHelper.getTasksList(reportid);
      await setTasks(taskListFuture);
    });
  }

  Future<void> getTaskListUnpublished(String reportid) async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    await dbFuture.then((database) async {
      List<Tasks> taskListFuture =
          await databaseHelper.getTaskListUnpublished(reportid);
      setTasks(taskListFuture);
    });
  }
}
