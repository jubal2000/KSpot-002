
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kspot_002/models/etc_model.dart';
import 'package:kspot_002/view/chatting/chatting_edit_screen.dart';
import 'package:kspot_002/view/message/message_group_item.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/chat_model.dart';
import '../models/event_model.dart';
import '../repository/chat_repository.dart';
import '../repository/message_repository.dart';
import '../repository/user_repository.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/chatting/chatting_group_item.dart';
import '../view/chatting/chatting_talk_screen.dart';
import '../view/home/home_top_menu.dart';
import '../widget/user_item_widget.dart';
import '../widget/helpers/helpers/widgets/align.dart';

class ChatType {
  static int get public   => 0;
  static int get private  => 1;
  static int get one      => 2;
}

class ChatRoomType {
  static int get publicMy => 0;
  static int get public   => 1;
  static int get private  => 2;
  static int get one      => 3;
}

class ChatViewModel extends ChangeNotifier {
  final chatRepo = ChatRepository();
  final userRepo = UserRepository();
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();
  Stream? inviteStream;
  Stream? stream;
  int currentTab = 0;

  List<ChatGroupItem> mainShowList = [];
  List<String> tabList = [];
  List<GlobalKey> tabKeyList = [];
  var isTabOpen = [true, true];

  init() {
    initMessageTab();
    // getChatInviteStreamData();
    getChatStreamData();
  }

  initMessageTab() {
    tabKeyList = List.generate(3, (index) => GlobalKey());
    tabList = [
      'Public chat'.tr,
      'Private chat'.tr,
    ];
  }

  setMessageTab(selectTab) {
    currentTab = selectTab;
    notifyListeners();
  }

  getChatRoomData() async {
    cache.chatRoomData.clear();
    final roomData = await chatRepo.getChatRoomData();
    cache.chatRoomData.addAll(roomData);
    return roomData;
  }

  getChatInviteStreamData() {
    inviteStream ??= chatRepo.getChatInviteStreamData();
  }

  getChatStreamData() {
    stream ??= chatRepo.getChatStreamData();
  }

  createNewRoom(roomId) async {
    final result = await chatRepo.getChatRoomInfo(roomId);
    if (result != null) {
      LOG('-----> createNewRoom !! [$roomId] : ${result.toString()}');
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
  }

  enterRoom(roomId, roomInfo, isShow) {
    chatRepo.enterChatRoom(roomId, isShow).then((result2) {
      if (result2 != null && JSON_EMPTY(result2['error'])) {
        showTalkScreen(ChatRoomModel.fromJson(result2));
      }
    });
  }

  showTalkScreen(item) {
    LOG('--> showTalkScreen : ${item.id}');
    Get.to(() => ChatTalkScreen(item))!.then((result) {
      LOG('--> ChatTalkScreen exit : $result');
      if (result == ChatActionType.close) {
        showAlertDialog(Get.context!, 'Room exit'.tr, 'Chat room has ended'.tr, item.title, 'OK'.tr);
        chatRepo.cleanChatRoom(item.id);
      }
      notifyListeners();
    });
  }

  refreshShowList(bool isMy) {
    // LOG('--> refreshShowList : $isMy');
    List<ChatGroupItem> showList = [];
    List<String> showListKey = [];
    List<ChatGroupItem> showResultList = [];
    JSON descList = {};
    JSON unOpenCount = {};

    // current show room type
    var roomType = currentTab == ChatType.private ? ChatRoomType.private :
      (currentTab == ChatType.public && isMy) ? ChatRoomType.publicMy : ChatRoomType.public;

    if (cache.chatData.isNotEmpty) {
      for (var item in cache.chatData.entries) {
        final roomId = item.value.roomId;
        // get last message..
        if (item.value.action == 0) {
          var desc = descList[roomId];
          if (desc == null || desc.updateTime.isBefore(item.value.updateTime)) {
            descList[roomId] = item.value;
          }
          // get unread count..
          final isMyMsg = item.value.senderId == AppData.USER_ID;
          var isTimeCheck = false;
          MemberData? memberInfo = cache.getMemberFromRoom(roomId, AppData.USER_ID);
          if (memberInfo != null) {
            isTimeCheck = item.value.createTime.isAfter(memberInfo.createTime);
          }
          if (!isMyMsg && isTimeCheck && (item.value.openList == null || !item.value.openList!.contains(AppData.USER_ID))) {
            var open = unOpenCount[roomId];
            if (open == null) {
              unOpenCount[roomId] = 0;
            }
            unOpenCount[roomId]++;
            // unOpenCount[roomId]['updateTime'] = item.value.updateTime;
          }
          // LOG('--> unOpenCount [$roomId] : ${unOpenCount[roomId].toString()} / $isMyMsg, $isTimeCheck, ${item.value.openList}, ${AppData.USER_ID}');
        }
      }
    }
    // create show group..
    for (var item in cache.chatRoomData.entries) {
      // set reported room..
      cache.reportData['report'] ??= {};
      var reportData = cache.reportData['report'][item.key];
      if (item.value.type == currentTab &&
          !cache.blockData.containsKey(item.value.userId) &&
         ((item.value.type == ChatType.public && COMPARE_GROUP_COUNTRY(item.value.toJson()) && (
         ((isMy && item.value.memberList.contains(AppData.USER_ID)) ||
          (!isMy && !item.value.memberList.contains(AppData.USER_ID))))) ||
          ((item.value.type == ChatType.private && item.value.memberList.contains(AppData.USER_ID))))) {
        // set last message..
        if (descList[item.value.id] != null) {
          item.value.lastMessage = descList[item.value.id].desc ?? DateTime(0);
          item.value.updateTime  = descList[item.value.id].updateTime ?? DateTime(0);
        }
        // set unread count..
        var unOpen = 0;
        if (unOpenCount[item.key] != null) {
          unOpen = INT(unOpenCount[item.key]);
        }
        // add group item..
        var addGroup = ChatGroupItem(item.value, isBlocked: reportData != null, roomType: roomType,
          unOpenCount: unOpen, onSelected: (key) {
            // click enter open room..
            var isMember = item.value.memberList.contains(AppData.USER_ID);
            // if (roomType != ChatType.private || !isMember) {
            if (!isMember) {
              // check ban from room..
              if (item.value.checkBanUser(AppData.USER_ID)) {
                ShowToast('You can not enter now'.tr);
                return;
              }
              showAlertYesNoCheckDialog(Get.context!, item.value.title, 'Would you like to enter the chat room?'.tr,
                'Enter quietly'.tr, 'Cancel'.tr, 'OK'.tr).then((result) {
                if (result > 0) {
                  enterRoom(key, item.value, result == 1);
                }
              });
            } else {
              showTalkScreen(item.value);
            }
          }, onMenuSelected: (menu, key) {
            LOG('--> onMenuSelected [$key] : $menu');
            switch(menu) {
              case DropdownItemType.enter:
                if (item.value.checkBanUser(AppData.USER_ID)) {
                  ShowToast('You can not enter now'.tr);
                  return;
                }
                showAlertYesNoCheckDialog(Get.context!, item.value.title, 'Would you like to enter the chat room?'.tr,
                  'Enter quietly'.tr, 'Cancel'.tr, 'OK'.tr).then((result) {
                  if (result > 0) {
                    enterRoom(key, item.value, result == 1);
                  }
                });
                break;
              case DropdownItemType.exit:
                if (item.value.userId == AppData.USER_ID) {
                  ShowToast('You are currently an admin'.tr);
                  return;
                }
                showAlertYesNoCheckDialog(Get.context!, item.value.title, 'Would you like to leave the chat room?'.tr,
                  'Leave quietly'.tr, 'Cancel'.tr, 'OK'.tr).then((result) {
                  if (result > 0) {
                    chatRepo.exitChatRoom(key, result == 1).then((result2) {
                      LOG('--> result2 $result2');
                      if (result2 != null && JSON_EMPTY(result2['error'])) {
                        notifyListeners();
                      }
                    });
                 }
                });
                break;
              case DropdownItemType.report:
                userRepo.addReportItem(Get.context!, 'chatRoom', item.value.toJson(), (_) {
                    notifyListeners();
                });
                break;
              case DropdownItemType.unReport:
                if (reportData != null) {
                  userRepo.removeReportItem(Get.context!, reportData['id'], item.key, () {
                    LOG('--> unReport done : ${reportData.toString()}');
                    notifyListeners();
                  });
                }
                break;
              case DropdownItemType.alarmOn:
                cache.setChatRoomAlarmOff(item.value.id, false);
                notifyListeners();
                break;
              case DropdownItemType.alarmOff:
                cache.setChatRoomAlarmOff(item.value.id, true);
                notifyListeners();
                break;
              case DropdownItemType.bookmarkOn:
                cache.setRoomIndexTop(roomType, item.key);
                notifyListeners();
                break;
              case DropdownItemType.bookmarkOff:
                cache.removeRoomIndexTop(roomType, item.key);
                notifyListeners();
                break;
            }
          }
        );
        showList.add(addGroup);
        showListKey.add(item.key);
      }
    }
    // sort date..
    for (var a=0; a<showList.length-1; a++) {
      for (var b=a+1; b<showList.length; b++) {
        if (isMy) {
          final aDate = showList[a].groupItem!.updateTime;
          final bDate = showList[b].groupItem!.updateTime;
          if (aDate != bDate && aDate.isBefore(bDate)) {
            final tmp = showList[a];
            showList[a] = showList[b];
            showList[b] = tmp;
          }
        } else {
          final aCount = showList[a].groupItem!.memberList.length;
          final bCount = showList[b].groupItem!.memberList.length;
          if ((showList[a].isBlocked && !showList[b].isBlocked) || (!showList[b].isBlocked && aCount < bCount)) {
            final tmp = showList[a];
            showList[a] = showList[b];
            showList[b] = tmp;
          }
        }
      }
    }
    // sort index..
    for (ChatGroupItem item in showList) {
      var index = cache.getRoomIndexTop(item.roomType, item.groupItem!.id);
      if (index >= 0 && index < showResultList.length) {
        // LOG('--> showResultList : ${showResultList.toString()} / $index');
        showResultList.insert(index, item);
      } else {
        showResultList.add(item);
      }
    }
    // LOG('--> showList : ${showList.length} / ${showResultList.length}');
    return Column(
      children: [
        SubTitleBar(Get.context!, '${isMy ? 'MY CHAT'.tr : 'OTHER CHAT'.tr} ${showResultList.length}',
          height: 40,
          icon: isTabOpen[isMy ? 0 : 1] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          onActionSelect: (select) {
            isTabOpen[isMy ? 0 : 1] = !isTabOpen[isMy ? 0 : 1];
            notifyListeners();
          }
        ),
        SizedBox(height: 2),
        if (isTabOpen[isMy ? 0 : 1])...[
          SizedBox(height: 3),
          ...showResultList,
          SizedBox(height: 5),
        ],
      ],
    );
  }

  onSnapshotAction(snapshot) async {
    if (snapshot.hasError) {
      return Center(
        child: Text('Unable to get data'.tr));
    }
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        break;
      case ConnectionState.active:
        LOG('--> ConnectionState.active : ${snapshot.data.docs.length}');
        for (var item in snapshot.data.docs) {
          var data = FROM_SERVER_DATA(item.data() as JSON);
          final chatItem = ChatModel.fromJson(data);
          // LOG('--> chatItem [${chatItem.id}] : ${chatItem.action} / ${chatItem.toJson()}');
          if (chatItem.roomStatus > 0) {
            cache.setChatItem(chatItem);
            // LOG('--> chatItem [${chatItem.id}] : ${chatItem.roomId} / ${chatItem.toJson()}');
            if (chatItem.roomId.isNotEmpty && chatItem.action == 0 &&
                !cache.chatRoomData.containsKey(chatItem.roomId)) {
              await createNewRoom(chatItem.roomId);
            }
          }
        }
        return true;
      case ConnectionState.done:
    }
    return null;
  }

  onChattingNew(type) {
    Get.to(() => ChattingEditScreen(type))!.then((result) {
      if (result != null) {
        showTalkScreen(result);
        // Get.to(() => ChatTalkScreen(result));
      }
    });
  }

  showMainList(layout, snapshot) {
    return FutureBuilder(
      future: onSnapshotAction(snapshot),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
            child: ListView(
              shrinkWrap: true,
              children: [
                refreshShowList(true),
                if (currentTab == 0)...[
                  refreshShowList(false),
                ],
                SizedBox(height: UI_BOTTOM_HEIGHT + 20),
              ]
            )
          );
        } else {
          return Center(
            child: showLoadingFullPage(context),
          );
        }
      }
    );
  }
}