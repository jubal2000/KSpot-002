import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:provider/provider.dart';

import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/setup_view_model.dart';

class SetupPushScreen extends StatelessWidget {
  final _viewModel = SetupViewModel();

  @override
  Widget build(BuildContext context) {
    _viewModel.init(context);
    _viewModel.initPushSetting();
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notification setting'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: 50,
        ),
        body: ChangeNotifierProvider.value(
          value: _viewModel,
          child: Consumer<SetupViewModel>(
            builder: (context, viewModel, _) {
              LOG('--> SetupViewModel redraw');
              return Container(
                width: Get.width,
                height: Get.height,
                padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE_L, vertical: UI_VERTICAL_SPACE),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    viewModel.showPushSetting(),
                  ],
                ),
              );
            }
          )
        )
      )
    );
  }
}