import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spmconnectapp/Resource/connectivity.dart';
import 'package:spmconnectapp/Resource/images_repository.dart';
import 'package:spmconnectapp/Resource/reports_repository.dart';
import 'package:spmconnectapp/Resource/tasks_repository.dart';
import 'package:spmconnectapp/screens/home.dart';
import 'package:spmconnectapp/screens/login.dart';
import 'package:spmconnectapp/themes/appTheme.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await openBox();
  Box _box = Hive.box('myBox');
  String userId = _box.get('Name');
  runApp(new MyApp(userId != null));
}

Future openBox() async {
  // var dir = await getApplicationDocumentsDirectory();
  // Hive.init(dir.path);
  await Hive.initFlutter();
  // Hive.registerAdapter(ProjectManagersAdapter());
  return await Hive.openBox('myBox');
}

class MyApp extends StatefulWidget {
  static restartApp(BuildContext context) {
    final _MyAppState state = context.findAncestorStateOfType();
    state.restartApp();
  }

  static setCustomeTheme(BuildContext context) {
    final _MyAppState state = context.findAncestorStateOfType();
    state.setCustomeTheme();
  }

  final bool auth;
  MyApp(this.auth);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  Future setCustomeTheme() async {
    _box = Hive.box('myBox');
    _box.put('Theme', AppTheme.isLightTheme);
    setState(() {
      AppTheme.isLightTheme = !AppTheme.isLightTheme;
    });
  }

  bool isLoggedIn = false;
  Box _box;
  @override
  void initState() {
    super.initState();
    autoLogIn();
  }

  void autoLogIn() async {
    _box = Hive.box('myBox');
    final String userId = _box.get('Name');
    final bool darktheme = _box.get('Theme') ?? false;
    if (darktheme) setCustomeTheme();

    if (userId != null) {
      setState(() {
        isLoggedIn = true;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyReports>(
          create: (_) => MyReports.instance(),
        ),
        ChangeNotifierProvider<ReportTasks>(
          create: (_) => ReportTasks.instance(),
        ),
        ChangeNotifierProvider<ReportImages>(
          create: (_) => ReportImages.instance(),
        ),
        StreamProvider<ConnectivityStatus>.controller(
          create: (context) => ConnectivityService().connectionStatusController,
        ),
      ],
      child: MainWidget(
        key: key,
        seen: widget.auth,
      ),
    );
  }
}

class MainWidget extends StatelessWidget {
  final bool seen;
  MainWidget({
    Key key,
    this.seen,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          AppTheme.isLightTheme ? Brightness.dark : Brightness.light,
      statusBarBrightness:
          AppTheme.isLightTheme ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          AppTheme.isLightTheme ? Colors.white : Colors.black,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness:
          AppTheme.isLightTheme ? Brightness.dark : Brightness.light,
    ));

    return MaterialApp(
      key: key,
      title: 'Service Report App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      home: seen ? Myhome(null) : MyLoginPage(title: 'SPM Connect Login'),
    );
  }
}
