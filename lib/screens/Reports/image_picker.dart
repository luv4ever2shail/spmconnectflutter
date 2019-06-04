import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:spmconnectapp/models/images.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqlite_api.dart';

class ImagePicker extends StatefulWidget {
  final String reportid;

  ImagePicker(this.reportid);
  @override
  _ImagePickerState createState() => new _ImagePickerState(this.reportid);
}

class _ImagePickerState extends State<ImagePicker> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Asset> images = List<Asset>();

  List<Images> imagelist;
  int count = 0;
  List<Asset> images1 = List<Asset>();
  String reportid;

  _ImagePickerState(this.reportid);
  @override
  void initState() {
    super.initState();
    //updateListView(reportid);
  }

  Widget buildGridView() {
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
        children: List.generate(images1.length, (index) {
          Asset asset = images1[index];
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
          maxImages: 25,
          enableCamera: true,
          selectedAssets: images.length > 0 ? images : images1,
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

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
    if (resultList.length > 0) {
      images1.clear();
      imagelist.clear();
      _delete();
      for (final i in resultList) {
        _save(i.identifier, i.name, i.originalWidth, i.originalHeight);
      }
      updateListView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagelist == null) {
      imagelist = List<Images>();
      updateListView();
    }
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: buildGridView(),
              )
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            count > 0
                ? FloatingActionButton(
                    heroTag: 'bttn1',
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _neverSatisfied(context);
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
              onPressed: loadAssets,
              tooltip: 'Attach images',
            ),
          ],
        ));
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Images>> taskListFuture =
          databaseHelper.getImageList(reportid);
      taskListFuture.then((tasklist) {
        setState(() {
          this.imagelist = tasklist;
          this.count = tasklist.length;
        });
        if (count > 0) {
          for (final i in imagelist) {
            images1.add(Asset(i.identifier, i.name, i.width, i.height));
          }
        }
      });
    });
  }

  void _save(String identifier, String name, int width, int height) async {
    int result = 0;
    Images _image = Images(identifier, name, width, height, reportid, 0);

    result = await databaseHelper.insertImage(_image);

    if (result != 0) {
      print('success');
    } else {
      print('error');
    }
  }

  Future<void> _delete() async {
    int result2 = await databaseHelper.deleteAllImages(reportid);
    if (result2 != 0) {
      debugPrint('deleted all tasks');
    }
  }

  Future<void> _neverSatisfied(BuildContext _context) async {
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
                images1.clear();
                images.clear();
                imagelist.clear();
                _delete();
                updateListView();
                Scaffold.of(_context).showSnackBar(SnackBar(
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
