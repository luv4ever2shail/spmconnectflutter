import 'dart:convert';

Tasks reportFromJson(String str) => Tasks.fromJson(json.decode(str));

class Tasks {
  int id;
  String reportid;
  int published;
  String item;
  DateTime starttime;
  DateTime endtime;
  String workperformed;
  String hours;
  String date;
  String colspare1;
  String colspare2;
  String colspare3;
  String colspare4;
  String colspare5;

  Tasks(
    this.reportid,
    this.item,
    this.starttime,
    this.endtime,
    this.workperformed,
    this.hours,
    this.date,
    this.published,
    this.colspare1,
    this.colspare2,
    this.colspare3,
    this.colspare4,
    this.colspare5,
  );

  Tasks.withId({
    this.id,
    this.reportid,
    this.item,
    this.starttime,
    this.endtime,
    this.workperformed,
    this.hours,
    this.date,
    this.published,
    this.colspare1,
    this.colspare2,
    this.colspare3,
    this.colspare4,
    this.colspare5,
  });

  int get getid => id;

  String get getreportid => reportid;

  int get getpublished => published;

  String get getitem => item;

  DateTime get getstarttime => starttime;

  DateTime get getendtime => endtime;

  String get getworkperformed => workperformed;

  String get gethours => hours;

  String get getdate => date;

  String get getspare1 => colspare1;
  String get getspare2 => colspare2;
  String get getspare3 => colspare3;
  String get getspare4 => colspare4;
  String get getspare5 => colspare5;

  set getreportid(String newReportid) {
    this.reportid = newReportid;
  }

  set getpublished(int newPublishid) {
    this.published = newPublishid;
  }

  set getitem(String newItem) {
    this.item = newItem;
  }

  set getstarttime(DateTime newStarttime) {
    this.starttime = newStarttime;
  }

  set getendtime(DateTime newEndtime) {
    this.endtime = newEndtime;
  }

  set getworkperformed(String newWorkperformed) {
    this.workperformed = newWorkperformed;
  }

  set gethours(String newHours) {
    this.hours = newHours;
  }

  set getdate(String newDate) {
    this.date = newDate;
  }

  set getspare1(String spare1) {
    this.colspare1 = spare1;
  }

  set getspare2(String spare2) {
    this.colspare2 = spare2;
  }

  set getspare3(String spare3) {
    this.colspare3 = spare3;
  }

  set getspare4(String spare4) {
    this.colspare4 = spare4;
  }

  set getspare5(String spare5) {
    this.colspare5 = spare5;
  }

// Convert a Report object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (getid != null) {
      map['id'] = id;
    }
    map['reportid'] = reportid;
    map['item'] = item;
    map['starttime'] = starttime.toString();
    map['endtime'] = endtime.toString();
    map['workperformed'] = workperformed;
    map['hours'] = hours;
    map['date'] = date;
    map['taskpublished'] = published;
    map['taskspare1'] = colspare1;
    map['taskspare2'] = colspare2;
    map['taskspare3'] = colspare3;
    map['taskspare4'] = colspare4;
    map['taskspare5'] = colspare5;
    return map;
  }

  // Extract a Report object from a Map object
  Tasks.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.reportid = map['reportid'];
    this.item = map['item'];
    this.starttime =
        map['starttime'] != "null" ? DateTime.parse(map['starttime']) : '';
    this.endtime =
        map['endtime'] != "null" ? DateTime.parse(map['endtime']) : '';
    this.workperformed = map['workperformed'];
    this.hours = map['hours'];
    this.date = map['date'];
    this.published = map['taskpublished'];
    this.colspare1 = map['taskspare1'];
    this.colspare2 = map['taskspare2'];
    this.colspare3 = map['taskspare3'];
    this.colspare4 = map['taskspare4'];
    this.colspare5 = map['taskspare5'];
  }

  factory Tasks.fromJson(Map<String, dynamic> json) => Tasks.withId(
        reportid: json["ReportId"],
        id: int.parse(json["Taskid"]),
        item: json["ItemNo"],
        starttime: DateTime.parse(json["Starttime"]),
        endtime: DateTime.parse(json["Endtime"]),
        hours: json["Hours"],
        workperformed: json["WorkPerformed"],
        date: json["Datecreated"],
        published: 1,
        colspare1: json["Spare1"],
        colspare2: json["Spare2"],
        colspare3: json["Spare3"],
        colspare4: json["Spare4"],
        colspare5: json["Spare5"],
      );
}
