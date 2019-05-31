import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spmconnectapp/models/report.dart';

const directoryName = 'Connect_Signatures';

class ReportPreview extends StatefulWidget {
  final Report report;
  ReportPreview(this.report);
  @override
  State<StatefulWidget> createState() {
    return new ReportPreviewState(this.report);
  }
}

class ReportPreviewState extends State<ReportPreview> {
  @override
  void initState() {
    super.initState();
    loadSignature();
  }

  String path = '';
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
        Center(
            child: Text(
          'Report Information',
          style: TextStyle(
              fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        )),
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
        Center(
            child: Text(
          'Service Actions/Comments',
          style: TextStyle(
              fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        )),
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
                      child: Text('Further Actions'),
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
                      child: Text('Customer Comments'),
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
        Center(
            child: Text(
          'Customer Information',
          style: TextStyle(
              fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        )),
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
        Divider(),
        Center(
            child: Text(
          'Customer Signature',
          style: TextStyle(
              fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 10,
            child: Container(
                height: 250,
                padding: EdgeInsets.all(10),
                child: FadeInImage(
                  placeholder: AssetImage('assets/spm.png'),
                  image: FileImage(
                    File('$path${report.reportmapid.toString()}.png'),
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Future loadSignature() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String _path = directory.path;
      print("$_path/$directoryName/");
      path = "$_path/$directoryName/";
      setState(() {});
    } catch (e) {
      print(e);
    }
  }
}
