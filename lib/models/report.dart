class Report {
  int _id;
  String _projectno;
  String _customer;
  String _planloc;
  String _contactname;
  String _authorby;
  String _equipment;
  String _techname;
  String _date;
  String _furtheractions;
  String _custcomments;
  String _custrep;
  String _custemail;
  String _custcontact;
  int _reportmapid;

  Report(
      this._projectno,
      this._customer,
      this._planloc,
      this._contactname,
      this._authorby,
      this._equipment,
      this._techname,
      this._date,
      this._reportmapid);

  Report.withId(
      this._id,
      this._projectno,
      this._customer,
      this._planloc,
      this._contactname,
      this._authorby,
      this._equipment,
      this._techname,
      this._date,
      this._furtheractions,
      this._custcomments,
      this._custrep,
      this._custemail,
      this._custcontact,
      this._reportmapid);

  int get id => _id;

  int get reportmapid => _reportmapid;

  String get projectno => _projectno;

  String get customer => _customer;

  String get plantloc => _planloc;

  String get contactname => _contactname;

  String get authorby => _authorby;

  String get equipment => _equipment;

  String get techname => _techname;

  String get date => _date;

  String get furtheractions => _furtheractions;

  String get custcomments => _custcomments;

  String get custrep => _custrep;

  String get custemail => _custemail;

  String get custcontact => _custcontact;


  set reportmapid(int newReportid) {
    this._reportmapid = newReportid;
  }

  set projectno(String newTitle) {
    if (newTitle.length <= 255) {
      this._projectno = newTitle;
    }
  }

  set customer(String newCustomer) {
    this._customer = newCustomer;
  }

  set plantloc(String newPlantloc) {
    this._planloc = newPlantloc;
  }

  set contactname(String newContactname) {
    this._contactname = newContactname;
  }

  set authorby(String newAuthorby) {
    this._authorby = newAuthorby;
  }

  set equipment(String newEquipment) {
    this._equipment = newEquipment;
  }

  set techname(String newTechname) {
    this._techname = newTechname;
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set furtheractions(String furtheractions) {
    this._furtheractions = furtheractions;
  }

  set custcomments(String custcomments) {
    this._custcomments = custcomments;
  }

  set custrep(String custrep) {
    this._custrep = custrep;
  }

   set custemail(String custemail) {
    this._custemail = custemail;
  }

   set custcontact(String custcontact) {
    this._custcontact = custcontact;
  }

// Convert a Report object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['projectno'] = _projectno;
    map['customer'] = _customer;
    map['plantloc'] = _planloc;
    map['contactname'] = _contactname;
    map['authorby'] = _authorby;
    map['equipment'] = _equipment;
    map['techname'] = _techname;
    map['date'] = _date;
    map['furtheractions'] = _furtheractions;
    map['custcomments'] = _custcomments;
    map['custrep'] = _custrep;
    map['custemail'] = _custemail;
    map['custcontact'] = _custcontact;
    map['reportmapid'] = _reportmapid;

    return map;
  }

  // Extract a Report object from a Map object
  Report.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._projectno = map['projectno'];
    this._customer = map['customer'];
    this._planloc = map['plantloc'];
    this._contactname = map['contactname'];
    this._authorby = map['authorby'];
    this._equipment = map['equipment'];
    this._techname = map['techname'];
    this._date = map['date'];
    this._furtheractions = map['furtheractions'];
    this._custcomments = map['custcomments'];
    this._custrep = map['custrep'];
    this._custemail = map['custemail'];
    this._custcontact = map['custcontact'];
    this._reportmapid = map['reportmapid'];
  }
}
