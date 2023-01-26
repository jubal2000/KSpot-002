import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/common_sizes.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/story_view_model.dart';
import '../../widget/title_text_widget.dart';
import '../app/app_top_menu.dart';

class StoryScreen extends StatelessWidget {
  StoryScreen({Key? key}) : super(key: key);

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

class StoryDetailScreen extends StatefulWidget {
  StoryDetailScreen(this.itemInfo, {Key? key, this.topTitle = '', this.onUpdate}) : super(key: key);

  JSON itemInfo;
  String topTitle;
  Function(JSON)? onUpdate;

  @override
  StoryDetailState createState() => StoryDetailState();
}

class StoryDetailState extends State<StoryDetailScreen> {
  final _topHeight = 50.0;
  final _itemKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.topTitle, style: AppBarTitleStyle(context)),
              titleSpacing: 0,
              toolbarHeight: _topHeight,
            ),
            body: Container(
                height: MediaQuery.of(context).size.height - _topHeight,
                child: Stack(
                    children: [
                      // ListView(
                      //     children: [
                      //       SizedBox(height: 15),
                      //       MainStoryItem(widget.itemInfo, key: _itemKey,
                      //           itemHeight: MediaQuery.of(context).size.width, bottomSpace: 0, isFullScreen: true)
                      //     ]
                      // ),
                      // Positioned(
                      //     left: 0,
                      //     bottom: 0,
                      //     child: Container(
                      //         height: _topHeight,
                      //         color: Theme.of(context).colorScheme.secondaryContainer,
                      //         child: Padding(
                      //             padding: EdgeInsets.symmetric(horizontal: 15),
                      //             child: showCommentMenu(context, widget.itemInfo, false, 30, (uploadData) {
                      //               var state = _itemKey.currentState as MainStoryItemState;
                      //               state.refreshData(uploadData);
                      //             },
                      //                 onUpdate: widget.onUpdate
                      //             )
                      //         )
                      //     )
                      // )
                    ]
                )
            )
        )
    );
  }
}