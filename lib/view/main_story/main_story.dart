import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view_model/event_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/common_sizes.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/story_view_model.dart';
import '../../widget/title_text_widget.dart';
import '../app/app_top_menu.dart';

class MainStory extends StatelessWidget {
  MainStory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoryViewModel>.value(
      value: StoryViewModel(),
      child: Consumer<StoryViewModel>(builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: AppTopMenuBar(MainMenuID.story),
            automaticallyImplyLeading: false,
            toolbarHeight: UI_APPBAR_TOOL_HEIGHT.w,
          ),
          body: viewModel.showMainList(context),
        );
      }),
    );
  }
}
