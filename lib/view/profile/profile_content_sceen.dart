import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:provider/provider.dart';

import '../../data/theme_manager.dart';
import '../../models/event_model.dart';
import '../../utils/utils.dart';
import '../../view_model/event_view_model.dart';
import '../../view_model/user_view_model.dart';
import '../story/story_item.dart';

class ProfileContentScreen extends StatelessWidget {
  ProfileContentScreen(this.parentViewModel, this.type, this.title, {Key? key}) : super(key: key);

  UserViewModel parentViewModel;
  ProfileContentType type;
  String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: UI_EDIT_TOOL_HEIGHT,
          actions: [
            if (parentViewModel.isMyProfile)...[
              IconButton(
                onPressed: () {

                },
                icon: Icon(Icons.add)
              ),
              SizedBox(width: 10.w),
            ],
          ],
        ),
        body: ChangeNotifierProvider.value(
          value: parentViewModel,
          child: Consumer<UserViewModel>(
            builder: (context, viewModel, _) {
              LOG('--> UserViewModel redraw');
              return Container(
                padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
                child: viewModel.showContentList(type),
              );
            }
          )
        )
      ),
    );
  }
}