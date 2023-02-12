import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';

class StoryRepository {
  final api = Get.find<ApiService>();
  Stream? stream;

  getStoryStreamFromGroup(String groupId) {
    stream = api.getStoryStreamFromGroup(groupId);
  }

  getStoryStreamFromGroupNext(String lastTime, String groupId) {
    stream = api.getStoryStreamFromGroupNext(lastTime, groupId);
  }
}