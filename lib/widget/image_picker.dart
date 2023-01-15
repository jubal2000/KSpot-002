import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../core/dialogs.dart';
import '../core/utils.dart';
import '../services/api_service.dart';

// ignore: non_constant_identifier_names
ShowImagePicker(BuildContext context, String key) async {
  final api = Get.find<ApiService>();
  XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
  LOG('---> showImagePicker : $pickImage');
  if (pickImage != null) {
    var imageUrl  = await showImageCroper(pickImage.path);
    LOG('---> imageUrl : $imageUrl');
    return imageUrl;
  }
  return null;
}

// ignore: non_constant_identifier_names
ShowUserPicCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.square,
  ];
  return await StartImageCroper(imageFilePath, CropStyle.circle, preset, CropAspectRatioPreset.square, false);
}

// ignore: non_constant_identifier_names
ShowBannerImageCroper(String imageFilePath) async {
  var preset = [
    CropAspectRatioPreset.ratio16x9
  ];
  return await StartImageCroper(imageFilePath, CropStyle.rectangle, preset, CropAspectRatioPreset.ratio16x9, false);
}

// ignore: non_constant_identifier_names
StartImageCroper(String imageFilePath, CropStyle cropStyle, List<CropAspectRatioPreset> preset, CropAspectRatioPreset initPreset, bool lockAspectRatio) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    cropStyle: cropStyle,
    sourcePath: imageFilePath,
    aspectRatioPresets: preset,
    maxWidth: 1024,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Image size edit'.tr,
          toolbarColor: Colors.purple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: initPreset,
          lockAspectRatio: lockAspectRatio),
      IOSUiSettings(
        title: 'Image size edit'.tr,
      ),
    ],
  );
  return croppedFile?.path;
}