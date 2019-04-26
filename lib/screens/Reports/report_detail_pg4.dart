import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/signpad2.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:printing/printing.dart';
import 'package:spmconnectapp/screens/pdf.dart';

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

  FocusNode custrepFocusNode;
  FocusNode custemailFocusNode;
  FocusNode custcontactFocusNode;

  @override
  void initState() {
    super.initState();
    custrepFocusNode = FocusNode();
    custemailFocusNode = FocusNode();
    custcontactFocusNode = FocusNode();
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

    MyPdf myPdf = new MyPdf(report);

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return Signpad2(report.reportmapid.toString());
                      }),
                    );
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
            Center(
              child: RaisedButton(
                onPressed: () {
                  Printing.layoutPdf(onLayout: myPdf.buildPdf);
                },
                elevation: 20.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Print Report',
                  textScaleFactor: 1.5,
                ),
                color: Colors.amber,
              ),
            )
          ],
        ),
      ),
    );
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
