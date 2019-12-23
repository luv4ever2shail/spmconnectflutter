import 'package:flutter/widgets.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/models/images.dart';
import 'package:sqflite/sqlite_api.dart';

class ReportImages with ChangeNotifier {
  List<Images> images;
  List<Asset> imageassets;
  int count;
  int assetcount;
  ReportImages();

  ReportImages.instance() : images = new List<Images>() {
    imageassets = new List<Asset>();
    count = 0;
    assetcount = 0;
  }
  @override
  void dispose() {
    super.dispose();
  }

  setImages(List<Images> _images) async {
    images.clear();
    if (_images == null)
      images.clear();
    else
      images = _images;
    notifyListeners();
    setImageAssets(_images);
  }

  setImageAssets(List<Images> _images) async {
    imageassets.clear();
    if (_images == null)
      imageassets.clear();
    else if (_images.length > 0) {
      for (final i in _images) {
        imageassets.add(Asset(i.identifier, i.name, i.width, i.height));
      }
    }
    notifyListeners();
    setcount(_images == null ? 0 : _images.length);
  }

  setcount(int reportCount) async {
    count = reportCount;
    notifyListeners();
  }

  List<Images> get getImages => images;

  List<Asset> get getImageAssets => imageassets;

  int get getCount => count;

  Future<void> fetchImages(String reportid) async {
    final Future<Database> dbFuture = DBProvider.db.initializeDatabase();
    await dbFuture.then((database) async {
      List<Images> taskListFuture = await DBProvider.db.getImageList(reportid);
      setImages(taskListFuture);
    });
  }
}
