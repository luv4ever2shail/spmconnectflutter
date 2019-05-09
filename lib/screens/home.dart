import 'dart:convert';
import 'dart:io';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/models/users.dart';
import 'package:spmconnectapp/screens/Reports/report_list.dart';
import 'package:spmconnectapp/screens/Sharepoint/report_list_unpublished.dart';
import 'package:spmconnectapp/screens/login.dart';
import 'package:spmconnectapp/screens/privacy_policy.dart';
import 'package:spmconnectapp/utils/permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String sfName;
  String sfEmail;
  String sfID;
  String sfPosition;
  String sfEmpid;

  @override
  void initState() {
    super.initState();
    if (accessToken != null) {
      getUserInfo(accessToken);
    }
    getUserInfoSF();
  }

  static final Config config = new Config(Apikeys.tenantid, Apikeys.clientid,
      "openid profile offline_access", Apikeys.redirectUrl);

  final AadOAuth oauth = AadOAuth(config);
  var drawerIcons = [
    Icon(Icons.person),
    Icon(Icons.security),
    Icon(Icons.lock),
    Icon(Icons.sync),
    Icon(Icons.exit_to_app)
  ];
  var drawerText = [
    "Profile",
    "Privacy",
    "Permissions",
    "Sync Data",
    "Log Out"
  ];

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
            ? sfEmail == null && sfName == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _getMailAccountDrawerr()
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
                  navigateToReports();
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
      sfEmail == null ? '' : sfEmail,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );

    Text name = new Text(
      sfName == null ? '' : sfName,
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
          onDetailsPressed: () => showDialog(
              context: context, builder: (context) => _userprofile(context)),
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
                        getUserInfoSF();
                        showDialog(
                            context: context,
                            builder: (context) => _userprofile(context));
                      } else if (drawerText[position] == 'Privacy') {
                        navigateToprivacy();
                      } else if (drawerText[position] == 'Permissions') {
                        navigateToPermissions();
                      } else if (drawerText[position] == 'Sync Data') {
                        navigateToReportsUnpublished();
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

  void navigateToReports() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportList();
    }));
  }

  void navigateToReportsUnpublished() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportListUnpublished();
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
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyLoginPage();
      }));
    } catch (e) {}
  }

  storeUserInfoToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Name', _users.displayName);
    prefs.setString('Email', _users.mail);
    prefs.setString('Position', _users.jobtitle);
    prefs.setString('Id', _users.id);
    prefs.setString('EmpId', _users.empid);
    setState(() {});
  }

  removeUserInfoFromSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Remove String
    prefs.remove("Name");
    prefs.remove("Email");
    prefs.remove("Position");
    prefs.remove("Id");
    prefs.remove("EmpId");
  }

  getUserInfoSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sfName = prefs.getString('Name');
    sfEmail = prefs.getString('Email');
    sfPosition = prefs.getString('Position');
    sfID = prefs.getString('Id');
    sfEmpid = prefs.getString('EmpId');
    setState(() {});
  }

  Future getUserInfo(String accesstoken) async {
    try {
      Response response = await get(
        Uri.encodeFull("https://graph.microsoft.com/beta/me/"),
        headers: {
          "Authorization": "Bearer " + accesstoken,
          "Accept": "application/json"
        },
      );
      var data = json.decode(response.body);
      _users = Users.fromJson(data);
      setState(() {});
      removeUserInfoFromSF();
      storeUserInfoToSF();
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
          "Content-Type": "image/jpg",
        },
      );
      return response;
    } catch (e) {
      print(e);
    }
  }

  Widget _userprofile(BuildContext context) {
    ThemeData localtheme = Theme.of(context);
    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      elevation: 10.0,
      title: Text('User Information'),
      shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Text(
                _users == null ? sfName : _users.displayName,
                style: localtheme.textTheme.headline,
              ),
              new Text(
                _users == null ? sfEmail : 'Email : ${_users.mail}',
                style: localtheme.textTheme.subhead
                    .copyWith(fontStyle: FontStyle.italic),
              ),
              SizedBox(
                height: 2.0,
              ),
              new Text(
                _users == null
                    ? 'Job Tile : $sfPosition'
                    : 'Job Tile : ${_users.jobtitle}',
                style: localtheme.textTheme.subhead
                    .copyWith(fontStyle: FontStyle.italic),
              ),
              new Text(
                _users == null ? 'Id : $sfID' : 'Id : ${_users.id}',
                style: localtheme.textTheme.body2,
              ),
              new Text(
                _users == null
                    ? 'Emp Id : $sfEmpid'
                    : 'Emp Id : ${_users.empid}',
                style: localtheme.textTheme.body2,
              )
            ],
          ),
        )
      ],
    );
  }
}
