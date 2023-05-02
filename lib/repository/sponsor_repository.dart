import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/event_model.dart';
import '../models/sponsor_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';

class SponsorRepository {
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();

  Future<Map<String, SponsorModel>> getSponsorDataAll() async {
    var data = await api.getSponsorData();
    var result = cache.setSponsorData(data);
    // for (var item in data.entries) {
    //   var sponsorItem = SponsorModel.fromJson(item.value);
    //   cache.setSponsorItem(item.value);
    // }
    return result;
  }

  Future<JSON?> addSponsorItem(SponsorModel sponsorInfo) async {
    var eventItem = await api.getEventFromId(sponsorInfo.targetId);
    if (eventItem != null) {
      return await api.addSponsorItem(sponsorInfo.toJson());
    }
    return null;
  }

  Future<bool> setSponsorStatus(String sponsorId, int status) async {
    return await api.setSponsorStatus(sponsorId, status);
  }

  Future<bool> setSponsorShowStatus(String sponsorId, int status) async {
    return await api.setSponsorShowStatus(sponsorId, status);
  }

  checkIsEnabled(SponsorModel sponsorInfo) {
    return sponsorInfo.startTime.isAfter(DateTime.now()) && checkIsExpired(sponsorInfo);
  }

  checkIsExpired(SponsorModel sponsorInfo) {
    return sponsorInfo.endTime.isAfter(DateTime.now());
  }
}