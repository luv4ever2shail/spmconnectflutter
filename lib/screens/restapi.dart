import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Myrestapipage extends StatefulWidget {

  @override
  _MyrestapipageState createState() => new _MyrestapipageState();
}

class _MyrestapipageState extends State<Myrestapipage> {

  

  Future<String> getData() async{
    http.Response response = await http.get(
      Uri.encodeFull("http://spmautomation.sharepoint.com/sites/SPMConnect/_api/web/lists/GetByTitle('TestList')"),
      headers: {
        "Authorization" : "Bearer ",
        "Accept" : "application/json;odata=verbose"

      },
      );

      List data = json.decode(response.body);
      print(data[1]['title']);

      return response.body;

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
        )
      ),
    );
  }
}
