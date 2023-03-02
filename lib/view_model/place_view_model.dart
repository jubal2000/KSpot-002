
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
  PlaceModel? placeInfo;
  final _imageGalleryKey  = GlobalKey();
  final JSON imageData = {};

  init(BuildContext context) {
    buildContext = context;
  }

  setPlaceInfo(PlaceModel item) {
    placeInfo = item;
    LOG('----> setplaceInfo: ${placeInfo!.toJson()}');
    if (placeInfo!.picData != null) {
      for (var item in placeInfo!.picData!) {
        var jsonItem = {'id': item.id, 'type': 0};
        if (item.url.isNotEmpty) jsonItem['url'] = item.url;
        // if (item.data != null) jsonItem['data'] = item.data.toString();
        imageData[item.id] = jsonItem;
      }
    }
  }

  setImageData() {
    placeInfo!.picData = imageData.entries.map((item) => PicData.fromJson(item.value)).toList();
    LOG('----> setImageData: ${placeInfo!.picData!.length}');
  }

  picLocalImage() async {
    List<XFile> pickList = await ImagePicker().pickMultiImage(maxWidth: PIC_IMAGE_SIZE_MAX, maxHeight: PIC_IMAGE_SIZE_MAX);
    if (pickList.isNotEmpty) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var url  = await ShowImageCroper(image.path);
        var data = await ReadFileByte(url);
        var resizeData = await resizeImage(data!, IMAGE_SIZE_MAX) as Uint8List;
        var key = Uuid().v1();
        imageData[key] = {'id': key, 'type': 0, 'url': '', 'data': resizeData};
        // imageList[key] = PicData(id: key, type: 0, url: '', data: String.fromCharCodes(resizeData)).toJson();
        // LOG('----> picLocalImage: ${imageData[key]}');
        if (placeInfo!.pic.isEmpty) placeInfo!.pic = key;
      }
      notifyListeners();
    }
  }

  showImageSelector() {
    LOG('----> showImageSelector: ${imageData.length}');
    for (var item in imageData.entries) {
      LOG('  -- ${item.value}');
    }
    return ImageEditScrollViewer(
        imageData,
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
              imageData.remove(key);
              notifyListeners();
              break;
            }
            default: {
              placeInfo!.pic = key;
            }
          }
        }
    );
  }
}