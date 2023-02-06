
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/follow_model.dart';
import '../repository/follow_repository.dart';
import '../utils/utils.dart';

class FollowViewModel extends ChangeNotifier {
  final repo = FollowRepository();
  BuildContext? buildContext;

  init(BuildContext context) {
    buildContext = context;
  }

  Future<Map<String, FollowModel>> getFollowList(String userId) async {
    AppData.followData = await repo.getFollowListFromUserId(userId);
    return AppData.followData;
  }
}