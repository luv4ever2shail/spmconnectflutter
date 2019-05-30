import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:spmconnectapp/models/report.dart';

class ReportPreview extends StatefulWidget {
  final Report report;
  ReportPreview(this.report);
  @override
  State<StatefulWidget> createState() {
    return new ReportPreviewState(this.report);
  }
}

class ReportPreviewState extends State<ReportPreview> {
  Report report;
  ReportPreviewState(this.report);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(
          'Report Details',
          style: TextStyle(fontSize: 19.0),
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    return ListView(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Divider(),
        Center(child: Text('Report Information')),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Table(
              border: TableBorder.all(width: 1.0, color: Colors.black),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Report No'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.reportno),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Created On'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.date),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Project'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.projectno),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Customer'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.customer),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Plant Location'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.plantloc),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Contact Name'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.contactname),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Authorized By'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.authorby),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Equipment'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.equipment),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Technician'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.techname),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(),
        Center(child: Text('Service Actions/Comments')),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Table(
              border: TableBorder.all(width: 1.0, color: Colors.black),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: new Text('Further Actions')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.furtheractions),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Center(child: Text('Customer Comments')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.custcomments),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(),
        Center(child: Text('Customer Representative')),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Table(
              border: TableBorder.all(width: 1.0, color: Colors.black),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Customer Representative'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.custrep),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Customer Email'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.custemail),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text('Customer Contact'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(this.report.custcontact),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
