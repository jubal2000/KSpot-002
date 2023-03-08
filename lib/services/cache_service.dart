import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_model.dart';
import '../models/event_model.dart';
import '../models/message_model.dart';
import '../models/story_model.dart';
import '../utils/utils.dart';
import '../view/message/message_group_item.dart';
import 'local_service.dart';

class CacheService extends GetxService {
  Map<String, EventModel>? eventData;
  Map<String, Widget> eventListItemData = {};
  Map<String, Widget> eventMapItemData = {};

  Map<String, StoryModel>? storyData;
  Map<String, Widget> storyListItemData = {};

  Map<String, MessageModel>? messageData;
  Map<String, MessageGroupModel>? messageGroupData;

  Map<String, ChatModel> chatData = {};
  Map<String, ChatRoomModel> chatRoomData = {};

  JSON reportData = {};
  JSON blockData = {};
  JSON chatItemData = {};

  List<String> roomAlarmData = [];
  List<String> publicMyRoomIndexData = [];
  List<String> publicIndexData = [];
  List<String> privateIndexData = [];
  Map<String, JSON> chatRoomFlagData = {};

  Future<CacheService> init() async {
    eventListItemData = {};
    eventMapItemData  = {};
    storyListItemData = {};
    chatRoomData      = {};
    await loadChatRoomFlag(); // from local..
    return this;
  }

  setEventItem(EventModel addItem) {
    eventData ??= {};
    eventData![addItem.id] = addItem;
    eventListItemData.remove(addItem.id);
    eventMapItemData.remove(addItem.id);
    LOG('--> setEventItem [${addItem.id}] : ${eventData![addItem.id]!.title} / ${eventData!.length}');
  }

  setStoryItem(StoryModel addItem) {
    storyData ??= {};
    storyData![addItem.id] = addItem;
    storyListItemData.remove(addItem.id);
    LOG('--> setStoryItem [${addItem.id}] : ${storyData![addItem.id]!.desc} / ${storyData!.length}');
  }

  setMessageItem(MessageModel addItem) {
    messageData ??= {};
    messageData![addItem.id] = addItem;
    storyListItemData.remove(addItem.id);
    // LOG('--> setMessageItem [${addItem.id}] : ${messageData![addItem.id]!.desc} / ${messageData!.length}');
  }

  setChatItem(ChatModel addItem) {
    chatData[addItem.id] = addItem;
    // LOG('--> setChatItem [${addItem.id}] : ${chatData![addItem.id]!.desc} / ${chatData!.length}');
  }

  setChatItemData(JSON addData) {
    var count = 0;
    for (var item in addData.entries) {
      var chatItem = ChatModel.fromJson(item.value);
      var chatItemOrg = chatData[item.key];
      var openCount = chatItem.openList != null ? chatItem.openList!.length : 0;
      var openOrgCount = chatItemOrg != null && chatItemOrg.openList != null ? chatItemOrg.openList!.length : 0;
      if (openCount != openOrgCount || chatItem.action == 9) count++; // is chat item edited..
      setChatItem(chatItem);
    }
    // LOG('--> setChatItem : ${addData.length} / ${chatData!.length}');
    return count;
  }

  setChatItemList(List<JSON> addData) {
    for (var item in addData) {
      setChatItem(ChatModel.fromJson(item));
    }
    // LOG('--> setChatItem : ${addData.length} / ${chatData!.length}');
  }

  setChatRoomItem(ChatRoomModel addItem, [bool isClearItem = false]) {
    chatRoomData[addItem.id] = addItem;
    if (isClearItem) {
      chatItemData.clear();
    }
    LOG('--> setChatRoomItem [${addItem.id}] :  ${chatRoomData.length}');
  }

  setChatRoomFlag(String roomId, {var isNoticeShow = true}) {
    var addItem = {'id': roomId, 'noticeShow': isNoticeShow};
    chatRoomFlagData[roomId] = addItem;
    var localData = List<String>.from(chatRoomFlagData.entries.map((e) => jsonEncode(e.value))).toList();
    StorageManager.saveData('chatRoomFlag', localData);
   }

  loadChatRoomFlag() async {
    chatRoomFlagData.clear();
    var localData = await StorageManager.readData('chatRoomFlag');
    if (localData != null) {
      for (var item in localData) {
        JSON addItem = jsonDecode(item);
        chatRoomFlagData[addItem['id']] = addItem;
      }
    }
    LOG('--> loadChatRoomFlag : ${chatRoomFlagData.toString()}');
  }

  readRoomIndexData() async {
    publicMyRoomIndexData = List<String>.from(await StorageManager.readData('publicMyRoomIndexData') ?? []);
    publicIndexData       = List<String>.from(await StorageManager.readData('publicIndexData') ?? []);
    privateIndexData      = List<String>.from(await StorageManager.readData('privateIndexData') ?? []);
    LOG('--> publicMyRoomIndexData: ${publicMyRoomIndexData.toString()}');
    LOG('--> publicIndexData: ${publicIndexData.toString()}');
    LOG('--> privateIndexData: ${privateIndexData.toString()}');
    return true;
  }

  setRoomIndexTop(int type, String roomId) {
    switch (type) {
      case 0:
        if (publicMyRoomIndexData.contains(roomId)) {
          publicMyRoomIndexData.remove(roomId);
        }
        publicMyRoomIndexData.insert(0, roomId);
        // publicMyRoomIndexData.refresh();
        StorageManager.saveData('publicMyRoomIndexData', publicMyRoomIndexData);
        break;
      case 1:
        if (publicIndexData.contains(roomId)) {
          publicIndexData.remove(roomId);
        }
        publicIndexData.insert(0, roomId);
        // publicIndexData.refresh();
        StorageManager.saveData('publicIndexData', publicIndexData);
        break;
      case 2:
        if (privateIndexData.contains(roomId)) {
          privateIndexData.remove(roomId);
        }
        privateIndexData.insert(0, roomId);
        // privateIndexData.refresh();
        StorageManager.saveData('privateIndexData', privateIndexData);
        break;
    }
  }

  removeRoomIndexTop(int type, String roomId) {
    switch (type) {
      case 0:
        if (publicMyRoomIndexData.contains(roomId)) {
          publicMyRoomIndexData.remove(roomId);
        }
        StorageManager.saveData('publicMyRoomIndexData', publicMyRoomIndexData);
        break;
      case 1:
        if (publicIndexData.contains(roomId)) {
          publicIndexData.remove(roomId);
        }
        StorageManager.saveData('publicIndexData', publicIndexData);
        break;
      case 2:
        if (privateIndexData.contains(roomId)) {
          privateIndexData.remove(roomId);
        }
        StorageManager.saveData('privateIndexData', privateIndexData);
        break;
    }
  }

  getMemberFromRoom(String roomId, String userId) {
    if (!chatRoomData.containsKey(roomId)) return null;
    for (var item in chatRoomData[roomId]!.memberData) {
      if (item.id == userId) {
        return item;
      }
    }
    return null;
  }

  getRoomIndexTop(int type, String roomId) {
    return getRoomIndexData(type).indexOf(roomId);
  }

  getRoomIndexData(int type) {
    switch (type) {
      case 0:
        return publicMyRoomIndexData;
      case 1:
        return publicIndexData;
      default:
        return privateIndexData;
    }
  }

  List<String> getBlockDataList() {
    if (blockData.entries.isEmpty) return [];
    return List<String>.from(blockData.entries.map((item) => item.value).toList());
  }

  Future sortStoryDataCreateTimeDesc() async {
    if (JSON_NOT_EMPTY(storyData) && storyData!.length > 1) {
      storyData = SplayTreeMap<String,StoryModel>.from(storyData!, (a, b) {
        final aDate = DateTime.parse(storyData![a]!.createTime);
        final bDate = DateTime.parse(storyData![b]!.createTime);
        return aDate != bDate && aDate.isBefore(bDate) ? -1 : 1;
      });
    }
    return true;
  }

  Future sortMessageDataCreateTimeDesc() async {
    if (JSON_NOT_EMPTY(messageData) && messageData!.length > 1) {
      messageData = SplayTreeMap<String,MessageModel>.from(messageData!, (a, b) {
        final aDate = DateTime.parse(messageData![a]!.createTime);
        final bDate = DateTime.parse(messageData![b]!.createTime);
        return aDate != bDate && aDate.isBefore(bDate) ? -1 : 1;
      });
    }
    return true;
  }
}