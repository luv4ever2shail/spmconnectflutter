import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/report_list.dart';
import 'package:spmconnectapp/screens/privacy_policy.dart';

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
        appBar: AppBar(
          title: Text('SPM Connect'),
          backgroundColor: barColor,
          actions: <Widget>[
            PopupMenuButton<Choice>(
              onSelected: (choices) {
                navigateToprivacy();
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
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Privacy'),
];
