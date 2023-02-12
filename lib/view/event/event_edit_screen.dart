import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/data/common_sizes.dart';
import '../../models/place_model.dart';
import 'event_edit_input_screen.dart';
import 'event_screen.dart';
import 'package:kspot_002/view/story/story_screen.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:kspot_002/view_model/signup_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/dropdown_widget.dart';
import '../../widget/page_dot_widget.dart';
import '../../widget/title_text_widget.dart';
import '../../widget/verify_phone_widget.dart';
import 'event_edit_place_screen.dart';

class EventEditScreen extends StatefulWidget {
  EventEditScreen({Key? key, this.eventInfo, this.placeInfo}) : super(key: key);

  EventModel? eventInfo;
  PlaceModel? placeInfo;

  @override
  _EventEditScreenState createState ()=> _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  final _viewModel = EventEditViewModel();

  @override
  void initState () {
    _viewModel.isEditMode = widget.eventInfo != null;
    LOG('--> EventEditScreen : ${_viewModel.isEditMode}');
    if (_viewModel.isEditMode) {
      _viewModel.setEditItem(widget.eventInfo!, widget.placeInfo);
    } else {
      _viewModel.setEditItem(EventModelEx.empty(''), null);
    }
    super.initState ();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.init(context);
    return  ChangeNotifierProvider<EventEditViewModel>.value(
      value: _viewModel,
      child: Consumer<EventEditViewModel>(
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
                  title: TopTitleText(context, viewModel.isEditMode ? 'Event Edit'.tr : viewModel.titleN[viewModel.stepIndex].tr),
                  titleSpacing: 0,
                  toolbarHeight: UI_EDIT_TOOL_HEIGHT.w,
                  backgroundColor: Colors.transparent,
                ),
                body: Container(
                  child: Column(
                    children: [
                      if (viewModel.isEditMode)...[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE_L),
                            child: EventEditInputScreen(parentViewModel: viewModel)
                          ),
                        ),
                      ],
                      if (!viewModel.isEditMode)...[
                        PageDotWidget(
                          viewModel.stepIndex, viewModel.stepMax,
                          dotType: PageDotType.line,
                          height: 5.h,
                          frontColor: Theme.of(context).primaryColor,
                          width: Get.width - (UI_HORIZONTAL_SPACE.w * 2),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_L.w, UI_TOP_SPACE.w, UI_HORIZONTAL_SPACE_L.w, 0),
                            child: IndexedStack(
                              key: ValueKey(viewModel.stepIndex),
                              index: viewModel.stepIndex,
                              children: [
                                showAgreeStep(context, viewModel),
                                EventEditPlaceScreen(parentViewModel: viewModel),
                                EventEditInputScreen(parentViewModel: viewModel),
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
                              height: UI_BOTTOM_HEIGHT.w,
                              color: viewModel.isNextEnable ? Theme.of(context).primaryColor : Colors.black45,
                              alignment: Alignment.center,
                              child: Text('Next'.tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.inversePrimary)),
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

  showAgreeStep(BuildContext context, EventEditViewModel viewModel) {
    var textColor = Theme.of(context).hintColor;
    return LayoutBuilder(
        builder: (context, layout) {
          return Container(
              height: layout.maxHeight,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: FutureBuilder(
                                  future: loadTerms(),
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      return Html(
                                          data: snapshot.data,
                                          style: {
                                            "p" : Style(color: textColor),
                                            "h2": Style(color: textColor),
                                            "h3": Style(color: textColor),
                                            "h4": Style(color: textColor),
                                          }
                                      );
                                    } else {
                                      return showLoadingImageSize(Size(double.infinity, MediaQuery.of(context).size.height * 0.28));
                                    }
                                  }
                              )
                          )
                      )
                  ),
                  if (!viewModel.isShowOnly)...[
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Checkbox(
                            value: viewModel.agreeChecked,
                            onChanged: (status) {
                              viewModel.setCheck(status ?? false);
                            }
                        ),
                        Text(
                          'I agree to the Privacy Policy'.tr,
                          style: ItemTitleStyle(context),
                        )
                      ],
                    ),
                  ]
                ],
              )
          );
        }
    );
  }
}
