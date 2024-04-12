import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/place/place_edit_group_screen.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../utils/utils.dart';
import '../../view_model/place_edit_view_model.dart';
import '../../widget/helpers/helpers/widgets/align.dart';
import '../../widget/page_dot_widget.dart';
import '../../widget/title_text_widget.dart';
import '../../models/place_model.dart';
import '../event/event_edit_place_screen.dart';
import 'place_edit_input_screen.dart';

class PlaceEditScreen extends StatefulWidget {
  PlaceEditScreen({Key? key, this.placeInfo}) : super(key: key);

  PlaceModel? placeInfo;

  @override
  _PlaceEditScreenState createState ()=> _PlaceEditScreenState();
}

class _PlaceEditScreenState extends State<PlaceEditScreen> {
  final _viewModel = PlaceEditViewModel();

  @override
  void initState () {
    _viewModel.isEditMode = widget.placeInfo != null;
    LOG('--> EventEditScreen : ${_viewModel.isEditMode}');
    if (_viewModel.isEditMode) {
      _viewModel.setEditItem(widget.placeInfo!);
    } else {
      _viewModel.setEditItem(PlaceModelEx.empty(''));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  ChangeNotifierProvider<PlaceEditViewModel>.value(
      value: _viewModel,
      child: Consumer<PlaceEditViewModel>(
        builder: (context, viewModel, _) {
          return WillPopScope(
            onWillPop: () async {
              viewModel.moveBackStep();
              return false;
            },
            child: SafeArea(
              top: false,
              child:Scaffold(
                appBar: AppBar(
                  title: TopTitleText(context, viewModel.isEditMode ? 'Place Edit'.tr : viewModel.titleN[viewModel.stepIndex].tr),
                  titleSpacing: 0,
                  toolbarHeight: UI_EDIT_TOOL_HEIGHT.w,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                body: Container(
                  child: Column(
                    children: [
                      if (viewModel.isEditMode)...[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                            child: PlaceEditInputScreen(parentViewModel: viewModel)
                          ),
                        ),
                      ],
                      if (!viewModel.isEditMode)...[
                        PageDotWidget(
                          viewModel.stepIndex, viewModel.stepMax,
                          dotType: PageDotType.line,
                          height: 5.h,
                          activeColor: Theme.of(context).primaryColor,
                          width: Get.width - (UI_HORIZONTAL_SPACE.w * 2),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE, UI_TOP_SPACE.w, UI_HORIZONTAL_SPACE, 0),
                            child: IndexedStack(
                              key: ValueKey(viewModel.stepIndex),
                              index: viewModel.stepIndex,
                              children: [
                                showAgreeStep(context, viewModel),
                                PlaceEditGroupSelectScreen(parentViewModel: viewModel),
                                PlaceEditInputScreen(parentViewModel: viewModel),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (!viewModel.isShowOnly)...[
                        SizedBox(height: UI_LIST_TEXT_SPACE_S),
                        Obx(() => BottomCenterAlign(
                          child: GestureDetector(
                            onTap: () {
                              // if (!viewModel.isNextEnable) return; // disabled for Dev..
                              viewModel.moveNextStep();
                            },
                            child: Container(
                              width: double.infinity,
                              height: UI_BOTTOM_HEIGHT.w,
                              color: viewModel.isNextEnable.value ? Theme.of(context).primaryColor : Colors.black45,
                              alignment: Alignment.center,
                              child: Text('Next'.tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.inversePrimary)),
                            )
                          )
                        )),
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
