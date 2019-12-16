class Images {
  String _identifier;
  String _name;
  int _width;
  int _height;
  String _reportid;
  int _published;
  String colspare1;
  String colspare2;
  String colspare3;

  Images(
    this._identifier,
    this._name,
    this._height,
    this._width,
    this._reportid,
    this._published,
    this.colspare1,
    this.colspare2,
    this.colspare3,
  );

  int get width => _width;

  int get height => _height;

  int get published => _published;

  String get identifier => _identifier;

  String get name => _name;

  String get reportid => _reportid;

  String get spare1 => colspare1;
  String get spare2 => colspare2;
  String get spare3 => colspare3;

  set published(int newPublishid) {
    this._published = newPublishid;
  }

  set identifier(String newIdentifier) {
    this._identifier = newIdentifier;
  }

  set reportid(String newReportid) {
    this._reportid = newReportid;
  }

  set width(int newWidth) {
    this._width = newWidth;
  }

  set height(int newHeight) {
    this._height = newHeight;
  }

  set name(String newName) {
    this._name = newName;
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

// Convert a Report object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['reportid'] = _reportid;
    map['identifier'] = _identifier;
    map['name'] = _name;
    map['width'] = _width;
    map['height'] = _height;
    map['imagepublished'] = _published;
    map['spare1'] = colspare1;
    map['spare2'] = colspare2;
    map['spare3'] = colspare3;
    return map;
  }

  // Extract a Report object from a Map object
  Images.fromMapObject(Map<String, dynamic> map) {
    this._reportid = map['reportid'];
    this._identifier = map['identifier'];
    this._name = map['name'];
    this._width = map['width'];
    this._height = map['height'];
    this._published = map['imagepublished'];
    this.colspare1 = map['spare1'];
    this.colspare2 = map['spare2'];
    this.colspare3 = map['spare3'];
  }
}
