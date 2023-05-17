import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/event_model.dart';
import '../models/recommend_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';

class RecommendRepository {
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();

  Future<Map<String, RecommendModel>> getRecommendDataAll() async {
    var data = await api.getRecommendData();
    var result = cache.setRecommendData(data);
    // for (var item in data.entries) {
    //   var sponsorItem = RecommendModel.fromJson(item.value);
    //   cache.setRecommendItem(item.value);
    // }
    return result;
  }

  Future<JSON?> addRecommendItem(RecommendModel info) async {
    var eventItem = await api.getEventFromId(info.targetId);
    if (eventItem != null) {
      return await api.addRecommendItem(info.toJson());
    }
    return null;
  }

  Future<bool> setRecommendStatus(String recommendId, int status) async {
    return await api.setRecommendStatus(recommendId, status);
  }

  Future<bool> setRecommendShowStatus(String recommendId, int status) async {
    return await api.setRecommendShowStatus(recommendId, status);
  }

  checkIsEnabled(RecommendModel info) {
    return info.startTime.isAfter(DateTime.now()) && checkIsExpired(info);
  }

  checkIsExpired(RecommendModel info) {
    return info.endTime.isAfter(DateTime.now());
  }
}