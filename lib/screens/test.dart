import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/home.dart';

class BasicAppBarSample extends StatefulWidget {
  @override
  _BasicAppBarSampleState createState() => _BasicAppBarSampleState();
}

class _BasicAppBarSampleState extends State<BasicAppBarSample> {
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Basic AppBar'),
          actions: <Widget>[
            // action button            
            // overflow menu
            PopupMenuButton<Choice>(
              onSelected: (choices){
                navigateToDetail();
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
          padding: const EdgeInsets.all(16.0),
          //child: ChoiceCard(choice: _selectedChoice),
        ),
      ),
    );
  }


  void navigateToDetail() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Myhome();
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

