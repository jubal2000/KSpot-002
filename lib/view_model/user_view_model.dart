import 'package:flutter/cupertino.dart';

import '../utils/utils.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final _userRepo = UserRepository();

  UserModel? userInfo;

  void _setUserMain(UserModel? user) {
    LOG("--> _setUserMain: ${user?.toJSON()}");
    userInfo = user;
    notifyListeners();
  }

  Future<void> getUserInfo(String userId) async {
    _userRepo
        .getUserInfo(userId)
        .then((value) => _setUserMain(value))
        .onError((error, stackTrace) => _setUserMain(null));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
