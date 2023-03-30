import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_model.dart';
import '../models/event_group_model.dart';
import '../models/event_model.dart';
import '../models/message_model.dart';
import '../models/place_model.dart';
import '../models/sponsor_model.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';
import '../view/message/message_group_item.dart';
import 'local_service.dart';

class CacheService extends GetxService {
  Map<String, UserModel> userData = {};
  Map<String, Widget> userListItemData = {};

  Map<String, PlaceModel> placeData = {};
  Map<String, Widget> placeListItemData = {};

  Map<String, EventModel> eventData = {};
  Map<String, Widget> eventListItemData = {};
  Map<String, Widget> eventMapItemData = {};

  Map<String, EventGroupModel> eventGroupData = {};

  Map<String, StoryModel> storyData = {};
  Map<String, Widget> storyListItemData = {};

  Map<String, MessageModel> messageData = {};
  Map<String, MessageGroupModel> messageGroupData = {};

  Map<String, ChatModel> chatData = {};
  Map<String, ChatRoomModel> chatRoomData = {};

  Map<String, SponsorModel> sponsorData = {};
  Map<String, Widget> sponsorListItemData = {};

  JSON bookmarkData = {};
  JSON reportData = {};
  JSON blockData = {};
  JSON chatItemData = {};

  List<String> roomAlarmData = [];
  List<String> publicMyRoomIndexData = [];
  List<String> publicIndexData = [];
  List<String> privateIndexData = [];
  Map<String, JSON> chatRoomFlagData = {};

  Future<CacheService> init() async {
    userData = {};
    userListItemData = {};
    placeData = {};
    placeListItemData = {};
    eventData = {};
    eventListItemData = {};
    eventMapItemData = {};
    eventGroupData = {};
    storyData = {};
    storyListItemData = {};
    messageData = {};
    messageGroupData = {};
    chatData = {};
    chatRoomData = {};
    sponsorData = {};
    sponsorListItemData = {};
    reportData = {};
    blockData = {};
    chatItemData = {};

    await loadChatRoomFlag(); // from local..
    return this;
  }

  setUserItem(UserModel addItem, [var isRemoveItem = true]) {
    addItem.cacheTime = DateTime.now();
    userData[addItem.id] = addItem;
    if (isRemoveItem) {
      userListItemData.remove(addItem.id);
    }
    // LOG('--> setUserItem [${addItem.id}] : ${eventData![addItem.id]!.title} / ${eventData!.length}');
  }

  setUserData(JSON addData) {
    for (var item in addData.entries) {
      setUserItem(item.value);
    }
  }

  setPlaceItem(PlaceModel addItem, [var isRemoveItem = true]) {
    addItem.cacheTime = DateTime.now();
    placeData[addItem.id] = addItem;
    if (isRemoveItem) {
      placeListItemData.remove(addItem.id);
    }
    // LOG('--> setPlaceItem [${addItem.id}] : ${eventData![addItem.id]!.title} / ${eventData!.length}');
  }

  setPlaceData(JSON addData) {
    for (var item in addData.entries) {
      setPlaceItem(item.value);
    }
  }

  setEventItem(EventModel addItem, [var isRemoveItem = true]) {
    addItem.cacheTime = DateTime.now();
    eventData[addItem.id] = addItem;
    if (isRemoveItem) {
      eventListItemData.remove(addItem.id);
      eventMapItemData.remove(addItem.id);
    }
    // LOG('--> setEventItem [${addItem.id}] : ${eventData![addItem.id]!.title} / ${eventData!.length}');
  }

  setEventData(JSON addData) {
    for (var item in addData.entries) {
      setEventItem(item.value);
    }
  }

  setEventGroupItem(EventGroupModel addItem, [var isRemoveItem = true]) {
    addItem.cacheTime = DateTime.now();
    eventGroupData[addItem.id] = addItem;
    // LOG('--> setEventItem [${addItem.id}] : ${eventData![addItem.id]!.title} / ${eventData!.length}');
  }

  setEventGroupData(JSON addData) {
    for (var item in addData.entries) {
      setEventGroupItem(item.value);
    }
  }

  setStoryItem(StoryModel addItem, [var isRemoveItem = true]) {
    addItem.cacheTime = DateTime.now();
    storyData[addItem.id] = addItem;
    if (isRemoveItem) {
      storyListItemData.remove(addItem.id);
    }
    // LOG('--> setStoryItem [${addItem.id}] : ${storyData![addItem.id]!.desc} / ${storyData!.length}');
  }

  setStoryData(JSON addData) {
    for (var item in addData.entries) {
      setStoryItem(item.value);
    }
  }

  setMessageItem(MessageModel addItem) {
    addItem.cacheTime = DateTime.now();
    messageData[addItem.id] = addItem;
    // LOG('--> setMessageItem [${addItem.id}] : ${messageData![addItem.id]!.desc} / ${messageData!.length}');
  }

  setMessageData(JSON addData) {
    for (var item in addData.entries) {
      setMessageItem(item.value);
    }
  }
  setMessageGroupItem(MessageGroupModel addItem) {
    addItem.cacheTime = DateTime.now();
    messageGroupData[addItem.id] = addItem;
    // LOG('--> setMessageGroupItem [${addItem.id}] : ${messageGroupData![addItem.id]!.desc} / ${messageGroupData!.length}');
  }

  setMessageGroupData(JSON addData) {
    for (var item in addData.entries) {
      setMessageGroupItem(item.value);
    }
  }

  setChatItem(ChatModel addItem) {
    addItem.cacheTime = DateTime.now();
    chatData[addItem.id] = addItem;
    // LOG('--> setMessageGroupItem [${addItem.id}] : ${messageGroupData![addItem.id]!.desc} / ${messageGroupData!.length}');
  }

  setChatData(JSON addData) {
    for (var item in addData.entries) {
      setChatItem(item.value);
    }
  }

  setChatRoomItem(ChatRoomModel addItem, [bool isClearItem = false]) {
    chatRoomData[addItem.id] = addItem;
    if (isClearItem) {
      chatItemData.clear();
    }
    LOG('--> setChatRoomItem [${addItem.id}] :  ${chatRoomData.length}');
  }

  setSponsorItem(SponsorModel addItem, [var isRemoveItem = true]) {
    addItem.cacheTime = DateTime.now();
    sponsorData[addItem.id] = addItem;
    if (isRemoveItem) {
      sponsorListItemData.remove(addItem.id);
    }
    // LOG('--> setSponsorItem [${addItem.id}] : ${messageData![addItem.id]!.desc} / ${messageData!.length}');
  }

  setSponsorData(JSON addData) {
    for (var item in addData.entries) {
      setSponsorItem(item.value);
    }
  }

  getUserItem(String key) {
    var cacheItem = userData[key];
    if (cacheItem != null && cacheItem.cacheTime != null) {
      if (cacheItem.cacheTime!.isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
        return null;
      }
    }
    return cacheItem;
  }

  getPlaceItem(String key) {
    var cacheItem = placeData[key];
    if (cacheItem != null && cacheItem.cacheTime != null) {
      if (cacheItem.cacheTime!.isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
        return null;
      }
    }
    return cacheItem;
  }

  getEventItem(String key) {
    var cacheItem = eventData[key];
    if (cacheItem != null && cacheItem.cacheTime != null) {
      if (cacheItem.cacheTime!.isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
        return null;
      }
    }
    return cacheItem;
  }

  getEventGroupItem(String key) {
    var cacheItem = eventGroupData[key];
    if (cacheItem != null && cacheItem.cacheTime != null) {
      if (cacheItem.cacheTime!.isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
        return null;
      }
    }
    return cacheItem;
  }

  getStoryItem(String key) {
    var cacheItem = storyData[key];
    if (cacheItem != null && cacheItem.cacheTime != null) {
      if (cacheItem.cacheTime!.isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
        return null;
      }
    }
    return cacheItem;
  }

  getMessageItem(String key) {
    var cacheItem = messageData[key];
    if (cacheItem != null && cacheItem.cacheTime != null) {
      if (cacheItem.cacheTime!.isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
        return null;
      }
    }
    return cacheItem;
  }

  getSponsorItem(String key) {
    var cacheItem = sponsorData[key];
    if (cacheItem != null && cacheItem.cacheTime != null) {
      if (cacheItem.cacheTime!.isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
        return null;
      }
    }
    return cacheItem;
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
    if (storyData.length > 1) {
      storyData = SplayTreeMap<String,StoryModel>.from(storyData, (a, b) {
        final aDate = storyData[a]!.createTime;
        final bDate = storyData[b]!.createTime;
        return aDate != bDate && aDate.isBefore(bDate) ? -1 : 1;
      });
    }
    return true;
  }

  Future sortMessageDataCreateTimeDesc() async {
    if (messageData.length > 1) {
      messageData = SplayTreeMap<String,MessageModel>.from(messageData, (a, b) {
        final aDate = messageData[a]!.createTime;
        final bDate = messageData[b]!.createTime;
        return aDate != bDate && aDate.isBefore(bDate) ? -1 : 1;
      });
    }
    return true;
  }
}