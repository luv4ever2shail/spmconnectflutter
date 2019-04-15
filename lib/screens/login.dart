import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyLoginPageState createState() => new _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  @override
  initState() {
    super.initState();
  }

  static final Config config = new Config(
      "f01aeb10-788c-4137-b031-9eb6bcccd671",
      "47367b96-9640-40ff-912f-73e75cd333f1",
      "openid profile offline_access");
  final AadOAuth oauth = AadOAuth(config);

  String accessToken;


  Future<String> getData() async{
    http.Response response = await http.get(
      Uri.encodeFull("http://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('TestListApp')"),
      headers: {
        "Authorization" : "Bearer " + accessToken,
        "Accept" : "application/json;odata=verbose"

      },
      );

      var data = json.decode(response.body);
      print(data);

      return response.body;

  }

  Widget build(BuildContext context) {
    // adjust window size for browser login
    oauth.setWebViewScreenSize(MediaQuery.of(context).size);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.launch),
                title: Text('Login'),
                onTap: () {
                  login();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Logout'),
                onTap: () {
                  logout();
                },
              ),
              // adding raised button to retrieve data from rest api
              RaisedButton(
                onPressed: getData,
                child: Text('Get Data'),
              ),
            ],
          ),
          constraints: BoxConstraints(
              maxHeight: 300.0,
              maxWidth: 200.0,
              minWidth: 150.0,
              minHeight: 150.0),
        ),
      ),
    );
  }

  void showError(dynamic ex) {
    // showMessage(ex.toString(),false);
    showMessage('Login Interrupted by the user.', false);
  }

  void showMessage(String text, bool login) {
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new FlatButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
            if (login) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Myhome();
              }));
            }
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login() async {
    try {
      await oauth.login();
      accessToken = await oauth.getAccessToken();
      //showMessage("Logged in successfully, your access token: $accessToken",true);
      print('$accessToken');
      showMessage('Logged in successfully', false);
    } catch (e) {
      showError(e);
    }
  }

  void logout() async {
    await oauth.logout();
    showMessage("Logged out", false);
  }
}
