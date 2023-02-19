import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_model.dart';
import '../models/event_model.dart';
import '../models/message_model.dart';
import '../models/story_model.dart';
import '../utils/utils.dart';
import '../view/message/message_group_item.dart';

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
    LOG('--> setMessageItem [${addItem.id}] : ${messageData![addItem.id]!.desc} / ${messageData!.length}');
  }

  setChatItem(ChatModel addItem) {
    chatData ??= {};
    chatData![addItem.id] = addItem;
    LOG('--> setChatItem [${addItem.id}] : ${chatData![addItem.id]!.desc} / ${chatData!.length}');
  }

  setChatRoomItem(ChatRoomModel addItem) {
    chatRoomData ??= {};
    chatRoomData![addItem.id] = addItem;
    LOG('--> setChatRoomItem [${addItem.id}] : ${chatRoomData![addItem.id]!.title} / ${chatRoomData!.length}');
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