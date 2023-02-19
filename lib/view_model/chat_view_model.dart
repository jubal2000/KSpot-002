
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
  final repo  = MessageRepository();
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

  getChatRoomData() {
    stream = repo.getChatRoomStreamData();
  }

  getMessageData() {
    stream = repo.startChatStreamToMe();
  }

  Future<List<ChatGroupItem>> refreshShowList() async {
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
        }
        var open = unOpenCount[targetId];
        if (open == null) {
          unOpenCount[targetId] = 0;
        }
      }
    }
    // create group..
    for (var item in cache.chatRoomData.entries) {
      if (item.value.type == currentTab) {
        LOG('--> cache.chatRoomData item : ${item.value.memberData}');
        var addGroup = ChatGroupItem(item.value, unOpenCount: unOpenCount[item.key] ?? 0, onSelected: (key) {
          // Get.to(() => ChattingTalkScreen(targetId, targetName, targetPic));
        });
        showList.add(addGroup);
      }
    }
    // sort date..
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
    LOG('--> showItemList : ${snapshot.hasError} / ${snapshot.connectionState}');
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
          cache.setChatRoomItem(ChatRoomModel.fromJson(data));
          LOG('--> cache.setChatRoomItem : ${data['id']} / ${cache.chatRoomData.length}');
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
    if (currentTab == 0) {
      return FutureBuilder(
        future: refreshShowList(),
        builder: (context, snapshot) {
          LOG('--> snapshot.hasData : ${snapshot.hasData}');
          if (snapshot.hasData) {
            mainShowList = snapshot.data!;
            return Container(
                padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                child: ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(height: 10),
                      ...mainShowList,
                      SizedBox(height: UI_BOTTOM_HEIGHT + 20),
                    ]
                )
            );
          } else {
            return Center(
              child: Text('No message'.tr),
            );
          }
        }
      );
    } else {
      return FutureBuilder(
        future: refreshShowList(),
        builder: (context, snapshot) {
          LOG('--> snapshot.hasData : ${snapshot.hasData}');
          if (snapshot.hasData) {
            mainShowList = snapshot.data!;
            return Container(
                padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                child: ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(height: 10),
                      ...mainShowList,
                      SizedBox(height: UI_BOTTOM_HEIGHT + 20),
                    ]
                )
            );
          } else {
            return Center(
              child: Text('No message'.tr),
            );
          }
        }
      );
    }
  }
}