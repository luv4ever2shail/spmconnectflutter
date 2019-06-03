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
  String _error = 'No Error Dectected';

  List<Images> imagelist;
  int count = 0;
  List<Asset> images1 = List<Asset>();
  String reportid;

  _ImagePickerState(this.reportid);
  @override
  void initState() {
    super.initState();
    updateListView(reportid);
  }

  Widget buildGridView() {
    if (images.length > 0) {
      return GridView.count(
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
    } else {
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(images1.length, (index) {
          Asset asset = images1[index];
          return AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
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
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#abcdef",
            actionBarTitle: "SPM Connect",
            allViewTitle: "All Photos",
            selectCircleStrokeColor: "#000000",
          ));
    } on PlatformException catch (e) {
      error = e.message;
    }
    images1.clear();
    imagelist.clear();
    _delete();
    for (final i in resultList) {
      _save(i.identifier, i.name, i.originalWidth, i.originalHeight);
    }
    print(_error);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imagelist == null) {
      updateListView(reportid);
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
      floatingActionButton: FloatingActionButton(
        onPressed: loadAssets,
        child: Icon(Icons.attach_file),
        tooltip: 'Attach Pictures',
      ),
    );
  }

  void updateListView(String reportid) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Images>> taskListFuture =
          databaseHelper.getImageList(reportid);
      taskListFuture.then((tasklist) {
        if (count > 0) {
          for (final i in imagelist) {
            images1.add(Asset(i.identifier, i.name, i.width, i.height));
          }
        }
        setState(() {
          this.imagelist = tasklist;
          this.count = tasklist.length;
        });
      });
    });
  }

  void _save(String identifier, String name, int width, int height) async {
    int result = 0;
    Images _image = Images(identifier, name, width, height, reportid);

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
}
