import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/report_list.dart';
//import 'package:spmconnect/screens/report_detail.dart';
void main() => runApp(MyApp());

//*Main widget called MyApp
class MyApp extends StatelessWidget {

	@override
  Widget build(BuildContext context) {
    return MaterialApp(
	    title: 'Service Reports',
	    debugShowCheckedModeBanner: false,
	    theme: ThemeData(
		    primarySwatch: Colors.blue
	    ),
	    home: ReportList(),
    );
  }
}