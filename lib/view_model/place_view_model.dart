
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:uuid/uuid.dart';

import '../data/app_data.dart';
import '../data/style.dart';
import '../models/etc_model.dart';
import '../utils/utils.dart';
import '../widget/card_scroll_viewer.dart';

class PlaceViewModel extends ChangeNotifier {
  BuildContext? buildContext;
  PlaceModel? editItem;
  final _imageGalleryKey  = GlobalKey();
  final JSON imageList = {};

  init(BuildContext context) {
    buildContext = context;
  }

  setEditItem(PlaceModel item) {
    editItem = item;
    LOG('----> setEditItem: ${editItem!.toJson()}');
    if (editItem!.picData != null) {
      for (var item in editItem!.picData!) {
        LOG('  -- ${item.toJson()}');
      }
      for (var item in editItem!.picData!) {
        var jsonItem = {'id': item.id, 'type': 0};
        if (item.url.isNotEmpty) jsonItem['url'] = item.url;
        if (item.data != null) jsonItem['data'] = item.data.toString();
        imageList[item.id] = jsonItem;
      }
    }
  }

  setImageData() {
    editItem!.picData = imageList.entries.map((item) => PicData.fromJson(item.value)).toList();
    LOG('----> setImageData: ${editItem!.picData!.length}');
  }

  picLocalImage() async {
    List<XFile> pickList = await ImagePicker().pickMultiImage();
    if (pickList.isNotEmpty) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var imageUrl   = await ShowImageCroper(image.path);
        var imageData  = await ReadFileByte(imageUrl);
        var resizeData = await resizeImage(imageData!, IMAGE_SIZE_MAX) as Uint8List;
        var key = Uuid().v1();
        imageList[key] = PicData(id: key, type: 0, url: '', data: String.fromCharCodes(resizeData)).toJson();
        LOG('----> picLocalImage: ${imageList[key]}');
        if (editItem!.pic.isEmpty) editItem!.pic = key;
      }
      notifyListeners();
    }
  }

  showImageSelector() {
    LOG('----> showImageSelector: ${imageList.length}');
    for (var item in imageList.entries) {
      LOG('  -- ${item.value}');
    }
    return ImageEditScrollViewer(
        imageList,
        key: _imageGalleryKey,
        title: 'IMAGE'.tr,
        addText: 'Photo Add'.tr,
        selectText: '[first]'.tr,
        selectTextStyle: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: Colors.purple,
            shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.white.withOpacity(0.5))),
        onActionCallback: (key, status) {
          switch (status) {
            case 1: {
              picLocalImage();
              break;
            }
            case 2: {
              imageList.remove(key);
              notifyListeners();
              break;
            }
            default: {
              editItem!.pic = key;
            }
          }
        }
    );
  }
}