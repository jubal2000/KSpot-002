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

  TitleColorText(title, List<String> colorText,
      {double fontSize = UI_FONT_SIZE_H}) {
    List<String> showText = title.split(' ');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: showText
          .map((item) => TextInterface(
          title: '$item ',
          color: colorText.contains(item)
              ? Colors.blue
              : Colors.black87,
          font: TextFont.M,
          size: fontSize.sp))
          .toList(),
    );
  }

  SubTitleColorText(title, List<String> colorText,
      {JSON replaceStr = const {}, double fontSize = UI_FONT_SIZE_S}) {
    if (replaceStr.isNotEmpty) {
      for (var key in replaceStr.keys) {
        title = title.replaceAll(key, replaceStr[key]);
      }
    }
    List<String> showText = title.split(' ');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: showText
          .map((item) => TextInterface(
          title: '$item ',
          color: colorText.contains(item)
              ? Colors.blue
              : Colors.black87,
          font: TextFont.M,
          size: fontSize.sp))
          .toList(),
    );
  }

  SubTitleText(text,
      {double fontSize = UI_FONT_SIZE_S,
        int maxLine = 1,
        double height = 1,
        Color color = Colors.black87}) {
    return TextInterface(
        title: text,
        color: color,
        font: TextFont.L,
        size: fontSize.sp,
        align: TextAlign.center,
        lineMax: maxLine,
        height: height);
  }
}
