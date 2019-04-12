import 'package:flutter/material.dart';
// import 'package:spmconnectapp/Maps.dart';
//import 'package:spmconnectapp/screens/home.dart';
import 'package:spmconnectapp/screens/login.dart';

void main() => runApp(MyApp());

//*Main widget called MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Reports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home:MyLoginPage(title : 'SPM Connect Login'),
    );
  }
}
