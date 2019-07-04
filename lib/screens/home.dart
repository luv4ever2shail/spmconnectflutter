import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/aad_auth/aad_oauth.dart';
import 'package:spmconnectapp/aad_auth/model/config.dart';
import 'package:spmconnectapp/models/users.dart';
import 'package:spmconnectapp/screens/Reports/report_list.dart';
import 'package:spmconnectapp/screens/Sharepoint/report_list_unpublished.dart';
import 'package:spmconnectapp/screens/login.dart';
import 'package:spmconnectapp/screens/privacy_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmconnectapp/utils/profiledialog.dart';

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
  String sfName;
  String sfEmail;
  String sfID;
  String sfPosition;
  String sfEmpid;
  String sfprofilepic;
  @override
  void initState() {
    super.initState();
    if (accessToken != null) {
      getUserInfo(accessToken);
      getUserPic(accessToken);
    }
    getUserInfoSF();
  }

  static final Config config = new Config(Apikeys.tenantid, Apikeys.clientid,
      "openid profile offline_access", Apikeys.redirectUrl);

  final AadOAuth oauth = AadOAuth(config);
  var drawerIcons = [
    Icon(Icons.person),
    Icon(Icons.security),
    Icon(Icons.sync),
    Icon(Icons.exit_to_app)
  ];
  var drawerText = ["Profile", "Privacy", "Sync Reports", "Log Out"];

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
          centerTitle: true,
          title: Text(
            'SPM Connect',
            style: TextStyle(fontSize: 35.0, fontStyle: FontStyle.italic),
          ),
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
                      subtitle:
                          Text('- Create/Access all you service reports.'),
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
      _users == null
          ? sfEmail == null ? 'Email Not Found' : sfEmail
          : _users.mail == null ? 'Email Not Found' : _users.mail,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );

    Text name = new Text(
      _users == null
          ? sfName == null ? 'Name Not Found' : sfName
          : _users.displayName == null ? 'Name Not Found' : _users.displayName,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );

    return Drawer(
        child: Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: barColor),
          accountName: name,
          accountEmail: email,
          currentAccountPicture: GestureDetector(
            child: sfprofilepic == null
                ? Icon(
                    Icons.account_circle,
                    size: 60.0,
                    color: Colors.white,
                  )
                : ClipOval(
                    child: Image.file(File('$sfprofilepic')),
                  ),
            onTap: () {
              Navigator.of(context).pop();
              showprofile();
            },
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
                        showprofile();
                      } else if (drawerText[position] == 'Privacy') {
                        navigateToprivacy();
                      } else if (drawerText[position] == 'Sync Reports') {
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

  void showprofile() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            name: sfName,
            email: sfEmail,
            jobtitle: sfPosition,
            empid: sfEmpid,
            id: sfID,
            buttonText: "Okay",
            profile: sfprofilepic,
          ),
    );
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

  void logout() async {
    try {
      removeUserInfoFromSF();
      await oauth.logout();
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyLoginPage();
      }));
    } catch (e) {}
  }

  Future storeUserInfoToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Name', _users.displayName);
    prefs.setString('Email', _users.mail);
    prefs.setString('Position', _users.jobtitle);
    prefs.setString('Id', _users.id);
    prefs.setString('EmpId', _users.empid);
    setState(() {});
  }

  Future removeUserInfoFromSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("Name");
    prefs.remove("Email");
    prefs.remove("Position");
    prefs.remove("Id");
    prefs.remove("EmpId");
    prefs.remove('Profilepic');
  }

  Future getUserInfoSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sfName = prefs.getString('Name');
    sfEmail = prefs.getString('Email');
    sfPosition = prefs.getString('Position');
    sfID = prefs.getString('Id');
    sfEmpid = prefs.getString('EmpId');
    sfprofilepic = prefs.getString('Profilepic');
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
      await removeUserInfoFromSF();
      await storeUserInfoToSF();
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
        },
      );
      if (response.statusCode == 200) {
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        await Directory('$path/Picture').create(recursive: true);
        File('$path/Picture/profile.jpg').writeAsBytesSync(response.bodyBytes);
        var filePath = '$path/Picture/profile.jpg';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('Profilepic', filePath);
        setState(() {
          sfprofilepic = filePath;
        });
        await getUserInfoSF();
      }
    } catch (e) {
      print(e);
    }
  }
}
