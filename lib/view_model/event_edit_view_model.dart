import 'dart:convert';
import 'dart:typed_data';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:uuid/uuid.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/style.dart';
import '../data/theme_manager.dart';
import '../models/etc_model.dart';
import '../models/event_group_model.dart';
import '../models/event_model.dart';
import '../models/place_model.dart';
import '../repository/event_repository.dart';
import '../utils/utils.dart';
import '../view/follow/follow_screen.dart';
import '../view/profile/profile_screen.dart';
import '../widget/event_time_edit_widget.dart';
import '../view/profile/profile_target_screen.dart';
import '../widget/card_scroll_viewer.dart';
import '../widget/edit/edit_list_widget.dart';
import '../widget/event_group_dialog.dart';

class EventEditViewModel extends ChangeNotifier {
  EventModel?   editItem;
  PlaceModel?   placeInfo;
  final userRepo  = UserRepository();
  final eventRepo = EventRepository();
  final titleN = ['Agree to Terms and Conditions', 'Spot Select', 'Event Edit'];

  // for Edit..
  final _imageGalleryKey  = GlobalKey();
  JSON imageData = {};
  JSON managerData = {};
  JSON customData = {};
  var titlePicKey = '';

  var stepIndex = 0;
  var stepMax = 3;
  var agreeMax = 1;

  var isShowOnly = false;
  var isEdited = false;
  var isEditMode = false;
  var agreeChecked = false;

  get isNextEnable {
    switch(stepIndex) {
      case 0: return agreeChecked;
      case 1: return true;
      // case 1: return placeInfo != null;
    }
    return checkEditDone(false);
  }

  get editEventToJSON {
    if (editItem != null) {
      return editItem!.getTimeDataMap;
    }
    return {};
  }

  get editManagerToJSON {
    if (editItem != null) {
      return editItem!.getManagerDataMap;
    }
    return {};
  }

  get editCustomToJSON {
    if (editItem != null) {
      return editItem!.getCustomDataMap;
    }
    return {};
  }

  get editOptionToJSON {
    JSON result = {};
    if (editItem != null) {
      for (var item in editItem!.getOptionDataMap.entries) {
       result[item.key] = item.value['value'];
      }
    }
    return result;
  }

  initData() {
    imageData = {};
    managerData = {};
    customData = {};
    titlePicKey = '';
    isEdited = false;
  }

  setEditItem(EventModel eventItem, PlaceModel? placeItem) {
    editItem   = eventItem;
    placeInfo  = placeItem;
    if (editItem!.picData != null) {
      for (var item in editItem!.picData!) {
        LOG('  -- ${item.toJson()}');
      }
      for (var item in editItem!.picData!) {
        var jsonItem = {'id': item.id, 'type': 0};
        if (item.url.isNotEmpty) jsonItem['url'] = item.url;
        // if (item.data != null) jsonItem['data'] = item.data.toString();
        imageData[item.id] = jsonItem;
        if (item.url == editItem!.pic) {
          titlePicKey = item.id;
        }
      }
    }
    refreshOption();
  }

  setEventGroup(EventGroupModel group) {
    AppData.currentEventGroup = group;
    AppData.currentContentType = group.contentType;
    notifyListeners();
  }

  setPlaceInfo(PlaceModel? place) {
    placeInfo = place;
    notifyListeners();
  }

  onItemAdd(EditListType type, JSON listItem) {
    unFocusAll(Get.context!);
    AppData.listSelectData = listItem;
    switch (type) {
      // case EditListType.reserve:
      //   onEditReserve({"id":Uuid().v1().toString()});
      //   break;
      case EditListType.timeRange:
        addTimeItem();
        break;
      case EditListType.manager:
      case EditListType.member:
        Get.to(() => FollowScreen(AppData.userInfo, selectData: editItem!.getManagerDataMap, isShowMe: true, isSelectable: true))!.then((value) {
          LOG("-->  FollowScreen result : $value");
          if (value == null) return;
          managerData = {};
          editItem!.managerData = [];
          if (value.isNotEmpty) {
            for (var item in value.entries) {
              final addItem = {
                'id': item.key,
                'status': 1,
                'nickName': STR(item.value['nickName']),
                'pic': STR(item.value['pic'])
              };
              managerData[item.key] = addItem;
              editItem!.managerData!.add(MemberData.fromJson(addItem));
              LOG("--> managerData add [${item.key}] : ${editItem!.managerData}");
            }
          }
          notifyListeners();
        });
        break;
      case EditListType.customField:
        showCustomFieldSelectDialog(Get.context!).then((customId) {
          if (customId.isNotEmpty) {
            var key = Uuid().v1();
            var customInfo = AppData.INFO_CUSTOMFIELD[customId];
            var title = customInfo['titleEdit'] ?? customInfo['title'];
            var addItem = {'id':key, 'title':title, 'customId':customId, 'parentId': customInfo['parentId']};
            if (customInfo['titleEx'] != null) addItem['titleEx'] = customInfo['titleEx'];
            LOG("-->  showCustomFieldSelectDialog edit result : $customId / $addItem");
            customData[key] = addItem;
            editItem!.customData ??= [];
            editItem!.customData!.add(CustomData.fromJson(addItem));
            notifyListeners();
          }
        });
        break;
    }
  }

  onItemSelected(EditListType type, String key, int status) async {
    unFocusAll(Get.context!);
    switch (type) {
      case EditListType.reserve:
        // if (status == 0) {
        //   onEditReserve(_eventInfo['reserveData'][key]);
        // } else {
        //   showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
        //     setState(() {
        //       if (result == 1)  _eventInfo['reserveData'].remove(key);
        //     });
        //   });111
        // }
        break;
      case EditListType.timeRange:
        if (status == 0) {
          for (var item in editItem!.timeData!) {
            LOG('--> onItemSelected item : ${item.toJson()} / ${item.runtimeType}');
          }
          onEditTime(editItem!.getTimeData(key)!.toJson());
        } else {
          showAlertYesNoDialog(Get.context!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            if (result == 1) {
              editItem!.removeTimeData(key);
              isEdited = true;
            }
          });
        }
        break;
      case EditListType.manager:
      case EditListType.member:
        if (status == 0) {
          var userInfo = await userRepo.getUserInfo(managerData[key]['id']);
          if (userInfo != null) {
            Get.to(() => ProfileTargetScreen(userInfo))!.then((result) {

            });
          } else {
            showUserAlertDialog(Get.context!, '${managerData[key]['id']}');
          }
        } else {
          showAlertYesNoDialog(Get.context!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            if (result == 1) {
              managerData.remove(key);
              editItem!.setManagerDataMap(managerData);
              isEdited = true;
            }
          });
        }
        break;
      case EditListType.customField:
        if (status == 1) {
          showAlertYesNoDialog(Get.context!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            if (result == 1) {
              customData.remove(key);
              editItem!.setCustomDataMap(customData);
              isEdited = true;
            }
          });
        }
        break;
      // case EditListType.goods:
      //   if (status == 0) {
      //     var userInfo =  _eventInfo['linkGoodsData'][key];
      //     Navigator.push(Get.context!, MaterialPageRoute(builder: (context) => TargetGoodsScreen(userInfo))).then((value) {
      //       _eventInfo['linkGoodsData'] = AppData.listSelectData;
      //     });
      //   } else {
      //     showAlertYesNoDialog(Get.context!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
      //       if (result == 1) {
      //         customData.remove(key);
      //         eventInfo['linkGoodsData'].remove(key);
      //       }
      //     });
      //   }
    }
  }

  onItemChanged(EditListType type, JSON listData) {
    LOG('-----> onItemChanged : $listData');
    unFocusAll(Get.context!);
    switch (type) {
      case EditListType.customField:
        customData = listData;
        editItem!.setCustomDataMap(customData);
        isEdited = true;
        break;
    }
  }

  onSettingChanged(JSON data) {
    LOG('-----> onSettingChanged : $data');
    editItem!.setOptionDataMap(data);
    isEdited = true;
  }

  checkCustomField(String id, [bool isParent = false]) {
    if (isParent) {
      for (var item in editItem!.getCustomDataMap.entries) {
        if (item.value['parentId'] == id) {
          return true;
        }
      }
    } else {
      return editItem!.getCustomDataMap[id] != null;
    }
    return false;
  }

  addTimeItem() {
    onEditTime(JSON.from(jsonDecode('{"id":"${Uuid().v1()}", "type":0, "index":999}')), false);
  }

  onEditTime(JSON editField, [bool isEdit = true]) {
    Get.to(() => EventTimeSelectWidget(editField, isEdit: isEdit))!.then((result) {
      LOG('-----> EventTimeSelectScreen result : $result');
      if (result != null) {
        try {
          var key = result['id'] ?? Uuid().v1();
          result['id'] = key;
          result['desc'] = TIME_DATA_DESC(result);
          var addItem = TimeData.fromJson(result);
          editItem!.timeData ??= [];
          editItem!.addTimeData(addItem);
          isEdited = true;
          notifyListeners();
          LOG('=======> timeData result : ${addItem.toJson()}');
        } catch (e) {
          LOG('--> timeData error : $e');
        }
      }
    });
  }

  refreshOption() {
    final optionMap = editItem!.getOptionDataMap;
    for (var item in AppData.INFO_EVENT_OPTION.entries) {
      if (item.value.runtimeType != String && item.value.runtimeType != int) {
        bool isAdd = true;
        if (item.value['customShow'] != null) {
          isAdd = false;
          for (var customItem in editItem!.getCustomDataMap.entries) {
            if (STR(customItem.value['customId']) == STR(item.value['customShow'])) {
              isAdd = true;
              break;
            }
          }
        }
        if (isAdd && BOL(item.value['value']) && !optionMap.containsKey(item.key)) {
          LOG('--> add default option data : ${item.key} / ${optionMap.toString()}');
          optionMap[item.key] = {'key': item.key, 'value': '1'};
        }
      }
    }
    if (editItem!.status == 2) {
      optionMap['open'] = {'key': 'open', 'value': ''};
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
        var imageFile = pickList[i];
        var url   = await ShowImageCroper(imageFile.path);
        var data  = await ReadFileByte(url);
        var resizeData = await resizeImage(data!, IMAGE_SIZE_MAX) as Uint8List;
        var key = Uuid().v1();
        imageData[key] = {'id': key, 'type': 0, 'url': '', 'data': resizeData};
        // LOG('----> picLocalImage: ${imageData[key]['color']}');
        if (titlePicKey.isEmpty) titlePicKey = key;
        // if (editItem!.pic.isEmpty) editItem!.pic = key;
      }
      setImageData();
      notifyListeners();
    }
  }

  Future<Color> getImagePalette (ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator
        .fromImageProvider(imageProvider);
    if (paletteGenerator.dominantColor != null) {
      return paletteGenerator.dominantColor!.color;
    }
    return Colors.white;
  }

  showImageSelector() {
    LOG('----> showImageSelector: ${imageData.length} / $titlePicKey');
    for (var item in imageData.entries) {
      LOG('  -- ${item.value}');
      if (titlePicKey.isEmpty) titlePicKey = item.key;
    }
    return ImageEditScrollViewer(
        imageData,
        key: _imageGalleryKey,
        title: 'EVENT PHOTO *'.tr,
        addText: 'Photo Add'.tr,
        selectedId: titlePicKey,
        selectText: '[first]'.tr,
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
            default: {
              titlePicKey = key;
            }
          }
        }
    );
  }

  setCheck(value) {
    agreeChecked = value;
    notifyListeners();
  }

  checkEditDone(showAlert) {
    if (imageData.isEmpty) {
      if (showAlert) showAlertDialog(Get.context!, 'Upload Failed'.tr, 'Please enter select picture..'.tr, '', 'OK'.tr);
      return false;
    }
    if (editItem!.title.isEmpty) {
      if (showAlert) showAlertDialog(Get.context!, 'Upload Failed'.tr, 'Please enter event title..'.tr, '', 'OK'.tr);
      return false;
    }
    if (editItem!.timeData == null || editItem!.timeData!.isEmpty) {
      if (showAlert) showAlertDialog(Get.context!, 'Upload Failed'.tr, 'Please enter event time..'.tr, '', 'OK'.tr);
      return false;
    }
    if (editItem!.managerData == null || editItem!.managerData!.isEmpty) {
      if (showAlert) showAlertDialog(Get.context!, 'Upload Failed'.tr, 'Please enter select manager..'.tr, '', 'OK'.tr);
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
      Future.delayed(Duration(milliseconds: 200)).then((_) {
        if (stepIndex == 2) {
          onItemAdd(EditListType.timeRange, {});
        }
      });
    } else {
      if (checkEditDone(true)) {
        uploadStart();
      }
    }
  }

  uploadStart() async {
    LOG('---> uploadStart: ${imageData.length}');
    showLoadingDialog(Get.context!, 'Uploading now...'.tr);
    // upload new images..
    editItem!.picData = null;
    if (imageData.isNotEmpty) {
      editItem!.picData ??= [];
      var upCount = 0;
      for (var item in imageData.entries) {
        if (item.value['data'] != null) {
          var result = await eventRepo.uploadImageInfo(item.value as JSON);
          if (result != null) {
            editItem!.picData!.add(PicData(
              id: item.key,
              type: 0,
              url: result,
            ));
            item.value['url'  ] = result;
            upCount++;
          }
        } else if (JSON_NOT_EMPTY(item.value['url'])) {
          editItem!.picData!.add(PicData.fromJson(item.value));
        }
        // set title pic..
        if (titlePicKey == item.key) {
          editItem!.pic = STR(item.value['url']);
          var color = await getImagePalette(Image.memory(item.value['data']).image);
          editItem!.themeColor = color.hexCode;
        }
      }
      if (editItem!.pic.isEmpty) {
        var firstItem = imageData.entries.first.value;
        editItem!.pic = firstItem['url'];
        var color = await getImagePalette(Image.memory(firstItem['data']).image);
        editItem!.themeColor = color.hexCode;
      }
      LOG('----------> image upload done : $upCount / ${editItem!.themeColor}');
    }
    // upload customField image..
    if (editItem!.customData != null) {
      var upCount = 0;
      for (var item in editItem!.customData!) {
        if (item.data != null) {
          // var result = await eventRepo.uploadImageData(item, 'eventCustom_img');
          var result = await eventRepo.uploadImageInfo({
            'id': item.id,
            'type': 0,
            'data': item.data,
          }, 'eventCustom_img');
          if (result != null) {
            item.url = result;
            item.data = null;
            upCount++;
          }
        }
      }
      LOG('---> custom image upload done : $upCount');
    }
    // clean option data..
    if (placeInfo != null) {
      editItem!.country       = placeInfo!.country;
      editItem!.countryState  = placeInfo!.countryState;
      editItem!.placeId       = placeInfo!.id;
      editItem!.groupId       = placeInfo!.groupId;
    } else {
      editItem!.country       = AppData.currentCountry;
      editItem!.countryState  = AppData.currentState;
    }
    // set status..
    editItem!.status = 1;
    editItem!.showStatus = JSON_EMPTY(editItem!.getOptionDataMap) || editItem!.getOptionValue('open_now') ? 1 : 0;
    // set search data..
    editItem!.searchData = CreateSearchWordList(editItem!.toJson());
    editItem!.userId = AppData.USER_ID;
    LOG('---> addEventItem : ${editItem!.toJson()}');

    eventRepo.addEventItem(editItem!).then((result) {
      hideLoadingDialog();
      if (result != null) {
        showAlertDialog(Get.context!, 'Upload'.tr, 'Event Upload Complete'.tr, '', 'OK'.tr).then((_) {
          Get.back(result: result);
        });
      } else {
        showAlertDialog(Get.context!, 'Upload'.tr, 'Event Upload Failed'.tr, '', 'OK'.tr);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}