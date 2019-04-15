class Tasks{

  int _id;
  int _reportid;
  String _item;
  String _starttime;
  String _endtime;
  String _workperformed;
  String _hours;
  String _date;

	Tasks(this._reportid, this._item, this._starttime, this._endtime, this._workperformed, this._hours,this._date);

	Tasks.withId(this._id, this._reportid, this._item, this._starttime, this._endtime, this._workperformed, this._hours,this._date);

	int get id => _id;

	int get reportid => _reportid;

	String get item => _item;

	String get starttime => _starttime;

	String get endtime => _endtime;

	String get workperformed => _workperformed;

	String get hours => _hours;

  String get date => _date;

	set reportid(int newReportid) {
			this._reportid = newReportid;
	}

	set item(String newItem) {		
			this._item = newItem;		
	}

  set starttime(String newStarttime) {		
			this._starttime = newStarttime;		
	}

  set endtime(String newEndtime) {		
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

// Convert a Report object into a Map object
	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['reportid'] = _reportid;
		map['item'] = _item;
		map['starttime'] = _starttime;
		map['endtime'] = _endtime;
		map['workperformed'] = _workperformed;
		map['hours'] = _hours;
    map['date'] = _date;
		return map;
	}

  // Extract a Report object from a Map object
	Tasks.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._reportid = map['reportid'];
		this._item = map['item'];
		this._starttime = map['starttime'];
		this._endtime = map['endtime'];
		this._workperformed = map['workperformed'];
		this._hours = map['hours'];
    this._date = map['date'];
	}

}