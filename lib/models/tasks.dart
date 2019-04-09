class Tasks{

  int _id;
  int _reportid;
  String _item;
  String _time;
  String _workperformed;
  String _hours;

	Tasks(this._reportid, this._item, this._time, this._workperformed, this._hours);

	Tasks.withId(this._id, this._reportid, this._item, this._time, this._workperformed, this._hours);

	int get id => _id;

	int get reportid => _reportid;

	String get item => _item;

	String get time => _time;

	String get workperformed => _workperformed;

	String get hours => _hours;


	set reportid(int newTitle) {
			this._reportid = newTitle;
	}

	set item(String newProject) {		
			this._item = newProject;		
	}

  set time(String newPlantloc) {		
			this._time = newPlantloc;		
	}

  set workperformed(String newContactname) {		
			this._workperformed = newContactname;		
	}

  set hours(String newAuthorby) {		
			this._hours = newAuthorby;		
	}

// Convert a Report object into a Map object
	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['reportid'] = _reportid;
		map['item'] = _item;
		map['time'] = _time;
		map['workperformed'] = _workperformed;
		map['hours'] = _hours;
		return map;
	}

  // Extract a Report object from a Map object
	Tasks.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._reportid = map['reportid'];
		this._item = map['item'];
		this._time = map['time'];
		this._workperformed = map['workperformed'];
		this._hours = map['hours'];
	}

}