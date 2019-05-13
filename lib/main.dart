import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmconnectapp/screens/home.dart';
import 'package:spmconnectapp/screens/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    autoLogIn();
  }

  void autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('Name');

    if (userId != null) {
      setState(() {
        isLoggedIn = true;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Service Reports',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: isLoggedIn
            ? Myhome(null)
            : MyLoginPage(title: 'SPM Connect Login'));
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
///// TODO: Sync Method to retrieve list
///// TODO: Sync Method to upload data
///// TODO: Google GeoLocation (create spmconnect email gmail)
///// TODO: Figure out gesture bug while swiping between pages on task list page when it goes longer - Not Required
///// TODO: azure active directory retrieve username
///// TODO: sharepoint  create a new list
///// TODO: GEO Location for the plant location
///// TODO: Design screen to update and receive data off sharepoint
///// TODO: Fix bug -  when typing on textbox keyboard covers it resigetoavoid scafold
///// TODO: Arrange screen files and group them accordingly
///// TODO: Auto login and put the logout button under privacy list view
///// TODO: Save floating button on task list
///// TODO: Try to achieve the hours worked by subtracting the time
///// TODO: Report no should have an id reflecting along with report no - store id on shared preferences have employee id now
///// TODO: SQL Column to store the data is uploaded or not
///// TODO: Implement error on hours worked if its in negative or zero
///// TODO: Sharepoint update method with rest api
///// TODO: Locking down of report once signed off and remove delete button // prevent user from deleting the report
///// TODO: storage permission should popup
///// TODO: Database column to signify its been signed off and cant access it anymore, instead show pdf
///// TODO: Report list page needs to prevent from users to access the report if its signed off
///// TODO: Implement pdf viewer to view files from local source
///// TODO: figure out saving of pdf first before displaying it
///// TODO: Remove permission screen
///// TODO: Implement uploading tasks
///// TODO: Auto login
// TODO: Clean up sharepoint and azure app create new accounts
// TODO: pdf creation with all the fields
// TODO: SPM splash screen
// TODO: Storage issues with ios
// TODO: SPM Logo
// TODO: Implement way to publish pdf and signatures
///// TODO: Fix the bug on plant location
///// TODO: Fix bugs on getting user infos
///// TODO: try to remove flush bar plugin and printing plugin to save pdf

/*
/TODO: Step to post data to sharepoint list.
// TODO: Gather the list of rows where published report and task == 0
//TODO: Convert each row to JSON
// TODO: post each item to sharepoint
// TODO: update sql table that particular row has been posted  ---- repeat  
*/
