import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:kspot_002/repository/user_repository.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';
import '../view/sign_up/sign_up_done_screen.dart';
import '../widget/verify_phone_widget.dart';

enum TextInputId {
  nickname,
}

class SignUpViewModel extends ChangeNotifier {
  final repo = UserRepository();
  var stepIndex = 2;
  var stepMax = 3;
  var isShowOnly = false;
  var isChecked = [false, false];
  var isMobileVerified = false;
  var isSignUpDone = false;
  var textEditController = List.generate(TextInputId.values.length, (index) => TextEditingController());

  BuildContext? viewContext;

  get isNextEnable {
    switch(stepIndex) {
      case 0: return isChecked[0] && isChecked[1];
      case 1: return isMobileVerified;
    }
    return isSignUpDone;
  }

  init(context) {
    viewContext = context;
  }

  setCheck(index, value) {
    isChecked[index] = value;
    notifyListeners();
  }

  setSignUpDone(value) {
    isSignUpDone = value;
    notifyListeners();
  }

  moveNextStep() {
    if (stepIndex + 1 < stepMax) {
      stepIndex++;
      notifyListeners();
    } else {
      // user sign up..
      repo.createNewUser(AppData.loginInfo).then((result) {
        if (result != null) {
          AppData.userInfo = result;
          Get.to(() => SignupStepDoneScreen());
        } else {
          showAlertDialog(viewContext!, 'Sign up'.tr, 'Sign up failed', '', 'OK'.tr);
        }
      });
    }
  }

  moveBackStep() {
    if (stepIndex - 1 >= 0) {
      stepIndex--;
      notifyListeners();
    }
  }
}