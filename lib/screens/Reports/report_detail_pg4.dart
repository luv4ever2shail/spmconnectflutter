import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/signpad2.dart';
import 'package:spmconnectapp/utils/validator.dart';

class ReportDetail4 extends StatefulWidget {
  final Report report;
  final DBProvider helper;

  ReportDetail4(this.report, this.helper);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail4(this.report);
  }
}

class _ReportDetail4 extends State<ReportDetail4> {
  String _emailError;
  String _phoneError;
  Report report;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  TextEditingController custrepController;
  TextEditingController custemailController;
  TextEditingController custcontactController;
  FocusNode custrepFocusNode;
  FocusNode custemailFocusNode;
  FocusNode custcontactFocusNode;

  @override
  void initState() {
    super.initState();
    custrepController = TextEditingController();
    custemailController = TextEditingController();
    custcontactController = TextEditingController();
    custrepFocusNode = FocusNode();
    custemailFocusNode = FocusNode();
    custcontactFocusNode = FocusNode();
    custrepController.text = report.getcustrep;
    custemailController.text = report.getcustemail;
    custcontactController.text = report.getcustcontact;
    if (Platform.isAndroid) {
      requestPermission();
    }
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    custrepController.dispose();
    custemailController.dispose();
    custcontactController.dispose();
    custrepFocusNode.dispose();
    custemailFocusNode.dispose();
    custcontactFocusNode.dispose();
    super.dispose();
  }

  _ReportDetail4(this.report);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                maxLength: 30,
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
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
                maxLength: 45,
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
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
                    errorText: _emailError,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Third Element

            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
                keyboardType: TextInputType.phone,
                maxLength: 10,
                controller: custcontactController,
                style: textStyle,
                focusNode: custcontactFocusNode,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  debugPrint('Something changed in Cust contact Text Field');
                  updateCustContact();
                },
                decoration: InputDecoration(
                    labelText: 'Customer Contact',
                    labelStyle: textStyle,
                    hintText: '###-###-####',
                    errorText: _phoneError,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Fourth Element -

            Material(
              elevation: 20.0,
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.blue,
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                onPressed: () async {
                  await onConfirm();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Icon(
                        Icons.assignment_turned_in,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Customer Sign Off",
                        textAlign: TextAlign.center,
                        style: style.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermission() async {
    final Map<Permission, PermissionStatus> permissionRequestResult = await [
      Permission.location,
    ].request();
    print(permissionRequestResult[Permission.storage]);
    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult[Permission.storage];
      print(_permissionStatus);
    });
  }

  Future onConfirm() async {
    if (custemailController.text == null ||
        custcontactController.text == null) {
      print('_email or phonenumber is null.');
      setState(() {
        _emailError = 'Email cannot be empty';
        _phoneError = 'Contact no cannot be empty';
      });
      return;
    }

    bool isEmail = Validator.instance.validateEmail(custemailController.text);
    bool isPhone =
        Validator.instance.validateNumber(custcontactController.text);
    if (!isEmail) {
      setState(() => _emailError = 'Not a valid email address');
      return;
    }

    if (!isPhone) {
      setState(() => _phoneError = "Please enter valid contact no");
      return;
    }
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    try {
      if (Platform.isIOS) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return Signpad2(
                report.getreportmapid.toString(), report, widget.helper);
          }),
        );
      } else {
        if (_permissionStatus.isGranted) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return Signpad2(
                  report.getreportmapid.toString(), report, widget.helper);
            }),
          );
        } else {
          await requestPermission();
        }
      }
    } catch (e) {
      print("Error in sign up: $e");
    }
  }

// Update the project no.
  void updateCustContact() {
    report.getcustcontact = custcontactController.text.trim();
  }

  // Update the customer namme of Note object
  void updateCustEmail() {
    report.getcustemail = custemailController.text.trim();
  }

  // Update the plant location namme of Note object
  void updateCustrep() {
    report.getcustrep = custrepController.text.trim();
  }
}
