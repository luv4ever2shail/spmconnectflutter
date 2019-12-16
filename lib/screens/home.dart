import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/Resource/reports_repository.dart';
import 'package:spmconnectapp/aad_auth/aad_oauth.dart';
import 'package:spmconnectapp/aad_auth/model/config.dart';
import 'package:spmconnectapp/models/users.dart';
import 'package:spmconnectapp/screens/Reports/report_list.dart';
import 'package:spmconnectapp/screens/Sharepoint/report_list_unpublished.dart';
import 'package:spmconnectapp/screens/login.dart';
import 'package:spmconnectapp/screens/privacy_policy.dart';
import 'package:spmconnectapp/themes/appTheme.dart';
import 'package:spmconnectapp/utils/profiledialog.dart';

class Myhome extends StatefulWidget {
  final String accessToken;

  Myhome(this.accessToken);
  @override
  State<StatefulWidget> createState() {
    return _MyhomeState(this.accessToken);
  }
}

class _MyhomeState extends State<Myhome> with TickerProviderStateMixin {
  AnimationController animationController;
  String accessToken;
  Box _box;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  _MyhomeState(this.accessToken);
  Users _users;
  @override
  void initState() {
    animationController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    animationController..forward();
    _box = Hive.box('myBox');
    if (accessToken != null) {
      getUserInfo(accessToken);
      getUserPic(accessToken);
    }
    initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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
    MyReports myReports = Provider.of<MyReports>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: _box.get('Name') != null
            ? _getMailAccountDrawerr(myReports)
            : Container(),
        backgroundColor: AppTheme.getTheme().backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'SPM Connect',
            style: TextStyle(fontSize: 35.0, fontStyle: FontStyle.italic),
          ),
          backgroundColor: AppTheme.barColor,
        ),
        body: AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: animationController,
                child: new Transform(
                  transform: new Matrix4.translationValues(
                      0.0, 40 * (1.0 - animationController.value), 0.0),
                  child: ListView.builder(
                    itemCount: 1,
                    padding: EdgeInsets.only(
                      top: 0,
                    ),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            height: 150.0,
                            child: Material(
                              type: MaterialType.transparency,
                              color: Colors.transparent,
                              child: new InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                splashColor: Colors.deepOrange,
                                onTap: () async {
                                  await animationController
                                      .reverse()
                                      .then((f) async {
                                    await navigateToReports(myReports);
                                  }).then((onValue) {
                                    animationController.forward();
                                  });
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
                                      subtitle: Text(
                                          '- Create/Access all you service reports.'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              );
            }),
      ),
    );
  }

  Drawer _getMailAccountDrawerr(MyReports myReports) {
    Text email = new Text(
      _box.get('Email'),
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );
    Text name = new Text(
      _box.get('Name'),
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
    );

    return Drawer(
        child: Container(
      color: AppTheme.getTheme().backgroundColor,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.barColor,
            ),
            otherAccountsPictures: <Widget>[
              // SizedBox(
              //   height: AppBar().preferredSize.height,
              //   child: Padding(
              //     padding: EdgeInsets.only(top: 8, right: 8),
              //     child: Container(
              //       width: AppBar().preferredSize.height - 8,
              //       height: AppBar().preferredSize.height - 8,
              //       child: Material(
              //         color: Colors.transparent,
              //         child: InkWell(
              //           borderRadius: BorderRadius.all(
              //             Radius.circular(32.0),
              //           ),
              //           onTap: () {
              //             MyApp.setCustomeTheme(context);
              //           },
              //           child: Icon(
              //             Icons.lightbulb_outline,
              //             color: AppTheme.isLightTheme
              //                 ? Colors.white
              //                 : Colors.lightBlue,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
            accountName: name,
            accountEmail: email,
            currentAccountPicture: GestureDetector(
              child: _box.get('Profilepic') == null
                  ? Icon(
                      Icons.account_circle,
                      size: 60.0,
                      color: Colors.white,
                    )
                  : ClipOval(
                      child: Image.file(File('${_box.get('Profilepic')}')),
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
                    onTap: () async {
                      Navigator.pop(context);
                      if (drawerText[position] == "Profile") {
                        showprofile();
                      } else if (drawerText[position] == 'Privacy') {
                        navigateToprivacy();
                      } else if (drawerText[position] == 'Sync Reports') {
                        await myReports.getReportListUnpublished();
                        navigateToReportsUnpublished();
                      } else if (drawerText[position] == 'Log Out') {
                        await signout(context);
                      }
                    },
                  );
                }),
          )
        ],
      ),
    ));
  }

  void showprofile() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        name: _box.get('Name'),
        email: _box.get('Email'),
        jobtitle: _box.get('Position'),
        empid: _box.get('EmpId'),
        id: _box.get('Id'),
        buttonText: "Okay",
        profile: _box.get('Profilepic'),
      ),
    );
  }

  Future<void> navigateToReports(MyReports myReports) async {
    await myReports.fetchReports();
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

  Future<void> signout(BuildContext _context) async {
    bool result = await showAlertDialog(
        _context, 'Logout', 'Do you really wanna logout?');
    print(result);
    if (result) {
      await removeUserInfoFromSF();
      await oauth.logout();
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyLoginPage();
      }));
    }
  }

  Future<bool> showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext br) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(
            title,
            style: TextStyle(color: AppTheme.barColor, fontSize: 25),
          ),
          content: Text(
            message,
            style: new TextStyle(
                fontSize: 15, fontFamily: 'Nunito', color: AppTheme.barColor),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'No',
                style: new TextStyle(
                    fontSize: 15,
                    fontFamily: 'Nunito',
                    color: AppTheme.barColor),
              ),
              onPressed: () {
                result = false;
                Navigator.pop(br);
              },
            ),
            FlatButton(
              child: Text(
                'Yes',
                style: new TextStyle(
                    fontSize: 15,
                    fontFamily: 'Nunito',
                    color: AppTheme.barColor),
              ),
              onPressed: () {
                result = true;
                Navigator.pop(br);
              },
            )
          ],
        );
      },
    );
    return result;
  }

  Future storeUserInfoToSF() async {
    _box.put('Name', _users.displayName);
    _box.put('Email', _users.mail);
    _box.put('Position', _users.jobtitle);
    _box.put('Id', _users.id);
    _box.put('EmpId', _users.empid);
    setState(() {});
  }

  Future removeUserInfoFromSF() async {
    _box.delete("Name");
    _box.delete("Email");
    _box.delete("Position");
    _box.delete("Id");
    _box.delete("EmpId");
    _box.delete('Profilepic');
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
      print("Get User Info : " + e);
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
        _box.put('Profilepic', filePath);
        setState(() {});
      }
    } catch (e) {
      print("Get User Picture : " + e);
    }
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
      print(_deviceData[0].toString());
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
