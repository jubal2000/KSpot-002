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

    // _eventInfo['reserveDay'] ??= 7;
    // _eventInfo['reserveData'] ??= {};
    // if (_eventInfo['reserveData'].length > 1) {
    //   _eventInfo['reserveData'] = JSON_START_DAY_SORT_DESC(_eventInfo['reserveData']);
    // }

    // if (AppData.isMoveListBottom) {
    //   Future.delayed(const Duration(milliseconds: 200), () {
    //     _scrollController.scrollToIndex(0, preferPosition: AutoScrollPosition.begin);
    //     AppData.isMoveListBottom = false;
    //   });
    // }
  }

  // refreshReservButton(DateTime? date, JSON? jsonData) async {
  //   LOG('--> refreshReservButton : $date / $jsonData');
  //   if (date == null) return;
  //   AppData.currentDate = date;
  //   _selectInfo       = jsonData;
  //   _selectReserve    = null;
  //   _isCanReserve     = false;
  //   _isShowReserveBtn = false;
  //
  //   if (date != null && JSON_NOT_EMPTY(jsonData)) {
  //     _isCanReserve       = _eventInfo['option'] != null && BOL(_eventInfo['option']['reserv']);
  //     _isShowReserveList  = !BOL(_eventInfo['option']['rev_show']) || _isManager;
  //     if (_isCanReserve) {
  //       if (JSON_NOT_EMPTY(_eventInfo['reserveData'])) {
  //         _eventInfo['reserveData'] = JSON_START_DAY_SORT(_eventInfo['reserveData']);
  //         for (var item in _eventInfo['reserveData'].entries) {
  //           // var time = STR(item.value['startTime']).split(':');
  //           // LOG('--> checkTime : ${item.value['startTime']} => $time');
  //           // var checkTime = DateTime(date.year, date.month, date.day, int.parse(time[0]), int.parse(time[1]));
  //           if (CheckCanReserve(date, INT(item.value['startDay']))) {
  //             _selectReserve = item.value;
  //             // LOG('--> refreshSelectReservItem check : $_selectReserve = ${AppData.currentDate!} / ${INT(item.value['startDay'])}');
  //             break;
  //           }
  //         }
  //         _isCanReserve = _selectReserve != null;
  //         _isShowReserveBtn = _isCanReserve;
  //         // check today reserve..
  //         if (date.isToday()) {
  //           _isShowReserveBtn = _eventInfo['option'] == null || !BOL(_eventInfo['option']['today_off']);
  //         }
  //         // check already reserved..
  //         if (_isShowReserveBtn) {
  //           _isShowReserveBtn = await api.checkReserveDay(_eventInfo['id'], AppData.USER_ID, DATE_STR(date));
  //         }
  //       }
  //       LOG('--> refreshSelectReservItem result : $_isCanReserve / $_isShowReserveBtn');
  //     }
  //   }
  //   setState(() { });
  // }

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
            titleSpacing: 0,
            toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
            actions: [
              if (viewModel.isManager || AppData.IS_ADMIN)...[
                SizedBox(width: 15),
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
                        ...DropdownItems.placeItems0.map(
                              (item) =>
                              DropdownMenuItem<DropdownItem>(
                                value: item,
                                child: DropdownItems.buildItem(context, item),
                              ),
                        ),
                      if (viewModel.eventInfo!.status != 1)
                        ...DropdownItems.placeItems1.map(
                              (item) =>
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
                                Row(
                                  children: [
                                    viewModel.showPicture(),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          viewModel.showTitle()
                                        ]
                                      ),
                                    ),
                                    if (!widget.isPreview)...[
                                      SizedBox(height: 20),
                                      viewModel.showShareBox(),
                                    ],
                                  ]
                                ),
                                SizedBox(height: 20),
                                if (viewModel.eventInfo!.desc.isNotEmpty)...[
                                  viewModel.showDesc(),
                                ],
                                if (JSON_NOT_EMPTY(viewModel.eventInfo!.tagData))...[
                                  SizedBox(height: 30),
                                  viewModel.showTagList(),
                                ],
                                // if (INT(_eventInfo['price']) > 0)...[
                                //   showHorizontalDivider(Size(double.infinity * 0.9, 40), color: LineColor(context)),
                                //   SubTitle(context, 'ENTRANCE FEE(site)'.tr),
                                //   Text('${PRICE_FULL_STR(_eventInfo['price'], _eventInfo['priceCurrency'])}', style: DescBodyPriceStyle(context)),
                                // ],
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
              )
            );
          }
        )
      )
    );
  }
}
