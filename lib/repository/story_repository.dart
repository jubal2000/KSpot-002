import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/story_model.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class StoryRepository {
  final api = Get.find<ApiService>();

  /////////////////////////////////////////////////////////////////////////////////////////////

  getStoryStreamFromGroup(String groupId) {
    return api.getStoryStreamFromGroup(groupId, AppData.currentCountry, AppData.currentState);
  }

  getStoryStreamFromGroupNext(DateTime lastTime, String groupId) {
    return api.getStoryStreamFromGroupNext(lastTime, groupId, AppData.currentCountry, AppData.currentState);
  }

  Future<StoryModel?> addStoryItem(StoryModel addItem) async {
    final result = await api.addStoryItem(addItem.toJson());
    if (result != null) {
      return StoryModel.fromJson(result);
    }
    return null;
  }

  Future<bool> deleteStoryItem(String targetId) async {
    return await api.deleteStoryItem(targetId);
  }


  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<String?> uploadImageInfo(JSON imageInfo, [String path = 'story_img']) async {
    return await api.uploadImageData(imageInfo, path);
  }

}