import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
  final _api = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Padding (
            padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
            child: FutureBuilder(
            future: _api.getAppStartInfo(AppData.defaultInfoID),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                LOG('--> snapshot.data : ${snapshot.data}');
                final startData = StartModel.fromJson(snapshot.data as JSON);
                return ChangeNotifierProvider<AppViewModel>(
                  create: (_) => AppViewModel(),
                  child: Consumer<AppViewModel>(builder: (context, viewModel, _) {
                    if (!viewModel.isCanStart) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Future.delayed(const Duration(milliseconds: 500), () async {
                          var versionInfo = startData.appVersion[Platform.isAndroid ? 'android' : 'ios'];
                          var result = await viewModel.checkAppUpdate(context, versionInfo!);
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
                            alignment: Alignment(0, -0.25),
                            child: Image.asset(
                              APP_LOGO_XL,
                              width: MediaQuery.of(context).size.width * 0.5,
                            )
                        ),
                        Visibility(
                          visible: viewModel.isCanStart,
                          child: Align(
                            alignment: Alignment(0, 0.65),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (AppData.loginInfo.loginType.isEmpty)...[
                                  Container(
                                    width: Get.size.width,
                                    height: UI_BUTTON_HEIGHT,
                                    padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Get.toNamed(Routes.SIGNUP);
                                      },
                                      child: Text(
                                        'SIGN UP'.tr,
                                      )
                                    ),
                                  ),
                                  SizedBox(height: UI_ITEM_SPACE_M.w),
                                ],
                                Container(
                                  width: Get.size.width,
                                  height: UI_BUTTON_HEIGHT,
                                  padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        if (AppData.loginInfo.loginId.isEmpty) {
                                          final userCredential = await FirebaseAuth.instance.signInAnonymously();
                                          LOG('--> userCredential : $userCredential');
                                        }
                                        Get.toNamed(Routes.APP);
                                      },
                                      child: Text(
                                        'START'.tr,
                                      )
                                  ),
                                )
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
    );
  }
}
