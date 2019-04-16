import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:spmconnectapp/API_Keys/api.dart';

class Myrestapipage extends StatefulWidget {
  @override
  _MyrestapipageState createState() => new _MyrestapipageState();
}

class _MyrestapipageState extends State<Myrestapipage> {
  Future<String> getData() async {
    http.Response response = await http.get(
      Uri.encodeFull(
          "http://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('TestList')"),
      headers: {
        "Authorization": "Bearer ",
        "Accept": "application/json;odata=verbose"
      },
    );

    List data = json.decode(response.body);
    print(data[1]['title']);

    return response.body;
  }

  Future getListData() async {
    try {
      http.Response response = await http.get(
        Uri.encodeFull(Apikeys.sharepointListUrl),
        headers: {
          "Authorization": "Bearer " + getSharepointToken().toString(),
          "Accept": "application/json"
        },
      );
      var data = json.decode(response.body);
      List rest = data["value"] as List;
      for (var items in rest) {
        print(items['Customer']);
      }
    } catch (e) {
      showError(e);
    }
  }

  Future<String> getSharepointToken() async {
    String accesstoken = "";
    try {
      http.Response response = await http.post(
        Uri.encodeFull(Apikeys.sharepointTokenurl),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "grant_type": "client_credentials",
          "client_id": Apikeys.sharepointClientId,
          "client_secret": Apikeys.sharepointClientSecret,
          "resource": Apikeys.sharepointResource,
        },
      );
      var data = json.decode(response.body);
      print('Token Type : ' + data["token_type"]);
      print('Expires In : ' + data["expires_in"]);
      print('Not Before : ' + data["not_before"]);
      print('Expires On : ' + data["expires_on"]);
      print('Resource : ' + data["resource"]);
      print('Access Token : ' + data["access_token"]);
      accesstoken = data["access_token"];
    } catch (e) {
      showError(e);
    }
    return accesstoken;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Testing'),
      ),
      body: Center(
          child: RaisedButton(
        onPressed: getData,
        child: Text('Get Data'),
      )),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
    //showMessage('Login Interrupted by the user.', false);
  }

  void showMessage(String text) {
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new FlatButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }
}
