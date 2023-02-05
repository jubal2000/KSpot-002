import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/event_model.dart';
import 'package:kspot_002/widget/image_scroll_viewer.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/place_model.dart';
import '../../utils/utils.dart';
import '../../widget/comment_widget.dart';
import '../../widget/like_widget.dart';
import '../place/place_screen.dart';


class EventDetailScreen extends StatefulWidget {
  EventDetailScreen(this.eventInfo, this.placeInfo, {Key? key, this.topTitle = '', this.isPreview = false, this.isShowHome = true, this.isShowPlace = true}) : super(key: key);

  EventModel eventInfo;
  PlaceModel? placeInfo;
  String topTitle;
  bool isPreview;
  bool isShowHome;
  bool isShowPlace;

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetailScreen> {
  final _scrollController = AutoScrollController();
  final _topHeight = 50.0;
  final _botHeight = 70.0;
  final _subTabHeight = 45.0;
  // Future<JSON>? _initData;

  var _isManager = false;
  var _isOpenStoryList = false;
  var _isCanReserve = false;
  var _isShowReserveBtn = false;
  var _isShowReserveList = false;

  JSON? _selectReserve;
  JSON? _selectInfo;
  late final JSON _eventInfo = widget.eventInfo.toJson();

  initData() {
    _isManager  = CheckManager(_eventInfo);
    AppData.selectEventTime = {};

    _eventInfo['reserveDay'] ??= 7;
    _eventInfo['reserveData'] ??= {};
    if (_eventInfo['reserveData'].length > 1) {
      _eventInfo['reserveData'] = JSON_START_DAY_SORT_DESC(_eventInfo['reserveData']);
    }

    // if (AppData.isMoveListBottom) {
    //   Future.delayed(const Duration(milliseconds: 200), () {
    //     _scrollController.scrollToIndex(0, preferPosition: AutoScrollPosition.begin);
    //     AppData.isMoveListBottom = false;
    //   });
    // }
    LOG('--> initData : $_isCanReserve / $_isShowReserveList / ${_eventInfo['option']}');
  }

  refreshReservButton(DateTime? date, JSON? jsonData) async {
    LOG('--> refreshReservButton : $date / $jsonData');
    if (date == null) return;
    AppData.currentDate = date;
    _selectInfo       = jsonData;
    _selectReserve    = null;
    _isCanReserve     = false;
    _isShowReserveBtn = false;

    if (date != null && JSON_NOT_EMPTY(jsonData)) {
      _isCanReserve       = _eventInfo['option'] != null && BOL(_eventInfo['option']['reserv']);
      _isShowReserveList  = !BOL(_eventInfo['option']['rev_show']) || _isManager;
      if (_isCanReserve) {
        if (JSON_NOT_EMPTY(_eventInfo['reserveData'])) {
          _eventInfo['reserveData'] = JSON_START_DAY_SORT(_eventInfo['reserveData']);
          for (var item in _eventInfo['reserveData'].entries) {
            // var time = STR(item.value['startTime']).split(':');
            // LOG('--> checkTime : ${item.value['startTime']} => $time');
            // var checkTime = DateTime(date.year, date.month, date.day, int.parse(time[0]), int.parse(time[1]));
            if (CheckCanReserve(date, INT(item.value['startDay']))) {
              _selectReserve = item.value;
              // LOG('--> refreshSelectReservItem check : $_selectReserve = ${AppData.currentDate!} / ${INT(item.value['startDay'])}');
              break;
            }
          }
          _isCanReserve = _selectReserve != null;
          _isShowReserveBtn = _isCanReserve;
          // check today reserve..
          if (date.isToday()) {
            _isShowReserveBtn = _eventInfo['option'] == null || !BOL(_eventInfo['option']['today_off']);
          }
          // check already reserved..
          if (_isShowReserveBtn) {
            _isShowReserveBtn = await api.checkReserveDay(_eventInfo['id'], AppData.USER_ID, DATE_STR(date));
          }
        }
        LOG('--> refreshSelectReservItem result : $_isCanReserve / $_isShowReserveBtn');
      }
    }
    setState(() { });
  }

  toggleStatus() {
    var title = _eventInfo['status'] == 1 ? 'Disable' : 'Enable';
    showAlertYesNoDialog(context, title.tr, '$title spot?'.tr, 'In the disable state, other users cannot see it'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
      if (value == 1) {
        if (api.checkIsExpired(_eventInfo)) {
          showAlertDialog(context, title.tr, 'Event period has ended'.tr, 'Event duration must be modified'.tr, 'OK'.tr);
          return;
        }
        api.setPlaceEventItemStatus(_eventInfo['id'], _eventInfo['status'] == 1 ? 2 : 1).then((result) {
          if (result) {
            setState(() {
              widget.eventInfo['status'] = _eventInfo['status'] == 1 ? 2 : 1;
              ShowToast(INT(widget.eventInfo['status']) == 1 ? 'Enabled'.tr : 'Disabled'.tr, Theme.of(context).primaryColor);
            });
          }
        });
      }
    });
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
      AppData.uploadEvent = _eventInfo;
      AppData.currentDate ??= DateTime.now();
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        // title: Text(widget.topTitle, style: AppBarTitleStyle(context)),
        title: Row(
          children: [
            if (widget.placeInfo != null && STR(widget.placeInfo!['pic']).isNotEmpty)...[
              showImage(widget.placeInfo!['pic'], Size(30,30)),
              SizedBox(width: 10),
              Text(STR(widget.placeInfo!['title']).toUpperCase(), style: AppBarTitleStyle(context)),
            ],
            if (widget.placeInfo == null || STR(widget.placeInfo!['pic']).isEmpty)...[
              Text(STR(widget.topTitle).isNotEmpty ? widget.topTitle.toUpperCase() : '', style: AppBarTitleStyle(context)),
            ],
          ],
        ),
        titleSpacing: 0,
        toolbarHeight: _topHeight,
        actions: [
          if (widget.isShowHome)
            GestureDetector(
              child: Icon(Icons.home),
              onTap: () {
                Navigator.of(context).pop('home');
              },
            ),
          if (widget.isShowHome && widget.isShowPlace)
            SizedBox(width: 10),
          if (widget.isShowPlace)
            GestureDetector(
              child: Icon(Icons.place_outlined),
              onTap: () async {
                AppData.placeStateKey = GlobalKey<PlaceDetailState>();
                var placeInfo = widget.placeInfo ?? await api.getPlaceFromId(_eventInfo['placeId']);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                      PlaceDetailScreen(placeInfo, null, key: AppData.placeStateKey))).then((result) {
                  if (result == 'home') {
                    Navigator.of(context).pop('home');
                    return;
                  }
                  if (result == 'deleted') {
                    ShowToast('Deleted'.tr);
                  }
                  setState(() {
                  });
                });
              },
            ),
          if (_isManager || AppData.IS_ADMIN)...[
            SizedBox(width: 15),
            GestureDetector(
              child: Icon(INT(_eventInfo['status']) == 1 ? Icons.visibility : Icons.visibility_off),
              onTap: () {
                toggleStatus();
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
                  if (_eventInfo['status'] == 1)
                    ...DropdownItems.placeItems0.map(
                          (item) =>
                          DropdownMenuItem<DropdownItem>(
                            value: item,
                            child: DropdownItems.buildItem(context, item),
                          ),
                    ),
                  if (_eventInfo['status'] != 1)
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
                  LOG("--> selected.index : ${selected.type}");
                  switch (selected.type) {
                    case DropdownItemType.enable:
                    case DropdownItemType.disable:
                      toggleStatus();
                      break;
                    case DropdownItemType.edit:
                      EditPlaceEventContent(context, _eventInfo, (result) {
                        if (result.isNotEmpty) {
                          setState(() {
                            widget.eventInfo = result;
                          });
                        }
                      });
                      break;
                    case DropdownItemType.delete:
                      showAlertYesNoDialog(context, 'Delete'.tr,
                          'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((value) {
                        if (value == 1) {
                          if (!AppData.isDevMode) {
                            showTextInputDialog(context, 'Delete confirm'.tr,
                                'Typing \'delete now\''.tr, 'Alert) Recovery is not possible'.tr, 10, null).then((result) {
                              if (result == 'delete now') {
                                api.setPlaceItemStatus(_eventInfo['id'], 0).then((result) {
                                  if (result) {
                                    widget.eventInfo['status'] = 0;
                                    Navigator.of(context).pop('deleted');
                                  }
                                });
                              }
                            });
                          } else {
                            api.setPlaceItemStatus(_eventInfo['id'], 0).then((result) {
                              if (result) {
                                widget.eventInfo['status'] = 0;
                                Navigator.of(context).pop('deleted');
                              }
                            });
                          }
                        }
                      });
                      break;
                    case DropdownItemType.promotion:
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          PromotionTabScreen('event', targetInfo: widget.eventInfo)));
                  }
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
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height - _topHeight - 10 - _botHeight,
        child: Stack(
          children: [
            ListView(
              controller: _scrollController,
              // physics: BouncingScrollPhysics(),
              children: [
                if (_eventInfo['picData'] != null && _eventInfo['picData'].isNotEmpty)...[
                  ImageScrollViewer(
                    List<dynamic>.from(_eventInfo['picData']),
                    rowHeight: MediaQuery
                        .of(context)
                        .size
                        .width,
                    showArrow: _eventInfo['picData'].length > 1,
                    showPage: _eventInfo['picData'].length > 1,
                    autoScroll: false,
                  ),
                ],
                // if (_eventInfo['imageData'] == null || _eventInfo['imageData'].isEmpty)...[
                //   showHorizontalDivider(Size(double.infinity, 1)),
                // ],
                Container(
                  padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              child: showSizedRoundImage(STR(_eventInfo['pic']), 60, 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                border: Border.all(color: COL(_eventInfo['themeColor'], defaultValue: Theme.of(context).primaryColor.withOpacity(0.5)), width: 3),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(STR(_eventInfo['title']), style: MainTitleStyle(context), maxLines: 9),
                                      ),
                                    ]
                                  ),
                                  if (widget.placeInfo != null)...[
                                    SizedBox(height: 2),
                                    Text(STR(widget.placeInfo!.title),
                                        style: ItemDescStyle(context))
                                  ]
                                ]
                              ),
                            )
                          ]
                        ),
                        if (!widget.isPreview)...[
                          SizedBox(height: 20),
                          Row(
                            children: [
                              ShareWidget(context, 'place', _eventInfo, showTitle: true),
                              SizedBox(width: 10),
                              LikeWidget(context, 'place', _eventInfo, showCount: true),
                            ]
                          ),
                        ],
                        SizedBox(height: 20),
                        if (STR(_eventInfo['desc']).isNotEmpty)...[
                          Text(DESC(_eventInfo['desc']), style: DescBodyStyle(context)),
                          SizedBox(height: 10),
                        ],
                        if (INT(_eventInfo['price']) > 0)...[
                          showHorizontalDivider(Size(double.infinity * 0.9, 40), color: LineColor(context)),
                          SubTitle(context, 'ENTRANCE FEE(site)'.tr),
                          Text('${PRICE_FULL_STR(_eventInfo['price'], _eventInfo['priceCurrency'])}', style: DescBodyPriceStyle(context)),
                        ],
                        if (JSON_NOT_EMPTY(_eventInfo['managerData']))...[
                          showHorizontalDivider(Size(double.infinity * 0.9, 40), color: LineColor(context)),
                          SubTitle(context, 'MANAGER'.tr),
                          ShowManagerList(context, _eventInfo['managerData']),
                        ],
                        if (JSON_NOT_EMPTY(_eventInfo['customData']))...[
                          showHorizontalDivider(Size(double.infinity * 0.9, 1), color: LineColor(context)),
                          ShowCustomField(context, _eventInfo['customData']),
                          SizedBox(height: 10),
                        ],
                        if (JSON_NOT_EMPTY(_eventInfo['tagData']))...[
                          TagTextList(context, List<String>.from(_eventInfo['tagData']), '#', false, null),
                          SizedBox(height: 20),
                        ],
                      ]
                    )
                  ),
                  if (JSON_NOT_EMPTY(_eventInfo['timeData']))...[
                    SizedBox(height: 30),
                    SubTitleBar(context, 'SCHEDULE'.tr),
                    ShowTimeList(_eventInfo['timeData'], currentDate: AppData.currentDate, showAddButton: false,
                      onInitialSelected: (dateTime, jsonData) {
                        LOG('--> ShowTimeList onInitialSelected : $dateTime / $jsonData');
                          refreshReservButton(dateTime, jsonData);
                      },
                      onSelected: (dateTime, jsonData) {
                        LOG('--> ShowTimeList onSelected : $dateTime / $jsonData');
                          refreshReservButton(dateTime, jsonData);
                      }
                    ),
                    SizedBox(height: 20),
                  ],
                  if (_isCanReserve && AppData.currentDate != null)...[
                    SubTitleBarEx(context, 'RESERVATION LIST'.tr, height: _subTabHeight, child: Text(DATE_STR(AppData.currentDate!), style: SubTitleStyle(context))),
                    ShowReserveListWidget(context, _eventInfo, _isManager),
                  ],
                  if (!widget.isPreview)...[
                    SubTitleBar(context, 'COMMENT'.tr, height: _subTabHeight, icon: _isOpenStoryList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, onActionSelect: (select) {
                      setState(() {
                        _isOpenStoryList = !_isOpenStoryList;
                      });
                    }),
                    if (_isOpenStoryList)...[
                      AutoScrollTag(
                        key: ValueKey(0),
                        controller: _scrollController,
                        index: 0,
                        child: CommentTabWidget(_eventInfo, 'placeEvent'),
                      ),
                    ]
                    // AutoScrollTag(
                    //   key: ValueKey(0),
                    //   controller: _scrollController,
                    //   index: 0,
                    //   child: CommentTabWidget(_eventInfo, 'placeEvent'),
                    // ),
                    // SizedBox(height: 5),
                  ],
                  SizedBox(height: _botHeight),
                ]
              ),
              if (_isShowReserveBtn && _selectReserve != null)
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      var _addItem = {
                        'status'    : 1,
                        'people'    : 1,
                        'reserveStatus': 'request',
                        'price'     : DBL(_selectReserve!['price']),
                        'currency'  : STR(_selectReserve!['currency']),
                        'title'     : STR(_eventInfo['title']),
                        'targetType': 'event',
                        'targetId'  : _eventInfo['id'],
                        'targetDate': DATE_STR(AppData.currentDate!),
                        'userId'    : AppData.USER_ID,
                        'userName'  : AppData.USER_NICKNAME,
                        'userPic'   : AppData.USER_PIC,
                      };
                      // Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(
                      //   ReservationScreen(_addItem, _selectReserve!, typeTitle: 'EVENT'.tr))).then((value) => {
                      // });
                    },
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: _botHeight,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('RESERVATION'.tr, style: ItemTitleLargeInverseStyle(context)),
                            // Text(STR(_selectReserve!['descEx']), style: ItemTitleInverseStyle(context)),
                          ]
                        )
                      ),
                    )
                  ),
                ),
            ]
          )
        )
      )
    );
  }
}
