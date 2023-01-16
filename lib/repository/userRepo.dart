import 'package:kspot_002/services/api_service.dart';

import '../data/utils.dart';
import '../models/user_model.dart';

class UserRepo {
  final _apiService = ApiService();

  Future<UserModel?> getStartUserInfo(String loginId) async {
    try {
      final response = await _apiService.getStartUserInfo(loginId);
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
      final response = await _apiService.getUserInfo(userId);
      final jsonData = UserModel.fromJson(FROM_SERVER_DATA(response));
      LOG("--> getUserInfo result: ${jsonData.toJSON()}");
      return jsonData;
    } catch (e) {
      LOG("--> getUserInfo error: $e");
      throw e.toString();
    }
  }
}