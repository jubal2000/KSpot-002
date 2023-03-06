
import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
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
  JSON fileData = {};
  Map<String, UploadFileModel> uploadFileData = {};
  DateTime? startTime;

  var  memberList = [].obs;
  var  isAdmin = false.obs;
  var  roomTitle = ''.obs;
  var  isNoticeShow = true.obs;
  var  isNoticeAll  = true.obs;

  init(context) {
    buildContext = context;
  }

  initData(ChatRoomModel room) {
    roomInfo = room;
    LOG('--> initData room : $isAdmin / ${roomInfo!.noticeData}');
    roomTitle.value = roomInfo!.title;
    initMemberList();
  }

  initMemberList() {
    var adminCheck = false;
    var memberCheck = false;
    memberList.clear();
    for (var item in roomInfo!.memberData) {
      memberList.add(item.nickName);
      if (item.id == AppData.USER_ID) {
        memberCheck = true;
        isAdmin.value = item.status == 2;
        if (item.createTime != null) {
          startTime = DateTime.parse(item.createTime!);
        }
      }
      if (item.status == 2) {
        adminCheck = true;
      }
    }
    LOG('--> initMemberList : ${memberList.length} / $memberCheck');
    if (!adminCheck && roomInfo!.userId == AppData.USER_ID) {
      isAdmin.value = true;
    }
    if (!memberCheck) {
      Get.back();
    }
  }

  getChatData() {
    chatRepo.startChatStreamData(roomInfo!.id, startTime ?? DateTime.now(), (result) {
      if (result.isNotEmpty) {
        // var orgCount = showList.length;
        // LOG('--> orgCount : $orgCount / ${result.length}');
        showList.clear();
        showList.addAll(result);
        cache.setChatItemData(result);
        // var updateCount = cache.setChatItemData(result);
        // LOG('--> startChatStreamData check : $orgCount / ${result.length} / $updateCount');
        // var lastItem = showList.entries.last.value as JSON;
        // var lastKey = roomInfo!.id;
        // AppData.isMainActive = true;
        // AppData.chatReadLog[lastKey] = {'id': lastKey, 'lastId': lastItem['id'], 'createTime': SERVER_TIME_STR(lastItem['createTime'])};
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
        if (scrollController.hasClients) {
          scrollController.jumpTo(0);
        }
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
    final reverseM = JSON.from(LinkedHashMap.fromEntries(showList.entries.toList().reversed));
    for (var item in reverseM.entries) {
      // LOG('--> reverseM item : ${item.value.toString()}');
      var action = INT(item.value['action']);
      if (action != 0 && JSON_NOT_EMPTY(item.value['memberData'])) {
        roomInfo!.memberData.clear();
        for (var mItem in item.value['memberData']) {
          roomInfo!.memberData.add(MemberData.fromJson(mItem));
          // set admin id..
          if (INT(mItem['status']) == 2) {
            roomInfo!.userId = STR(mItem['id']);
          }
        }
        if (action == ChatActionType.title) {
          roomInfo!.title = STR(item.value['desc']);
          roomTitle.value = roomInfo!.title;
          LOG('--> title changed ! : ${roomInfo!.title}');
        } else {
          if (action == ChatActionType.notice) {
            if (JSON_NOT_EMPTY(item.value['noticeData'])) {
              roomInfo!.noticeData = List<NoticeModel>.from(item.value['noticeData'].map((e) => NoticeModel.fromJson(e)).toList());
            } else {
              roomInfo!.noticeData = [];
            }
            isNoticeShow.value = true;
            LOG('--> notice changed ! : ${roomInfo!.noticeData!.toString()}');
          }
          initMemberList();
          memberList.refresh();
          cache.setChatRoomItem(roomInfo!);
          cache.chatItemData.clear();
        }
        return true;
      }
    }
    return false;
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
          fileData[addItem.id] = imageItem;
        } else {
          var imageItem = {'id': addItem.id, 'url': 'assets/file_icons/icon_${addItem.extension}.png'};
          fileData[addItem.id] = imageItem;
        }
        LOG('--> addItem : ${addItem.toJson()}');
        uploadFileData[addItem.id] = addItem;
      }
      notifyListeners();
    }
    AppData.isMainActive = true;
  }

  refreshRoomInfo([bool isNew = false]) async {
    LOG('--> refreshRoomInfo : $isNew');
    if (isNew) {
      var result = await chatRepo.getChatRoomInfo(roomInfo!.id);
      if (result != null) {
        roomInfo = ChatRoomModel.fromJson(result);
        cache.setChatRoomItem(roomInfo!, true);
        cache.chatItemData.clear();
      }
    }
    if (cache.chatRoomData.containsKey(roomInfo!.id)) {
      initData(cache.chatRoomData[roomInfo!.id]!);
      // notifyListeners();
    }
  }

  showChatList() {
    List<Widget> result = [];
    var parentId = '';
    refreshMemberList();
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
        if (addItem == null || addItem.openCount != openCount) {
          LOG('--> addItem : ${isAdmin.value} / $isOpened => ${addItem != null} / ${addItem != null ? addItem.openCount : 0} / $openCount');
          addItem = ChatItem(
            item.value,
            openCount: openCount,
            isOwner: isOwner,
            isManager: isAdmin.value,
            isOpened: isOpened,
            isShowFace: isShowFace,
            isShowDate: isShowDate,
            onSelected: (key, status) {
              switch(status) {
                case 8: // room update
                  refreshRoomInfo();
                  break;
                case 9: // talk list update
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
        if (action == 0) {
          parentId = item.value['senderId'];
        } else {
          parentId = '';
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
      )
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
          if (fileData.isNotEmpty)...[
            Row(
              children: [
                Container(
                  width: Get.width - UI_HORIZONTAL_SPACE * 2 - 50,
                  child: ImageEditScrollViewer(
                    fileData,
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
                          fileData.remove(key);
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
                        fileData.clear();
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
                      if (!AppData.isMainActive || (sendText.isEmpty && fileData.isEmpty)) return;
                      if (fileData.length > UPLOAD_FILE_MAX) {
                        showAlertDialog(buildContext!, 'Upload'.tr,
                            'You can\'t add any more'.tr, '${'Max'.tr}: $UPLOAD_FILE_MAX', 'OK'.tr);
                        return;
                      }
                      AppData.isMainActive = false;
                      if (uploadFileData.isNotEmpty) {
                        showLoadingDialog(buildContext!, 'Uploading now...'.tr);
                      }
                      chatRepo.createChatItem(roomInfo!, '', sendText, 0, uploadFileData).then((result) {
                        hideLoadingDialog();
                        textController.text = '';
                        sendText = '';
                        fileData.clear();
                        uploadFileData.clear();
                        AppData.isMainActive = true;
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

  noticeItem(NoticeModel notice, [int index = 0]) {
    const imageSize = 40.0;
    JSON noticeFileData = {};
    if (notice.fileData != null && notice.fileData!.isNotEmpty) {
      // LOG("--> thumbList : ${widget.messageItem['fileData']}");
      for (var item in notice.fileData!) {
        LOG("--> fileData item : ${item.toJson()}");
        JSON addItem = {'id': item.id};
        addItem['url']      = item.thumb;
        addItem['linkPic']  = item.url;
        // addItem['title']    = IS_IMAGE_FILE(item.extension) ? '' : item.name;
        noticeFileData[item.id] = addItem;
      }
    }
    return Container(
      width: Get.width * 0.9,
      padding: EdgeInsets.fromLTRB(isAdmin.value ? 10 : UI_HORIZONTAL_SPACE_M, UI_HORIZONTAL_SPACE,
          10, UI_HORIZONTAL_SPACE_S),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isAdmin.value)...[
            SizedBox(
              width: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      showNoticeEditDialog(buildContext!, 'Notice Edit'.tr,
                          notice.toJson()).then((result) {
                        LOG('--> showNoticeEditDialog result : $result');
                        if (result != null) {
                          result['id'         ] ??= '';
                          result['index'      ] = 0;
                          result['userId'     ] = AppData.USER_ID;
                          result['userName'   ] = AppData.USER_NICKNAME;
                          result['createTime' ] = DateTime.now().toString();
                          chatRepo.setChatRoomNotice(roomInfo!.id,
                              NoticeModel.fromJson(result), BOL(result['isFirst']));
                        }
                      });
                    },
                    child: Icon(Icons.edit_note, size: 24),
                  ),
                ]
              )
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(DESC(notice.desc), style: ItemDescStyle(buildContext!)),
                    ),
                    SizedBox(
                        width: 30,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (index == 0)
                                GestureDetector(
                                  onTap: () {
                                    isNoticeShow.value = false;
                                  },
                                  child: Icon(Icons.highlight_remove, size: 24),
                                ),
                            ]
                        )
                    )
                  ]
                ),
                SizedBox(height: 5),
              // Text('$index. ${SERVER_TIME_STR(notice.createTime)}', style: ItemDescExInfoStyle(buildContext!)),
                if (noticeFileData.isNotEmpty)...[
                  SizedBox(
                    width: noticeFileData.length * imageSize,
                    child: CardScrollViewer(
                      noticeFileData,
                      itemWidth: imageSize,
                      itemHeight: imageSize,
                      itemRound: 8,
                      sidePadding: 0,
                      isImageExView: true,
                      backgroundPadding: EdgeInsets.zero,
                      onActionCallback: (key, status) {
                        LOG('--> onActionCallback : $key / $status');
                        showImageSlideDialog(buildContext!, noticeFileData.entries.map((e) => STR(e.value['linkPic']).toString()).toList(), 0, true);
                      },
                    ),
                  ),
                  SizedBox(height: 5),
                ],
                Text(SERVER_TIME_STR(notice.createTime), style: ItemDescExInfoStyle(buildContext!)),
              ],
            )
          ),
        ]
      )
    );
  }

  showChatNotice() {
    return Obx(() => TopCenterAlign(
      child: AnimatedSize(
      duration: Duration(milliseconds: 200),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          height: isNoticeShow.value ? null : 0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Theme.of(buildContext!).canvasColor.withOpacity(0.8)
          ),
          child: FittedBox(
            child: Column(
              children: [
                if (!isNoticeAll.value || roomInfo!.noticeData!.length <= 1)
                  noticeItem(roomInfo!.noticeData!.first, 0),
                if (isNoticeAll.value && roomInfo!.noticeData!.length > 1)
                  ...roomInfo!.noticeSortedList!.map((e) =>
                    noticeItem(e, e.index)).toList(),
                if ((LIST_NOT_EMPTY(roomInfo!.noticeData) && roomInfo!.noticeData!.length > 1))
                  GestureDetector(
                    onTap: () {
                      isNoticeAll.value = !isNoticeAll.value;
                    },
                    child: Container(
                      width: 100,
                      height: 30,
                      color: Colors.transparent,
                      child: Icon(isNoticeAll.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 24),
                    )
                  )
              ],
            )
          )
        )
      )
    ));
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

  roomMenuList() {
    return [
      ...DropdownItems.chatRoomMenu1.map((item) => DropdownMenuItem<DropdownItem>(
        value: item,
        child: DropdownItems.buildItem(buildContext!, item),
      )),
      if (isAdmin.value)...[
        ...DropdownItems.chatRoomAdmin1.map((item) => DropdownMenuItem<DropdownItem>(
          value: item,
          child: DropdownItems.buildItem(buildContext!, item),
        )),
      ]
    ];
  }

  onRoomMenuAction(DropdownItemType type) {
    switch(type) {
      case DropdownItemType.exit:
        if (isAdmin.value) {
          ShowToast('You are currently an admin'.tr);
          return;
        }
        showAlertYesNoCheckDialog(buildContext!, 'Room Exit'.tr, 'Would you like to leave the chat room?'.tr,
            'Leave quietly'.tr, 'Cancel'.tr, 'OK'.tr).then((result) {
          if (result > 0) {
            chatRepo.exitChatRoom(roomInfo!.id, result == 1).then((result2) {
              if (result2 != null && JSON_EMPTY(result2['error'])) {
                Get.back();
              }
            });
          }
        });
        break;
      case DropdownItemType.title:
        showTextInputDialog(buildContext!, 'Room Title'.tr, '', roomInfo!.title, 1, null).then((result) {
          if (result.isNotEmpty && roomInfo!.title != result) {
            chatRepo.setChatRoomTitle(roomInfo!.id, result);
          }
        });
        break;
      case DropdownItemType.noticeShow:
        isNoticeShow.value = true;
        break;
      case DropdownItemType.noticeAdd:
        if (JSON_EMPTY(roomInfo!.noticeData) || roomInfo!.noticeData!.length < CHAT_NOTICE_MAX) {
          showNoticeEditDialog(buildContext!, 'Notice Add'.tr, {}).then((result) async {
            if (result != null) {
              JSON addItem = {};
              addItem['id'         ] ??= '';
              addItem['status'     ] = 1;
              addItem['index'      ] = 0;
              if (JSON_NOT_EMPTY(result['fileData'])) {
                showLoadingDialog(buildContext!, 'Uploading now...'.tr);
                for (JSON item in result['fileData']) {
                  if (item['data'] != null) {
                    var result = await api.uploadData(item['data'], item['id'], 'chat_notice_img');
                    if (result != null && item['thumbData'] != null) {
                      var thumbResult = await api.uploadData(item['thumbData'], item['id'], 'chat_notice_img_thumb');
                      if (thumbResult != null) {
                        item['url'] = result;
                        item['thumb'] = thumbResult;
                      }
                    }
                  } else {
                    var result = await api.uploadFile(File.fromUri(Uri.parse(item['path'])), 'chat_notice_file', item['id']);
                    if (result != null) {
                      item['url'] = result;
                    }
                  }
                  addItem['fileData'] ??= [];
                  addItem['fileData'].add(item);
                }
              }
              addItem['desc'       ] = STR(result['desc']);
              addItem['userId'     ] = AppData.USER_ID;
              addItem['userName'   ] = AppData.USER_NICKNAME;
              addItem['createTime' ] = DateTime.now().toString();
              chatRepo.setChatRoomNotice(roomInfo!.id, NoticeModel.fromJson(addItem), BOL(result['isFirst']));
              hideLoadingDialog();
            }
          });
        } else {
          ShowToast('Notice is the maximum number'.tr);
        }
        break;
    }
  }
}