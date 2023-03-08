
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/theme_manager.dart';
import 'package:kspot_002/view_model/app_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../utils/utils.dart';
import '../../view_model/chat_edit_view_model.dart';
import '../../view_model/chat_view_model.dart';
import '../../widget/edit/edit_component_widget.dart';
import '../../widget/edit/edit_list_widget.dart';
import '../../widget/edit/edit_setup_widget.dart';

class ChattingEditScreen extends StatelessWidget {
  ChattingEditScreen(
      this.selectedTab,
      { Key? key }) : super(key: key);

  int selectedTab;
  final _viewModel = ChatEditViewModel();

  @override
  Widget build(BuildContext context) {
    _viewModel.init(context, selectedTab);
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title : Text('Create Room'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
        ),
        body: LayoutBuilder(
          builder: (context, layout) {
            return ChangeNotifierProvider<ChatEditViewModel>.value(
                value: _viewModel,
                child: Consumer<ChatEditViewModel>(builder: (context, viewModel, _) {
                  LOG('--> ChatEditViewModel refresh');
                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                          child: ListView(
                            children: [
                              SizedBox(height: UI_ITEM_SPACE_M),
                              // viewModel.showTypeSelect(),
                              // SizedBox(height: UI_LIST_TEXT_SPACE_S),
                              if (viewModel.type == 0)...[
                                viewModel.showImageSelector(),
                                SizedBox(height: UI_LIST_TEXT_SPACE_S),
                                SubTitle(context, 'INFO'.tr),
                                SizedBox(height: UI_LIST_TEXT_SPACE_S),
                                viewModel.showTitle(),
                              ],
                              if (viewModel.type == 1)...[
                                SubTitle(context, 'INFO'.tr),
                                SizedBox(height: UI_LIST_TEXT_SPACE_S),
                                // viewModel.showPassword(),
                                // SizedBox(height: UI_LIST_TEXT_SPACE_S),
                              ],
                              viewModel.showInviteMessage(),
                              SizedBox(height: UI_LIST_TEXT_SPACE_S),
                              viewModel.showMembers(),
                              SizedBox(height: UI_LIST_TEXT_SPACE_L),
                            ],
                          )
                        )
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!viewModel.createButtonEnable) return;
                          viewModel.uploadStart();
                        },
                        child: Container(
                          height: UI_BUTTON_HEIGHT.w,
                          color: viewModel.createButtonEnable ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).disabledColor,
                          child: Center(
                            child: Text('CREATE ROOM'.tr, style: ButtonTitleStyle(context)),
                          )
                        )
                      )
                    ]
                  );
                }
              )
            );
          }
        ),
      )
    );
  }
}
