import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/utils/database_helper.dart';

class ReportDetail2 extends StatefulWidget {
  final String appBarTitle;
  final Report report;

  ReportDetail2(this.report, this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail2(this.report, this.appBarTitle);
  }
}

class _ReportDetail2 extends State<ReportDetail2> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Report report;

  FocusNode customerFocusNode;
  FocusNode plantlocFocusNode;
  FocusNode contactnameFocusNode;
  FocusNode authorbyFocusNode;
  FocusNode technameFocusNode;
  FocusNode equipFocusNode;

  @override
  void initState() {
    super.initState();
    customerFocusNode = FocusNode();
    plantlocFocusNode = FocusNode();
    contactnameFocusNode = FocusNode();
    authorbyFocusNode = FocusNode();
    technameFocusNode = FocusNode();
    equipFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    customerFocusNode.dispose();
    plantlocFocusNode.dispose();
    contactnameFocusNode.dispose();
    authorbyFocusNode.dispose();
    technameFocusNode.dispose();
    equipFocusNode.dispose();

    super.dispose();
  }

  TextEditingController projectController = TextEditingController();
  TextEditingController customerController = TextEditingController();
  TextEditingController planlocController = TextEditingController();
  TextEditingController contactnameController = TextEditingController();
  TextEditingController authorizedbyController = TextEditingController();
  TextEditingController equipmentController = TextEditingController();
  TextEditingController technameController = TextEditingController();
  _ReportDetail2(this.report, this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    projectController.text = report.projectno;
    customerController.text = report.customer;
    planlocController.text = report.plantloc;
    contactnameController.text = report.contactname;
    authorizedbyController.text = report.authorby;
    equipmentController.text = report.equipment;
    technameController.text = report.techname;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            // First Element - Project Number
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(),
                textInputAction: TextInputAction.next,
                //autofocus: true,
                controller: projectController,
                style: textStyle,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(customerFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Project Text Field');
                  updateProjectno();
                },
                decoration: InputDecoration(
                    labelText: 'Project No.',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Second Element - Customer Name
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: customerController,
                style: textStyle,
                focusNode: customerFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(plantlocFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Customer Text Field');
                  updateCustomername();
                },
                decoration: InputDecoration(
                    labelText: 'Customer',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Third Element - Plant Location
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: planlocController,
                style: textStyle,
                focusNode: plantlocFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(contactnameFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Plant Location Text Field');
                  updatePlantloc();
                },
                decoration: InputDecoration(
                    labelText: 'Plant Location',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            //Fourth Element - Contact Name
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: contactnameController,
                style: textStyle,
                focusNode: contactnameFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(authorbyFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Contact Name Text Field');
                  updateContactname();
                },
                decoration: InputDecoration(
                    labelText: 'Contact Name',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            //Fifth Element - Authorized By
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: authorizedbyController,
                style: textStyle,
                focusNode: authorbyFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(equipFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Authorized by Text Field');
                  updateAuthorby();
                },
                decoration: InputDecoration(
                    labelText: 'Authorized By',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            //Sixth Element - Equipment
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: equipmentController,
                style: textStyle,
                focusNode: equipFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(technameFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Equipment Text Field');
                  updateEquipment();
                },
                decoration: InputDecoration(
                    labelText: 'Equipment',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            //Seventh Element - Technician Name
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: technameController,
                style: textStyle,
                focusNode: technameFocusNode,
                onChanged: (value) {
                  debugPrint('Something changed in SPM Tech Name Text Field');
                  updateTechname();
                },
                decoration: InputDecoration(
                    labelText: 'SPM Tech Name',
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
  void updateProjectno() {
    report.projectno = projectController.text;
  }

  // Update the customer namme of Note object
  void updateCustomername() {
    report.customer = customerController.text;
  }

  // Update the plant location namme of Note object
  void updatePlantloc() {
    report.plantloc = planlocController.text;
  }

  // Update the customer namme of Note object
  void updateContactname() {
    report.contactname = contactnameController.text;
  }

  // Update the customer namme of Note object
  void updateAuthorby() {
    report.authorby = authorizedbyController.text;
  }

  // Update the customer namme of Note object
  void updateEquipment() {
    report.equipment = equipmentController.text;
  }

  // Update the customer namme of Note object
  void updateTechname() {
    report.techname = technameController.text;
  }
}
