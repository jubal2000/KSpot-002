import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kspot_002/data/dialogs.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/routes.dart';
import '../../data/themes.dart';
import '../../models/start_model.dart';
import '../../utils/utils.dart';
import '../../services/api_service.dart';
import '../../services/firebase_service.dart';
import '../../view_model/app_view_model.dart';

class IntroScreen extends StatelessWidget {
  IntroScreen({Key? key}) : super(key: key);
  final userRepo = UserRepository();
  final api  = Get.find<ApiService>();
  final _viewModel = AppViewModel();

  @override
  Widget build(BuildContext context) {
    _viewModel.init(context);
    return WillPopScope(
        onWillPop: () async => await showAlertYesNoDialog(context,
          'APP EXIT'.tr,
          'Are you sure you want to quit the app?'.tr,
          '',
          'Cancel'.tr,
          'OK'.tr
      ).then((result) {
        return result == 1;
      }),
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: Padding (
              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
              child: FutureBuilder(
              future: api.getAppStartInfo(AppData.defaultInfoID),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  LOG('--> snapshot.data : ${snapshot.data}');
                  final startData = StartModel.fromJson(snapshot.data as JSON);
                  return ChangeNotifierProvider.value(
                    value:  _viewModel,
                    child: Consumer<AppViewModel>(builder: (context, viewModel, _) {
                      if (!viewModel.isCanStart) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Future.delayed(const Duration(milliseconds: 500), () async {
                            var versionInfo = startData.appVersion[Platform.isAndroid ? 'android' : 'ios'];
                            var result = await viewModel.checkAppUpdate(versionInfo!);
                            LOG('--> checkAppUpdate result : $result');
                            if (result) {
                              viewModel.setCanStart(true);
                            }
                          });
                        });
                      }
                      return Stack(
                        children: [
                          Align(
                              alignment: Alignment(0, -0.35),
                              child: Image.asset(
                                APP_LOGO_XL,
                                width: MediaQuery.of(context).size.width * 0.5,
                              )
                          ),
                          Visibility(
                            visible: viewModel.isCanStart,
                            child: Align(
                              alignment: Alignment(0, 0.8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: Get.size.width,
                                    height: UI_BUTTON_HEIGHT,
                                    padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Get.toNamed(Routes.SIGN_IN);
                                      },
                                      child: Text(
                                        'SIGN IN'.tr,
                                      )
                                    ),
                                  ),
                                  SizedBox(height: UI_ITEM_SPACE_M),
                                  Container(
                                    width: Get.size.width,
                                    height: UI_BUTTON_HEIGHT,
                                    padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          await userRepo.startGuestUser();
                                          Get.toNamed(Routes.HOME);
                                        },
                                        child: Text(
                                          'GUEST START'.tr,
                                        )
                                    ),
                                  ),
                                  SizedBox(height: UI_ITEM_SPACE_L * 1.5),
                                  GestureDetector(
                                    onTap: () async {
                                      Get.toNamed(Routes.SIGN_UP);
                                    },
                                    child: Container(
                                      width: Get.size.width,
                                      height: UI_BUTTON_HEIGHT,
                                      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                                      color: Colors.transparent,
                                      child: Center(
                                        child: Text('SIGNUP'.tr, style: ItemTitleAlertStyle(context)),
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(0, 0.95),
                            child: Text('Version $APP_VERSION\nApp created by JH.Factory', textAlign: TextAlign.center),
                          )
                        ],
                      );
                    }
                    )
                  );
                } else {
                  return CircularProgressIndicator();
                }
              }
            )
          )
        )
      )
    );
  }
}
