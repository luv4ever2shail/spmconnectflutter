import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/login.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Reports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue,),
      home:MyLoginPage(title : 'SPM Connect Login'),
    );
  }
}

///// TODO: create login button for office 365
///// TODO: circular loading screen rotaing while loggin in
///// TODO: complete api key list
// TODO: arrange sharepoint access token retrieval method
// TODO: figure out similar way to store access token from sharepoint as the add auth
// TODO: save as png signature pad
// TODO: create extra columns as backup on sql database
// TODO: Delete tasks for not save report (created new and never got saved but created tasks for it.)
// TODO: Pull to refresh
// TODO: Sync Method to retrieve list
// TODO: Sync Method to upload data
// TODO: Clean up sharepoint and azure app create new accounts
// TODO: Google GeoLocation (create spmconnect email gmail)
// TODO: Figure out gesture bug while swiping between pages on task list page when it goes longer

