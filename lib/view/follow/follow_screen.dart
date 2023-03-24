import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/follow_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../view_model/follow_view_model.dart';
import '../profile/profile_target_screen.dart';

class FollowScreen extends StatefulWidget {
  FollowScreen(this.userInfo, {Key? key,
    this.isSelectable = false,
    this.isShowAppBar = true,
    this.isShowMe = false,
    this.topTitle = '',
    this.selectMax = 9,
    this.selectData,
  }) : super(key: key);

  UserModel userInfo;
  bool isSelectable;
  bool isShowAppBar;
  bool isShowMe;
  String topTitle;
  int  selectMax;

  JSON? selectData;

  @override
  FollowScreenState createState() => FollowScreenState();
}

class FollowScreenState extends State<FollowScreen> {
  final _viewModel = FollowViewModel();
  List<FollowTab>? _tabList;
  JSON selectDataOrg = {};

  refreshTab() {
    _tabList = [
      FollowTab(0, Icon(Icons.star, size: 16), "FOLLOWING".tr, AppData.followData, selectData: widget.selectData,
          isShowMe: widget.isShowMe, isSelectable: widget.isSelectable, selectMax: widget.selectMax, onSelected: onSelected),
      FollowTab(1, Icon(Icons.star_border, size: 16), "FOLLOWER".tr, AppData.followData, selectData: widget.selectData,
          isShowMe: widget.isShowMe, isSelectable: widget.isSelectable, selectMax: widget.selectMax, onSelected: onSelected),
    ];
  }

  onSelected(JSON list) {
    widget.selectData = {};
    widget.selectData!.addAll(list);
  }

  @override
  void initState() {
    if (widget.selectData != null) {
      selectDataOrg = {};
      selectDataOrg.addAll(widget.selectData!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.init(context);
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: selectDataOrg);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: widget.isShowAppBar ? AppBar(
            title: Text(widget.topTitle.isNotEmpty ? widget.topTitle : 'FOLLOW LIST'.tr, style: AppBarTitleStyle(context)),
            titleSpacing: 0,
            toolbarHeight: 50,
            actions: [
              if (widget.isSelectable)
                TextButton(
                  onPressed: () {
                    Get.back(result: widget.selectData);
                  }, child: Text('Select Done'.tr)
                )
            ],
          ) : null,
          body: FutureBuilder(
            future: _viewModel.getFollowList(widget.userInfo.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                refreshTab();
                return ChangeNotifierProvider<FollowViewModel>(
                  create: (_) => _viewModel,
                  child: Consumer<FollowViewModel>(builder: (context, viewModel, _) {
                    return DefaultTabController(
                      length: _tabList!.length,
                      child: Scaffold(
                        appBar: AppBar(
                          toolbarHeight: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          bottom: TabBar(
                            padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
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
                    );
                  }
                )
              );
            } else {
              return showLoadingFullPage(context);
            }
          }),
        ),
      )
    );
  }
}

class FollowTab extends StatefulWidget {
  final api = Get.find<ApiService>();
  FollowTab(this.selectedTab, this.icon, this.title, this.followData, {
    Key? key, this.isSelectable = false, this.isShowMe = false, this.selectMax = 9, this.selectData, this.onSelected
  }) : super(key: key);

  int selectedTab;
  Icon icon;
  String title;
  Map<String, FollowModel> followData;
  bool isSelectable;
  bool isShowMe;
  int selectMax;

  JSON? selectData;
  Function(JSON)? onSelected;

  Widget getTab() {
    return Tab(icon: icon, iconMargin: EdgeInsets.zero, text: title, height: UI_TAB_HEIGHT.w);
    // return Tab(text: title, height: UI_APPBAR_TOOL_HEIGHT.w);
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
        // var state = AppData.searchWidgetKey[SearchKeys.follow0.index + widget.selectedTab].currentState as SearchWidgetState;
        // state.clearFocus();
      }
    });
  }

  refreshList() {
    LOG('--> refreshList : ${widget.isShowMe} / ${widget.followData.length}');
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
    if (widget.followData.isNotEmpty) {
      for (var item in widget.followData.entries) {
        var isOwner = AppData.userInfo.checkOwner(item.value.userId);
        if (!AppData.blockUserData.containsKey(STR(item.value.targetId)) &&
            !AppData.blockUserData.containsKey(STR(item.value.userId))) {
          if ((widget.selectedTab == 0 && isOwner) || (widget.selectedTab == 1 && !isOwner)) {
            LOG('--> _searchText : $_searchText / $isOwner : ${item.value.targetId}');
            if (_searchText.isEmpty
                || (isOwner && item.value.targetName.toLowerCase().contains(_searchText.toLowerCase()))
                || (!isOwner && item.value.userName.toLowerCase().contains(_searchText.toLowerCase()))
            ) {
              LOG('--> add : ${item.value}');
              _itemList.add(item.value.toJson());
            }
          }
        }
      }
    }
  }

  onMenuSelected(DropdownItemType menu, String id, JSON targetUser) {
    LOG('--> onMenuSelected : $menu');
    switch (menu) {
      case DropdownItemType.message:
        JSON uploadData = {
          "status":       1,
          "desc":         '',
          "imageData":    [],
          "targetId":     targetUser['id'],
          "targetName":   targetUser['nickName'],
          "targetPic":    targetUser['pic'],
          "senderId":     AppData.USER_ID,
          "senderName":   AppData.USER_NICKNAME,
          "senderPic":    AppData.USER_PIC,
          "createTime":   CURRENT_SERVER_TIME(),
        };
        showEditCommentDialog(context, CommentType.message, 'To. ${STR(targetUser['nickName'])}', uploadData, targetUser, false, true, false).then((result) {
          LOG('--> showEditCommentDialog comment result : $result');
          if (result.isNotEmpty) {
            setState(() {

            });
          }
        });
        break;
      case DropdownItemType.unfollow:
        showAlertYesNoDialog(context, 'Follow cancel'.tr,
            'Are you sure you want to unfollow?'.tr, '${targetUser['nickName']}', 'Cancel'.tr, 'OK'.tr).then((value) {
          if (value == 1) {
            api.setFollowStatus(AppData.userInfo.toJson(), targetUser['id'], 0).then((value) {
              setState(() {
                LOG('--> AppData.USER_FOLLOW after : ${AppData.followData.length}');
                refreshList();
              });
            });
          }
        });
    }
  }

  onSelected(JSON selectItem, bool status) {
    LOG('--> tab onSelected [$status] : $selectItem');
    final key = STR(selectItem['id']);
    widget.selectData ??= {};
    if (status) {
      widget.selectData![key] = selectItem;
    } else {
      widget.selectData!.remove(key);
    }
    if (widget.onSelected != null) widget.onSelected!(widget.selectData!);
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
      padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
      child: Column(
        children: [
          SizedBox(height: 10),
          if (widget.isSelectable)...[
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Theme.of(context).errorColor.withOpacity(0.25),
              ),
              child: Center(
                child: Text(widget.selectMax == 1 ? 'Please select a target'.tr : 'Please select targets'.tr, style: ItemTitleAlertStyle(context)),
              )
            )
          ],
          // SearchWidget(
          //   key: AppData.searchWidgetKey[SearchKeys.follow0.index + widget.selectedTab],
          //   isShowList: false,
          //   padding: EdgeInsets.zero,
          //   onEdited: onSearchEdited,
          // ),
          SizedBox(height: 5),
          SingleChildScrollView(
            child: Column(
              children: _itemList.map((item) => FollowListItem(item, isFollowing: AppData.userInfo.checkOwner(item['userId']),
                isSelected: widget.selectData != null && widget.selectData!.containsKey(item['targetId']),
                isSelectable: widget.isSelectable,
                isShowMenu: widget.selectedTab == 0,
                selectMax: widget.selectMax,
                onSelected: onSelected,
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
    this.isSelected = false,
    this.isSelectable = false,
    this.isFollowing = true,
    this.isShowMenu = false,
    this.selectMax = 99,
    this.height = 70.0,
    this.onSelected,
    this.onMenuSelected}) : super(key: key);

  JSON followItem;
  bool isSelected;
  bool isSelectable;
  bool isFollowing;
  bool isShowMenu;
  double height;
  int selectMax;

  Function(JSON, bool)? onSelected;
  Function(DropdownItemType, String, JSON)? onMenuSelected;

  @override
  FollowListItemState createState() => FollowListItemState();
}

class FollowListItemState extends State<FollowListItem> {
  final repo = UserRepository();
  Future<UserModel?>? _followInit;
  var userId = '';
  UserModel? userInfo;
  
  refreshData(UserModel user) {
    userInfo = user;
    if (widget.isFollowing) {
      widget.followItem['targetName'] = user.nickName;
      widget.followItem['targetPic' ] = user.pic;
    } else {
      widget.followItem['userName'] = user.nickName;
      widget.followItem['userPic' ] = user.pic;
    }
    if (AppData.followData.containsKey(widget.followItem['id'])) {
      AppData.followData[widget.followItem['id']] = FollowModel.fromJson(widget.followItem);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userId = STR(widget.isFollowing ? widget.followItem['targetId'] : widget.followItem['userId']);
    _followInit = repo.getUserInfo(userId);
    return GestureDetector(
      onTap: () {
        if (widget.isSelectable) {
          if (widget.selectMax == 1) {
            AppData.listSelectData.clear();
            AppData.listSelectData[userInfo!.id] = userInfo;
            Navigator.of(context).pop();
          } else {
            AppData.listSelectData[userInfo!.id] = userInfo;
          }
        } else {
          Get.to(() => ProfileTargetScreen(userInfo!));
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
                      value: widget.isSelected,
                      onChanged: (value) {
                        setState(() {
                          widget.isSelected = value!;
                          if (widget.onSelected != null) widget.onSelected!(userInfo!.toJson(), value);
                          // if (_isChecked) {
                          //   if (widget.selectMax == 1) {
                          //     AppData.listSelectData.clear();
                          //     AppData.listSelectData[userId] = _userInfo;
                          //     Navigator.of(context).pop();
                          //   } else {
                          //     AppData.listSelectData[userId] = _userInfo;
                          //   }
                          // } else {
                          //   AppData.listSelectData.remove(userId);
                          // }
                        });
                      }
                    ),
                  if (widget.isSelectable && widget.selectMax == 1)
                    Icon(Icons.arrow_forward_ios, size: 24, color: Theme.of(context).primaryColor),
                  SizedBox(
                    width: widget.height - 10,
                    height: widget.height - 10,
                    child: ClipOval(
                        child: showImageFit(userInfo!.pic)
                    )
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userInfo!.nickName, style: ItemTitleStyle(context)),
                        if (userInfo!.message.isNotEmpty) ...[
                          Text(DESC(userInfo!.message), maxLines: 1, style: ItemDescStyle(context)),
                        ],
                        Text(DATE_STR(DateTime.parse(userInfo!.createTime)), style: ItemDescExStyle(context)),
                      ],
                    ),
                  ),
                  if (!widget.isSelectable)
                    editMenuWidget,
                ],
              );
            } else {
              return showLoadingFullPage(context);
            }
          }
        )
      )
    );
  }

  Widget get editMenuWidget {
    return  DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Container(
          width: 24,
          height: double.infinity,
          alignment: Alignment.centerRight,
          child: Icon(Icons.more_vert_outlined, size: 22, color: Colors.grey),
        ),
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
              child: buildItem(item),
            ),
          ),
          if (!widget.isShowMenu)
            ...UserMenuItems.followerMenu.map((item) => DropdownMenuItem<DropdownItem>(
              value: item,
              child: buildItem(item),
            ),
          ),
        ],
        onChanged: (value) {
          var selected = value as DropdownItem;
          if (widget.onMenuSelected != null) widget.onMenuSelected!(selected.type, widget.followItem['id'], userInfo!.toJson());
        },
      ),
    );
  }

  static Widget buildItem(DropdownItem item) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: Colors.grey,
                    size: 20
                  ),
                  if (item.text != null)...[
                    SizedBox(width: 3),
                    Text(item.text!.tr, style: TextStyle(fontSize: 14), maxLines: 2),
                  ]
                ],
              ),
            ),
          ),
          if (item.isLine)
            showHorizontalDivider(Size(double.infinity, 2), color: Colors.grey),
        ]
      )
    );
  }
}



