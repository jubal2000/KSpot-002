import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';
import '../view/sign_up/sign_up_done.dart';
import '../widget/verify_phone_widget.dart';

enum TextInput {
  nickname,
}

class SignUpViewModel extends ChangeNotifier {
  var stepIndex = 2;
  var stepMax = 3;
  var isShowOnly = false;
  var isChecked = [false, false];
  var isMobileVerified = false;
  var isSignUpDone = false;
  var textEditController = List.generate(TextInput.values.length, (index) => TextEditingController());

  BuildContext? viewContext;

  get isNextEnable {
    switch(stepIndex) {
      case 0: return isChecked[0] && isChecked[1];
      case 1: return isMobileVerified;
    }
    return isSignUpDone;
  }

  Future<String> loadTerms() async {
    return await rootBundle.loadString('assets/html/terms_0.html');
  }

  Future<String> loadCondition() async {
    return await rootBundle.loadString('assets/html/terms_1.html');
  }

  setViewContext(context) {
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
      Get.to(() => SignupStepDone());
    }
  }

  moveBackStep() {
    if (stepIndex - 1 >= 0) {
      stepIndex--;
      notifyListeners();
    }
  }
}