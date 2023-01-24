import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../data/app_data.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';

class FollowScreen extends StatefulWidget {
  FollowScreen(this.userInfo, {Key? key,
    this.isSelectable = false,
    this.isShowAppBar = true,
    this.isShowMe = false,
    this.topTitle = '',
    this.selectMax = 9}) : super(key: key);

  JSON userInfo;
  bool isSelectable;
  bool isShowAppBar;
  bool isShowMe;
  String topTitle;
  int  selectMax;

  @override
  FollowScreenState createState() => FollowScreenState();
}

class FollowScreenState extends State<FollowScreen> {
  // final _tabTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black);
  List<FollowTab>? _tabList;

  refreshTab() {
    debugPrint('--> refreshTab : ${widget.userInfo['followData'].length} / ${widget.userInfo['followData']}');
    _tabList = [
      FollowTab(0, "FOLLOW".tr  , widget.userInfo['followData'] ?? {}, isShowMe: widget.isShowMe, isSelectable: widget.isSelectable, selectMax: widget.selectMax),
      FollowTab(1, "FOLLOWER".tr, widget.userInfo['followData'] ?? {}, isShowMe: widget.isShowMe, isSelectable: widget.isSelectable, selectMax: widget.selectMax),
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshTab();
    if (widget.isShowAppBar) {
      return SafeArea(
          child: GestureDetector(
              onTap: () {
                setState(() {
                  AppData.setSearchEnable(false);
                });
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.topTitle.isNotEmpty ? widget.topTitle : 'FOLLOW LIST', style: AppBarTitleStyle(context)),
                  titleSpacing: 0,
                  toolbarHeight: 50,
                  // actions: [
                  //   if (widget.isShowMe)...[
                  //     GestureDetector(
                  //       child: Column(
                  //         children: [
                  //           Icon(Icons.account_circle_outlined),
                  //           SizedBox(height: 2),
                  //           Text('Can Select Me', style: ItemDescExStyle(context)),
                  //         ],
                  //       ),
                  //     )
                  //   ]
                  // ],
                ),
                body: DefaultTabController(
                  length: _tabList!.length,
                  child: Scaffold(
                    appBar: AppBar(
                      toolbarHeight: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      bottom: TabBar(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        labelColor: Theme.of(context).colorScheme.primary,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                        tabs: _tabList!.map((item) => item.getTab()).toList(),
                      ),
                    ),
                    body: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: _tabList!,
                    )
                  ),
                ),
              )
          )
      );
    } else {
      return SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              AppData.setSearchEnable(false);
            });
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: DefaultTabController(
              length: _tabList!.length,
              child: Scaffold(
                appBar: TabBar(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  labelColor: Theme.of(context).colorScheme.primary,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                  tabs: _tabList!.map((item) => item.getTab()).toList(),
                  onTap: (value) {
                    AppData.setSearchEnable(false);
                  },
                ),
                body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: _tabList!
                ),
              ),
            ),
          )
        )
      );
    }
  }
}

class FollowTab extends StatefulWidget {
  final api = Get.find<ApiService>();
  FollowTab(this.selectedTab, this.title, this.followData, { Key? key, this.isSelectable = false, this.isShowMe = false, this.selectMax = 9 }) : super(key: key);

  int selectedTab;
  String title;
  JSON followData;
  bool isSelectable;
  bool isShowMe;
  int selectMax;

  Widget getTab() {
    return Tab(text: title, height: 40);
  }

  @override
  FollowTabState createState() => FollowTabState();
}

class FollowTabState extends State<FollowTab> {
  final api = Get.find<ApiService>();
  final _scrollController = PageController(viewportFraction: 1, keepPage: true);
  List<JSON> _itemList = [];
  String _searchText = '';

  onSearchEdited(String text, int status) {
    setState(() {
      _searchText = text;
      refreshList();
      if (status == 1) {
        var state = AppData.searchWidgetKey[SearchKeys.follow0.index + widget.selectedTab].currentState as SearchWidgetState;
        state.clearFocus();
      }
    });
  }

  refreshList() {
    LOG('--> refreshList : ${widget.isShowMe} / ${widget.followData.entries.length}');
    _itemList.clear();
    if (widget.isShowMe) {
      _itemList.add({
        'userId'    : AppData.USER_ID,
        'userPic'   : AppData.USER_PIC,
        'userName'  : AppData.USER_NICKNAME,
        'targetId'  : AppData.USER_ID,
        'targetPic' : AppData.USER_PIC,
        'targetName': AppData.USER_NICKNAME,
      });
    }
    for (var item in widget.followData.entries) {
      var isOwner = CheckOwner(item.value['userId']);
      if (!AppData.blockList.containsKey(STR(item.value['targetId'])) &&
          !AppData.blockList.containsKey(STR(item.value['userId']))) {
        if ((widget.selectedTab == 0 && isOwner) || (widget.selectedTab == 1 && !isOwner)) {
          LOG('--> _searchText : $_searchText / $isOwner : ${item.value['targetName']}');
          if (_searchText.isEmpty
              || (isOwner && STR(item.value['targetName']).toString().toLowerCase().contains(_searchText.toLowerCase()))
              || (!isOwner && STR(item.value['userName']).toString().toLowerCase().contains(_searchText.toLowerCase()))
          ) {
            LOG('--> add : ${item.value}');
            _itemList.add(item.value);
          }
        }
      }
    }
  }

  onMenuSelected(DropdownItemType menu, String id, JSON userInfo) {
    LOG('--> onMenuSelected : $menu');
    switch (menu) {
      case DropdownItemType.message:
        JSON uploadData = {
          "status":       1,
          "desc":         '',
          "imageData":    [],
          "targetId":     userInfo['id'],
          "targetName":   userInfo['nickName'],
          "targetPic":    userInfo['pic'],
          "senderId":     AppData.userInfo['id'],
          "senderName":   AppData.userInfo['nickName'],
          "senderPic":    AppData.userInfo['pic'],
          "createTime":   CURRENT_SERVER_TIME(),
        };
        LOG('--> showEditCommentDialog pushToken : ${STR(userInfo['pushToken'])}');
        showEditCommentDialog(context, CommentType.message, 'To. ${STR(userInfo['nickName'])}', uploadData, userInfo, false, true, false).then((result) {
          LOG('--> showEditCommentDialog comment result : $result');
          if (result.isNotEmpty) {
            setState(() {

            });
          }
        });
        break;
      case DropdownItemType.unfollow:
        showAlertYesNoDialog(context, 'Follow cancel'.tr,
            'Are you sure you want to unfollow?'.tr, '${userInfo['nickName']}', 'Cancel'.tr, 'OK'.tr).then((value) {
          if (value == 1) {
            debugPrint('--> AppData.USER_FOLLOW : ${AppData.USER_FOLLOW.length}');
            api.setFollowStatus(userInfo['id'], 0).then((value) {
              setState(() {
                debugPrint('--> AppData.USER_FOLLOW after : ${AppData.USER_FOLLOW.length}');
                refreshList();
              });
            });
          }
        });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshList();
    debugPrint('--> list show : ${_itemList.length} / ${widget.isShowMe}');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 10),
          if (widget.isSelectable)...[
            Container(
              width: double.infinity,
              height: 40,
              color: Theme.of(context).errorColor.withOpacity(0.5),
              child: Center(
                child: Text(widget.selectMax == 1 ? 'Please select a target'.tr : 'Please select targets'.tr, style: ItemTitleAlertStyle(context)),
              )
            )
          ],
          SearchWidget(
            key: AppData.searchWidgetKey[SearchKeys.follow0.index + widget.selectedTab],
            isShowList: false,
            padding: EdgeInsets.zero,
            onEdited: onSearchEdited,
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            child: Column(
              children: _itemList.map((item) => FollowListItem(item, isFollowing: CheckOwner(item['userId']),
                isSelectable: widget.isSelectable,
                isShowMenu: widget.selectedTab == 0,
                selectMax: widget.selectMax,
                onMenuSelected: onMenuSelected,
              )).toList(),
            )
            // ListView.builder(
            //       scrollDirection: Axis.vertical,
            //       controller: _scrollController,
            //       itemCount: _itemList!.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         var key = _itemList!.keys.elementAt(index);
            //         return _itemList![key]!;
            //       }
            //     ),
          ),
        ]
      )
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class FollowListItem extends StatefulWidget {
  FollowListItem(this.followItem, {Key? key,
    this.isSelectable = false,
    this.isFollowing = true,
    this.isShowMenu = false,
    this.selectMax = 99,
    this.height = 70.0,
    this.onMenuSelected}) : super(key: key);

  JSON followItem;
  bool isSelectable;
  bool isFollowing;
  bool isShowMenu;
  double height;
  int selectMax;

  Function(DropdownItemType, String, JSON)? onMenuSelected;

  @override
  FollowListItemState createState() => FollowListItemState();
}

class FollowListItemState extends State<FollowListItem> {
  final api = Get.find<ApiService>();
  Future<JSON>? _followInit;
  var _id = '';
  var _isChecked = false;
  JSON _userInfo = {};
  
  refreshData(JSON data) {
    _isChecked = AppData.listSelectData.containsKey(_id);
    _userInfo = data;
    if (widget.isFollowing) {
      widget.followItem['targetName'] = data['nickName'];
      widget.followItem['targetPic' ] = data['pic'];
    } else {
      widget.followItem['userName'] = data['nickName'];
      widget.followItem['userPic' ] = data['pic'];
    }
    if (AppData.USER_FOLLOW.containsKey(widget.followItem['id'])) {
      AppData.USER_FOLLOW[widget.followItem['id']] = widget.followItem;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _id = STR(widget.isFollowing ? widget.followItem['targetId'] : widget.followItem['userId']);
    _followInit = api.getUserInfoFromId(_id);
    return GestureDetector(
        onTap: () {
          if (widget.isSelectable) {
            if (widget.selectMax == 1) {
              AppData.listSelectData.clear();
              AppData.listSelectData[_userInfo['id']] = _userInfo;
              Navigator.of(context).pop();
            } else {
              AppData.listSelectData[_userInfo['id']] = _userInfo;
            }
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TargetProfileScreen(_userInfo)));
          }
        },
        child: Container(
            width: double.infinity,
            height: widget.height,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 5),
            child: FutureBuilder(
                future: _followInit,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    refreshData(snapshot.data);
                    return Row(
                      children: [
                        if (widget.isSelectable && widget.selectMax > 1)
                          Checkbox(
                              value: _isChecked,
                              onChanged: (value) {
                                setState(() {
                                  _isChecked = value!;
                                  if (_isChecked) {
                                    if (widget.selectMax == 1) {
                                      AppData.listSelectData.clear();
                                      AppData.listSelectData[_id] = _userInfo;
                                      Navigator.of(context).pop();
                                    } else {
                                      AppData.listSelectData[_id] = _userInfo;
                                    }
                                  } else {
                                    AppData.listSelectData.remove(_id);
                                  }
                                });
                              }
                          ),
                        if (widget.isSelectable && widget.selectMax == 1)
                          Icon(Icons.arrow_forward_ios, size: 24, color: Theme.of(context).primaryColor),
                        SizedBox(
                            width: widget.height - 10,
                            height: widget.height - 10,
                            child: ClipOval(
                                child: showImageFit(_userInfo['pic'] ?? 'assets/ui/main_picture_00.png')
                            )
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${STR(_userInfo['nickName'])}', style: ItemTitleStyle(context)),
                              if (STR(_userInfo['message']).isNotEmpty) ...[
                                SizedBox(height: 5),
                                Text(DESC(_userInfo['message']), maxLines: 2, style: ItemDescStyle(context)),
                              ]
                            ],
                          ),
                        ),
                        // SizedBox(width: 10),
                        // Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   crossAxisAlignment: CrossAxisAlignment.end,
                        //   children: [
                        //     // Text(SERVER_TIME_STR(widget.followItem['createTime']), style: Theme
                        //     //     .of(context)
                        //     //     .textTheme
                        //     //     .subtitle2),
                        //     // SizedBox(height: 5),
                        //     Container(
                        //       width: 16,
                        //       height: 16,
                        //       child: Text("1", style: TextStyle(fontSize: 7, color: Colors.white)),
                        //       alignment: Alignment.center,
                        //       decoration: BoxDecoration(
                        //           shape: BoxShape.circle,
                        //           color: Colors.purple.withOpacity(0.6)
                        //       ),
                        //     )
                        //   ],
                        // ),
                        EditMenuWidget,
                      ],
                    );
                  } else {
                    return showLoadingImageSize(Size(double.infinity, widget.height));
                  }
                })
        )
    );
  }

  Widget get EditMenuWidget {
    return  DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Container(
          width: 24,
          height: double.infinity,
          alignment: Alignment.centerRight,
          child: Icon(Icons.more_vert_outlined, size: 22, color: Colors.grey),
        ),
        // customItemsIndexes: const [3],
        // customItemsHeight: 3,
        itemHeight: 45,
        dropdownWidth: 160,
        buttonHeight: 30,
        buttonWidth: 30,
        itemPadding: const EdgeInsets.only(left: 12, right: 12),
        offset: const Offset(0, 8),
        items: [
          if (widget.isShowMenu)
            ...UserMenuItems.followingMenu.map((item) => DropdownMenuItem<DropdownItem>(
              value: item,
              child: GoodsMenuItems.buildItem(item),
            ),
          ),
          if (!widget.isShowMenu)
            ...UserMenuItems.followerMenu.map((item) => DropdownMenuItem<DropdownItem>(
              value: item,
              child: GoodsMenuItems.buildItem(item),
            ),
          ),
        ],
        onChanged: (value) {
          var selected = value as DropdownItem;
          if (widget.onMenuSelected != null) widget.onMenuSelected!(selected.type, widget.followItem['id'], _userInfo);
        },
      ),
    );
  }
}

