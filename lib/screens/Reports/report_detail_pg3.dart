import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:spmconnectapp/models/report.dart';
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
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  Report report;

  FocusNode custcommentsFocusNode;
  FocusNode custrepFocusNode;
  FocusNode contactnameFocusNode;

  @override
  void initState() {
    super.initState();
    custcommentsFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    custcommentsFocusNode.dispose();
    super.dispose();
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> deleteAssets() async {
    await MultiImagePicker.deleteImages(assets: images);
    setState(() {
      images = List<Asset>();
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 300,
          enableCamera: true,
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#abcdef",
            actionBarTitle: "Example App",
            allViewTitle: "All Photos",
            selectCircleStrokeColor: "#000000",
          ));
    } on PlatformException catch (e) {
      error = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  TextEditingController furtheractionController = TextEditingController();
  TextEditingController custcommentsController = TextEditingController();

  _ReportDetail3(this.report);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    furtheractionController.text = report.furtheractions;
    custcommentsController.text = report.custcomments;

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
                keyboardType: TextInputType.text,
                maxLines: 8,
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
                keyboardType: TextInputType.text,
                maxLines: 8,
                controller: custcommentsController,
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
            Center(child: Text('Error: $_error')),
            RaisedButton(
              child: Text("Pick images"),
              onPressed: loadAssets,
            ),
            // Expanded(
            //   child: buildGridView(),
            // ),
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
}
