import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/event_model.dart';
import '../models/story_model.dart';
import '../utils/utils.dart';

class CacheService extends GetxService {
  Map<String, EventModel>? eventData;
  Map<String, Widget> eventListItemData = {};
  Map<String, Widget> eventMapItemData = {};

  Map<String, StoryModel>? storyData;
  Map<String, Widget> storyListItemData = {};

  Future<CacheService> init() async {
    eventListItemData = {};
    eventMapItemData  = {};
    storyListItemData = {};
    return this;
  }

  setEventItem(EventModel eventItem) {
    eventData ??= {};
    eventData![eventItem.id] = eventItem;
    eventListItemData.remove(eventItem.id);
    eventMapItemData.remove(eventItem.id);
    LOG('--> setEventItem [${eventItem.id}] : ${eventData![eventItem.id]!.title} / ${eventData!.length}');
  }

  setStoryItem(StoryModel storyItem) {
    storyData ??= {};
    storyData![storyItem.id] = storyItem;
    storyListItemData.remove(storyItem.id);
    LOG('--> setStoryItem [${storyItem.id}] : ${storyData![storyItem.id]!.desc} / ${storyData!.length}');
    sortStoryDataCreateTimeDesc();
  }

  sortStoryDataCreateTimeDesc() {
    if (JSON_NOT_EMPTY(storyData) && storyData!.length > 1) {
      storyData = SplayTreeMap<String,StoryModel>.from(storyData!, (a, b) {
        LOG("--> check : ${storyData![a]!.createTime} > ${storyData![b]!.createTime}");
        return DateTime.parse(storyData![a]!.createTime).isBefore(DateTime.parse(storyData![b]!.createTime)) ? -1 : 1;
      });
    }
  }
}