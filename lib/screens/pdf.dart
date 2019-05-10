import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as Pdf;
import 'package:printing/printing.dart';
import 'package:spmconnectapp/models/report.dart';

const directoryName = 'Pdfs';

class MyPdf {
  final Report report;

  MyPdf(this.report);

  Future<void> buildPdf() async {
    final PdfDoc pdf = PdfDoc()
      ..addPage(Pdf.MultiPage(
          pageFormat: PdfPageFormat.letter
              .copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          header: (Pdf.Context context) {
            if (context.pageNumber == 1) {
              return null;
            }
            return Pdf.Container(
                alignment: Pdf.Alignment.centerRight,
                margin:
                    const Pdf.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                padding:
                    const Pdf.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                decoration: const Pdf.BoxDecoration(
                    border: Pdf.BoxBorder(
                        bottom: true, width: 0.5, color: PdfColors.grey)),
                child: Pdf.Text('Portable Document',
                    style: Pdf.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey)));
          },
          build: (Pdf.Context context) => <Pdf.Widget>[
                Pdf.Header(
                    level: 0,
                    child: Pdf.Row(
                        mainAxisAlignment: Pdf.MainAxisAlignment.spaceBetween,
                        children: <Pdf.Widget>[
                          Pdf.Text('SPM Service Report', textScaleFactor: 2),
                          Pdf.PdfLogo(),
                        ])),
                Pdf.Header(level: 1, text: 'Report Details'),
                Pdf.Paragraph(
                    text:
                        'Service Report No :' + report.reportmapid.toString()),
                Pdf.Paragraph(text: 'Date Of Service :' + report.date),
                Pdf.Paragraph(text: 'SPM Tech Name :' + report.techname),
                Pdf.Paragraph(text: 'Project Number :' + report.projectno),
                Pdf.Paragraph(text: 'Plant Location :' + report.plantloc),
                Pdf.Paragraph(text: 'Customer/Company :' + report.customer),
                Pdf.Paragraph(text: 'Contact Name :' + report.contactname),
                Pdf.Paragraph(text: 'Authorized By :' + report.authorby),
                Pdf.Paragraph(text: 'Equipment :' + report.equipment),
                Pdf.Header(level: 2, text: 'Task Performed'),
                Pdf.Table.fromTextArray(
                    context: context,
                    data: const <List<String>>[
                      <String>['Item', 'Hours', 'Task Performed'],
                      <String>['1993', 'PDF 1.0', 'Acrobat 1'],
                      <String>['1994', 'PDF 1.1', 'Acrobat 2'],
                      <String>['1996', 'PDF 1.2', 'Acrobat 3'],
                      <String>['1999', 'PDF 1.3', 'Acrobat 4'],
                    ]),
              ]));
    print('Started creating pdf');
    await savepdf(pdf);
    print('PDF Creation finished');
    //pdf.save();
  }

  Future<void> savepdf(PdfDoc pdf) async {
    Directory directory = await getExternalStorageDirectory();
    String path = directory.path;
    print('$path/$directoryName/${report.reportmapid}.pdf');
    await Directory('$path/$directoryName').create(recursive: true);
    File('$path/$directoryName/${report.reportmapid}.pdf')
        .writeAsBytesSync(pdf.save());
  }
}
