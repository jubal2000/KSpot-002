import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:kspot_002/services/cache_service.dart';
import 'package:kspot_002/view/event/event_detail_screen.dart';
import 'package:kspot_002/view/profile/profile_target_screen.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../view_model/user_view_model.dart';
import '../../widget/bookmark_widget.dart';
import '../../widget/like_widget.dart';
import '../profile/profile_screen.dart';
import '../story/story_detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  BookmarkScreen(this.userInfo, {Key? key,
    this.isSelectable = false,
    this.isShowAppBar = true,
    this.isShowMe = false,
    this.topTitle = '',
    this.selectMax = 999}) : super(key: key);

  UserModel userInfo;
  bool isSelectable;
  bool isShowAppBar;
  bool isShowMe;
  String topTitle;
  int  selectMax;

  @override
  BookmarkState createState() => BookmarkState();
}

class BookmarkState extends State<BookmarkScreen> {
  // final _tabTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black);
  final userRepo = UserRepository();
  final userView = UserViewModel();
  final tabKeyList = List.generate(4, (index) => GlobalKey());
  Future<JSON>? _dataInit;

  initData() {
    _dataInit = userRepo.getBookmarkFromUserId(widget.userInfo.id);
  }

  refreshData() {
    setState(() {
      for (var item in tabKeyList) {
        var state = item.currentState as BookmarkTabState?;
        if (state != null && state.mounted) {
          state.refreshData();
        }
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
    userView.init(context);
    if (widget.isShowAppBar) {
      return SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            setState(() {
              // AppData.setSearchEnable(false);
            });
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.topTitle.isNotEmpty ? widget.topTitle : 'LIKE LIST'.tr, style: AppBarTitleStyle(context)),
              titleSpacing: 0,
              toolbarHeight: 50,
            ),
            body: FutureBuilder(
              future: _dataInit,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  userView.bookmarkData = snapshot.data as JSON;
                  return BookmarkTab(userView, 0, Icon(Icons.event_available, size: 16), "EVENT".tr , 'event', AppData.USER_ID, key: tabKeyList[1]);
                } else {
                  return showLoadingFullPage(context);
                }
              }
            ),
          )
        )
      );
    } else {
      return SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              // AppData.setSearchEnable(false);
            });
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: FutureBuilder(
              future: _dataInit,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  userView.bookmarkData = snapshot.data as JSON;
                  return BookmarkTab(userView, 0, Icon(Icons.event_available, size: 16), "EVENT".tr , 'event', AppData.USER_ID, key: tabKeyList[1]);
                } else {
                  return showLoadingFullPage(context);
                }
              }
            ),
          ),
        ),
      );
    }
  }
}

class BookmarkTab extends StatefulWidget {
  BookmarkTab(this.userView, this.tabIndex, this.icon, this.title, this.targetType, this.userId,
    { Key? key, this.isSelectable = false, this.isShowMe = false, this.selectMax = 999 }) : super(key: key);

  UserViewModel userView;
  int tabIndex;
  Icon icon;
  String title;
  String targetType;
  String userId;
  bool isSelectable;
  bool isShowMe;
  int selectMax;

  Widget getTab() {
    return Tab(icon: icon, iconMargin: EdgeInsets.zero, text: title, height: UI_TAB_HEIGHT.w);
  }

  @override
  BookmarkTabState createState() => BookmarkTabState();
}

class BookmarkTabState extends State<BookmarkTab> with AutomaticKeepAliveClientMixin<BookmarkTab> {
  final api = Get.find<ApiService>();
  final cache = Get.find<CacheService>();
  List<Widget> showList = [];

  @override
  bool get wantKeepAlive => true;

  refreshData() {
    showList.clear();
    JSON tmpList = JSON_CREATE_TIME_SORT_DESC(widget.userView.bookmarkData);
    for (var item in tmpList.entries) {
      if (item.value['targetType'] == widget.targetType) {
        showList.add(BookmarkItem(item.value, widget.targetType, onChanged: (action) {
          if (action == 1) {
            setState(() {
              widget.userView.bookmarkData.remove(item.key);
              refreshData();
            });
          }
        }));
      }
    }
    LOG('--> refreshData : ${showList.length} / ${widget.userView.bookmarkData.length}');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshData();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 10),
        children: showList.map((e) => e).toList()
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class BookmarkItem extends StatefulWidget {
  BookmarkItem(this.itemInfo, this.targetType, {Key? key, this.itemHeight = 70, this.onChanged}) : super(key: key);

  JSON itemInfo;
  String targetType;
  double itemHeight;
  Function(int)? onChanged;

  @override
  BookmarkItemState createState() => BookmarkItemState();
}

class BookmarkItemState extends State<BookmarkItem> {
  final userRepo = UserRepository();
  var _imageSize = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _imageSize = widget.itemHeight - 10;
    return GestureDetector(
      onTap: () async {
        switch(widget.targetType) {
          case 'event':
            var targetInfo = await userRepo.getEventFromId(STR(widget.itemInfo['targetId']));
            if (targetInfo != null) {
              Get.to(() => EventDetailScreen(targetInfo, null))!.then((result) {
                setState(() {});
              });
            } else {
              ShowToast('Can not find target'.tr);
            }
            break;
          case 'story':
            var targetInfo = await userRepo.getStoryFromId(STR(widget.itemInfo['targetId']));
            if (targetInfo != null) {
              Get.to(() => StoryDetailScreen(targetInfo))!.then((result) {
                setState(() {});
              });
            } else {
              ShowToast('Can not find target'.tr);
            }
            break;
          case 'user':
            var targetInfo = await userRepo.getUserInfo(STR(widget.itemInfo['targetId']));
            if (targetInfo != null) {
              Get.to(() => ProfileTargetScreen(targetInfo))!.then((result) {
                setState(() {});
              });
            } else {
              ShowToast('Can not find target'.tr);
            }
            break;
        }
      },
      child: Container(
        height: widget.itemHeight,
        padding: EdgeInsets.symmetric(vertical: 5),
        color: Colors.transparent,
        child: Row(
          children: [
            showSizedRoundImage(widget.itemInfo['targetPic'], _imageSize, 6),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(STR(widget.itemInfo['targetTitle']), style: ItemTitleStyle(context)),
                  SizedBox(height: 5),
                  Text(SERVER_TIME_STR(widget.itemInfo['updateTime'] ?? widget.itemInfo['createTime']), style: ItemDescStyle(context)),
                ],
              )
            ),
            BookmarkSmallWidget(context, widget.targetType,
                { 'id': STR(widget.itemInfo['targetId']),
                  'title': STR(widget.itemInfo['targetTitle']),
                  'pic': STR(widget.itemInfo['targetPic']) },
              onChangeCount: (value) {
                if (widget.onChanged != null) widget.onChanged!(1);
            }),
          ],
        ),
      )
    );
  }
}