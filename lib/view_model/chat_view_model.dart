
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:helpers/helpers/widgets/align.dart';
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
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/chatting/chatting_group_item.dart';
import '../view/chatting/chatting_tab_screen.dart';
import '../view/chatting/chatting_talk_screen.dart';
import '../view/home/home_top_menu.dart';
import '../widget/user_item_widget.dart';
import 'app_view_model.dart';

enum ChatType {
  public,
  private,
  one,
}

enum ChatRoomType {
  publicMy,
  public,
  private,
  one,
}

class ChatViewModel extends ChangeNotifier {
  final chatRepo = ChatRepository();
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();
  BuildContext? buildContext;
  Stream? stream;
  int currentTab = 0;

  List<ChatGroupItem> mainShowList = [];
  List<ChatTabScreen> tabList = [];
  List<GlobalKey> tabKeyList = [];
  var isTabOpen = [true, false];

  init(context) {
    buildContext = context;
    initMessageTab();
    getChatStreamData();
  }

  initMessageTab() {
    tabKeyList = List.generate(3, (index) => GlobalKey());
    tabList = [
      ChatTabScreen(ChatType.public , 'Public chat'.tr , key: tabKeyList[0]),
      ChatTabScreen(ChatType.private, 'Private chat'.tr, key: tabKeyList[1]),
    ];
  }

  setMessageTab(selectTab) {
    currentTab = selectTab;
    notifyListeners();
  }

  getChatRoomData() async {
    final roomData = await chatRepo.getChatRoomData();
    cache.chatRoomData.addAll(roomData);
    return roomData;
  }

  getChatStreamData() {
    stream ??= chatRepo.getChatStreamData();
  }

  createNewRoom(roomId) async {
    final result = await chatRepo.getChatRoomInfo(roomId);
    if (result != null) {
      LOG('-----> new Room !! [$roomId] : ${result.toString()}');
      cache.setChatRoomItem(ChatRoomModel.fromJson(result));
    }
  }

  showTalkScreen(item) {
    Get.to(() => ChattingTalkScreen(item))!.then((_) {
      notifyListeners();
    });
  }

  refreshShowList(bool isMy) {
    LOG('--> refreshShowList : $isMy');
    List<ChatGroupItem> showList = [];
    List<String> showListKey = [];
    List<ChatGroupItem> showResultList = [];
    JSON descList = {};
    JSON unOpenCount = {};
    var roomType = currentTab == 1 ? ChatRoomType.private : (currentTab == 0 && isMy) ? ChatRoomType.publicMy : ChatRoomType.public;

    if (cache.chatData != null) {
      // get last message...
      for (var item in cache.chatData!.entries) {
        final targetId = item.value.roomId;
        // get last message..
        if (item.value.action < 1) {
          var desc = descList[targetId];
          if (desc == null || DateTime.parse(desc.updateTime).isBefore(DateTime.parse(item.value.updateTime))) {
            descList[targetId] = item.value;
            // LOG('--> descList item add [$targetId] : ${item.value}');
          }
        }
        final isMyMsg = item.value.senderId == AppData.USER_ID;
        if (!isMyMsg && item.value.action < 1 && (item.value.openList == null || !item.value.openList!.contains(AppData.USER_ID))) {
          var open = unOpenCount[targetId];
          LOG('--> unOpenCount add [$targetId] : ${item.value.openList} => ${open == null}');
          if (open == null) {
            unOpenCount[targetId] = {'id': targetId, 'count': 0};
          }
          unOpenCount[targetId]['count']++;
          unOpenCount[targetId]['updateTime'] = item.value.updateTime;
          LOG('--> unOpenCount [$targetId] : ${unOpenCount[targetId]}');
        }
      }
    }
    // create group..
    for (var item in cache.chatRoomData.entries) {
      if (item.value.type == currentTab && !cache.blockData.containsKey(item.value.userId) &&
         ((item.value.type == 0 && COMPARE_GROUP_COUNTRY(item.value.toJson()) && (
         ((isMy && item.value.memberList.contains(AppData.USER_ID)) ||
          (!isMy && !item.value.memberList.contains(AppData.USER_ID))))) ||
          (item.value.type == 1 && item.value.memberList.contains(AppData.USER_ID)))) {
        if (descList[item.value.id] != null) {
          item.value.lastMessage = descList[item.value.id].desc ?? '';
        }
        // LOG('--> cache.chatRoomData item : ${descList.length} / ${item.value.lastMessage}');
        LOG('--> ChatGroupItem [${item.key}] : ${unOpenCount[item.key]}');
        var unOpen = 0;
        if (unOpenCount[item.key] != null) {
          item.value.updateTime = unOpenCount[item.key]['updateTime'];
          unOpen = INT(unOpenCount[item.key]['count']);
        }
        var addGroup = ChatGroupItem(item.value, roomType: roomType,
          unOpenCount: unOpen, onSelected: (key) {
          if (!item.value.memberList.contains(AppData.USER_ID)) {
            showAlertYesNoCheckDialog(buildContext!, item.value.title, 'Would you like to enter the chat room?'.tr,
              'Enter quietly'.tr, 'Cancel'.tr, 'OK'.tr).then((result) {
              if (result > 0) {
                showTalkScreen(item.value);
              }
            });
          } else {
            showTalkScreen(item.value);
          }
        }, onMenuSelected: (menu, key) {
          LOG('--> onMenuSelected [$key] : $menu');
          switch(menu) {
            case DropdownItemType.enter:
              showAlertYesNoCheckDialog(buildContext!, item.value.title, 'Would you like to enter the chat room?'.tr,
                'Enter quietly'.tr, 'Cancel'.tr, 'OK'.tr).then((result) {
                if (result > 0) {
                  showTalkScreen(item.value);
                }
              });
              break;
            case DropdownItemType.exit:
              showAlertYesNoCheckDialog(buildContext!, item.value.title, 'Would you like to leave the chat room?'.tr,
                'Leave quietly'.tr, 'Cancel'.tr, 'OK'.tr).then((result) {
                if (result > 0) {
                  chatRepo.exitChatRoom(key, result == 1).then((result) {
                    if (result) {
                      notifyListeners();
                    }
                  });
               }
              });
              break;
            case DropdownItemType.alarmOn:
              break;
            case DropdownItemType.alarmOff:
              break;
            case DropdownItemType.indexTop:
              cache.setRoomIndexTop(roomType.index, item.value.id);
              notifyListeners();
              break;
          }
        });
        showList.add(addGroup);
        showListKey.add(item.key);
      }
    }
    // sort date..
    for (var a=0; a<showList.length-1; a++) {
      for (var b=a+1; b<showList.length; b++) {
        if (isMy) {
          final aDate = DateTime.parse(showList[a].groupItem!.updateTime);
          final bDate = DateTime.parse(showList[b].groupItem!.updateTime);
          if (aDate != bDate && aDate.isBefore(bDate)) {
            final tmp = showList[a];
            showList[a] = showList[b];
            showList[b] = tmp;
          }
        } else {
          final aCount = showList[a].groupItem!.memberList.length;
          final bCount = showList[b].groupItem!.memberList.length;
          if (aCount < bCount) {
            final tmp = showList[a];
            showList[a] = showList[b];
            showList[b] = tmp;
          }
        }
      }
    }
    // final roomIndexData = cache.getRoomIndexData(roomType.index);
    // LOG('--> roomIndexData : ${roomIndexData.toString()}');
    // for (var item in roomIndexData) {
    //   if (showListKey.contains(item)) {
    //     showResultList.add(item);
    //   }
    // }
    // for (var item in showList) {
    //   if (!showResultList.contains(item)) {
    //     showResultList.add(item);
    //   }
    // }
    // sort index..
    for (ChatGroupItem item in showList) {
      var index = cache.getRoomIndexTop(item.roomType.index, item.groupItem!.id);
      if (index >= 0 && index < showResultList.length) {
        // LOG('--> showResultList : ${showResultList.toString()} / $index');
        showResultList.insert(index, item);
      } else {
        showResultList.add(item);
      }
    }
    LOG('--> showList : ${showList.length} / ${showResultList.length}');
    return Column(
      children: [
        SubTitleBar(buildContext!, isMy ? 'MY CHAT'.tr : 'OTHER CHAT'.tr,
          height: 35,
          icon: isTabOpen[isMy ? 0 : 1] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, onActionSelect: (select) {
          isTabOpen[isMy ? 0 : 1] = !isTabOpen[isMy ? 0 : 1];
          notifyListeners();
        }),
        if (isTabOpen[isMy ? 0 : 1])...[
          SizedBox(height: 5),
          ...showResultList,
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
        for (var item in snapshot.data.docs) {
          var data = FROM_SERVER_DATA(item.data() as JSON);
          final chatItem = ChatModel.fromJson(data);
          cache.setChatItem(chatItem);
          LOG('--> chatItem [${chatItem.id}] : ${chatItem.roomId} / ${chatItem.toJson()}');
          if (chatItem.roomId.isNotEmpty && !cache.chatRoomData.containsKey(chatItem.roomId)) {
            await createNewRoom(chatItem.roomId);
          }
        }
        return true;
      case ConnectionState.done:
    }
    return null;
  }

  onChattingNew(type) {
    Get.to(() => ChattingEditScreen(type))!.then((result) {

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
                SizedBox(height: 10),
                refreshShowList(true),
                if (currentTab == 0)...[
                  SizedBox(height: 5),
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