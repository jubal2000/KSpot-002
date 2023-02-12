import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/utils/utils.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:kspot_002/widget/csc_picker/csc_picker.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../services/cache_service.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/event_view_model.dart';
import '../../view_model/story_view_model.dart';
import '../../widget/title_text_widget.dart';

class StoryScreen extends StatelessWidget {
  StoryScreen({Key? key}) : super(key: key);
  final cache = Get.find<CacheService>();

  @override
  Widget build(BuildContext context) {
    AppData.eventViewModel.init(context);
    return Scaffold(
      body: ChangeNotifierProvider<AppViewModel>.value(
        value: AppData.appViewModel,
        child: Consumer<AppViewModel>(
          builder: (context, appViewModel, _) {
            LOG('--> AppViewModel');
            // AppData.eventViewModel.googleWidget = null;
            return LayoutBuilder(
              builder: (context, layout) {
                return ChangeNotifierProvider<StoryViewModel>.value(
                    value: AppData.storyViewModel,
                    child: Consumer<StoryViewModel>(builder: (context, viewModel, _) {
                      LOG('--> StoryViewModel 1');
                      return viewModel.showMainList(layout);
                    })
                );
              }
            );
          }
        )
      )
    );
  }
}
