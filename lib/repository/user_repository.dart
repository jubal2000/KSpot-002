import 'package:kspot_002/services/api_service.dart';

import '../utils/utils.dart';
import '../models/user_model.dart';

class UserRepository {
  final api = ApiService();

  Future<UserModel?> getStartUserInfo(String loginId) async {
    try {
      final response = await api.getStartUserInfo(loginId);
      final jsonData = UserModel.fromJson(FROM_SERVER_DATA(response));
      LOG("--> getStartUserInfo result: ${jsonData.toJSON()}");
      return jsonData;
    } catch (e) {
      LOG("--> getStartUserInfo error: $e");
      throw e.toString();
    }
  }

  Future<UserModel?> getUserInfo(String userId) async {
    try {
      final response = await api.getUserInfoFromId(userId);
      final jsonData = UserModel.fromJson(FROM_SERVER_DATA(response));
      LOG("--> getUserInfo result: ${jsonData.toJSON()}");
      return jsonData;
    } catch (e) {
      LOG("--> getUserInfo error: $e");
      throw e.toString();
    }
  }

  Future<bool> setUserInfoJSON(String userId, JSON items) async {
    LOG('--> setUserInfoJSON : $userId / $items');
    if (userId.isEmpty) return false;
    return api.setUserInfoJSON(userId, items);
  }

  Future<bool> setUserInfoItem(UserModel user, String key) async {
    final userInfo = user.toJSON();
    LOG('--> setUserInfoItem : ${user.id} - $key / ${userInfo[key]}');
    return api.setUserInfoItem(userInfo, key);
  }
}
