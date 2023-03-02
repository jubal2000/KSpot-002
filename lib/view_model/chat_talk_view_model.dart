
import 'dart:collection';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:uuid/uuid.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/chat_model.dart';
import '../models/etc_model.dart';
import '../models/upload_model.dart';
import '../repository/chat_repository.dart';
import '../repository/user_repository.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../widget/card_scroll_viewer.dart';
import '../widget/chat_item.dart';

class ChatTalkViewModel extends ChangeNotifier {
  final chatRepo = ChatRepository();
  final userRepo = UserRepository();
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();

  final textController    = TextEditingController();
  final scrollController  = ScrollController();

  BuildContext? buildContext;
  ChatRoomModel? roomInfo;

  final iconSize      = 24.0;
  final showMemberMax = 4;

  var  sendText = '';
  JSON showList = {};
  JSON imageData = {};
  Map<String, UploadFileModel> uploadFileData = {};

  var  memberList = [].obs;
  var  isManager = false;

  init(context) {
    buildContext = context;
  }

  initData(ChatRoomModel room) {
    roomInfo = room;
    DateTime? startTime;
    for (var item in roomInfo!.memberData) {
      // LOG('--> roomInfo!.memberData :${item.toJson()}');
      if (item.id == AppData.USER_ID && item.createTime != null) {
        startTime = DateTime.parse(item.createTime!);
        isManager = item.status == 2;
      }
    }
    chatRepo.startChatStreamData(roomInfo!.id, startTime ?? DateTime.now(), (result) {
      if (result.isNotEmpty) {
        var orgCount = showList.length;
        LOG('--> orgCount : $orgCount / ${result.length}');
        showList.clear();
        showList.addAll(result);
        var updateCount = cache.setChatItemData(result);
        LOG('--> startChatStreamData check : $orgCount / ${result.length} / $updateCount');
        var lastItem = showList.entries.last.value as JSON;
        var lastKey = roomInfo!.id;
        AppData.isMainActive = true;
        AppData.chatReadLog[lastKey] = {'id': lastKey, 'lastId': lastItem['id'], 'createTime': SERVER_TIME_STR(lastItem['createTime'])};
        notifyListeners();
        // if (orgCount != result.length || updateCount > 0) {
        //   notifyListeners();
        // }
      }
    });
  }

  refreshListYPos() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 200), () {
        scrollController.jumpTo(0);
      });
    });
  }

  getUserInfo() async {
    for (var item in roomInfo!.memberData) {
      var result = await userRepo.getUserInfo(item.id);
      if (result != null) {
        item = MemberData.fromJson(result.toJson());
      }
    }
  }

  showTitleWithPic() {
    return SizedBox(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(roomInfo!.type == 0 ? 8 : 100),
        child: showImageFit(roomInfo!.pic),
      ),
    );
  }

  showMemberListText() {
    return Obx(() => Row(
      children: [
        for (var i=0; i<memberList.length; i++)
          Text(i > 0 ? ', ${memberList[i]}' : memberList[i], style: ItemDescStyle(buildContext!)),
        SizedBox(width: 10),
        Text('${memberList.length}', style: ItemTitleBoldStyle(buildContext!)),
      ],
    ));
  }

  refreshMemberList() {
    memberList.value = [];
    final reverseM = JSON.from(LinkedHashMap.fromEntries(showList.entries.toList().reversed));
    for (var item in reverseM.entries) {
      // LOG('--> reverseM item : ${item.value.toString()}');
      if (INT(item.value['action']) != 0 && LIST_NOT_EMPTY(item.value['memberData'])) {
        for (var member in item.value['memberData']) {
          memberList.add(member['nickName']);
          roomInfo!.addMemberData(member);
        }
        cache.chatRoomData[roomInfo!.id] = roomInfo!;
        memberList.refresh();
        // LOG('--> refreshMemberList : ${memberList.toString()} / ${item.value['memberList'].toString()}');
        return;
      }
    }
    if (memberList.isEmpty && LIST_NOT_EMPTY(reverseM.entries)) {
      for (var member in roomInfo!.memberData) {
        memberList.add(member.nickName);
      }
      memberList.refresh();
    }
  }

  selectAttachFile() async {
    if (!AppData.isMainActive) return;
    AppData.isMainActive = false;
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      for (var item in result.files) {
        var addItem = UploadFileModel(
          id: Uuid().v4(),
          status: 1,
          name: item.name,
          size: item.size,
          extension: item.extension ?? '',
          thumb: '',
          url: '',
          path: item.path,
        );
        if (IS_IMAGE_FILE(addItem.extension) && item.path != null) {
          var data = await ReadFileByte(item.path!);
          var thumbData = await resizeImage(data!, 128) as Uint8List;
          var imageItem = {'id': addItem.id, 'data': data, 'thumb': thumbData};
          addItem.data = data;
          addItem.thumbData = thumbData;
          imageData[addItem.id] = imageItem;
        } else {
          var imageItem = {'id': addItem.id, 'url': 'assets/file_icons/icon_${addItem.extension}.png'};
          imageData[addItem.id] = imageItem;
        }
        LOG('--> addItem : ${addItem.toJson()}');
        uploadFileData[addItem.id] = addItem;
      }
      notifyListeners();
    }

    // imageData.clear();
    // List<XFile>? imageList = await ImagePicker().pickMultiImage(maxWidth: PIC_IMAGE_SIZE_MAX, maxHeight: PIC_IMAGE_SIZE_MAX);
    // if (LIST_NOT_EMPTY(imageList)) {
    //   showLoadingDialog(buildContext!, 'Processing now...'.tr);
    //   for (var i = 0; i < imageList.length; i++) {
    //     var image = imageList[i];
    //     var data = await ReadFileByte(image.path);
    //     if (data != null) {
    //       var thumbData = await resizeImage(data.buffer.asUint8List(), 256) as Uint8List;
    //       var key = Uuid().v1();
    //       imageData[key] = {'id': key, 'data': data, 'thumb': thumbData};
    //     }
    //   }
    //   hideLoadingDialog();
    //   notifyListeners();
    // }
    AppData.isMainActive = true;
  }

  showChatList() {
    List<Widget> result = [];
    var parentId = '';
    // showList = JSON_CREATE_TIME_SORT_ASCE(showList);
    refreshMemberList();
    // LOG('--> showChatList memberList : ${memberList.length} / ${memberList.toString()}');
    for (var i=0; i<showList.length; i++) {
      var isShowDate = true;
      var item = showList.entries.elementAt(i);
      var action = INT(item.value['action']);
      if (action >= 0) {
        if (i+1 < showList.length) {
          var nextItem = showList.entries.elementAt(i+1);
          isShowDate = item.value['senderId'] != nextItem.value['senderId'];
        }
        var isOwner = CheckOwner(item.value['senderId']);
        var isOpened = false;
        var openCount = 0;
        if (item.value['memberList'] != null && item.value['memberList'].length > 1) {
          if (LIST_NOT_EMPTY(item.value['openList'])) {
            for (var member in item.value['memberList']) {
              // LOG('--> member item : $member / ${item.value['memberList'].toString()} / ${item.value['openList'].toString()}');
              if (item.value['openList'].contains(member)) {
                openCount++;
              }
            }
            // LOG('--> isOpened : $isOpened / ${roomInfo!.memberList.length - 1} / $openCount');
            isOpened = item.value['memberList'].length - 1 <= openCount;
          }
        }
        var isShowFace = parentId != item.value['senderId'];
        ChatItem? addItem = cache.chatItemData[item.key];
        // LOG('-----> showList check [${STR(item.value['desc'])}] : $isOwner / $isOpened / [$openCount / ${addItem != null} ? ${addItem != null ? addItem.openCount : 0}]');
        // LOG('--> addItem : $isOpened => ${addItem != null} / ${addItem != null ? addItem.openCount : 0} / $openCount');
        if (addItem == null || addItem.openCount != openCount) {
          addItem = ChatItem(
              item.value,
              openCount: openCount,
              isOwner: isOwner,
              isManager: isManager,
              isOpened: isOpened,
              isShowFace: isShowFace,
              isShowDate: isShowDate,
              onSelected: (key, status) {
                switch(status) {
                  case 9:
                    notifyListeners();
                    break;
                }
              }, onSetOpened: (message) {
            api.addChatOpenItem(message['id'], AppData.USER_ID);
          }
          );
        }
        result.add(addItem);
        cache.chatItemData[item.key] = addItem;
        if (INT(item.value['action']) == 0) {
          parentId = item.value['senderId'];
        }
      }
    }
    return result;
  }
  
  showChatMainList() {
    return Expanded(
      child: SingleChildScrollView(
          reverse: true,
          controller: scrollController,
          child: Column(
            children: [
              SizedBox(height: 10),
              ...showChatList(),
              SizedBox(height: 10),
            ],
          )
      ),
    );
  }
  
  showChatEditBox() {
    return Container(
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
      color: Theme.of(buildContext!).dialogBackgroundColor,
      child: Column(
        children: [
          SizedBox(height: 10),
          if (imageData.isNotEmpty)...[
            Row(
              children: [
                Container(
                  width: Get.width - UI_HORIZONTAL_SPACE * 2 - 50,
                  child: ImageEditScrollViewer(
                    imageData,
                    itemWidth: 40.0,
                    itemHeight: 40.0,
                    isEditable: true,
                    sidePadding: 0,
                    onActionCallback: (key, status) {
                      LOG('--> onActionCallback : $key / $status');
                      switch (status) {
                        case 1:
                          selectAttachFile();
                          break;
                        case 2:
                          imageData.remove(key);
                          uploadFileData.remove(key);
                          notifyListeners();
                        break;
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showAlertYesNoDialog(buildContext!, 'Remove'.tr, 'Remove all files?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
                      if (result == 1) {
                        imageData.clear();
                        uploadFileData.clear();
                        notifyListeners();
                      }
                    });
                  },
                  icon: Icon(Icons.close, size: 20),
                )
              ],
            ),
            SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: textController,
                  decoration: inputChatSuffix(buildContext!),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 200,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(buildContext!).primaryColor),
                  onChanged: (value) {
                    sendText = value;
                    scrollController.jumpTo(0);
                  },
                )
              ),
              Container(
                width: 80,
                height: 40,
                padding: EdgeInsets.only(left: 10),
                child: ElevatedButton(
                    onPressed: () async {
                      if (!AppData.isMainActive || (sendText.isEmpty && imageData.isEmpty)) return;
                      if (imageData.length > UPLOAD_IMAGE_MAX) {
                        showAlertDialog(buildContext!, 'Image'.tr,
                            'You can\'t add any more'.tr, '${'Max'.tr}: $UPLOAD_IMAGE_MAX', 'OK'.tr);
                        return;
                      }
                      AppData.isMainActive = false;
                      // showLoadingDialog(buildContext!, 'Uploading now...'.tr);
                      chatRepo.createChatItem(roomInfo!, sendText, uploadFileData).then((result) {
                        hideLoadingDialog();
                        AppData.isMainActive = true;
                        textController.text = '';
                        sendText = '';
                        imageData.clear();
                        uploadFileData.clear();
                        notifyListeners();
                      });
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(buildContext!).primaryColor),
                    ),
                    child: Text('Send'.tr,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                        color: Theme.of(buildContext!).colorScheme.inversePrimary))
                )
              )
            ]
          ),
          SizedBox(height: 20),
        ]
      )
    );
  }

  showChatButtonBox() {
    return Positioned(
      left: 15,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                selectAttachFile();
              },
              child: Icon(Icons.attach_file, size: iconSize,
                color: Theme.of(buildContext!).primaryColor.withOpacity(0.5)),
            ),
            SizedBox(width: 15),
            GestureDetector(
              onTap: () async {
                // paste..
                ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
                if (cdata != null) {
                  sendText = cdata.text.toString();
                  textController.text = sendText;
                }
              },
              child: Icon(Icons.paste, size: iconSize,
                color: Theme.of(buildContext!).primaryColor.withOpacity(0.5)),
            ),
          ],
        )
      )
    );
  }
}