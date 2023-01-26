import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:uuid/uuid.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/style.dart';
import '../data/theme_manager.dart';
import '../models/etc_model.dart';
import '../models/event_group_model.dart';
import '../models/event_model.dart';
import '../models/place_model.dart';
import '../utils/utils.dart';
import '../view/follow/follow_screen.dart';
import '../view/main_event/event_time_edit_screen.dart';
import '../view/main_my/target_profile.dart';
import '../widget/card_scroll_viewer.dart';
import '../widget/edit/edit_list_widget.dart';
import '../widget/event_group_dialog.dart';

class EventEditViewModel extends ChangeNotifier {
  EventModel?   editItem;
  PlaceModel?   placeInfo;
  BuildContext? buildContext;
  final repo = UserRepository();

  // for Edit..
  final _imageGalleryKey  = GlobalKey();
  JSON imageList = {};
  JSON managerData = {};
  JSON customData = {};

  var stepIndex = 2;
  var stepMax = 3;
  var agreeMax = 1;

  var isShowOnly = false;
  var isInputDone = false;
  var agreeChecked = false;

  init(BuildContext context) {
    buildContext = context;
  }

  setEditItem(EventModel item) {
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
    unFocusAll(buildContext!);
    AppData.listSelectData = listItem;
    switch (type) {
      // case EditListType.reserve:
      //   onEditReserve({"id":Uuid().v1().toString()});
      //   break;
      case EditListType.timeRange:
        addTimeItem();
        break;
      case EditListType.manager:
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
              editItem!.managerData!.add(ManagerData.fromJson(addItem));
              LOG("--> managerData add [${item.key}] : ${editItem!.managerData}");
            }
          }
          notifyListeners();
        });
        break;
      case EditListType.customField:
        showCustomFieldSelectDialog(buildContext!).then((customId) {
          if (customId.isNotEmpty) {
            var key = Uuid().v1();
            var customInfo = AppData.INFO_CUSTOMFIELD[customId];
            var title = customInfo['titleEdit'] ?? customInfo['title'];
            var addItem = {'id':key, 'title':title, 'customId':customId};
            if (customInfo['titleEx'] != null) addItem['titleEx'] = customInfo['titleEx'];
            LOG("-->  showCustomFieldSelectDialog result : $customId / $addItem");
            customData[key] = addItem;
            editItem!.customData ??= [];
            editItem!.customData!.add(CustomData.fromJson(addItem));
          }
        });
        break;
    }
  }

  onItemSelected(EditListType type, String key, int status) async {
    unFocusAll(buildContext!);
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
          showAlertYesNoDialog(buildContext!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            if (result == 1) {
              editItem!.removeTimeData(key);
            }
          });
        }
        break;
      case EditListType.manager:
        if (status == 0) {
          var userInfo = await repo.getUserInfo(managerData[key]['id']);
          if (userInfo != null) {
            Get.to(() => TargetProfileScreen(userInfo))!.then((result) {

            });
          } else {
            showUserAlertDialog(buildContext!, '${managerData[key]['id']}');
          }
        } else {
          showAlertYesNoDialog(buildContext!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            if (result == 1) {
              managerData.remove(key);
              editItem!.setManagerDataMap(managerData);
            }
          });
        }
        break;
      case EditListType.customField:
        if (status == 1) {
          showAlertYesNoDialog(buildContext!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            if (result == 1) {
              customData.remove(key);
              editItem!.setCustomDataMap(customData);
            }
          });
        }
        break;
      // case EditListType.goods:
      //   if (status == 0) {
      //     var userInfo =  _eventInfo['linkGoodsData'][key];
      //     Navigator.push(buildContext!, MaterialPageRoute(builder: (context) => TargetGoodsScreen(userInfo))).then((value) {
      //       _eventInfo['linkGoodsData'] = AppData.listSelectData;
      //     });
      //   } else {
      //     showAlertYesNoDialog(buildContext!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
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
    unFocusAll(buildContext!);
    switch (type) {
      case EditListType.customField:
        customData = listData;
        editItem!.setCustomDataMap(customData);
        break;
    }
  }

  addTimeItem() {
    onEditTime(JSON.from(jsonDecode('{"id":"${Uuid().v1()}", "type":0, "index":999}')), false);
  }

  onEditTime(JSON editField, [bool isEdit = true]) {
    Get.to(() => EventTimeSelectScreen(editField, isEdit: isEdit))!.then((result) {
      LOG('-----> EventTimeSelectScreen result : $result');
      if (result != null) {
        try {
          var key = result['id'] ?? Uuid().v1();
          result['id'] = key;
          result['desc'] = TIME_DATA_DESC(result);
          var addItem = TimeData.fromJson(result);
          editItem!.timeData ??= [];
          editItem!.addTimeData(addItem);
          LOG('=======> timeData result : ${addItem.toJson()}');
        } catch (e) {
          LOG('--> timeData error : $e');
        }
      }
    });
  }

  get isNextEnable {
    switch(stepIndex) {
      case 0: return agreeChecked;
      case 1: return placeInfo != null;
    }
    return isInputDone;
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
        title: 'EVENT PHOTO *'.tr,
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

  setCheck(value) {
    agreeChecked = value;
    notifyListeners();
  }

  moveNextStep() {
    if (stepIndex + 1 < stepMax) {
      stepIndex++;
      notifyListeners();
    } else {
      // Get.to(() => SignupStepDoneScreen());
    }
  }

  moveBackStep() {
    if (stepIndex - 1 >= 0) {
      stepIndex--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}