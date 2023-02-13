import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/story_model.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class StoryRepository {
  final api = Get.find<ApiService>();

  getStoryStreamFromGroup(String groupId) {
    return api.getStoryStreamFromGroup(groupId, AppData.currentCountry, AppData.currentState);
  }

  getStoryStreamFromGroupNext(String lastTime, String groupId) {
    return api.getStoryStreamFromGroupNext(lastTime, groupId, AppData.currentCountry, AppData.currentState);
  }

  Future<JSON?> addStoryItem(StoryModel addItem) async {
    return await api.addStoryItem(addItem.toJson());
  }

  /////////////////////////////////////////////////////////////////////////////////////////////

  Future<String?> uploadImageInfo(JSON imageInfo, [String path = 'story_img']) async {
    return await api.uploadImageData(imageInfo, path);
  }

}