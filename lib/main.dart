import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Reports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyLoginPage(title: 'SPM Connect Login'),
    );
  }
}

///// TODO: create login button for office 365
///// TODO: circular loading screen rotaing while loggin in
///// TODO: complete api key list
///// TODO: arrange sharepoint access token retrieval method
///// TODO: figure out similar way to store access token from sharepoint as the add auth
///// TODO: save as png signature pad
///// TODO: create extra columns as backup on sql database
///// TODO: Delete tasks for not save report (created new and never got saved but created tasks for it.) ** Get rid of the dialog box
///// TODO: Pull to refresh
// TODO: Sync Method to retrieve list
// TODO: Sync Method to upload data
// TODO: Clean up sharepoint and azure app create new accounts
// TODO: pdf creation with all the fiels
// TODO: figure out saving of pdf first before displaying it
///// TODO: Google GeoLocation (create spmconnect email gmail)
// TODO: Figure out gesture bug while swiping between pages on task list page when it goes longer
///// TODO: azure active directory retrieve username
// TODO: sharepoint  create a new list
///// TODO: GEO Location for the plant location
// TODO: Design screen to update and receive data off sharepoint
///// TODO: Fix bug -  when typing on textbox keyboard covers it resigetoavoid scafold
///// TODO: Arrange screen files and group them accordingly
///// TODO: Auto login and put the logout button under privacy list view
///// TODO: Save floating button on task list
///// TODO: Try to achieve the hours worked by subtracting the time
// TODO: Report no should have an id reflecting along with report no
// TODO: Storage issues with ios
// TODO: SQL Column to store the data is uploaded or not
// TODO: SPM splash screen
// TODO: Implement error on hours worked if its in negative or zero
// TODO: SPM Logo

/*
TODO: Step to post data to sharepoint list
  - Gather the list of rows
  - Convert each row to json
  - post each item to sharepoint
  - update sql table that particular row has been posted  ---- repeat  
*/
