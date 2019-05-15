import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';

const directoryName = 'Connect_Pdfs';

class Pdfviewer extends StatefulWidget {
  final String reportno;

  Pdfviewer(this.reportno);
  @override
  _PdfviewerState createState() => _PdfviewerState(this.reportno);
}

class _PdfviewerState extends State<Pdfviewer> {
  bool _isLoading = true;
  PDFDocument document;
  String reportno;

  String errortext;

  _PdfviewerState(this.reportno);

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    try {
      if (Platform.isIOS) {
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        print("$path/$directoryName/$reportno.pdf");
        File file = File("$path/$directoryName/$reportno.pdf");
        document = await PDFDocument.fromFile(file);
      } else {
        Directory directory = await getExternalStorageDirectory();
        String path = directory.path;
        print("$path/$directoryName/$reportno.pdf");
        File file = File("$path/$directoryName/$reportno.pdf");
        document = await PDFDocument.fromFile(file);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print(e);
      errortext = e.toString() + '\n PDF NOT FOUND!!!';
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viewing Report $reportno'),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : errortext == null
                  ? PDFViewer(
                      showPicker: false,
                      indicatorBackground: Colors.amber,
                      document: document,
                      tooltip: PDFViewerTooltip(first: "First"))
                  : Center(
                      child: Text(errortext),
                    )),
    );
  }
}
