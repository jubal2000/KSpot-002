import 'dart:collection';

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

  Map<String, ChatModel>? chatData;
  Map<String, ChatRoomModel> chatRoomData = {};

  JSON reportData = {};
  JSON blockData = {};

  List<String> roomAlarmData = [];
  var publicMyRoomIndexData = [].obs;
  var publicIndexData = [].obs;
  var privateIndexData = [].obs;

  Future<CacheService> init() async {
    eventListItemData = {};
    eventMapItemData  = {};
    storyListItemData = {};
    chatRoomData      = {};
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
    chatData ??= {};
    chatData![addItem.id] = addItem;
    // LOG('--> setChatItem [${addItem.id}] : ${chatData![addItem.id]!.desc} / ${chatData!.length}');
  }

  setChatItemData(JSON addData) {
    chatData ??= {};
    for (var item in addData.entries) {
      setChatItem(ChatModel.fromJson(item.value));
    }
    // LOG('--> setChatItem : ${addData.length} / ${chatData!.length}');
  }

  setChatItemList(List<JSON> addData) {
    chatData ??= {};
    for (var item in addData) {
      setChatItem(ChatModel.fromJson(item));
    }
    // LOG('--> setChatItem : ${addData.length} / ${chatData!.length}');
  }

  setChatRoomItem(ChatRoomModel addItem) {
    chatRoomData[addItem.id] = addItem;
    LOG('--> setChatRoomItem [${addItem.id}] : ${chatRoomData[addItem.id]!.title} / ${chatRoomData[addItem.id]!.status} / ${chatRoomData.length}');
  }

  readRoomIndexData() async {
    publicMyRoomIndexData.value = await StorageManager.readData('publicMyRoomIndexData') ?? [];
    publicIndexData.value       = await StorageManager.readData('publicIndexData') ?? [];
    privateIndexData.value      = await StorageManager.readData('privateIndexData') ?? [];
    LOG('--> publicMyRoomIndexData: ${publicMyRoomIndexData.toString()}');
    LOG('--> publicIndexData: ${publicIndexData.toString()}');
    LOG('--> privateIndexData: ${privateIndexData.toString()}');
  }

  setRoomIndexTop(int type, String roomId) {
    switch (type) {
      case 0:
        if (publicMyRoomIndexData.contains(roomId)) {
          publicMyRoomIndexData.remove(roomId);
        }
        publicMyRoomIndexData.insert(0, roomId);
        publicMyRoomIndexData.refresh();
        StorageManager.saveData('publicMyRoomIndexData', List<String>.from(publicMyRoomIndexData.toList()));
        break;
      case 1:
        if (publicIndexData.contains(roomId)) {
          publicIndexData.remove(roomId);
        }
        publicIndexData.insert(0, roomId);
        publicIndexData.refresh();
        StorageManager.saveData('publicIndexData', List<String>.from(publicIndexData.toList()));
        break;
      case 2:
        if (privateIndexData.contains(roomId)) {
          privateIndexData.remove(roomId);
        }
        privateIndexData.insert(0, roomId);
        privateIndexData.refresh();
        StorageManager.saveData('privateIndexData', List<String>.from(privateIndexData.toList()));
        break;
    }
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