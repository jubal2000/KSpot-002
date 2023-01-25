import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/routes.dart';
import '../../data/style.dart';
import '../../utils/utils.dart';
import '../../widget/rounded_button.dart';

class SignupStepDoneScreen extends StatelessWidget {
  const SignupStepDoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 160.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  showImage('assets/ui/logo_01_01.png', Size(UI_LOGO_ICON_SIZE_M.w, UI_LOGO_ICON_SIZE_M.w)),
                  SizedBox(height: UI_TOP_TEXT_SPACE.h),
                  TitleColorText('Congratulations on your membership'.tr, ['membership', '회원가입을']),
                  SizedBox(height: UI_LIST_TEXT_SPACE.h),
                  SubTitleText('Experience the many services and benefits of KSpot'.tr),
                ],
              ),
              Container(
                width: Get.size.width,
                height: UI_BUTTON_HEIGHT,
                margin: EdgeInsets.all(UI_HORIZONTAL_SPACE.w),
                child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(Routes.APP);
                    },
                    child: Text(
                      'Use the service'.tr,
                    )
                ),
              )
            ],
          )
        )
      )
    );
  }
}
