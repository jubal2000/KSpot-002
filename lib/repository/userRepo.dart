import 'package:kspot_002/services/api_service.dart';

import '../data/utils.dart';
import '../models/user_model.dart';

class UserRepo {
  final _apiService = ApiService();

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
