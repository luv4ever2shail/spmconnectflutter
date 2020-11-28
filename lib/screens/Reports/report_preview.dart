import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:spmconnectapp/Resource/images_repository.dart';
import 'package:spmconnectapp/Resource/tasks_repository.dart';
import 'package:spmconnectapp/models/report.dart';

const directoryName = 'Connect_Signatures';

class ReportPreview extends StatefulWidget {
  final Report report;
  ReportPreview(
    this.report,
  );
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
    ReportImages reportImages = Provider.of<ReportImages>(context);
    ReportTasks reportTasks = Provider.of<ReportTasks>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: TextStyle(fontSize: 19.0),
        ),
        centerTitle: true,
      ),
      body: Scrollbar(
        thickness: 10,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: body(reportImages, reportTasks),
        ),
      ),
    );
  }

  Widget body(ReportImages reportImages, ReportTasks reportTasks) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * .01,
        right: MediaQuery.of(context).size.width * .01,
      ),
      child: Column(
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
                        child: new Text(report.getreportno),
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
                        child: new Text(report.getdate),
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
                        child: new Text(report.getprojectno),
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
                        child: new Text(report.getcustomer),
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
                        child: new Text(this.report.getplantloc),
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
                        child: new Text(report.getcontactname),
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
                        child: new Text(report.getauthorby),
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
                        child: new Text(report.getequipment),
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
                        child: new Text(report.gettechname),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (reportTasks.getTasks.length > 0) ...[
            Divider(),
            Center(
              child: Text(
                'Tasks Performed',
                style: TextStyle(
                    fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
            ),
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
                          child: Text('Item'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text('Hours Worked'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text('Work Perfomed'),
                        ),
                      ],
                    ),
                    ...reportTasks.getTasks.map((task) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(task.getitem),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(task.gethours.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(task.workperformed.toString()),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
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
                        child: new Text(report.getfurtheractions),
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
                        child: new Text(report.getcustcomments),
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
                        child: new Text(report.getcustrep),
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
                        child: new Text(report.getcustemail),
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
                        child: new Text(report.getcustcontact),
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
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Container(
                height: 250,
                width: MediaQuery.of(context).size.width * 0.5,
                padding: EdgeInsets.all(10),
                child: path.length > 0
                    ? Image.file(
                        io.File('$path'),
                      )
                    : Image.asset(
                        'assets/spm.png',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          if (reportImages.getImageAssets.length > 0) ...[
            Divider(),
            Center(
              child: Text(
                'Attached Images',
                style: TextStyle(
                    fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: reportImages.imageassets.map((task) {
                  Asset asset = task;
                  return Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AssetThumb(
                      asset: asset,
                      width: 3840,
                      height: 2160,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

  Future loadSignature() async {
    try {
      io.Directory directory = await getApplicationDocumentsDirectory();
      String _path = directory.path;
      print("$_path/$directoryName/");
      _path = "$_path/$directoryName/${report.getreportmapid.toString()}.png";
      // io.File file = new io.File(_path);
      bool result = await io.File(_path).exists();
      // path = "$_path/$directoryName/${report.getreportmapid.toString()}.png";
      if (result) {
        setState(() {
          path =
              "$_path/$directoryName/${report.getreportmapid.toString()}.png";
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
