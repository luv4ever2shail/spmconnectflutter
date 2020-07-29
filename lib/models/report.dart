import 'dart:convert';

Report reportFromJson(String str) => Report.fromJson(json.decode(str));

class Report {
  int id;
  String reportno;
  String projectno;
  String customer;
  String planloc;
  String contactname;
  String authorby;
  String equipment;
  String techname;
  String date;
  String furtheractions;
  String custcomments;
  String custrep;
  String custemail;
  String custcontact;
  String refjob;
  String projectmanager;
  int reportmapid;
  int published;
  int signed;
  String colspare1;
  String colspare2;
  String colspare3;
  String colspare4;
  String colspare5;

  Report(
    this.reportno,
    this.projectno,
    this.customer,
    this.planloc,
    this.contactname,
    this.authorby,
    this.equipment,
    this.techname,
    this.date,
    this.furtheractions,
    this.custcomments,
    this.custrep,
    this.custemail,
    this.custcontact,
    this.refjob,
    this.projectmanager,
    this.reportmapid,
    this.published,
    this.signed,
    this.colspare1,
    this.colspare2,
    this.colspare3,
    this.colspare4,
    this.colspare5,
  );

  Report.withId({
    this.id,
    this.reportno,
    this.projectno,
    this.customer,
    this.planloc,
    this.contactname,
    this.authorby,
    this.equipment,
    this.techname,
    this.date,
    this.furtheractions,
    this.custcomments,
    this.custrep,
    this.custemail,
    this.custcontact,
    this.refjob,
    this.projectmanager,
    this.reportmapid,
    this.signed,
    this.published,
    this.colspare1,
    this.colspare2,
    this.colspare3,
    this.colspare4,
    this.colspare5,
  });

  int get getId => id;

  int get getreportmapid => reportmapid;

  int get getreportpublished => published;

  int get getreportsigned => signed;

  String get getprojectno => projectno;

  String get getreportno => reportno;

  String get getcustomer => customer;

  String get getplantloc => planloc;

  String get getcontactname => contactname;

  String get getauthorby => authorby;

  String get getequipment => equipment;

  String get gettechname => techname;

  String get getdate => date;

  String get getfurtheractions => furtheractions;

  String get getcustcomments => custcomments;

  String get getcustrep => custrep;

  String get getcustemail => custemail;

  String get getcustcontact => custcontact;

  String get getrefjob => refjob;

  String get getprojectmanager => projectmanager;

  String get getspare1 => colspare1;
  String get getspare2 => colspare2;
  String get getspare3 => colspare3;
  String get getspare4 => colspare4;
  String get getspare5 => colspare5;

  set getreportmapid(int newReportid) {
    this.reportmapid = newReportid;
  }

  set getreportpublished(int newPublishid) {
    this.published = newPublishid;
  }

  set getreportsigned(int newSigned) {
    this.signed = newSigned;
  }

  set getprojectno(String newProject) {
    this.projectno = newProject;
  }

  set repotno(String newReport) {
    this.reportno = newReport;
  }

  set getcustomer(String newCustomer) {
    this.customer = newCustomer;
  }

  set getplantloc(String newPlantloc) {
    this.planloc = newPlantloc;
  }

  set getcontactname(String newContactname) {
    this.contactname = newContactname;
  }

  set getauthorby(String newAuthorby) {
    this.authorby = newAuthorby;
  }

  set getequipment(String newEquipment) {
    this.equipment = newEquipment;
  }

  set gettechname(String newTechname) {
    this.techname = newTechname;
  }

  set getdate(String newDate) {
    this.date = newDate;
  }

  set getfurtheractions(String furtheractions) {
    this.furtheractions = furtheractions;
  }

  set getcustcomments(String custcomments) {
    this.custcomments = custcomments;
  }

  set getcustrep(String custrep) {
    this.custrep = custrep;
  }

  set getcustemail(String custemail) {
    this.custemail = custemail;
  }

  set getcustcontact(String custcontact) {
    this.custcontact = custcontact;
  }

  set getrefjob(String jobno) {
    this.refjob = jobno;
  }

  set getprojectmanager(String pm) {
    this.projectmanager = pm;
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
    if (getId != null) {
      map['id'] = id;
    }
    map['projectno'] = projectno;
    map['reportno'] = reportno;
    map['customer'] = customer;
    map['plantloc'] = planloc;
    map['contactname'] = contactname;
    map['authorby'] = authorby;
    map['equipment'] = equipment;
    map['techname'] = techname;
    map['date'] = date;
    map['furtheractions'] = furtheractions;
    map['custcomments'] = custcomments;
    map['custrep'] = custrep;
    map['custemail'] = custemail;
    map['custcontact'] = custcontact;
    map['refjob'] = refjob;
    map['projectmanager'] = projectmanager;
    map['reportmapid'] = reportmapid;
    map['reportpublished'] = published;
    map['reportsigned'] = signed;
    map['spare1'] = colspare1;
    map['spare2'] = colspare2;
    map['spare3'] = colspare3;
    map['spare4'] = colspare4;
    map['spare5'] = colspare5;

    return map;
  }

  // Extract a Report object from a Map object
  Report.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.projectno = map['projectno'] ?? '';
    this.reportno = map['reportno'];
    this.customer = map['customer'] ?? '';
    this.planloc = map['plantloc'] ?? '';
    this.contactname = map['contactname'] ?? '';
    this.authorby = map['authorby'] ?? '';
    this.equipment = map['equipment'] ?? '';
    this.techname = map['techname'] ?? '';
    this.date = map['date'] ?? '';
    this.furtheractions = map['furtheractions'] ?? '';
    this.custcomments = map['custcomments'] ?? '';
    this.custrep = map['custrep'] ?? '';
    this.custemail = map['custemail'] ?? '';
    this.custcontact = map['custcontact'] ?? '';
    this.refjob = map['refjob'];
    this.projectmanager = map['projectmanager'] ?? '';
    this.reportmapid = map['reportmapid'];
    this.published = map['reportpublished'];
    this.signed = map['reportsigned'];
    this.colspare1 = map['spare1'];
    this.colspare2 = map['spare2'];
    this.colspare3 = map['spare3'];
    this.colspare4 = map['spare4'];
    this.colspare5 = map['spare5'];
  }

  factory Report.fromJson(Map<String, dynamic> json) => Report.withId(
        reportno: json["Title"],
        id: int.parse(json["Report_Id"]),
        projectno: json["ProjectNo"],
        customer: json["Customer"],
        planloc: json["PlantLoc"],
        contactname: json["ContactName"],
        authorby: json["Authorizedby"],
        equipment: json["Equipment"],
        techname: json["TechName"],
        date: json["DateCreated"],
        furtheractions: json["FurtherActions"],
        custcomments: json["CustComments"],
        custrep: json["CustRep"],
        custemail: json["CustEmail"],
        custcontact: json["CustContact"],
        reportmapid: int.parse(json["ReportMapId"]),
        published: 1,
        signed: int.parse(json["Signed"]),
        colspare1: json["Spare1"],
        colspare2: json["Spare2"],
        colspare3: json["Spare3"],
        colspare4: json["Spare4"],
        colspare5: json["Spare5"],
        refjob: json["RefJob"],
        projectmanager: json["ProjectManager"],
      );
}
