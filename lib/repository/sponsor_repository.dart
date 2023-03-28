import 'package:get/get.dart';

import '../models/sponsor_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';

class SponsorRepository {
  final cache = Get.find<CacheService>();
  final api   = Get.find<ApiService>();

  Future<JSON> addSponsorItem(SponsorModel sponsorInfo) async {
    return await api.addSponsorItem(sponsorInfo.toJson());
  }

  Future<bool> setSponsorStatus(String sponsorId, int status) async {
    return await api.setEventStatus(sponsorId, status);
  }

  Future<bool> setSponsorShowStatus(String sponsorId, int status) async {
    return await api.setEventShowStatus(sponsorId, status);
  }

  checkIsEnabled(SponsorModel sponsorInfo) {
    return sponsorInfo.startTime.isAfter(DateTime.now()) && checkIsExpired(sponsorInfo);
  }

  checkIsExpired(SponsorModel sponsorInfo) {
    return sponsorInfo.endTime.isAfter(DateTime.now());
  }
}