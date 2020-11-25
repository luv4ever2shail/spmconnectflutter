import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/Resource/images_repository.dart';
import 'package:spmconnectapp/models/images.dart';

class ImagePicker extends StatefulWidget {
  final String reportid;
  ImagePicker(this.reportid);
  @override
  _ImagePickerState createState() => new _ImagePickerState(this.reportid);
}

class _ImagePickerState extends State<ImagePicker> {
  List<Asset> images = List<Asset>();
  String reportid;
  _ImagePickerState(this.reportid);
  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView(ReportImages reportImages) {
    if (images.length > 0) {
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            ),
          );
        }),
      );
    } else {
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(reportImages.imageassets.length, (index) {
          Asset asset = reportImages.imageassets[index];
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            ),
          );
        }),
      );
    }
  }

  Future<void> loadAssets(ReportImages reportImages) async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 25,
          enableCamera: true,
          selectedAssets: images.length > 0 ? images : reportImages.imageassets,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#132763",
            actionBarTitle: "SPM Connect",
            allViewTitle: "All Photos",
            selectCircleStrokeColor: "#ffffff",
          ));
    } on PlatformException catch (e) {
      error = e.message;
      print(error);
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
    });
    if (resultList.length > 0) {
      await reportImages.setImages(null);
      await _delete();
      for (final i in resultList) {
        await _save(i.identifier, i.name, i.originalWidth, i.originalHeight);
      }
      await reportImages.fetchImages(reportid);
    }
  }

  @override
  Widget build(BuildContext context) {
    ReportImages reportImages = Provider.of<ReportImages>(context);
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: buildGridView(reportImages),
              )
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            reportImages.getCount > 0
                ? FloatingActionButton(
                    heroTag: 'bttn1',
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _neverSatisfied(context, reportImages);
                    },
                    tooltip: 'Delete all images',
                  )
                : Offstage(),
            SizedBox(
              height: 5.0,
            ),
            FloatingActionButton(
              heroTag: 'bttn2',
              child: Icon(
                Icons.attach_file,
                color: Colors.white,
              ),
              onPressed: () => loadAssets(reportImages),
              tooltip: 'Attach images',
            ),
          ],
        ));
  }

  Future<void> _save(
      String identifier, String name, int width, int height) async {
    int result = 0;
    Images _image = Images(
      identifier,
      name,
      width,
      height,
      reportid,
      0,
      '',
      '',
      '',
    );

    result = await DBProvider.db.insertImage(_image);

    if (result != 0) {
      print('success');
    } else {
      print('error');
    }
  }

  Future<void> _delete() async {
    int result2 = await DBProvider.db.deleteAllImages(reportid);
    if (result2 != 0) {
      debugPrint('deleted all images');
    }
  }

  Future<void> _neverSatisfied(
      BuildContext _context, ReportImages reportImages) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Images?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure want to clear all images attached to the report?')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                images.clear();
                await reportImages.setImages(null);
                await _delete();
                await reportImages.fetchImages(reportid);
                ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
                  content: Text("Images attached cleared successfully."),
                ));
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
