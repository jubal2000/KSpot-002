
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/models/message_model.dart';
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
import 'app_view_model.dart';

class MessageViewModel extends ChangeNotifier {
  final repo  = MessageRepository();
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();
  BuildContext? buildContext;
  Stream? stream;

  List<Widget> mainShowList = [];

  init(BuildContext context) {
    buildContext = context;
  }

  getMessageData() {
    return repo.getMessageData();
  }

  setMessageData(JSON eventData) {
    for (var item in eventData.entries) {
      cache.setMessageItem(MessageModel.fromJson(item.value));
    }
    LOG('--> setMessageData result : ${cache.messageData!.length}');
    refreshShowList();
  }

  startMessageStreamToMe() {
    stream = repo.startMessageStreamToMe();
  }

  Future refreshShowList() async {
    List<Widget> showList = [];
    if (cache.messageData == null) return showList;
    for (var item in cache.messageData!.entries) {
      var targetId   = item.value.senderId;
      var targetName = item.value.senderName;
      var targetPic  = item.value.senderPic;
      if (CheckOwner(item.value.senderId)) {
        targetId   = item.value.targetId;
        targetName = item.value.targetName;
        targetPic  = item.value.targetPic;
      }
      var addGroup = cache.messageListItemData[targetId];
      if (addGroup == null) {
        addGroup = MessageGroupItem(targetId, targetName, targetPic, item.value);
        cache.messageListItemData[targetId] = addGroup;
      }
      showList.add(addGroup);
    }
    LOG('------> refreshShowList : ${showList.length}');
    return sortDataCreateTimeDesc(showList);
  }

  sortDataCreateTimeDesc(showList) {
    for (var a=0; a<showList.length-1; a++) {
      for (var b=a+1; b<showList.length; b++) {
        final aDate = DateTime.parse(showList[a].messageItem.createTime);
        final bDate = DateTime.parse(showList[b].messageItem.createTime);
        // LOG("----> check : ${aDate.toString()} > ${bDate.toString()}");
        if (aDate != bDate && aDate.isBefore(bDate)) {
          LOG("--> changed : ${aDate.toString()} <-> ${bDate.toString()}");
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
    return Stack(
      children: [
        if (mainShowList.isNotEmpty)...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: UI_APPBAR_TOOL_HEIGHT),
                ...mainShowList,
                SizedBox(height: UI_BOTTOM_HEIGHT + 20),
              ]
            )
          )
        ],
        if (mainShowList.isEmpty)...[
          FutureBuilder(
            future: refreshShowList(),
            builder: (context, snapshot) {
              LOG('--> snapshot.hasData : ${snapshot.hasData}');
              if (snapshot.hasData) {
                mainShowList = snapshot.data;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                    child: ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(height: UI_APPBAR_TOOL_HEIGHT),
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
          ),
        ],
        TopCenterAlign(
          child: SizedBox(
            height: UI_TOP_MENU_HEIGHT * 1.7,
            child: HomeTopMenuBar(
              MainMenuID.message,
              isShowDatePick: false,
              onCountryChanged: () {
                notifyListeners();
              },
            ),
          )
        ),
      ]
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}