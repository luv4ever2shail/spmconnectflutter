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
                // action button
                // overflow menu
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
            body: Column(
              children: <Widget>[
               Padding(
                 padding: EdgeInsets.all(2.0),
                child :Center(
                  child: Card(
                    elevation: 10.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          leading: Icon(Icons.description),
                          title: Text('Service Reports',textScaleFactor: 2.0,),
                          subtitle: Text(
                              'Access all you service reports.'),
                        ),
                        ButtonTheme.bar(
                          // make buttons use the appropriate styles for cards
                          child: ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('View Reports'),
                                onPressed: () {navigateToDetail();},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
               )
              ],
            )));
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
