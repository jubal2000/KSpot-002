import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/services/api_service.dart';
import 'package:uuid/uuid.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/style.dart';
import '../models/etc_model.dart';
import '../models/event_model.dart';
import '../models/story_model.dart';
import '../repository/event_repository.dart';
import '../repository/story_repository.dart';
import '../repository/user_repository.dart';
import '../utils/utils.dart';
import '../widget/card_scroll_viewer.dart';

class StoryEditViewModel extends ChangeNotifier {
  final userRepo  = UserRepository();
  final storyRepo = StoryRepository();
  final _imageGalleryKey  = GlobalKey();
  final _descController   = TextEditingController();

  StoryModel?   editItem;
  EventModel?   eventInfo;
  BuildContext? buildContext;
  JSON imageData = {};
  var isEditMode = false;
  var isEdited = false;
  var isShowOnly = false;

  var stepIndex = 0;
  var stepMax = 3;
  var agreeChecked = false;

  get editOptionToJSON {
    JSON result = {};
    if (editItem != null) {
      for (var item in editItem!.getOptionDataMap.entries) {
        result[item.key] = item.value['value'];
      }
    }
    return result;
  }

  get isNextEnable {
    switch(stepIndex) {
      case 0: return agreeChecked;
    }
    return eventInfo != null;
  }

  init(BuildContext context) {
    buildContext = context;
  }

  initData() {
    imageData = {};
    isEdited = false;
  }

  setEditItem(StoryModel story, EventModel? event) {
    editItem   = story;
    eventInfo  = event;
    if (editItem!.picData != null) {
      for (var item in editItem!.picData!) {
        LOG('--> picData item : ${item.toJson()}');
      }
      for (var item in editItem!.picData!) {
        var jsonItem = {'id': item.id, 'type': 0};
        if (item.url.isNotEmpty) jsonItem['url'] = item.url;
        // if (item.data != null) jsonItem['data'] = item.data.toString();
        imageData[item.id] = jsonItem;
      }
    }
    refreshOption();
  }

  setEventInfo(EventModel? event) {
    eventInfo = event;
    notifyListeners();
  }

  onSettingChanged(JSON data) {
    LOG('-----> onSettingChanged : $data');
    editItem!.setOptionDataMap(data);
    isEdited = true;
  }

  refreshOption() {
    final optionMap = editItem!.getOptionDataMap;
    for (var item in AppData.INFO_STORY_OPTION.entries) {
      if (item.value.runtimeType != String && item.value.runtimeType != int) {
        bool isAdd = true;
        if (isAdd && BOL(item.value) && !optionMap.containsKey(item.key)) {
          LOG('--> add default option data : ${item.key} / ${optionMap.toString()}');
          optionMap[item.key] = {'key': item.key, 'value': '1'};
        }
      }
    }
    if (editItem!.status == 2) {
      optionMap['open'] = '';
    }
    LOG('--> optionMap : ${optionMap.toString()}');
    editItem!.setOptionDataMap(optionMap);
    LOG('--> _eventInfo option : ${editItem!.getOptionDataMap}');
  }

  setImageData() {
    editItem!.picData = imageData.entries.map((item) => PicData.fromJson(item.value)).toList();
    LOG('----> setImageData: ${editItem!.picData!.length}');
  }

  picLocalImage() async {
    List<XFile> pickList = await ImagePicker().pickMultiImage(maxWidth: PIC_IMAGE_SIZE_MAX, maxHeight: PIC_IMAGE_SIZE_MAX);
    if (pickList.isNotEmpty) {
      for (var i=0; i<pickList.length; i++) {
        var image = pickList[i];
        var url   = await ShowImageCroper(image.path);
        var data  = await ReadFileByte(url);
        var resizeData = await resizeImage(data!, IMAGE_SIZE_MAX) as Uint8List;
        var key = Uuid().v1();
        imageData[key] = {'id': key, 'type': 0, 'url': '', 'data': resizeData};
        // LOG('----> picLocalImage: ${imageData[key]} / $key');
      }
      isEdited = true;
      setImageData();
      notifyListeners();
    }
  }

  showImageSelector() {
    LOG('----> showImageSelector: ${imageData.length}');
    return ImageEditScrollViewer(
        imageData,
        key: _imageGalleryKey,
        title: 'EVENT PHOTO *'.tr,
        addText: 'Photo Add'.tr,
        selectTextStyle: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: Colors.purple,
            shadows: outlinedText(strokeWidth: 1, strokeColor: Colors.white.withOpacity(0.5))),
        onActionCallback: (key, status) {
          LOG('----> onActionCallback: $key / $status');
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
          }
        }
    );
  }

  showDesc() {
    return Column(
      children: [
        SubTitle(buildContext!, 'DESC'.tr),
        TextFormField(
          controller: _descController,
          decoration: inputLabel(buildContext!, 'Description'.tr, ''),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          maxLength: STORY_DESC_LENGTH,
          scrollPadding: EdgeInsets.only(bottom: 150),
          // style: _editText,
          onChanged: (value) {
            editItem!.desc = value;
            isEdited = true;
          },
        ),
      ],
    );
  }

  showTag() {
    return Column(
      children: [
        SubTitle(buildContext!, 'TAG'.tr),
        TagTextField(List<String>.from(editItem!.getTagDataMap), (value) {
          editItem!.tagData = value;
        }),
      ],
    );
  }

  setCheck(value) {
    agreeChecked = value;
    notifyListeners();
  }

  checkEditDone(showAlert) {
    if (imageData.isEmpty) {
      if (showAlert) showAlertDialog(buildContext!, 'Upload Failed'.tr, 'Please enter select picture..'.tr, '', 'OK'.tr);
      return false;
    }
    if (editItem!.desc.isEmpty) {
      if (showAlert) showAlertDialog(buildContext!, 'Upload Failed'.tr, 'Please enter desc..'.tr, '', 'OK'.tr);
      return false;
    }
    return true;
  }

  moveBackStep() {
    if (!isEditMode && stepIndex - 1 >= 0) {
      stepIndex--;
      notifyListeners();
    } else {
      Get.back();
    }
  }

  moveNextStep() {
    if (!isEditMode && stepIndex + 1 < stepMax) {
      stepIndex++;
      notifyListeners();
    } else {
      if (checkEditDone(true)) {
        uploadStart();
      }
    }
  }

  uploadStart() async {
    LOG('---> uploadStart: ${imageData.length}');
    showLoadingDialog(buildContext!, 'Uploading now...'.tr);
    // upload new images..
    editItem!.picData = null;
    if (imageData.isNotEmpty) {
      editItem!.picData ??= [];
      var upCount = 0;
      for (var item in imageData.entries) {
        if (item.value['data'] != null) {
          var result = await storyRepo.uploadImageInfo(item.value as JSON);
          if (result != null) {
            editItem!.picData!.add(PicData(
              id: item.key,
              type: 0,
              url: result,
            ));
            item.value['url'] = result;
            upCount++;
          } else {
            showAlertDialog(buildContext!, 'Upload'.tr, 'Upload has been failed!'.tr, '', 'OK'.tr);
            return;
          }
        } else if (JSON_NOT_EMPTY(item.value['url'])) {
          editItem!.picData!.add(PicData.fromJson(item.value));
        }
      }
      LOG('---> image upload done : $upCount');
    }
    // clean option data..
    if (eventInfo != null) {
      editItem!.country       = eventInfo!.country;
      editItem!.countryState  = eventInfo!.countryState;
      editItem!.groupId       = eventInfo!.groupId;
      editItem!.eventId       = eventInfo!.id;
      editItem!.eventTitle    = eventInfo!.title;
      editItem!.eventPic      = eventInfo!.pic;
    } else {
      editItem!.country       = AppData.currentCountry;
      editItem!.countryState  = AppData.currentState;
    }
    // set status..
    editItem!.status = JSON_EMPTY(editItem!.getOptionDataMap) || editItem!.getOptionValue('open_now') ? 1 : 2;
    // set search data..
    editItem!.searchData  = CreateSearchWordList(editItem!.toJson());
    editItem!.userId      = AppData.USER_ID;
    editItem!.userName    = AppData.USER_NICKNAME;
    editItem!.userPic     = AppData.USER_PIC;
    LOG('---> addEventItem : ${editItem!.toJson()}');

    storyRepo.addStoryItem(editItem!).then((result) {
      hideLoadingDialog();
      if (result != null) {
        showAlertDialog(buildContext!, 'Upload'.tr, 'Story Upload Complete'.tr, '', 'OK'.tr).then((_) {
          Get.back(result: result);
        });
      } else {
        showAlertDialog(buildContext!, 'Upload'.tr, 'Story Upload Failed'.tr, '', 'OK'.tr);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}