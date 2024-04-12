import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/event/event_screen.dart';
import 'package:kspot_002/view/story/story_screen.dart';
import 'package:kspot_002/view_model/signup_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/routes.dart';
import '../../data/theme_manager.dart';
import '../../models/user_model.dart';
import '../../repository/user_repository.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/dropdown_widget.dart';
import '../../widget/page_dot_widget.dart';
import '../../widget/verify_phone_widget.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({Key? key}) : super(key: key);
  final _viewModel = SignUpViewModel();
  final userRepo = UserRepository();

  @override
  Widget build(BuildContext context) {
    return  ChangeNotifierProvider<SignUpViewModel>.value(
      value: _viewModel,
      child: Consumer<SignUpViewModel>(
        builder: (context, viewModel, _) {
          viewModel.init();
          return WillPopScope(
            onWillPop: () async {
              viewModel.moveBackStep();
              return false;
            },
            child: SafeArea(
              child:Scaffold(
                appBar: AppBar(
                  title: Text('SIGN IN'.tr, style: AppBarTitleStyle(context)),
                  titleSpacing: 0,
                ),
                body: Container(
                  padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_L.w, 0, UI_HORIZONTAL_SPACE_L.w, 0),
                  child: LayoutBuilder(
                    builder: (context, layout) {
                      return Container(
                        height: layout.maxHeight,
                        padding: EdgeInsets.only(top: UI_TOP_TEXT_SPACE.w),
                        child: ListView(
                          children: [
                            Text(
                              'Login phone number verification'.tr,
                              style: AppBarTitleStyle(context),
                            ),
                            SizedBox(height: UI_ITEM_SPACE_L.w),
                            Text(
                              'Please enter your registered phone number'.tr,
                              style: DescBodyExStyle(context),
                              maxLines: 2,
                            ),
                            Container(
                              padding: EdgeInsets.only(top: UI_ITEM_SPACE.w),
                              child: VerifyPhoneWidget(
                                AppData.loginInfo.mobile,
                                onCheckComplete: (intl, number, userValue) async {
                                  LOG('--> userValue : $userValue');
                                  if (userValue != null && userValue.user != null) {
                                    LOG('--> userValue.user!.uid : ${userValue.user!.uid}');
                                    AppData.loginInfo.loginId   = userValue.user!.uid;
                                    AppData.loginInfo.loginType = 'phone';
                                    AppData.loginInfo.mobileVerifyTime = CURRENT_SERVER_TIME().toString();
                                    // viewModel.isMobileVerified = true;
                                    // Future.delayed(const Duration(milliseconds: 500), () async {
                                    //   Get.toNamed(Routes.HOME);
                                    // });
                                  }
                                }
                              )
                            )
                          ],
                        )
                      );
                    }
                  ),
                ),
              )
            )
          );
        }
      )
    );
  }
}
