import 'dart:convert';
import 'dart:io';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/models/users.dart';
import 'package:spmconnectapp/screens/Reports/report_list.dart';
import 'package:spmconnectapp/screens/privacy_policy.dart';
import 'package:spmconnectapp/utils/permissions.dart';

class Myhome extends StatefulWidget {
  final String accessToken;

  Myhome(this.accessToken);
  @override
  State<StatefulWidget> createState() {
    return _MyhomeState(this.accessToken);
  }
}

class _MyhomeState extends State<Myhome> {
  String accessToken;
  _MyhomeState(this.accessToken);
  Users _users;
  Image image;
  @override
  void initState() {
    super.initState();
    getUserInfo(accessToken);
  }

  static final Config config = new Config(Apikeys.tenantid, Apikeys.clientid,
      "openid profile offline_access", Apikeys.redirectUrl);

  final AadOAuth oauth = AadOAuth(config);
  var drawerIcons = [
    Icon(Icons.person),
    Icon(Icons.security),
    Icon(Icons.lock),
    Icon(Icons.exit_to_app)
  ];
  var drawerText = ["Profile", "Privacy", "Permissions", "Log Out"];

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
        drawer: _users == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _getMailAccountDrawerr(),
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Center(
              child: Text(
            'SPM Connect',
            style: TextStyle(fontSize: 35.0, fontStyle: FontStyle.italic),
          )),
          backgroundColor: barColor,
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
                        textScaleFactor: 2.0,
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

  Drawer _getMailAccountDrawerr() {
    Text email = new Text(
      _users.mail == null ? '' : _users.mail,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );

    Text name = new Text(
      _users.displayName == null ? '' : _users.displayName,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );

    return Drawer(
        child: Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: barColor),
          accountName: name,
          accountEmail: email,
          currentAccountPicture: image == null
              ? Icon(
                  Icons.account_circle,
                  size: 60.0,
                  color: Colors.white,
                )
              : ImageIcon(
                  AssetImage('assets/officelogo.png'),
                  size: 35,
                  color: Colors.deepOrange,
                ),
        ),
        Expanded(
          flex: 2,
          child: ListView.builder(
              padding: EdgeInsets.only(top: 0.0),
              itemCount: drawerText.length,
              itemBuilder: (context, position) {
                return ListTile(
                  leading: drawerIcons[position],
                  title: Text(drawerText[position],
                      style: TextStyle(fontSize: 15.0)),
                  onTap: () {
                    this.setState(() {
                      Navigator.pop(context);
                      if (drawerText[position] == "Profile") {
                        print('profile');
                      } else if (drawerText[position] == 'Privacy') {
                        navigateToprivacy();
                      } else if (drawerText[position] == 'Permissions') {
                        navigateToPermissions();
                      } else if (drawerText[position] == 'Log Out') {
                        logout();
                      }
                    });
                  },
                );
              }),
        )
      ],
    ));
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

  Future getUserInfo(String accesstoken) async {
    Future.delayed(new Duration(seconds: 5), () {});
    try {
      Response response = await get(
        Uri.encodeFull("https://graph.microsoft.com/v1.0/me"),
        headers: {
          "Authorization": "Bearer " + accesstoken,
          "Accept": "application/json"
        },
      );
      var data = json.decode(response.body);
      _users = Users.fromJson(data);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future getUserPic(String accesstoken) async {
    try {
      Response response = await get(
        Uri.encodeFull("https://graph.microsoft.com/v1.0/me/photo/\$value"),
        headers: {
          "Authorization": "Bearer " + accesstoken,
          "Accept": "application/json"
        },
      );

      image = json.decode(response.body);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }
}
