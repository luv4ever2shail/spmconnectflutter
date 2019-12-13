import 'dart:convert';

Users usersFromJson(String str) => Users.fromJson(json.decode(str));

String usersToJson(Users data) => json.encode(data.toJson());

class Users {
  String displayName;
  String givenName;
  String mail;
  String surname;
  String empid;
  String id;
  String jobtitle;

  Users({
    this.displayName,
    this.givenName,
    this.mail,
    this.surname,
    this.empid,
    this.id,
    this.jobtitle,
  });

  factory Users.fromJson(Map<String, dynamic> json) => new Users(
        displayName: json["displayName"],
        givenName: json["givenName"],
        mail: json["mail"],
        surname: json["surname"],
        empid: json["employeeId"],
        id: json["id"],
        jobtitle: json["jobTitle"],
      );

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "givenName": givenName,
        "mail": mail,
        "surname": surname,
        "employeeId": empid,
        "id": id,
        "jobTitle": jobtitle,
      };
}
