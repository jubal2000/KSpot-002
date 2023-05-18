import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/event_model.dart';
import 'package:kspot_002/repository/event_repository.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:kspot_002/widget/csc_picker/csc_picker.dart';
import 'package:kspot_002/widget/image_scroll_viewer.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/place_model.dart';
import '../../utils/utils.dart';
import '../../view_model/event_detail_view_model.dart';
import '../../widget/comment_widget.dart';
import '../../widget/content_item_card.dart';
import '../../widget/like_widget.dart';
import '../../widget/share_widget.dart';
import '../place/place_detail_screen.dart';


class EventDetailScreen extends StatefulWidget {
  EventDetailScreen(this.eventInfo, this.placeInfo, {Key? key, this.isPreview = false, this.isShowHome = true, this.isShowPlace = true}) : super(key: key);

  EventModel eventInfo;
  PlaceModel? placeInfo;
  bool isPreview;
  bool isShowHome;
  bool isShowPlace;

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetailScreen> {
  final _viewModel = EventDetailViewModel();

  initData() {
    _viewModel.setEventData(widget.eventInfo, widget.placeInfo);
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      if (_viewModel.isEdited) {
        Get.back(result: _viewModel.eventInfo);
        return false;
      }
      return true;
    },
    child: ChangeNotifierProvider<EventDetailViewModel>.value(
      value: _viewModel,
      child: Consumer<EventDetailViewModel>(builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                viewModel.showPicture(),
                SizedBox(width: 15),
                Expanded(
                  child: viewModel.showTitle(),
                ),
              ]
            ),
            titleSpacing: 0,
            toolbarHeight: UI_EVENT_TOOL_HEIGHT,
            actions: [
              if (!viewModel.isManager && !AppData.IS_ADMIN)...[
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    customButton: SizedBox(
                      width: 22,
                      height: 22,
                      child: Icon(Icons.more_vert),
                    ),
                    items: [
                      ...DropdownItems.placeItems2.map((item) =>
                        DropdownMenuItem<DropdownItem>(
                          value: item,
                          child: DropdownItems.buildItem(context, item),
                        ),
                      )
                    ],
                    onChanged: (value) {
                      var selected = value as DropdownItem;
                      viewModel.onEventTopMenuAction(selected);
                    },
                    // customItemsHeights: const [5],
                    itemHeight: 45,
                    dropdownWidth: 190,
                    itemPadding: const EdgeInsets.all(10),
                    offset: const Offset(0, 10),
                  ),
                ),
              ],
              if (viewModel.isManager || AppData.IS_ADMIN)...[
                GestureDetector(
                  child: Icon(viewModel.eventInfo!.status == 1 ? Icons.visibility : Icons.visibility_off),
                  onTap: () {
                    viewModel.toggleStatus();
                  },
                ),
                SizedBox(width: 15),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    customButton: SizedBox(
                      width: 22,
                      height: 22,
                      child: Icon(Icons.more_vert),
                    ),
                    items: [
                      if (viewModel.eventInfo!.status == 1)
                        ...DropdownItems.placeItems0.map((item) =>
                          DropdownMenuItem<DropdownItem>(
                            value: item,
                            child: DropdownItems.buildItem(context, item),
                          ),
                        ),
                      if (viewModel.eventInfo!.status != 1)
                        ...DropdownItems.placeItems1.map((item) =>
                          DropdownMenuItem<DropdownItem>(
                            value: item,
                            child: DropdownItems.buildItem(context, item),
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      var selected = value as DropdownItem;
                      viewModel.onEventTopMenuAction(selected);
                    },
                    // customItemsHeights: const [5],
                    itemHeight: 45,
                    dropdownWidth: 190,
                    itemPadding: const EdgeInsets.all(10),
                    offset: const Offset(0, 10),
                  ),
                ),
              ],
              SizedBox(width: 20)
            ],
          ),
          body: LayoutBuilder(
            builder: (context, layout) {
              return Container(
                width: layout.maxWidth,
                height: layout.maxHeight,
                child: Stack(
                  children: [
                    ListView(
                      controller: viewModel.scrollController,
                      // physics: BouncingScrollPhysics(),
                      children: [
                        if (JSON_NOT_EMPTY(viewModel.eventInfo!.picData))...[
                          viewModel.showImageList(),
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                if (!widget.isPreview)...[
                                  viewModel.showShareBox(),
                                ],
                                if (viewModel.eventInfo!.desc.isNotEmpty)...[
                                  SizedBox(height: 30),
                                  viewModel.showDesc(),
                                ],
                                if (JSON_NOT_EMPTY(viewModel.eventInfo!.tagData))...[
                                  SizedBox(height: 30),
                                  viewModel.showTagList(),
                                ],
                                if (JSON_NOT_EMPTY(viewModel.eventInfo!.managerData))...[
                                  showHorizontalDivider(Size(double.infinity * 0.9, 40), color: LineColor(context)),
                                  viewModel.showManagerList(),
                                ],
                                if (JSON_NOT_EMPTY(viewModel.eventInfo!.customData))...[
                                  showHorizontalDivider(Size(double.infinity * 0.9, 30), color: LineColor(context)),
                                  viewModel.showCustomFieldList(),
                                ],
                                if (widget.placeInfo != null)...[
                                  showHorizontalDivider(Size(double.infinity * 0.9, 40), color: LineColor(context)),
                                  viewModel.showLocation(),
                                ],
                              ]
                            )
                          ),
                          if (JSON_NOT_EMPTY(viewModel.eventInfo!.timeData))...[
                            SizedBox(height: 30),
                            viewModel.showTimeList(),
                          ],
                          if (!widget.isPreview)...[
                            SizedBox(height: 20),
                            viewModel.showCommentList(),
                          ],
                          SizedBox(height: viewModel.botHeight),
                        ]
                      ),
                      if (viewModel.isShowReserveBtn && viewModel.selectReserve != null)
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: viewModel.showReserveButton(),
                        ),
                    // if (viewModel.isCanReserve)...[
                    //   SubTitleBarEx(context, 'RESERVATION LIST'.tr, height: _subTabHeight, child: Text(DATE_STR(AppData.currentDate!), style: SubTitleStyle(context))),
                    //   ShowReserveListWidget(context, _eventInfo, _isManager),
                    // ],
                      ],
                    )
                  );
                }
              ),
            );
          }
        )
      )
    );
  }
}
