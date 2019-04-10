import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/models/tasks.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database; // Singleton Database

  String reportTable = 'servicerpt_tbl';
  String colId = 'id';
  String colProjectno = 'projectno';
  String colCustomer = 'customer';
  String colPlantloc = 'plantloc';
  String colContactname = 'contactname';
  String colAuthorby = 'authorby';
  String colEquipment = 'equipment';
  String colTechname = 'techname';
  String colDate = 'date';
  String colfurteractions = 'furtheractions';
  String colcustcomments = 'custcomments';
  String colcustrep = 'custrep';
  String colreportmapid = 'reportmapid';

  String taskTable = 'tasks_tbl';
  String coltaskId = 'id';
  String coltaskreportid = 'reportid';
  String coltaskItem = 'item';
  String coltaskStartTime = 'starttime';
  String coltaskEndTime = 'endtime';
  String coltaskWork = 'workperformed';
  String coltaskHours = 'hours';
  String coltaskDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'servicereport.db';

    // Open/create the database at a given path
    var reportDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return reportDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $reportTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colProjectno TEXT, '
        '$colCustomer TEXT, $colPlantloc TEXT,$colContactname TEXT,$colAuthorby TEXT,$colEquipment TEXT,$colTechname TEXT, $colDate TEXT, '
        '$colfurteractions TEXT,$colcustcomments TEXT,$colcustrep TEXT,$colreportmapid INTEGER)');
    await db.execute(
        'CREATE TABLE $taskTable($coltaskId INTEGER PRIMARY KEY AUTOINCREMENT, $coltaskreportid INTEGER, '
        '$coltaskItem TEXT, $coltaskStartTime TEXT, $coltaskEndTime TEXT,$coltaskWork TEXT,$coltaskHours TEXT,$coltaskDate TEXT)');
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getReportMapList() async {
    Database db = await this.database;
    //		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(reportTable, orderBy: '$colreportmapid DESC');
    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> inserReport(Report report) async {
    Database db = await this.database;
    var result = await db.insert(reportTable, report.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateReport(Report report) async {
    var db = await this.database;
    var result = await db.update(reportTable, report.toMap(),
        where: '$colId = ?', whereArgs: [report.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteReport(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $reportTable WHERE $colId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $reportTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Report>> getReportList() async {
    var reportMapList =
        await getReportMapList(); // Get 'Map List' from database
    int count =
        reportMapList.length; // Count the number of map entries in db table

    List<Report> reportList = List<Report>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      reportList.add(Report.fromMapObject(reportMapList[i]));
    }

    return reportList;
  }

  Future<List<Report>> getNewreportid() async {
    var reportidMapList =
        await getNewreportidMap(); // Get 'Map List' from database
    int count =
        reportidMapList.length; // Count the number of map entries in db table

    List<Report> reportmapidList = List<Report>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      reportmapidList.add(Report.fromMapObject(reportidMapList[i]));
    }
    return reportmapidList;
  }

  Future<List<Map<String, dynamic>>> getNewreportidMap() async {
    Database db = await this.database;
    var result = await db.rawQuery(
        'SELECT * FROM $reportTable WHERE $colreportmapid = (SELECT MAX($colreportmapid) FROM $reportTable) ');
    //var result = await db.query(reportTable, orderBy: '$colProjectno DESC');
    return result;
  }

//*! Task table commands

  Future<int> inserTask(Tasks task) async {
    Database db = await this.database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateTask(Tasks task) async {
    var db = await this.database;
    var result = await db.update(taskTable, task.toMap(),
        where: '$coltaskId = ?', whereArgs: [task.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteTask(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $taskTable WHERE $coltaskId = $id');
    return result;
  }

  Future<int> deleteAllTasks(int reportmapid) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM $taskTable WHERE $coltaskreportid = $reportmapid');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCountTask() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $taskTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Tasks>> getTasksList(int reportid) async {
    var taskMapList =
        await getTasksMapList(reportid); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Tasks> tasklist = List<Tasks>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      tasklist.add(Tasks.fromMapObject(taskMapList[i]));
    }

    return tasklist;
  }

  Future<List<Map<String, dynamic>>> getTasksMapList(int reportid) async {
    Database db = await this.database;

    var result = await db.rawQuery(
        'SELECT * FROM $taskTable where $coltaskreportid = $reportid order by $coltaskId ASC');
    //var result = await db.query(reportTable, orderBy: '$colProjectno DESC');
    return result;
  }
}
