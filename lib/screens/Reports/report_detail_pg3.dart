import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spmconnectapp/models/report.dart';

class ReportDetail3 extends StatefulWidget {
  final Report report;

  ReportDetail3(this.report);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail3(this.report);
  }
}

class _ReportDetail3 extends State<ReportDetail3> {
  Report report;
  TextEditingController furtheractionController;
  TextEditingController custcommentsController;
  FocusNode custcommentsFocusNode;

  @override
  void initState() {
    super.initState();
    custcommentsFocusNode = FocusNode();
    furtheractionController = TextEditingController();
    custcommentsController = TextEditingController();
    furtheractionController.text = report.getfurtheractions;
    custcommentsController.text = report.getcustcomments;
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    custcommentsFocusNode.dispose();
    furtheractionController.dispose();
    custcommentsController.dispose();
    super.dispose();
  }

  _ReportDetail3(this.report);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            // First Element - Project Number
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
                keyboardType: TextInputType.text,
                maxLines: 8,
                maxLength: 500,
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
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                ],
                keyboardType: TextInputType.text,
                maxLines: 8,
                controller: custcommentsController,
                maxLength: 500,
                style: textStyle,
                focusNode: custcommentsFocusNode,
                textInputAction: TextInputAction.newline,
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
          ],
        ),
      ),
    );
  }

// Update the project no.
  void updateFurtheraction() {
    report.getfurtheractions = furtheractionController.text.trim();
  }

  // Update the customer namme of Note object
  void updateCustcomments() {
    report.getcustcomments = custcommentsController.text.trim();
  }
}
