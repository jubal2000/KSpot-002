import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/style.dart';
import '../models/event_model.dart';
import '../utils/utils.dart';
import '../view/main_event/main_event_time_edit.dart';
import '../widget/card_scroll_viewer.dart';
import '../widget/edit/edit_list_widget.dart';

class EventViewModel extends ChangeNotifier {
  Map<String, EventModel>? eventList;
  EventModel? editItem;
  BuildContext? buildContext;
  final _imageGalleryKey  = GlobalKey();
  final JSON imageList = {};

  init(BuildContext context) {
    buildContext = context;
  }

  addMainData(EventModel mainItem) {
    eventList ??= {};
    eventList![mainItem.id] = mainItem;
  }

  showMainList(context) {
    return ListView(
    );
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
        // Get.to(() => FollowScreen(AppData.userInfo, isShowMe: true, isSelectable: true))!.then((value) {
        //   setState(() {
        //     LOG("-->  widget.placeInfo['managerData'] Set : ${AppData.listSelectData}");
        //     _eventInfo['managerData'] = {};
        //     if (AppData.listSelectData.isNotEmpty) {
        //       for (var item in AppData.listSelectData.entries) {
        //         _eventInfo['managerData'][item.key] = {
        //           'userId': item.key,
        //           'pic': STR(item.value['pic']),
        //           'nickName': STR(item.value['nickName'])
        //         };
        //         LOG("--> managerData add [${item.key}] : ${_eventInfo['managerData'][item.key]}");
        //       }
        //     }
        //     LOG("--> managerData list : ${_eventInfo['managerData']}");
        //   });
        // });
        break;
      case EditListType.customField:
        // showCustomFieldSelectDialog(buildContext!).then((customId) {
        //   LOG("-->  showCustomFieldSelectDialog result : $customId / ${AppData.INFO_CUSTOMFIELD[customId]}");
        //   if (customId.isNotEmpty) {
        //     var key = Uuid().v1();
        //     var customInfo = AppData.INFO_CUSTOMFIELD[customId];
        //     var title = customInfo['titleEdit'] ?? customInfo['title'];
        //     _eventInfo['customData'] ??= {};
        //     _eventInfo['customData'][key] = {'id':key, 'title':title, 'customId':customId};
        //     if (customInfo['titleEx'] != null) _eventInfo['customData'][key]['titleEx'] = customInfo['titleEx'];
        //   }
        // });
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
        //   });
        // }
        break;
      case EditListType.timeRange:
        if (status == 0) {
          onEditTime(editItem!.getTimeData(key)!.toJson());
        } else {
          showAlertYesNoDialog(buildContext!, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
            if (result == 1) editItem!.subTimeData(key);
          });
        }
        break;
      case EditListType.manager:
        // if (status == 0) {
        //   var userInfo = await api.getUserInfoFromId(_eventInfo['managerData'][key]['userId']);
        //   if (JSON_NOT_EMPTY(userInfo)) {
        //     Navigator.push(context, MaterialPageRoute(builder: (context) =>
        //         TargetProfileScreen(userInfo))).then((value) {});
        //   } else {
        //     showUserAlertDialog(context, '${_eventInfo['managerData'][key]['userId']}');
        //   }
        // } else {
        //   showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
        //     setState(() {
        //       if (result == 1) {
        //         _eventInfo['managerData'].remove(key);
        //       }
        //     });
        //   });
        // }
        break;
      case EditListType.customField:
      //   if (status == 1) {
      //     showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
      //       setState(() {
      //         if (result == 1)  _eventInfo['customData'].remove(key);
      //         LOG('--> remove $key -> ${_eventInfo['customData']}');
      //       });
      //     });
      //   }
      //   break;
      // case EditListType.goods:
      //   if (status == 0) {
      //     var userInfo =  _eventInfo['linkGoodsData'][key];
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => TargetGoodsScreen(userInfo))).then((value) {
      //       setState(() {
      //         _eventInfo['linkGoodsData'] = AppData.listSelectData;
      //       });
      //     });
      //   } else {
      //     showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
      //       setState(() {
      //         if (result == 1)  _eventInfo['linkGoodsData'].remove(key);
      //       });
      //     });
      //   }
    }
  }

  addTimeItem() {
    onEditTime(JSON.from(jsonDecode('{"id":"${Uuid().v1()}", "type":0, "index":999}')), false);
  }

  onEditTime(JSON editField, [bool isEdit = true]) {
    Get.to(() => EventTimeSelectScreen(editField, isEdit: isEdit))!.then((result) {
      if (result != null) {
        try {
          var key = result['id'] ?? Uuid().v1();
          result['id'] = key;
          result['desc'] = TIME_DATA_DESC(result);
          var addItem = TimeData.fromJson(result);
          editItem!.timeData ??= [];
          editItem!.timeData!.add(addItem);
          LOG('=======> timeData result : ${addItem.toJson()}');
        } catch (e) {
          LOG('--> timeData error : $e');
        }
      }
    });
  }

  get editEventToJSON {
    JSON result = {};
     if (editItem != null && editItem!.timeData != null) {
       for (var item in editItem!.timeData!) {
         result[item.id] = item.toJson();
       }
     }
    LOG('--> editEventToJSON : ${result.toString()}');
    return result;
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
        title: '',
        addText: 'Photo Add'.tr,
        selectText: '[first]'.tr,
        selectTextStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.purple,
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

  @override
  void dispose() {
    super.dispose();
  }
}