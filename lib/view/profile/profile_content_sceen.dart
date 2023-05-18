import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/services/cache_service.dart';
import 'package:provider/provider.dart';

import '../../data/theme_manager.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../utils/utils.dart';
import '../../view_model/event_view_model.dart';
import '../../view_model/user_view_model.dart';
import '../event/event_edit_screen.dart';
import '../story/story_item.dart';

class ProfileContentScreen extends StatelessWidget {
  ProfileContentScreen(this.parentViewModel, this.type, this.title, {Key? key, this.addText}) : super(key: key);

  UserViewModel parentViewModel;
  ProfileContentType type;
  String title;
  String? addText;

  final cache = Get.find<CacheService>();

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
                  parentViewModel.addNewContent(type);
                },
                icon: addText != null ?
                  Text(addText!, style: ItemDescColorBoldStyle(context)) :
                  Icon(Icons.add, color: Colors.yellowAccent)
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
              return FutureBuilder(
                future: viewModel.getStartContentData(type),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
                      child: Column(
                        children:[
                          viewModel.showContentSearchBar(),
                          Expanded(
                            child: viewModel.showContentList(type),
                          )
                        ]
                      )
                    );
                  } else {
                    return showLoadingFullPage(context);
                  }
                }
              );
            }
          )
        )
      ),
    );
  }
}