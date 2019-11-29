import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spmconnectapp/screens/home.dart';
import 'package:spmconnectapp/screens/login.dart';
import 'package:spmconnectapp/themes/colors.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await openBox();
  Box _box = Hive.box('myBox');
  String userId = _box.get('Name');
  runApp(new MyApp(userId != null));
}

Future openBox() async {
  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  return await Hive.openBox('myBox');
}

class MyApp extends StatefulWidget {
  final bool auth;
  MyApp(this.auth);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  Box _box;
  @override
  void initState() {
    super.initState();
    //autoLogIn();
  }

  void autoLogIn() async {
    _box = Hive.box('myBox');
    final String userId = _box.get('Name');

    if (userId != null) {
      setState(() {
        isLoggedIn = true;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Service Reports',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        home: widget.auth
            ? Myhome(null)
            : MyLoginPage(title: 'SPM Connect Login'));
  }
}
