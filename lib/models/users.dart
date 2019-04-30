// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';

Users usersFromJson(String str) => Users.fromJson(json.decode(str));

String usersToJson(Users data) => json.encode(data.toJson());

class Users {
  String displayName;
  String givenName;
  String mail;
  String surname;
  String userPrincipalName;

  Users({
    this.displayName,
    this.givenName,
    this.mail,
    this.surname,
    this.userPrincipalName,
  });

  factory Users.fromJson(Map<String, dynamic> json) => new Users(
        displayName: json["displayName"],
        givenName: json["givenName"],
        mail: json["mail"],
        surname: json["surname"],
        userPrincipalName: json["userPrincipalName"],
      );

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "givenName": givenName,
        "mail": mail,
        "surname": surname,
        "userPrincipalName": userPrincipalName,
      };
}
