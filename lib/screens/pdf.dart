import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as Pdf;
import 'package:printing/printing.dart';
import 'package:spmconnectapp/models/report.dart';

const directoryName = 'Connect_Pdfs';

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
                Pdf.Paragraph(
                    text: 'Cust. Comments :' + report.custcomments.trim()),
                Pdf.Paragraph(
                    text: 'Further Actions :' + report.furtheractions),
                Pdf.Paragraph(text: 'Cust. Rep. :' + report.custrep),
                Pdf.Paragraph(text: 'Email :' + report.custemail),
                Pdf.Paragraph(text: 'Contact :' + report.custcontact),
              ]));
    print('Started creating pdf');
    await savepdf(pdf);
    print('PDF Creation finished');
    //pdf.save();
  }

  Future<void> savepdf(PdfDoc pdf) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    print('$path/$directoryName/${report.reportmapid}.pdf');
    await Directory('$path/$directoryName').create(recursive: true);
    File('$path/$directoryName/${report.reportmapid}.pdf')
        .writeAsBytesSync(pdf.save());
  }
}
