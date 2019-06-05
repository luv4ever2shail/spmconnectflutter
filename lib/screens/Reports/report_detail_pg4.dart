import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/signpad2.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class ReportDetail4 extends StatefulWidget {
  final Report report;

  ReportDetail4(this.report);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail4(this.report);
  }
}

class _ReportDetail4 extends State<ReportDetail4> {
  DatabaseHelper helper = DatabaseHelper();

  Report report;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  FocusNode custrepFocusNode;
  FocusNode custemailFocusNode;
  FocusNode custcontactFocusNode;

  @override
  void initState() {
    super.initState();
    custrepFocusNode = FocusNode();
    custemailFocusNode = FocusNode();
    custcontactFocusNode = FocusNode();
    if (Platform.isAndroid) {
      requestPermission();
    }
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    custrepFocusNode.dispose();
    custemailFocusNode.dispose();
    custcontactFocusNode.dispose();
    super.dispose();
  }

  TextEditingController custrepController = TextEditingController();
  TextEditingController custemailController = TextEditingController();
  MaskedTextController custcontactController =
      MaskedTextController(mask: '000-000-0000');
  TextEditingController custsignController = TextEditingController();

  _ReportDetail4(this.report);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

    custrepController.text = report.custrep;
    custemailController.text = report.custemail;
    custcontactController.text = report.custcontact;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: custrepController,
                style: textStyle,
                keyboardType: TextInputType.text,
                focusNode: custrepFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(custemailFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Cust rep Text Field');
                  updateCustrep();
                },
                decoration: InputDecoration(
                    labelText: 'Customer Representative',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Second Element - Cust Email
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: custemailController,
                keyboardType: TextInputType.emailAddress,
                style: textStyle,
                focusNode: custemailFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(custcontactFocusNode);
                },
                onChanged: (value) {
                  debugPrint('Something changed in Cust email Text Field');
                  updateCustEmail();
                },
                decoration: InputDecoration(
                    labelText: 'Customer Email',
                    labelStyle: textStyle,
                    hintText: 'abc@abc.com',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Third Element

            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.phone,
                controller: custcontactController,
                style: textStyle,
                focusNode: custcontactFocusNode,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  debugPrint('Something changed in Cust contact Text Field');
                  updateCustContact();
                },
                decoration: InputDecoration(
                    labelText: 'Customer Contact',
                    labelStyle: textStyle,
                    hintText: '###-###-####',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Fourth Element -
            Padding(
              padding:
                  EdgeInsets.only(top: 15.0, bottom: 15.0, left: 40, right: 40),
              child: Material(
                elevation: 20.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.blue,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  onPressed: () async {
                    if (Platform.isIOS) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return Signpad2(
                              report.reportmapid.toString(), report);
                        }),
                      );
                    } else {
                      if (_permissionStatus.value == 2) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return Signpad2(
                                report.reportmapid.toString(), report);
                          }),
                        );
                      } else {
                        requestPermission();
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Icon(
                          Icons.assignment_turned_in,
                          size: 40,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Customer Sign Off",
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermission() async {
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult[PermissionGroup.storage];
      print(_permissionStatus);
    });
  }

// Update the project no.
  void updateCustContact() {
    report.custcontact = custcontactController.text;
  }

  // Update the customer namme of Note object
  void updateCustEmail() {
    report.custemail = custemailController.text;
  }

  // Update the plant location namme of Note object
  void updateCustrep() {
    report.custrep = custrepController.text;
  }
}
