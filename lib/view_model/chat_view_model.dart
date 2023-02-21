
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/models/message_model.dart';
import 'package:kspot_002/view/chatting/chatting_edit_screen.dart';
import 'package:kspot_002/view/message/message_group_item.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
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

  getChatStreamData() {
    stream ??= chatRepo.getChatStreamData();
  }

  refreshShowList() {
    LOG('--> refreshShowList');
    List<ChatGroupItem> showList = [];
    JSON descList = {};
    JSON unOpenCount = {};
    if (cache.chatData != null) {
      // get last message...
      for (var item in cache.chatData!.entries) {
        final targetId = item.value.roomId;
        var desc = descList[targetId];
        if (desc == null || DateTime.parse(desc.updateTime).isBefore(DateTime.parse(item.value.updateTime))) {
          descList[targetId] = item.value;
          // LOG('--> descList item add [$targetId] : ${item.value}');
        }
        if (STR(item.value.openTime).isEmpty) {
          var open = unOpenCount[targetId];
          LOG('--> unOpenCount add [$targetId] : ${item.value.openTime} => ${open == null}');
          if (open == null) {
            unOpenCount[targetId] = 0;
          }
          unOpenCount[targetId]++;
          LOG('--> unOpenCount [$targetId] : ${unOpenCount[targetId]}');
        }
      }
    }
    // create group..
    for (var item in cache.chatRoomData.entries) {
      if (item.value.type == currentTab) {
        if (descList[item.value.id] != null) {
          item.value.lastMessage = descList[item.value.id].desc ?? '';
        }
        // LOG('--> cache.chatRoomData item : ${descList.length} / ${item.value.lastMessage}');
        LOG('--> ChatGroupItem [${item.key}] : ${unOpenCount[item.key]}');
        var addGroup = ChatGroupItem(item.value, unOpenCount: unOpenCount[item.key] ?? 0, onSelected: (key) {
          Get.to(() => ChattingTalkScreen(item.value))!.then((_) {
            notifyListeners();
          });
        });
        showList.add(addGroup);
      }
    }
    // sort date..
    LOG('--> showList : ${showList.length}');
    return sortDataCreateTimeDesc(showList);
  }

  sortDataCreateTimeDesc(showList) {
    for (var a=0; a<showList.length-1; a++) {
      for (var b=a+1; b<showList.length; b++) {
        final aDate = DateTime.parse(showList[a].groupItem.updateTime);
        final bDate = DateTime.parse(showList[b].groupItem.updateTime);
        // LOG("----> check : ${aDate.toString()} > ${bDate.toString()}");
        if (aDate != bDate && aDate.isBefore(bDate)) {
          final tmp = showList[a];
          showList[a] = showList[b];
          showList[b] = tmp;
        }
      }
    }
    return showList;
  }

  onSnapshotAction(snapshot) async {
    LOG('--> onSnapshotAction : ${snapshot.hasError} / ${snapshot.connectionState}');
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
          if (!cache.chatRoomData.containsKey(chatItem.roomId)) {
            final roomItem = await chatRepo.getChatRoomInfo();
            if (roomItem != null) {
              cache.setChatRoomItem(ChatRoomModel.fromJson(roomItem));
              LOG('--> cache.setChatRoomItem add : ${roomItem.id} / ${cache.chatRoomData.length}');
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

    });
  }

  showMainList(layout, snapshot) {
    onSnapshotAction(snapshot);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: 10),
          ...refreshShowList(),
          SizedBox(height: UI_BOTTOM_HEIGHT + 20),
        ]
      )
    );
  }
}