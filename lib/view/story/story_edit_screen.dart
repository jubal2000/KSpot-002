import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/repository/story_repository.dart';
import 'package:kspot_002/view/story/story_edit_event_screen.dart';
import 'package:kspot_002/view/story/story_edit_input_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

import '../../data/theme_manager.dart';
import '../../models/etc_model.dart';
import '../../models/event_model.dart';
import '../../models/story_model.dart';
import '../../utils/utils.dart';
import '../../view_model/story_edit_view_model.dart';
import '../../widget/page_dot_widget.dart';
import '../../widget/title_text_widget.dart';


class StoryEditScreen extends StatefulWidget {
  StoryEditScreen({Key? key, this.storyInfo, this.eventInfo}) : super(key: key);

  StoryModel? storyInfo;
  EventModel? eventInfo;

  @override
  _StoryEditScreenState createState ()=> _StoryEditScreenState();
}

class _StoryEditScreenState extends State<StoryEditScreen> {
  final _viewModel = StoryEditViewModel();

  @override
  void initState () {
    _viewModel.isEditMode = widget.storyInfo != null;
    if (_viewModel.isEditMode) {
      _viewModel.setEditItem(widget.storyInfo!, widget.eventInfo);
    } else {
      _viewModel.setEditItem(StoryModelEx.empty(''), null);
    }
    _viewModel.stepIndex = _viewModel.isEditMode ? 2 : 0;
    super.initState ();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoryEditViewModel>.value(
      value: _viewModel,
      child: Consumer<StoryEditViewModel>(
        builder: (context, viewModel, _) {
          return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                title: TopTitleText(context, viewModel.isEditMode ? 'Story edit'.tr : 'Story add'.tr),
                titleSpacing: 0,
                toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
              ),
              body: Container(
                  child: Column(
                    children: [
                      if (viewModel.isEditMode)...[
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE_L),
                              child: StoryEditInputScreen(parentViewModel: viewModel)
                          ),
                        ),
                      ],
                      if (!viewModel.isEditMode)...[
                        PageDotWidget(
                          viewModel.stepIndex, viewModel.stepMax,
                          dotType: PageDotType.line,
                          height: 5,
                          activeColor: Theme.of(context).primaryColor,
                          width: Get.width - (UI_HORIZONTAL_SPACE * 2),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_L, UI_TOP_SPACE, UI_HORIZONTAL_SPACE_L, 0),
                            child: IndexedStack(
                              key: ValueKey(viewModel.stepIndex),
                              index: viewModel.stepIndex,
                              children: [
                                showAgreeStep(context, viewModel),
                                StoryEditEventScreen(parentViewModel: viewModel),
                                StoryEditInputScreen(parentViewModel: viewModel),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (!viewModel.isShowOnly)...[
                        SizedBox(height: UI_LIST_TEXT_SPACE_S),
                        BottomCenterAlign(
                          child: GestureDetector(
                            onTap: () {
                              // if (!viewModel.isNextEnable) return; // disabled for Dev..
                              viewModel.moveNextStep();
                            },
                            child: Container(
                              width: double.infinity,
                              height: UI_BOTTOM_HEIGHT,
                              color: viewModel.isNextEnable ? Theme.of(context).primaryColor : Colors.black45,
                              alignment: Alignment.center,
                              child: Text('Next'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.inversePrimary)),
                            )
                          )
                        ),
                      ]
                    ],
                  )
                )
              )
            )
          );
        }
      )
    );
  }
}

