import 'package:flutter/material.dart';

class ReportDetail extends StatefulWidget {
  final String appBarTitle;
  ReportDetail(this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail(this.appBarTitle);
  }
}

class _ReportDetail extends State<ReportDetail> {
  String appBarTitle;

  TextEditingController projectController = TextEditingController();
  TextEditingController customerController = TextEditingController();
  TextEditingController planlocController = TextEditingController();
  TextEditingController contactnameController = TextEditingController();
  TextEditingController authorizedbyController = TextEditingController();
  TextEditingController equipmentController = TextEditingController();
  TextEditingController technameController = TextEditingController();
  _ReportDetail(this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    
    return WillPopScope(
        onWillPop: () {
          movetolastscreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                movetolastscreen();
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: projectController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Project Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Project No.',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: customerController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Customer Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Customer',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: planlocController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint(
                          'Something changed in Plant Location Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Plant Location',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //Fourth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: contactnameController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint(
                          'Something changed in Contact Name Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Contact Name',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //Fifth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: authorizedbyController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint(
                          'Something changed in Authorized by Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Authorized By',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //Sixth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: equipmentController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Equipment Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Equipment',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //Seventh Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: technameController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint(
                          'Something changed in SPM Tech Name Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'SPM Tech Name',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Button Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void movetolastscreen() {
    Navigator.pop(context);
  }
}
