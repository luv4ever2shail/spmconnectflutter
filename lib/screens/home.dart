import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/report_list.dart';

class Myhome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyhomeState();
  }
}

class _MyhomeState extends State<Myhome> {
  final barColor = const Color(0xFF192A56);
  final bgColor = const Color(0xFFEAF0F1);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: bgColor,
            appBar:
                AppBar(title: Text('SPM Connect'), backgroundColor: barColor),
            body: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(5.0),
                  child: Card(
                    color: Colors.white,
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      onTap: () {
                        navigateToDetail();
                      },
                      child: Image.asset(
                        'assets/tools.jpg',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                Text(
                  'Service Reports',
                  textScaleFactor: 2.0,
                )
                
              ],
              
            )));
  }

  void navigateToDetail() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportList();
    }));
  }
}
