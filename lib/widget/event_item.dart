
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/data/dialogs.dart';
import 'package:kspot_002/widget/bookmark_widget.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../models/place_model.dart';
import '../repository/event_repository.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../view_model/event_detail_view_model.dart';
import 'like_widget.dart';
import 'user_item_widget.dart';
import '../view/event/event_edit_screen.dart';

class EventCardItem extends StatefulWidget {
  EventCardItem(this.itemData,
      {Key? key,
        this.placeData,
        this.animationController,
        this.itemPadding,
        this.itemHeight = 90,
        this.isSelectable = false,
        // this.isShowTheme = true,
        this.isShowHomeButton = true,
        this.isShowPlaceButton = true,
        this.isShowUser = true,
        this.isShowLike = false,
        this.isPromotion = false,
        this.isMyItem = false,
        this.isExpired = false,
        this.isShowBookmark = true,
        this.selectMax = 9,
        this.onShowDetail,
        this.onRefresh}) : super(key: key);

  EventModel itemData;
  PlaceModel? placeData;
  bool isSelectable;
  bool isShowHomeButton;
  bool isShowPlaceButton;
  // bool isShowTheme;
  bool isShowUser;
  bool isShowLike;
  bool isPromotion;
  bool isMyItem;
  bool isExpired;
  bool isShowBookmark;
  int selectMax;

  double itemHeight;
  EdgeInsets? itemPadding;
  Function(JSON)? onRefresh;
  Function(String, int)? onShowDetail;
  AnimationController? animationController;

  @override
  EventCardItemState createState() => EventCardItemState();
}

class EventCardItemState extends State<EventCardItem> {
  final eventRepo = EventRepository();
  final api = Get.find<ApiService>();
  var _imageHeight = 0.0;
  List<JSON> _userListData = [];

  toggleEventShowStatus(context) {
    var title = widget.itemData.showStatus == 1 ? 'Disable' : 'Enable';
    showAlertYesNoDialog(context, title.tr, '$title event?'.tr, 'In the disable state, other users cannot see it'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
      if (value == 1) {
        if (eventRepo.checkIsExpired(widget.itemData)) {
          showAlertDialog(context, title.tr, 'Event period has ended'.tr, 'Event duration must be modified'.tr, 'OK'.tr);
          return;
        }
        eventRepo.setEventShowStatus(widget.itemData.id, widget.itemData.showStatus == 1 ? 0 : 1).then((result) {
          if (result) {
            setState(() {
              widget.itemData.showStatus = widget.itemData.showStatus == 1 ? 0 : 1;
              ShowToast(widget.itemData.showStatus == 1 ? 'Enabled'.tr : 'Disabled'.tr);
              if (widget.onRefresh != null) widget.onRefresh!(widget.itemData.toJson());
            });
          }
        });
      }
    });
  }

  moveToEventEdit() {
    Get.to(() => EventEditScreen(eventInfo: widget.itemData, placeInfo: widget.placeData))!.then((result) {
      if (result != null) {
        setState(() {
          widget.itemData = result;
          LOG('--> EventEditScreen result : ${widget.itemData.title}');
          if (widget.onRefresh != null) widget.onRefresh!(widget.itemData.toJson());
        });
      }
    });
  }

  deleteEvent(context) {
    showAlertYesNoDialog(context, 'Delete'.tr,
      'Are you sure you want to delete it?'.tr, 'Alert) Recovery is not possible'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
      if (value == 1) {
        // showTextInputDialog(context, 'Delete confirm'.tr,
        //     'Typing \'delete now\''.tr, 'Alert) Recovery is not possible'.tr, 10, null).then((result) {
        //   if (result.toLowerCase() == 'delete now') {
            eventRepo.setEventStatus(widget.itemData.id, 0).then((result) {
              if (result) {
                setState(() {
                  widget.itemData.status = 0;
                  if (widget.onRefresh != null) widget.onRefresh!(widget.itemData.toJson());
                });
              }
            });
        //   }
        // });
      }
    });
  }

  @override
  Widget build(context) {
    widget.itemPadding ??= EdgeInsets.symmetric(vertical: 5);
    _imageHeight = widget.itemHeight - widget.itemPadding!.top - widget.itemPadding!.bottom;
    _userListData.clear();
    if (JSON_NOT_EMPTY(widget.itemData.managerData)) {
      for (var item in widget.itemData.managerData!) {
        _userListData.add(item.toJson());
        // List<JSON>.from(widget.itemData['managerData'].entries.map((key, value) => JSON.from(value)).toList());
      }
    } else if (STR(widget.itemData.userId).isNotEmpty) {
      _userListData.add(widget.itemData.toJson());
    }
    final timeData = widget.itemData.getDateTimeData(AppData.currentDate);
    return GestureDetector(
        onTap: () {
          unFocusAll(context);
          if (widget.onShowDetail != null) widget.onShowDetail!(widget.itemData.id, 0);
        },
        child: Container(
          height: widget.itemHeight,
          padding: widget.itemPadding,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ColorFiltered(
              colorFilter: !widget.isExpired && widget.itemData.showStatus == 1 ? ColorFilter.mode(
                Colors.transparent,
                BlendMode.multiply,
              ) : ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(widget.isShowUser ? 20 : 0)),
                  color: Theme.of(context).canvasColor,
                ),
                child: Row(
                  children: [
                    // showSizedImage(item.value['pic'] ?? _placeInfo['pic'], _height - _padding * 2),
                    if (widget.isSelectable)...[
                      Icon(Icons.arrow_forward_ios, color: AppData.listSelectData.containsKey(widget.itemData.id) ?
                      Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      SizedBox(width: 5),
                    ],
                    SizedBox(
                      width: _imageHeight,
                      height: _imageHeight,
                      child: Stack(
                        children: [
                          // if (widget.animationController != null)
                          //   ScaleTransition(
                          //     scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(
                          //         parent: widget.animationController!,
                          //         curve: Curves.linear)
                          //     ),
                          //     child: showImage(STR(widget.itemData['pic']), Size(_imageHeight, _imageHeight)),
                          //   ),
                          // if (widget.animationController == null)
                          showImage(widget.itemData.pic, Size(_imageHeight, _imageHeight)),
                          if (widget.itemData.showStatus == 0)
                            OutlineIcon(Icons.visibility_off_outlined, 20, Colors.white, x:3, y:3),
                          if (widget.isExpired)
                            Center(
                                child: Text("EXPIRED".tr, style: ItemDescOutlineStyle(context))
                            )
                        ]
                      )
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // if (widget.isShowTheme)...[
                                //   Container(
                                //     width: 12,
                                //     height: 12,
                                //     decoration: BoxDecoration(
                                //       color: Theme.of(context).primaryColor.withOpacity(0.5),
                                //       borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                //     ),
                                //   ),
                                //   SizedBox(width: 5),
                                // ],
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(STR(widget.itemData.title), style: ItemTitleStyle(context), maxLines: 1),
                                      if (widget.isPromotion)...[
                                        SizedBox(width: 2),
                                        Icon(Icons.star, size: 20, color: Theme.of(context).colorScheme.tertiary),
                                      ]
                                    ],
                                  ),
                                ),
                                if (!widget.isSelectable && widget.isShowLike)...[
                                  SizedBox(width: 5),
                                  LikeSmallWidget(context, 'event', widget.itemData.toJson()),
                                ],
                                if (widget.isShowBookmark)...[
                                  SizedBox(width: 5),
                                  BookmarkWidget(context, 'event', widget.itemData.toJson()),
                                ],
                            ]
                          ),
                          Expanded(child:
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(timeData != null ? timeData.title : '', style: ItemDescExStyle(context)),
                                        Text(timeData != null ? timeData.desc  : '', style: ItemDescExStyle(context), maxLines: 3),
                                      ],
                                    ),
                                  ),
                                ),
                                if (widget.isShowUser && _userListData.isNotEmpty)
                                  UserIdCardWidget(_userListData),
                              ]
                            )
                          )
                        ],
                      )
                    )
                  ),
                  if (widget.isMyItem)
                  DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      customButton: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.centerRight,
                        color: Colors.transparent,
                        child: Icon(Icons.more_vert, color: Theme.of(context).hintColor.withOpacity(0.5)),
                      ),
                      // customItemsHeights: const [5],
                      items: [
                        if (widget.itemData.showStatus == 1)
                          ...DropdownItems.storyItems0.map(
                                (item) => DropdownMenuItem<DropdownItem>(
                              value: item,
                              child: DropdownItems.buildItem(context, item),
                            ),
                          ),
                        if (widget.itemData.showStatus == 0)
                          ...DropdownItems.storyItems1.map(
                                (item) => DropdownMenuItem<DropdownItem>(
                              value: item,
                              child: DropdownItems.buildItem(context, item),
                            ),
                          ),
                        // if (!widget.isMyItem)
                        //   ...DropdownItems.storyItems2.map(
                        //         (item) =>
                        //         DropdownMenuItem<DropdownItem>(
                        //           value: item,
                        //           child: DropdownItems.buildItem(context, item),
                        //         ),
                        //   ),
                      ],
                      onChanged: (value) {
                        var selected = value as DropdownItem;
                        LOG("--> selected.index : ${selected.type}");
                        switch (selected.type) {
                          case DropdownItemType.enable:
                          case DropdownItemType.disable:
                            toggleEventShowStatus(context);
                            break;
                          case DropdownItemType.edit:
                            moveToEventEdit();
                            break;
                          case DropdownItemType.delete:
                            deleteEvent(context);
                            break;
                        }
                      },
                      itemHeight: 45,
                      dropdownWidth: 190,
                      buttonHeight: 22,
                      buttonWidth: 22,
                      itemPadding: const EdgeInsets.all(10),
                      offset: const Offset(0, 5),
                    ),
                  ),
                ],
              ),
            )
          ),
        )
      )
    );
  }
}

class PlaceEventVerCardItem extends StatefulWidget {
  PlaceEventVerCardItem(this.itemData,
      {Key? key,
        this.placeData,
        this.animationController,
        this.itemPadding = const EdgeInsets.symmetric(vertical: 5),
        this.itemHeight = 120,
        this.itemWidth = 60,
        this.isSelectable = false,
        this.isShowTheme = true,
        this.isShowHomeButton = true,
        this.isShowPlaceButton = true,
        this.isShowUser = true,
        this.isShowLike = true,
        this.isPromotion = false,
        this.selectMax = 9,
        this.onRefresh}) : super(key: key);

  JSON itemData;
  JSON? placeData;
  bool isSelectable;
  bool isShowHomeButton;
  bool isShowPlaceButton;
  bool isShowTheme;
  bool isShowUser;
  bool isShowLike;
  AnimationController? animationController;
  int selectMax;
  bool isPromotion;

  double itemHeight;
  double itemWidth;
  EdgeInsets? itemPadding;
  Function(JSON)? onRefresh;

  @override
  PlaceEventVerCardItemState createState() => PlaceEventVerCardItemState();
}

class PlaceEventVerCardItemState extends State<PlaceEventVerCardItem> {
  final api = Get.find<ApiService>();
  var _imageSize = 0.0;
  var _isExpired = false;
  final List<JSON> _userListData = [];

  @override
  Widget build(context) {
    _userListData.clear();
    if (JSON_NOT_EMPTY(widget.itemData['managerData'])) {
      for (var item in widget.itemData['managerData'].entries) {
        _userListData.add(item.value as JSON);
        // List<JSON>.from(widget.itemData['managerData'].entries.map((key, value) => JSON.from(value)).toList());
      }
    } else if (STR(widget.itemData['userId']).isNotEmpty) {
      _userListData.add(widget.itemData);
    }
    _imageSize = widget.itemWidth;
    _isExpired = api.checkEventExpired(widget.itemData);
    return GestureDetector(
      onTap: () {
        if (widget.isSelectable) {
          if (widget.selectMax == 1) {
            AppData.listSelectData.clear();
            AppData.listSelectData[widget.itemData['id']] = widget.itemData;
            Navigator.of(context).pop();
          } else {
            AppData.listSelectData[widget.itemData['id']] = widget.itemData;
          }
        } else {
          unFocusAll(context);
          // AppData.uploadEvent = widget.itemData;
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) =>
          //     EventDetailScreen(widget.itemData, widget.placeData,
          //         isShowHome: widget.isShowHomeButton, isShowPlace: widget.isShowPlaceButton))).then((result) {
          //   if (result == 'home' && Navigator.of(context).canPop()) {
          //     Navigator.of(context).pop('home');
          //     return;
          //   }
          //   if (result == 'deleted') {
          //     ShowToast('Deleted'.tr);
          //   }
          //   setState(() {
          //     widget.itemData = AppData.uploadEvent;
          //     // if (widget.onRefresh != null) widget.onRefresh!(AppData.uploadEvent);
          //   });
          // });
        }
      },
      child: Container(
          height: widget.itemHeight,
          width: widget.itemWidth,
          margin: widget.itemPadding,
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.itemWidth / 12),
            child: Column(
              children: [
                SizedBox(
                    width: _imageSize,
                    height: _imageSize,
                    child: Stack(
                        children: [
                          showImage(STR(widget.itemData['pic']), Size(_imageSize, _imageSize)),
                          if (INT(widget.itemData['status']) == 2)
                            OutlineIcon(Icons.visibility_off_outlined, 20, Colors.white, x:3, y:3),
                          if (_isExpired)
                            Center(
                                child: Text("EXPIRED".tr, style: ItemDescOutlineStyle(context))
                            ),
                          if (widget.isSelectable)
                            TopLeftAlign(
                              child: Icon(Icons.arrow_forward_ios, color: AppData.listSelectData.containsKey(widget.itemData['id']) ?
                              Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                            ),
                          BottomRightAlign(
                              child: Container(
                                  height: 35,
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (widget.isPromotion)
                                        Icon(Icons.star, size: 26, color: Theme.of(context).colorScheme.secondary),
                                      if (widget.isShowLike)
                                        LikeWidget(context, 'event', widget.itemData),
                                    ],
                                  )
                              )
                          ),
                        ]
                    )
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(5),
                        color: Theme.of(context).canvasColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                children: [
                                  if (widget.isShowTheme && widget.itemData['themeColor'] != null)...[
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: COL(widget.itemData['themeColor'], defaultValue: Theme.of(context).primaryColor.withOpacity(0.5)),
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                ]
                            ),
                            if (STR(widget.itemData['title']).isNotEmpty)
                            // Expanded(
                            //   child: Row(
                            //     children: [
                            //       Text(STR(widget.itemData['title']), style: ItemTitleStyle(context), maxLines: 1),
                            //       if (widget.isPromotion)...[
                            //         SizedBox(width: 2),
                            //         Icon(Icons.star, size: 20, color: Theme.of(context).colorScheme.secondary),
                            //       ]
                            //     ],
                            //   ),
                            // ),
                              RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(text: STR(widget.itemData['title']), style: ItemTitleStyle(context)),
                                  maxLines: 3),
                            if (STR(widget.itemData['title']).isEmpty && STR(widget.itemData['desc']).isNotEmpty)
                              RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(text: DESC(widget.itemData['desc']), style: ItemDescStyle(context)),
                                  maxLines: 3),
                            if (JSON_NOT_EMPTY(widget.itemData['timeData']))
                              RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: EVENT_TIMEDATA_TITLE_TIME_STR(widget.itemData['timeData']),
                                    style: ItemDescExStyle(context),
                                  )
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (widget.isShowUser && _userListData.isNotEmpty)
                                  UserIdCardWidget(_userListData, isCanExtend: false),

                              ],
                            ),
                          ],
                        )
                    )
                ),
              ],
            ),
          )
      ),
    );
  }
}