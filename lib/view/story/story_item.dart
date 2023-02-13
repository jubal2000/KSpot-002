
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/place_model.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/comment_widget.dart';
import '../../widget/image_scroll_viewer.dart';
import '../../widget/like_widget.dart';
import '../../widget/share_widget.dart';
import '../../widget/user_item_widget.dart';
import '../place/place_detail_screen.dart';
import '../profile/target_profile.dart';

class MainStoryItem extends StatefulWidget {
  MainStoryItem(this.itemInfo, {Key? key, this.index = 0,
    this.itemHeight = 60, this.bottomSpace = 20, this.isFullScreen = false, this.onItemVisible, this.onItemDeleted}) : super(key: key);

  StoryModel itemInfo;
  double itemHeight;
  double bottomSpace;
  bool isFullScreen;
  int index;

  Function(int, bool)? onItemVisible;
  Function(int)? onItemDeleted;

  getKey() {
    return itemInfo.id;
  }

  @override
  MainStoryItemState createState() => MainStoryItemState();
}

class MainStoryItemState extends State<MainStoryItem> with AutomaticKeepAliveClientMixin<MainStoryItem> {
  final api = Get.find<ApiService>();
  Future<JSON>? _commentInit;
  JSON _commentList = {};
  List<Widget> _commentListWidget = [];
  var _isOpenComment = false;
  var _isMyStory = false;
  var _height = 100.0;

  final _imageKey = GlobalKey();

  loadCommentList() {
    _commentInit = api.getCommentFromTargetId('story', widget.itemInfo.id);
  }

  refreshData(JSON uploadData) {
    setState(() {
      _commentList[uploadData['id']] = uploadData;
      refreshCommentList();
    });
  }

  loadVideoData() {
    if (!mounted) return;
    LOG('--> loadVideoData : MainStoryItem');
    var state = _imageKey.currentState as ImageScrollViewerState;
    state.videoLoading();
  }

  refreshCommentList() {
    LOG('--> refreshCommentList : ${_commentList.length}');
    _commentListWidget = [];
    if (_commentList.length > 1) {
      _commentList = JSON_CREATE_TIME_SORT_DESC(_commentList);
    }
    for (var item in _commentList.entries) {
      _commentListWidget.add(StoryCommentItem(item.value));
    }
  }

  showUserWidget() {
    return UserCardWidget(
        widget.itemInfo.toJson(),
        faceCircleSize: 2,
        onProfileChanged: (result) {
          LOG('--> UserCardWidget onProfileChanged : $result');
          // widget.itemInfo['userName'] = result['userName'];
          // widget.itemInfo['userPic' ] = result['userPic' ];
          api.setStoryItemUserInfo(widget.itemInfo.id, result);
        },
        onSelected: (_) async {
          var userInfo = await api.getUserInfoFromId(widget.itemInfo.userId);
          if (JSON_NOT_EMPTY(userInfo)) {
            Get.to(() => TargetProfileScreen(UserModel.fromJson(userInfo!)))!.then((value) {

            });
          } else {
            showUserAlertDialog(context, '${widget.itemInfo.userId}');
          }
        }
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loadCommentList();
    _isMyStory = widget.itemInfo.userId == AppData.USER_ID;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (!widget.isFullScreen) {
            // Get.to(() => StoryDetailScreen(widget.itemInfo));
          }
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: widget.isFullScreen ? 0 : 15),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            boxShadow: [
              if (!widget.isFullScreen)
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 5,
                  offset: Offset(0, 5), // Shadow position
                ),
            ],
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.only(top: widget.isFullScreen ? 5 : 10, left: 5, bottom: 10),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          showUserWidget(),
                          Expanded(child: SizedBox(height: 1)),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    customButton: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.topRight,
                                      color: Colors.transparent,
                                      child: Icon(Icons.more_vert, color: Theme.of(context).hintColor.withOpacity(0.5)),
                                    ),
                                    // customItemsIndexes: const [1],
                                    // customItemsHeight: 20,
                                    items: [
                                      if (_isMyStory && widget.itemInfo.status == 1)
                                        ...DropdownItems.storyItems0.map(
                                              (item) =>
                                              DropdownMenuItem<DropdownItem>(
                                                value: item,
                                                child: DropdownItems.buildItem(context, item),
                                              ),
                                        ),
                                      if (_isMyStory && widget.itemInfo.status != 1)
                                        ...DropdownItems.storyItems1.map(
                                              (item) =>
                                              DropdownMenuItem<DropdownItem>(
                                                value: item,
                                                child: DropdownItems.buildItem(context, item),
                                              ),
                                        ),
                                      if (!_isMyStory)
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
                                            api.setStoryItemStatus(widget.itemInfo.id, status);
                                            widget.itemInfo.status = status;
                                          });
                                          break;
                                        case DropdownItemType.edit:
                                          // EditStoryContent(context, widget.itemInfo,
                                          //     {}, false, (result) {
                                          //       if (result.isNotEmpty) {
                                          //         setState(() {
                                          //           widget.itemInfo = result;
                                          //           LOG('--> EditStoryContent result : $result');
                                          //         });
                                          //       }
                                          //     });
                                          break;
                                        case DropdownItemType.delete:
                                          // showAlertYesNoDialog(context, 'Delete'.tr, 'Are you sure you want to delete it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
                                          //   if (result == 1) {
                                          //     api.deleteStoryItem(widget.itemInfo.id).then((result) {
                                          //       if (result) {
                                          //         if (widget.onItemDeleted != null) widget.onItemDeleted!(INT(widget.itemInfo['index']));
                                          //       }
                                          //     });
                                          //   }
                                          // });
                                          break;
                                        case DropdownItemType.report:
                                          // ShowReportMenu(context, widget.itemInfo, 'story', menuList: [
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
                                ),
                                // GestureDetector(
                                //   onTap: () {
                                //
                                //   },
                                //   child: Container(
                                //     width: 30,
                                //     height: 40,
                                //     color: Colors.transparent,
                                //     alignment: Alignment.topRight,
                                //     child: Icon(Icons.more_vert, size: 20)),
                                // ),
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text(SERVER_TIME_STR(widget.itemInfo.updateTime),
                                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
                                ),
                              ]
                          ),
                        ]
                    )
                ),
                VisibilityDetector(
                    key: GlobalKey(),
                    onVisibilityChanged: (info) {
                      if (widget.onItemVisible != null) widget.onItemVisible!(widget.index, info.visibleFraction > 0);
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width - 30,
                        height: MediaQuery.of(context).size.width - 30,
                        // padding: EdgeInsets.symmetric(horizontal: 5),
                        // decoration: BoxDecoration(
                        //   border: Border.all(
                        //     width: 2,
                        //     color: Colors.white10,
                        //   ),
                        // ),
                        child: Stack(
                            children: [
                              ImageScrollViewer(
                                List<dynamic>.from(widget.itemInfo.getPicDataList),
                                key: _imageKey,
                                rowHeight: MediaQuery.of(context).size.width - 45,
                                showArrow: false,
                                showPage: true,
                                autoScroll: false,
                                imageFit: BoxFit.fill,
                                onSelected: (selectedId) {
                                  LOG('--> ImageScrollViewer select item [${widget.isFullScreen}]: ${widget.itemInfo.getPicDataList.length}');
                                  showImageSlideDialog(context,
                                      List<String>.from(widget.itemInfo.getPicDataList.map((item) {
                                        LOG('--> imageData item : ${item.runtimeType} / $item');
                                        return item.runtimeType == String ? STR(item) : item['backPic'] ?? item['image'];
                                      }).toList()), 0, true);
                                },
                              ),
                              if (widget.itemInfo.status != 1)
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: ShadowIcon(Icons.visibility_off_outlined, 30, Colors.white, 3, 3),
                                )
                            ]
                        )
                    )
                ),
                SizedBox(height: 10),
                if (widget.itemInfo.desc.isNotEmpty)...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    child: Text(DESC(widget.itemInfo.desc), style: ItemDescStyle(context)),
                  ),
                ],
                FutureBuilder(
                    future: _commentInit,
                    builder: (context, snapshot) {
                      if (snapshot.hasData || _commentList.isNotEmpty) {
                        if (_commentList.isEmpty) {
                          _commentList = snapshot.data as JSON;
                          refreshCommentList();
                        }
                        return Column(
                            children: [
                              if (_commentList.isNotEmpty)...[
                                SizedBox(height: 5),
                                Container(
                                    padding: EdgeInsets.all(5),
                                    constraints: BoxConstraints(
                                      maxHeight: widget.isFullScreen ? double.infinity : _height,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      // physics: !widget.isFullScreen ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: _commentList.length,
                                      itemBuilder: (context, index) {
                                        var key = _commentList.keys.elementAt(index);
                                        var item = _commentList[key];
                                        return StoryCommentItem(item);
                                      },
                                    )
                                ),
                              ]
                            ]
                        );
                      } else {
                        return showLoadingImageSquare(_height);
                      }
                    }
                ),
                if (!widget.isFullScreen)
                  showCommentMenu(context, widget.itemInfo.toJson(), true, 0, (uploadData) {
                    setState(() {
                      _commentList[uploadData['id']] = uploadData;
                      refreshCommentList();
                    });
                  },
                      align: CrossAxisAlignment.end),
                SizedBox(height: widget.isFullScreen ? 60 : 2),
              ]
          ),
        )
    );
  }
}


Widget showCommentMenu(BuildContext context, JSON itemInfo, bool showParent, double padding, Function(JSON) onCommentAdded,
    { var align = CrossAxisAlignment.center, Function(JSON)? onUpdate }) {
  final api = Get.find<ApiService>();
  JSON uploadData = {
    "status":       1,
    "desc":         '',
    "imageData":    [],
    "targetType":   'story',
    "targetTitle":  '',
    "targetId":     itemInfo['id'],
    "userId":       AppData.USER_ID,
    "userName":     AppData.USER_NICKNAME,
    "userPic":      AppData.USER_PIC,
  };
  return GestureDetector(
    onTap: () {
      showEditCommentDialog(context, CommentType.story, 'Comment'.tr, uploadData, const {}, false, false, false).then((result) {
        if (result.isNotEmpty) {
          onCommentAdded(result);
          itemInfo['comments'] = INT(result['comments']);
          if (onUpdate != null) onUpdate(itemInfo);
        }
      });
    },
    child: Container(
      width: MediaQuery.of(context).size.width - padding,
      padding: EdgeInsets.symmetric(vertical: 5),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: align,
        children: [
          Text('COMMENT+'.tr, style: SubTitleStyle(context)),
          Expanded(child: SizedBox(height: 1)),
          ShareWidget(context, 'story', itemInfo, showTitle: true, title: 'SHARE'.tr),
          LikeWidget(context, 'story', itemInfo, showCount: true, onChangeCount: (value) {
            itemInfo['likes'] = value;
            if (onUpdate != null) onUpdate(itemInfo);
          }),
          if (showParent)...[
            SizedBox(width: 5),
            GestureDetector(
              onTap: () async {
                if (STR(itemInfo['targetType']) == 'place') {
                  var placeInfo = await api.getPlaceFromId(itemInfo['targetId']);
                  if (placeInfo != null) {
                    Get.to(() => PlaceDetailScreen(PlaceModel.fromJson(placeInfo), null, isShowHome: false))!.then((result) {
                    });
                  }
                } else {
                  var eventInfo = await api.getEventFromId(itemInfo['targetId']);
                  // if (eventInfo != null) {
                  //   Get.to(() => EventDetailScreen(PlaceModel.fromJson(eventInfo), null, isShowHome: false))!.then((result) {
                  //   });
                  // }
                }
              },
              child: Container(
                width: 40,
                height: 40,
                color: Colors.transparent,
                margin: EdgeInsets.only(right: 5, bottom: 5),
                child: Icon(STR(itemInfo['targetType']) == 'place' ? Icons.place_outlined : Icons.event_available,
                    size: 45, color: Theme.of(context).primaryColor.withOpacity(0.5)),
              ),
            )
          ]
        ],
      ),
    ),
  );
}

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
      var firstImage = widget.itemData.picData!.first;
      _imagePath = firstImage.runtimeType == String ? firstImage.toString() : firstImage.url;
    }
    LOG('--> widget.itemData : $_imagePath');

    return GestureDetector(
        onTap: () {
          // if (widget.isSelectable) {
          //   if (widget.selectMax == 1) {
          //     AppData.listSelectData.clear();
          //     AppData.listSelectData[widget.itemData.id] = widget.itemData;
          //     Navigator.of(context).pop();
          //   } else {
          //     AppData.listSelectData[widget.itemData.id] = widget.itemData;
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
                                        LikeWidget(context, 'event', widget.itemData.toJson()),
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