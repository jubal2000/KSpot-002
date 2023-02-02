import 'package:get/get.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:kspot_002/models/user_model.dart';
import 'package:kspot_002/services/api_service.dart';

import '../models/follow_model.dart';
import '../utils/utils.dart';

class FollowRepository {
  final api = Get.find<ApiService>();

  Future<Map<String, FollowModel>> getFollowListFromUserId(String userId) async {
    Map<String, FollowModel> result = {};
    try {
      final response = await api.getFollowList(userId);
      for (var item in response.entries) {
        result[item.key] = FollowModel.fromJson(item.value);
        LOG('--> getFollowListFromUserId item : ${result[item.key]!.toJson()}');
      }
    } catch (e) {
      LOG('--> getFollowListFromUserId error [$userId] : $e');
    }
    return result;
  }

  Future<FollowModel?> addFollowTarget(UserModel user, PlaceModel target) async {
    try {
      final response = await api.addFollowTarget(user.toJson(), target.toJson());
      return FollowModel.fromJson(response);
    } catch (e) {
      LOG('--> addFollowTarget error : $e');
    }
    return null;
  }
}
