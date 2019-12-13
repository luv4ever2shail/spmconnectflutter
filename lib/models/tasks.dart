class Tasks {
  int _id;
  String _reportid;
  int _published;
  String _item;
  DateTime _starttime;
  DateTime _endtime;
  String _workperformed;
  String _hours;
  String _date;
  String colspare1;
  String colspare2;
  String colspare3;
  String colspare4;
  String colspare5;

  Tasks(
    this._reportid,
    this._item,
    this._starttime,
    this._endtime,
    this._workperformed,
    this._hours,
    this._date,
    this._published,
    this.colspare1,
    this.colspare2,
    this.colspare3,
    this.colspare4,
    this.colspare5,
  );

  Tasks.withId(
      this._id,
      this._reportid,
      this._item,
      this._starttime,
      this._endtime,
      this._workperformed,
      this._hours,
      this._date,
      this._published);

  int get id => _id;

  String get reportid => _reportid;

  int get published => _published;

  String get item => _item;

  DateTime get starttime => _starttime;

  DateTime get endtime => _endtime;

  String get workperformed => _workperformed;

  String get hours => _hours;

  String get date => _date;

  String get spare1 => colspare1;
  String get spare2 => colspare2;
  String get spare3 => colspare3;
  String get spare4 => colspare4;
  String get spare5 => colspare5;

  set reportid(String newReportid) {
    this._reportid = newReportid;
  }

  set published(int newPublishid) {
    this._published = newPublishid;
  }

  set item(String newItem) {
    this._item = newItem;
  }

  set starttime(DateTime newStarttime) {
    this._starttime = newStarttime;
  }

  set endtime(DateTime newEndtime) {
    this._endtime = newEndtime;
  }

  set workperformed(String newWorkperformed) {
    this._workperformed = newWorkperformed;
  }

  set hours(String newHours) {
    this._hours = newHours;
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set spare1(String spare1) {
    this.colspare1 = spare1;
  }

  set spare2(String spare2) {
    this.colspare2 = spare2;
  }

  set spare3(String spare3) {
    this.colspare3 = spare3;
  }

  set spare4(String spare4) {
    this.colspare4 = spare4;
  }

  set spare5(String spare5) {
    this.colspare5 = spare5;
  }

// Convert a Report object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['reportid'] = _reportid;
    map['item'] = _item;
    map['starttime'] = _starttime.toString();
    map['endtime'] = _endtime.toString();
    map['workperformed'] = _workperformed;
    map['hours'] = _hours;
    map['date'] = _date;
    map['taskpublished'] = _published;
    map['taskspare1'] = colspare1;
    map['taskspare2'] = colspare2;
    map['taskspare3'] = colspare3;
    map['taskspare4'] = colspare4;
    map['taskspare5'] = colspare5;
    return map;
  }

  // Extract a Report object from a Map object
  Tasks.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._reportid = map['reportid'];
    this._item = map['item'];
    this._starttime =
        map['starttime'] != "null" ? DateTime.parse(map['starttime']) : '';
    this._endtime =
        map['endtime'] != "null" ? DateTime.parse(map['endtime']) : '';
    this._workperformed = map['workperformed'];
    this._hours = map['hours'];
    this._date = map['date'];
    this._published = map['taskpublished'];
    this.colspare1 = map['taskspare1'];
    this.colspare2 = map['taskspare2'];
    this.colspare3 = map['taskspare3'];
    this.colspare4 = map['taskspare4'];
    this.colspare5 = map['taskspare5'];
  }
}
