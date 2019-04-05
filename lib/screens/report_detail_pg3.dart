import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/signpad.dart';
import 'package:spmconnectapp/utils/database_helper.dart';

class ReportDetail3 extends StatefulWidget {
  final Report report;

  ReportDetail3(this.report);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail3(this.report);
  }
}

class _ReportDetail3 extends State<ReportDetail3> {
  DatabaseHelper helper = DatabaseHelper();

  Report report;

  FocusNode custcommentsFocusNode;
  FocusNode custrepFocusNode;
  FocusNode contactnameFocusNode;

  @override
  void initState() {
    super.initState();
    custcommentsFocusNode = FocusNode();
    custrepFocusNode = FocusNode();
    contactnameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    custcommentsFocusNode.dispose();
    custrepFocusNode.dispose();
    contactnameFocusNode.dispose();

    super.dispose();
  }

  TextEditingController furtheractionController = TextEditingController();
  TextEditingController custcommentsController = TextEditingController();
  TextEditingController custrepController = TextEditingController();

  _ReportDetail3(this.report);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    furtheractionController.text = report.furtheractions;
    custcommentsController.text = report.custcomments;
    custrepController.text = report.custrep;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            // First Element - Project Number
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                controller: furtheractionController,
                style: textStyle,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(custcommentsFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Furtheraction Text Field');
                  updateFurtheraction();
                },
                decoration: InputDecoration(
                    labelText: 'Further Action Req.',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Second Element - Customer Name
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                controller: custcommentsController,
                style: textStyle,
                focusNode: custcommentsFocusNode,
                textInputAction: TextInputAction.newline,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(custrepFocusNode),
                onChanged: (value) {
                  debugPrint(
                      'Something changed in Customer Comments Text Field');
                  updateCustcomments();
                },
                decoration: InputDecoration(
                    labelText: 'Customer Comments',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Third Element - Plant Location
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: custrepController,
                style: textStyle,
                focusNode: custrepFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(contactnameFocusNode),
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

            // Fourth Element - Plant Location
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                style: textStyle,
                //focusNode: custrepFocusNode,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SignApp();
                    }),
                  );
                },
                onChanged: (value) {
                  debugPrint('Something changed in Cust sign Text Field');
                  //updateCustrep();
                },
                decoration: InputDecoration(
                    labelText: 'Customer Signature',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Update the project no.
  void updateFurtheraction() {
    report.furtheractions = furtheractionController.text;
  }

  // Update the customer namme of Note object
  void updateCustcomments() {
    report.custcomments = custcommentsController.text;
  }

  // Update the plant location namme of Note object
  void updateCustrep() {
    report.custrep = custrepController.text;
  }
}
