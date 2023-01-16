import 'package:flutter/cupertino.dart';

import '../data/utils.dart';
import '../models/user_model.dart';
import '../repository/userRepo.dart';

class UserViewModel extends ChangeNotifier {
  final _userRepo = UserRepo();

  UserModel? userModel;

  void _setUserMain(UserModel? userInfo) {
    LOG("--> _setUserMain: ${userInfo?.toJSON()}");
    userModel = userInfo;
    notifyListeners();
  }

  Future<void> getStartUserInfo(String loginId) async {
    _userRepo
        .getStartUserInfo(loginId)
        .then((value) => _setUserMain(value))
        .onError((error, stackTrace) => _setUserMain(null));
  }
}
