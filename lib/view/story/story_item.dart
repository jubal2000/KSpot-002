
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../models/story_model.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/like_widget.dart';
import '../../widget/user_item_widget.dart';

class StoryCardItem extends StatefulWidget {
  StoryCardItem(this.itemData,
      {Key? key,
        this.itemPadding,
        this.itemHeight = 80,
        this.isSelectable = false,
        this.isShowTheme = true,
        this.isShowHomeButton = true,
        this.isShowPlaceButton = true,
        this.isShowUser = true,
        this.isShowLike = true,
        this.selectMax = 9,
        this.onRefresh}) : super(key: key);

  StoryModel itemData;
  bool isSelectable;
  bool isShowHomeButton;
  bool isShowPlaceButton;
  bool isShowTheme;
  bool isShowUser;
  bool isShowLike;
  int selectMax;

  double itemHeight;
  EdgeInsets? itemPadding;
  Function(JSON)? onRefresh;

  @override
  StoryCardItemState createState() => StoryCardItemState();
}

class StoryCardItemState extends State<StoryCardItem> {
  final api = Get.find<ApiService>();
  var _imageHeight = 0.0;
  var _imagePath = '';
  var _isMyItem = false;

  @override
  void initState() {
    _isMyItem = AppData.userInfo.checkOwner(widget.itemData.userId);
    super.initState();
  }

  @override
  Widget build(context) {
    widget.itemPadding ??= EdgeInsets.symmetric(vertical: 5);
    _imageHeight = widget.itemHeight - widget.itemPadding!.top - widget.itemPadding!.bottom;

    if (LIST_NOT_EMPTY(widget.itemData.picData)) {
      var firstImage = widget.itemData.picData.first;
      _imagePath = firstImage.runtimeType == String ? firstImage.toString() : firstImage.url;
    }
    LOG('--> widget.itemData : $_imagePath');

    return GestureDetector(
        onTap: () {
          // if (widget.isSelectable) {
          //   if (widget.selectMax == 1) {
          //     AppData.listSelectData.clear();
          //     AppData.listSelectData[widget.itemData['id']] = widget.itemData;
          //     Navigator.of(context).pop();
          //   } else {
          //     AppData.listSelectData[widget.itemData['id']] = widget.itemData;
          //   }
          // } else {
          //   Navigator.push(
          //       context, MaterialPageRoute(builder: (context) =>
          //       StoryDetailScreen(widget.itemData, onUpdate: (result) {
          //         setState(() {
          //           widget.itemData = result;
          //         });
          //       },))).then((result) {
          //     if (result == 'home' && Navigator.of(context).canPop()) {
          //       Navigator.of(context).pop('home');
          //       return;
          //     }
          //     if (result == 'deleted') {
          //       ShowToast('Deleted'.tr);
          //     }
          //   });
          // }
        },
        child: Container(
          height: widget.itemHeight,
          padding: widget.itemPadding,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Theme.of(context).canvasColor,
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
                              showImage(_imagePath, Size(_imageHeight, _imageHeight)),
                              if (widget.itemData.status == 2)
                                Positioned(
                                  top: 5,
                                  left: 5,
                                  child: ShadowIcon(Icons.visibility_off_outlined, 20, Colors.white, 3, 3),
                                )
                            ]
                        )
                    ),
                    SizedBox(width: 10),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    children: [
                                      if (widget.isShowTheme)...[
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.5),
                                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                      if (widget.isShowLike)...[
                                        SizedBox(width: 5),
                                        LikeWidget(context, 'event', widget.itemData.toJSON()),
                                      ],
                                      SizedBox(width: 5),
                                    ]
                                ),
                                Expanded(
                                  child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            DESC(widget.itemData.desc),
                                            style: ItemTitleExStyle(context),
                                            maxLines: 3,
                                          ),
                                        ),
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton2(
                                            customButton: Container(
                                              width: 40,
                                              height: 40,
                                              alignment: Alignment.topRight,
                                              color: Colors.transparent,
                                              child: Icon(Icons.more_vert, color: Theme.of(context).hintColor.withOpacity(0.5)),
                                            ),
                                            // customItemsHeights: const [5],
                                            items: [
                                              if (_isMyItem)
                                                ...DropdownItems.storyItems0.map(
                                                      (item) =>
                                                      DropdownMenuItem<DropdownItem>(
                                                        value: item,
                                                        child: DropdownItems.buildItem(context, item),
                                                      ),
                                                ),
                                              if (!_isMyItem)
                                                ...DropdownItems.storyItems2.map(
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
                                                  setState(() {
                                                    var status = selected.type == DropdownItemType.enable ? 1 : 2;
                                                    api.setStoryItemStatus(widget.itemData.id, status);
                                                    widget.itemData.status = status;
                                                  });
                                                  break;
                                                case DropdownItemType.edit:
                                                  // EditStoryContent(context, widget.itemData,
                                                  //     {}, false, (result) {
                                                  //       if (result.isNotEmpty) {
                                                  //         setState(() {
                                                  //           widget.itemData = result;
                                                  //           LOG('--> EditStoryContent result : $result');
                                                  //         });
                                                  //       }
                                                  //     });
                                                  break;
                                                case DropdownItemType.delete:
                                                  break;
                                                case DropdownItemType.report:
                                                  // ShowReportMenu(context, widget.itemData, 'story', menuList: [
                                                  //   {'id':'report', 'title':'Report it'},
                                                  // ]);
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
                                        ),                                ]
                                  ),
                                ),
                                Row(
                                    children: [
                                      Text(DATETIME_STR(TME(widget.itemData.createTime)), style: ItemDescExStyle(context)),
                                      Expanded(child: SizedBox(height: 1)),
                                      SizedBox(width: 10),
                                      Icon(Icons.favorite, size: 16, color: Theme.of(context).hintColor.withOpacity(0.25)),
                                      SizedBox(width: 5),
                                      Text('${widget.itemData.likeCount}', style: ItemDescExStyle(context)),
                                      SizedBox(width: 10),
                                      Icon(Icons.comment, size: 16, color: Theme.of(context).hintColor.withOpacity(0.25)),
                                      SizedBox(width: 5),
                                      Text('${widget.itemData.commentCount}', style: ItemDescExStyle(context)),
                                      SizedBox(width: 12),
                                    ]
                                )
                              ],
                            )
                        )
                    ),
                  ],
                ),
              )
          ),
        )
    );
  }
}

class StoryVerCardItem extends StatefulWidget {
  StoryVerCardItem(this.itemData,
      {Key? key,
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
        this.selectMax = 9,
        this.onRefresh}) : super(key: key);

  JSON itemData;
  bool isSelectable;
  bool isShowHomeButton;
  bool isShowPlaceButton;
  bool isShowTheme;
  bool isShowUser;
  bool isShowLike;
  AnimationController? animationController;
  int selectMax;

  double itemHeight;
  double itemWidth;
  EdgeInsets? itemPadding;
  Function(JSON)? onRefresh;

  @override
  StoryVerCardItemState createState() => StoryVerCardItemState();
}

class StoryVerCardItemState extends State<StoryVerCardItem> {
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
    }
    _imageSize = widget.itemWidth;
    _isExpired = api.checkIsExpired(widget.itemData);

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
          //     StoryDetailScreen(widget.itemData))).then((result) {
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
            borderRadius: BorderRadius.circular(widget.itemWidth / 6),
            child: Column(
              children: [
                SizedBox(
                    width: _imageSize,
                    height: _imageSize,
                    child: Stack(
                        children: [
                          showImage(STR(widget.itemData['backPic']), Size(_imageSize, _imageSize)),
                          if (INT(widget.itemData['status']) == 2)
                            ShadowIcon(Icons.visibility_off_outlined, 20, Colors.white, 3, 3),
                          if (_isExpired)
                            Center(
                                child: Text("EXPIRED".tr, style: ItemDescOutlineStyle(context))
                            ),
                          if (widget.isSelectable)
                            TopLeftAlign(
                              child: Icon(Icons.arrow_forward_ios, color: AppData.listSelectData.containsKey(widget.itemData['id']) ?
                              Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                            ),
                          if (widget.isShowLike)
                            TopRightAlign(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: LikeWidget(context, 'event', widget.itemData),
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