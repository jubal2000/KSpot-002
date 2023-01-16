import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/routes.dart';
import '../../data/themes.dart';
import '../../data/utils.dart';
import '../../services/api_service.dart';
import '../../services/firebase_service.dart';
import '../../view_model/app_view_model.dart';

class Intro extends StatelessWidget {
  Intro({Key? key}) : super(key: key);
  final _api = ApiService();
  final _viewModel = AppViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
            child: FutureBuilder(
            future: _api.getAppStartInfo(),
            builder: (context, snapshot) {
              LOG('--> snapshot : ${snapshot.hasData} / ${_viewModel.isCanStart}');
              if (snapshot.hasData) {
                return ChangeNotifierProvider<AppViewModel>(
                  create: (BuildContext context) => _viewModel,
                  child: Consumer<AppViewModel>(builder: (context, viewModel, _) {
                    if (!_viewModel.isCanStart) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Future.delayed(const Duration(milliseconds: 500), () async {
                          var result = await _viewModel.checkAppUpdate(context, AppData.startData);
                          LOG('--> checkAppUpdate result : $result');
                          if (result) {
                            _viewModel.setCanStart(true);
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
                        Align(
                          alignment: Alignment(0, 0.65),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: UI_BUTTON_HEIGHT,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Visibility(
                                  visible: _viewModel.isCanStart,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.toNamed(Routes.APP);
                                    },
                                    child: Text(
                                      'START'.tr,
                                    )
                                  ),
                                )
                              ),
                            ],
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
        ),
      ),
    );
  }
}
