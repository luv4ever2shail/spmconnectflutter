import 'package:path/path.dart';
import 'package:spmconnectapp/models/images.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/models/tasks.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  String reportTable = 'servicerpt_tbl';
  String taskTable = 'tasks_tbl';
  String imageTable = 'image_tbl';

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "servicereport.db");

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  // UPGRADE DATABASE TABLES
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      //await db.execute("ALTER TABLE $reportTable ADD COLUMN newSpare TEXT;");
    }
  }

  Future<void> _createDb(Database db, int newVersion) async {
    var batch = db.batch();
    createReportTable(batch);
    createReportTaskTable(batch);
    createReportImagesTable(batch);
    await batch.commit();
  }

  void createReportTable(Batch batch) {
    batch.execute('CREATE TABLE $reportTable ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'projectno TEXT, reportno TEXT,'
        'customer TEXT,'
        'plantloc TEXT,'
        'contactname TEXT,'
        'authorby TEXT,'
        'equipment TEXT,'
        'techname TEXT,'
        'date TEXT,'
        'furtheractions TEXT,'
        'custcomments TEXT,'
        'custrep TEXT,'
        'custemail TEXT,'
        'custcontact TEXT,'
        'reportmapid INTEGER,'
        'reportpublished INTEGER,'
        'reportsigned INTEGER,'
        'refjob TEXT,'
        'projectmanager TEXT,'
        'spare1 TEXT,'
        'spare2 TEXT,'
        'spare3 TEXT,'
        'spare4 TEXT,'
        'spare5 TEXT)');
  }

  void createReportTaskTable(Batch batch) {
    batch.execute('CREATE TABLE $taskTable ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'reportid TEXT,'
        'item TEXT,'
        'starttime TEXT,'
        'endtime TEXT,'
        'workperformed TEXT,'
        'hours TEXT,'
        'date TEXT,'
        'taskpublished INTEGER,'
        'taskspare1 TEXT,'
        'taskspare2 TEXT,'
        'taskspare3 TEXT,'
        'taskspare4 TEXT,'
        'taskspare5 TEXT)');
  }

  void createReportImagesTable(Batch batch) {
    batch.execute('CREATE TABLE $imageTable ('
        'reportid TEXT,'
        'identifier TEXT,'
        'name TEXT,'
        'width INTEGER,'
        'height INTEGER,'
        'imagepublished INTEGER,'
        'spare1 TEXT,'
        'spare2 TEXT,'
        'spare3 TEXT)');
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getReportMapList() async {
    Database db = await this.database;
    //		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(reportTable, orderBy: 'reportmapid DESC');
    return result;
  }

  Future<Report> getReport(int id) async {
    Database db = await this.database;
    var res = await db.query(reportTable, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Report.fromMapObject(res.first) : null;
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
        where: 'id = ?', whereArgs: [report.getId]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteReport(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $reportTable WHERE id = $id');
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
        'SELECT * FROM $reportTable WHERE reportmapid = (SELECT MAX(reportmapid) FROM $reportTable) ');
    //var result = await db.query(reportTable, orderBy: '$colProjectno DESC');
    return result;
  }

//*! Task table commands

  Future<int> insertTask(Tasks task) async {
    Database db = await this.database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  Future<Tasks> getTask(int id) async {
    Database db = await this.database;
    var res = await db.query(taskTable, where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Tasks.fromMapObject(res.first) : null;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateTask(Tasks task) async {
    var db = await this.database;
    var result = await db.update(taskTable, task.toMap(),
        where: 'id = ?', whereArgs: [task.getid]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteTask(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $taskTable WHERE id = $id');
    return result;
  }

  Future<int> deleteAllTasks(String reportmapid) async {
    var db = await this.database;
    int result = await db
        .rawDelete('DELETE FROM $taskTable WHERE reportid = $reportmapid');
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

  Future<List<Tasks>> getTasksList(String reportid) async {
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

  Future<List<Map<String, dynamic>>> getTasksMapList(String reportid) async {
    Database db = await this.database;
    var result = await db.rawQuery(
        'SELECT * FROM $taskTable where reportid ="$reportid" order by id ASC');
    //var result = await db.query(reportTable, orderBy: '$colProjectno DESC');
    return result;
  }

  //*! Sharepoint REST API QUERIES

  Future<List<Report>> getReportListUnpublished() async {
    var reportMapList =
        await getReportMapListUnpublished(); // Get 'Map List' from database
    int count =
        reportMapList.length; // Count the number of map entries in db table

    List<Report> reportList = List<Report>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      reportList.add(Report.fromMapObject(reportMapList[i]));
    }
    return reportList;
  }

  Future<List<Map<String, dynamic>>> getReportMapListUnpublished() async {
    Database db = await this.database;
    int published = 0;
    int signed = 1;
    var result = await db.rawQuery(
        'SELECT * FROM $reportTable where reportpublished = $published AND reportsigned = $signed order by reportmapid ASC');
    return result;
  }

// Getting all unpublished task

  Future<List<Tasks>> getTaskListUnpublished(String reportid) async {
    var reportMapList = await getTaskMapListUnpublished(
        reportid); // Get 'Map List' from database
    int count =
        reportMapList.length; // Count the number of map entries in db table

    List<Tasks> taskList = List<Tasks>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      taskList.add(Tasks.fromMapObject(reportMapList[i]));
    }

    return taskList;
  }

  Future<List<Map<String, dynamic>>> getTaskMapListUnpublished(
      String reportid) async {
    Database db = await this.database;
    int published = 0;
    var result = await db.rawQuery(
        'SELECT * FROM $taskTable where taskpublished = $published AND reportid = $reportid order by id ASC');
    return result;
  }

// Getting all unpublished Images
  Future<List<Images>> getImageListUnpublished(String reportid) async {
    var reportMapList = await getImageMapListUnpublished(
        reportid); // Get 'Map List' from database
    int count =
        reportMapList.length; // Count the number of map entries in db table

    List<Images> taskList = List<Images>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      taskList.add(Images.fromMapObject(reportMapList[i]));
    }

    return taskList;
  }

  Future<List<Map<String, dynamic>>> getImageMapListUnpublished(
      String reportid) async {
    Database db = await this.database;
    int published = 0;
    var result = await db.rawQuery(
        'SELECT * FROM $imageTable where imagepublished = $published AND reportid = $reportid');
    return result;
  }

//*! Image table commands

  Future<int> insertImage(Images image) async {
    Database db = await this.database;
    var result = await db.insert(imageTable, image.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateImage(Images image) async {
    var db = await this.database;
    var result = await db.update(imageTable, image.toMap(),
        where: 'reportid = ?', whereArgs: [image.reportid]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteImages(String id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $imageTable WHERE reportid = $id');
    return result;
  }

  Future<int> deleteAllImages(String reportmapid) async {
    var db = await this.database;
    int result = await db
        .rawDelete('DELETE FROM $imageTable WHERE reportid = $reportmapid');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCountImages() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $imageTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Images>> getImageList(String reportid) async {
    var taskMapList =
        await getImagesMapList(reportid); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Images> imageList = List<Images>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      imageList.add(Images.fromMapObject(taskMapList[i]));
    }

    return imageList;
  }

  Future<List<Map<String, dynamic>>> getImagesMapList(String reportid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $imageTable where reportid =$reportid');
    //var result = await db.query(reportTable, orderBy: '$colProjectno DESC');
    return result;
  }
}
