
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/message_model.dart';
import 'package:kspot_002/view/message/message_talk_screen.dart';
import 'package:kspot_002/view/message/message_group_item.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../models/event_model.dart';
import '../repository/message_repository.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import '../view/home/home_top_menu.dart';
import '../widget/user_item_widget.dart';
import '../widget/helpers/helpers/widgets/align.dart';

class MessageViewModel extends ChangeNotifier {
  final repo  = MessageRepository();
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();
  Stream? stream;

  List<MessageGroupItem> mainShowList = [];

  getMessageData() {
    stream = repo.startMessageStreamToMe();
  }

  Future<List<MessageGroupItem>> refreshShowList() async {
    List<MessageGroupItem> showList = [];
    JSON descList = {};
    JSON unOpenCount = {};
    JSON messageListItemData = {};
    // if (cache.messageData == null) return showList;
    // get last message...
    for (var item in cache.messageData!.entries) {
      var targetId = item.value.senderId;
      if (CheckOwner(item.value.senderId)) {
        targetId = item.value.targetId;
      } else {
        if (LIST_EMPTY(item.value.openTimeData) || item.value.openTimeData!.contains(AppData.USER_ID)) {
          unOpenCount[targetId]++;
        }
      }
      var desc = descList[targetId];
      if (desc == null || desc.updateTime.isBefore(item.value.updateTime)) {
        descList[targetId] = item.value;
      }
      var open = unOpenCount[targetId];
      if (open == null) {
        unOpenCount[targetId] = 0;
      }
    }
    // create group..
    for (var item in cache.messageData!.entries) {
      var targetId   = item.value.senderId;
      var targetName = item.value.senderName;
      var targetPic  = item.value.senderPic;
      if (CheckOwner(item.value.senderId)) {
        targetId   = item.value.targetId;
        targetName = item.value.targetName;
        targetPic  = item.value.targetPic;
      }
      var addGroup = messageListItemData[targetId];
      if (addGroup == null) {
        // set last message..
        item.value.desc       = descList[targetId].desc;
        item.value.updateTime = descList[targetId].updateTime;
        addGroup = MessageGroupItem(targetId, targetName, targetPic, item.value, unOpenCount: unOpenCount[targetId], onSelected: (key) {
          Get.to(() => MessageTalkScreen(targetId, targetName, targetPic));
        });
        messageListItemData[targetId] = addGroup;
        showList.add(addGroup);
      }
    }
    // sort date..
    return sortDataCreateTimeDesc(showList);
  }

  sortDataCreateTimeDesc(showList) {
    for (var a=0; a<showList.length-1; a++) {
      for (var b=a+1; b<showList.length; b++) {
        final aDate = showList[a].messageItem.updateTime;
        final bDate = showList[b].messageItem.updateTime;
        // LOG("----> check : ${aDate.toString()} > ${bDate.toString()}");
        if (aDate != bDate && aDate.isBefore(bDate)) {
          LOG("--> changed : ${aDate.toString()} / ${showList[a].messageItem.desc} <-> ${bDate.toString()} / ${showList[b].messageItem.desc}");
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
          cache.setMessageItem(MessageModel.fromJson(data));
          LOG('--> cache.messageData : ${data['id']} / ${cache.messageData!.length}');
        }
        return true;
      case ConnectionState.done:
    }
    return null;
  }

  showMainList(layout, snapshot) {
    onSnapshotAction(snapshot);
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