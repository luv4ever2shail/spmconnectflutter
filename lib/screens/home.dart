import 'dart:io';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/screens/Reports/report_list.dart';
import 'package:spmconnectapp/screens/privacy_policy.dart';
import 'package:spmconnectapp/utils/permissions.dart';

class Myhome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyhomeState();
  }
}

class _MyhomeState extends State<Myhome> {
  static final Config config = new Config(
      Apikeys.tenantid, Apikeys.clientid, "openid profile offline_access");

  final AadOAuth oauth = AadOAuth(config);

  final barColor = const Color(0xFF192A56);
  final bgColor = const Color(0xFFEAF0F1);

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                title: new Text('Are you sure?'),
                content: new Text('Do you want to exit an App'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No'),
                  ),
                  new FlatButton(
                    onPressed: () => exit(0),
                    child: new Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Center(
              child: Text(
            'SPM Connect',
            style: TextStyle(fontSize: 35.0, fontStyle: FontStyle.italic),
          )),
          backgroundColor: barColor,
          leading: Container(),
          actions: <Widget>[
            PopupMenuButton<Choice>(
              onSelected: (choices) {
                if (choices.title == 'Privacy') {
                  navigateToprivacy();
                } else if (choices.title == 'Logout') {
                  logout();
                } else {
                  navigateToPermissions();
                }
              },
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            height: 150.0,
            child: Material(
              type: MaterialType.transparency,
              color: Colors.transparent,
              child: new InkWell(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                splashColor: Colors.deepOrange,
                onTap: () {
                  navigateToDetail();
                },
                child: new Card(
                  margin: EdgeInsets.all(10.0),
                  color: Colors.lightBlueAccent,
                  elevation: 10.0,
                  child: Center(
                    child: ListTile(
                      leading: Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 45.0,
                      ),
                      title: Text(
                        'Service Reports',
                        textScaleFactor: 2.5,
                      ),
                      subtitle: Text(' - Access all you service reports.'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToDetail() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportList();
    }));
  }

  void navigateToprivacy() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PrivacyPolicyScreen();
    }));
  }

  void navigateToPermissions() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MyPermissions();
    }));
  }

  void logout() async {
    try {
      await oauth.logout();
      Navigator.pop(context);
      //showMessage("Logged out", false);
    } catch (e) {}
  }
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Privacy'),
  const Choice(title: 'Logout'),
  const Choice(title: 'Permissions'),
];
