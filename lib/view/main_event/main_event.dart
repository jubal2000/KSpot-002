import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view_model/event_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/common_sizes.dart';
import '../../widget/title_text_widget.dart';

class MainEvent extends StatelessWidget {
  MainEvent({Key? key}) : super(key: key);
  final _viewModel = EventViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EventViewModel>.value(
      value: _viewModel,
      child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: TopTitleText(context, 'Main Event'.tr, onAction: () {
              Get.back();
            }),
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: UI_APPBAR_TOOL_HEIGHT.h,
          ),
          body: _viewModel.showMainList(context),
        );
      }),
    );
  }
}
