import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../follow/follow_screen.dart';

enum ProfileMainTab {
  profile,
  follow,
  like,
}

enum ProfileContentTab {
  event,
  story,
}

class MainMyScreen extends StatefulWidget {
  const MainMyScreen({ Key? key }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainMyState();
}

class MainMyState extends State<MainMyScreen> {
  List<MainMyTab> _tabList = [];
  List<GlobalKey> _tabKeyList = [];
  final _topHeight = 40.0;
  var _currentTab = 0;

  initData() {
    _tabKeyList = List.generate(3, (index) => GlobalKey());
    _tabList = [
      MainMyTab(ProfileMainTab.profile , 'PROFILE'.tr  , AppData.userInfo, key: _tabKeyList[0]),
      MainMyTab(ProfileMainTab.follow  , 'FOLLOW'.tr   , AppData.userInfo, key: _tabKeyList[1]),
      MainMyTab(ProfileMainTab.like    , 'LIKE'.tr     , AppData.userInfo, key: _tabKeyList[2]),
    ];
  }

  refresh() {
    if (mounted) {
      setState(() {
        initData();
      });
    }
  }

  refreshTab(int tab) {
    if (mounted) {
      var state = _tabKeyList[tab].currentState as MainMyTabState;
      state.refresh();
    }
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      top: false,
      child: DefaultTabController(
        length: _tabList.length,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: _topHeight,
            bottom: TabBar(
              onTap: (index) {
                _currentTab = index;
                // AppData.setSearchEnable(false);
              },
              padding: EdgeInsets.symmetric(horizontal: 20),
              labelColor: Theme.of(context).primaryColor,
              labelStyle: ItemTitleStyle(context),
              unselectedLabelColor: Theme.of(context).hintColor,
              unselectedLabelStyle: ItemTitleStyle(context),
              indicatorColor: Theme.of(context).primaryColor,
              tabs: _tabList.map((item) => item.getTab()).toList(),
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: _tabList,
          ),
        ),
      )
    );
  }
}

// ignore: must_be_immutable
class MainMyTab extends StatefulWidget {
  MainMyTab(
      this.selectedTab,
      this.title,
      this.userInfo,
      { Key? key }) : super(key: key);

  ProfileMainTab selectedTab;
  String title;
  UserModel userInfo;

  Widget getTab() {
    return Tab(text: title, height: 40);
  }

  @override
  MainMyTabState createState() => MainMyTabState();
}

class MainMyTabState extends State<MainMyTab> {
  final repo = UserRepository();
  List<MyProfileTab> _tabList = [];

  final _msgTextController = TextEditingController();
  final _scrollController = PageController(viewportFraction: 1, keepPage: true);

  var _facePicSize = 150.0;
  var _snsPicSize = 50.0;
  var _tabviewHeight = 1000.0;
  var _tabviewKey = GlobalKey();
  var _currentTab = 0;
  var _isWaiting = false;
  var _isMyProfile = false;
  JSON _snsData = {};

  List<Widget> _shareLink = [];
  late List<bool> _tabRefreshDone = List.generate(_tabList.length, (index) => false);

  initUserInfo() {
    _isMyProfile  = AppData.USER_ID == widget.userInfo.id;
    _snsData      = widget.userInfo.getSnsDataMap;
    _tabList = [
      MyProfileTab(ProfileContentTab.event, _isMyProfile ? 'MY EVENT'.tr: 'EVENT'.tr, widget.userInfo, onRefresh: refreshTab),
      MyProfileTab(ProfileContentTab.story, _isMyProfile ? 'MY STORY'.tr: 'STORY'.tr, widget.userInfo, onRefresh: refreshTab),
    ];
    setUserMessage();
  }

  setUserPic(BuildContext context) async {
    if (!_isMyProfile) return;
    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    LOG('---> setUserPic : $pickImage');
    if (pickImage != null) {
      var imageUrl  = await ShowUserPicCroper(pickImage.path);
      LOG('---> imageUrl : $imageUrl');
      if (imageUrl != null) {
        showLoadingDialog(context, 'uploading now...'.tr);
        var imageData = await ReadFileByte(imageUrl);
        JSON imageInfo = {'id': widget.userInfo.id, 'image': imageData};
        var upResult = await repo.uploadImageData(imageInfo, 'user_img');
        if (upResult == null) {
          showAlertDialog(context, 'Profile image'.tr, 'Image update is failed'.tr, '', 'OK'.tr);
        }
        widget.userInfo.pic = upResult!;
        var setResult = await repo.setUserInfoItem(widget.userInfo, 'pic');
        Navigator.of(dialogContext!).pop();
        if (setResult) {
          showAlertDialog(context, 'Profile image'.tr, 'Image update is complete'.tr, '', 'OK'.tr);
          setState(() {
            AppData.USER_PIC = upResult;
          });
          LOG('---> setUserPic success : ${AppData.USER_PIC}');
        }
      }
    }
  }

  onMessageEdit() {
    showTextInputLimitDialog(context, 'Edit message'.tr, '', widget.userInfo.message, 1, 200, 6, null).then((result) async {
      if (result.isNotEmpty) {
        widget.userInfo.message = result;
        showLoadingDialog(context, 'Now Uploading...');
        var setResult = await repo.setUserInfoItem(widget.userInfo, 'message');
        Navigator.of(dialogContext!).pop();
        if (setResult) {
          setState(() {
            AppData.userInfo.message = widget.userInfo.message;
            setUserMessage();
          });
        }
      }
    });
  }

  setUserMessage() {
    if (widget.userInfo.message.isEmpty) {
      _msgTextController.text = _isMyProfile ? 'Enter your message to show here'.tr : '';
      widget.userInfo.message = '';
    } else {
      _msgTextController.text = widget.userInfo.message;
    }
  }

  refresh() {
    if (mounted) {
      setState(() {
        LOG("--> MainMyTabState update");
      });
    }
  }

  refreshTab(int tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  getSNSItemFromUser(String snsId, JSON snsData) {
    return snsData[snsId] ?? {};
  }

  @override
  void initState() {
    initUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _followTextStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
    _facePicSize    = MediaQuery.of(context).size.width * 0.3;
    _snsPicSize     = MediaQuery.of(context).size.width * 0.085;

    LOG("--> _tabviewHeight : $_tabviewHeight");
    switch (widget.selectedTab) {
      case ProfileMainTab.profile: {
        return SingleChildScrollView(
          controller: _scrollController,
          // physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                // if (!_isMyProfile && widget.userInfo['bannerData'] != null)
                //   BannerScrollViewer(
                //     widget.userInfo['bannerData'],
                //     rowHeight: 160,
                //     showArrow: true,
                //   ),
                // if (_isMyProfile && JSON_NOT_EMPTY(widget.userInfo['bannerData']))...[
                //   Stack(
                //     children: [
                //       BannerScrollViewer(
                //         widget.userInfo['bannerData'],
                //         rowHeight: 200,
                //         showArrow: widget.userInfo['bannerData'] != null,
                //         isOwner : true,
                //         onSelected: (key) async {
                //           debugPrint('--> banner item select : $key');
                //           for (var i=0; i<widget.userInfo['bannerData'].length; i++) {
                //             var bannerItem = widget.userInfo['bannerData'][i];
                //             if (key == bannerItem['id']) {
                //               if (bannerItem['linkType'] == 'history') {
                //                 var historyInfo = await api.getHistoryFromId(bannerItem['linkTarget']);
                //                 var homeItem = HomeItem(historyInfo['id'], widget.userInfo, widget.userInfo, historyInfo);
                //                 Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(ShowHistoryDetail(homeItem)));
                //               } else if (bannerItem['linkType'] == 'goods') {
                //                 var goodsInfo = await api.getGoodsDataFromId(bannerItem['linkTarget']);
                //                 Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(ShowGoodsDetail(goodsInfo)));
                //               }
                //               break;
                //             }
                //           }
                //         },
                //       ),
                //       Positioned(
                //         right: 5,
                //         bottom: 5,
                //         child: IconButton(
                //           icon: Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Icon(Icons.settings_sharp, color: Colors.black.withOpacity(0.5), size: 28),
                //               Icon(Icons.settings_sharp, color: Colors.white, size: 24),
                //             ]
                //           ),
                //           onPressed: () {
                //             Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(BannerEditScreen())).then((result) {
                //               setState(() {
                //                 widget.userInfo = AppData.userInfo;
                //                 debugPrint("--> BannerEditScreen result : ${widget.userInfo['bannerData']}");
                //               });
                //             });
                //           },
                //         )
                //       )
                //     ],
                //   ),
                // ],
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.45,
                        ),
                        child: Column(
                          children : [
                            SizedBox(
                              width: _facePicSize,
                              height: _facePicSize,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 300,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff7c94b6),
                                      borderRadius: BorderRadius.all(Radius.circular(300)),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.secondary,
                                        width: 4.0,
                                      ),
                                    ),
                                    child: getCircleImage(widget.userInfo['pic'] ?? 'assets/ui/main_picture_00.png', 300),
                                  ),
                                  if (_isMyProfile)
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: IconButton(
                                        icon: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.edit, color: Colors.black.withOpacity(0.5), size: 26),
                                            Icon(Icons.edit, color: Colors.white, size: 22),
                                          ]
                                        ),
                                        onPressed: () {
                                          setUserPic(context);
                                        },
                                      )
                                    )
                                ]
                              )
                            ),
                            SizedBox(height: 15),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(STR(widget.userInfo['nickName']), style: ItemTitleLargeStyle(context)),
                                    // if (_isMyProfile)...[
                                    //   SizedBox(width: 5),
                                    //   GestureDetector(
                                    //     child: Icon(Icons.edit, color: Colors.grey, size: 20),
                                    //     onTap: () {
                                    //       showTextInputLimitDialog(context, '닉네임 수정', '', widget.userInfo['nickName'], 1, 12, 1, null).then((result) async {
                                    //         if (result.isNotEmpty) {
                                    //           widget.userInfo['nickName'] = result;
                                    //           showLoadingDialog(context, 'Now Uploading...');
                                    //           var setResult = await setUserInfoItem(widget.userInfo, 'nickName');
                                    //           Navigator.of(dialogContext!).pop();
                                    //           if (setResult) {
                                    //             setState(() {
                                    //               AppData.USER_NICKNAME = result;
                                    //             });
                                    //           }
                                    //         }
                                    //       });
                                    //     },
                                    //   )
                                    // ]
                                  ]
                                ),
                                if (widget.userInfo['email'] != null)...[
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: STR(widget.userInfo['email'])));
                                      ShowToast('copied to clipboard'.tr);
                                    },
                                    child: Text(STR(widget.userInfo['email']), style: ItemDescStyle(context), maxLines: 3),
                                  ),
                                ]
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!_isMyProfile)...[
                                    ShowSendMessageWidget(context, widget.userInfo, title: 'TALK'.tr),
                                    SizedBox(width: 2),
                                  ],
                                  ShowBookmarkWidget(context, 'user', widget.userInfo, showCount: true, isEnabled: !_isMyProfile),
                                  SizedBox(width: 5),
                                  ShowLikeWidget(context, 'user', widget.userInfo, showCount: true, isEnabled: !_isMyProfile),
                                ],
                                // children: _shareLink,
                              ),
                            ),
                            if (_snsData.isNotEmpty)...[
                              Container(
                                padding: EdgeInsets.only(top: 10, bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    for (var item in snsLinkInfo)...[
                                      if (_snsData.containsKey(STR(item['id'])))...[
                                        GestureDetector(
                                          onTap: () async {
                                            final snsItem = getSNSItemFromUser(STR(item['id']), widget.userInfo['snsData']);
                                            var protocolUrl = '';
                                            var launchMode = LaunchMode.platformDefault;
                                            LOG('--> SNS select : $snsItem');
                                            switch(STR(item['id'])) {
                                              case 'facebook':
                                                protocolUrl = 'fb://facewebmodal/f?href=${STR(snsItem['link'])}';
                                                break;
                                              case 'instagram':
                                                protocolUrl = 'instagram://user?username=${STR(snsItem['link']).toString().replaceAll("@", '')}';
                                                break;
                                              default:
                                                protocolUrl = STR(snsItem['link']);
                                                launchMode = LaunchMode.externalApplication;
                                                break;
                                            }
                                            LOG('--> protocolUrl : $protocolUrl');
                                            var url = Uri.parse(protocolUrl);
                                            await launchUrl(url, mode: launchMode);
                                          },
                                          child: showImage(STR(item['icon']), Size(_snsPicSize, _snsPicSize), Theme.of(context).hintColor)
                                        ),
                                      ]
                                    ]
                                  ],
                                )
                              )
                            ]
                          ]
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children : [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(NUMBER_K(widget.userInfo['follow'] ?? 0), style: ItemTitleStyle(context)),
                                          Text("FOLLOW".tr, style: _followTextStyle),
                                        ],
                                      )
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(NUMBER_K(widget.userInfo['follower'] ?? 0), style: ItemTitleStyle(context)),
                                          Text("FOLLOWER".tr, style: _followTextStyle),
                                        ],
                                      )
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Stack(
                                children: [
                                  TextField(
                                    readOnly: true,
                                    controller: _msgTextController,
                                    maxLines: 8,
                                    decoration: messageLabelSuffix(context, ''),
                                    onTap: () {
                                      onMessageEdit();
                                    },
                                  ),
                                  if (_isMyProfile)
                                    Positioned(
                                      right: 10,
                                      bottom: 10,
                                      child: GestureDetector(
                                          onTap: () {
                                            onMessageEdit();
                                          },
                                          child: Icon(Icons.edit, color: Theme.of(context).hintColor)
                                      )
                                  ),
                                ]
                              )
                            ]
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                DefaultTabController(
                  length: _tabList.length,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: TabBar(
                          onTap: (index) {
                            _currentTab = index;
                            if (_isWaiting) return;
                            _isWaiting = true;
                            setState(() {
                              _tabviewHeight = 1000;
                              AppData.myProfileTabViewHeightReload = true;
                              Future.delayed(Duration(milliseconds: 200), () {
                                setState(() {
                                  _currentTab = index;
                                  _tabviewHeight = AppData.myProfileTabViewHeight[index];
                                  _isWaiting = false;
                                  log("--> onTap _tabviewHeight : $_tabviewHeight} / $index");
                                });
                              });
                            });
                          },
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          labelColor: Theme.of(context).primaryColor,
                          labelStyle: ItemDescBoldStyle(context),
                          unselectedLabelColor: Theme.of(context).hintColor,
                          unselectedLabelStyle: ItemDescDisableStyle(context),
                          indicatorColor: Theme.of(context).primaryColor,
                          tabs: _tabList.map((item) => item.getTab()).toList(),
                        ),
                      ),
                      Container(
                        key: _tabviewKey,
                        height: _tabviewHeight,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: _tabList,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ),
        );
      }
      case ProfileMainTab.follow: {
        return FollowScreen(AppData.userInfo, isShowAppBar: false);
      }
      case ProfileMainTab.like: {
        // return BookmarkScreen(AppData.userInfo, key:AppData.profileTabKey[widget.selectedTab.index], isShowAppBar: false);
      }
      default:{
        return Center();
      }
    }
  }

  Widget get botArrow {
    return Container(
      height: 80,
      padding: EdgeInsets.only(top: 15),
      alignment: Alignment.topCenter,
      child: Image.asset("assets/ui/my_arrow_00.png", width: 15, height: 30, color: Colors.purple),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ShoppingTopItem extends StatelessWidget {
  ShoppingTopItem(this.iconUrl, this.title, this.backgroundColor, {Key? key}) : super(key: key);

  String iconUrl;
  String title;
  Color  backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 110,
          height: 110,
          color: backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 80,
                child: Image.asset(iconUrl),
                padding: EdgeInsets.all(10),
              ),
              Text(title, style: TextStyle(fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold)),
            ]
        ),
      ),
    );
  }
}

class ShoppingBotItem extends StatelessWidget {
  ShoppingBotItem(this.title, this.count, {Key? key}) : super(key: key);

  String title;
  int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 35,
      // color: Colors.grey.withOpacity(0.25),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black)),
          SizedBox(height: 5),
          Text("$count", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple)),
        ]
      ),
    );
  }
}

class MyProfileTab extends StatelessWidget {
  MyProfileTab(this.selectedTab, this.title, this.userInfo, {Key? key, this.isSelectable = false, this.onRefresh})
      : super(key: key);

  final api = Get.find<ApiService>();
  ProfileContentTab selectedTab;
  String title;
  UserModel userInfo;
  Function(int)? onRefresh;

  var tabHeight = 40.0;
  var isSelectable;

  Widget getTab() {
    return Tab(text: title, height: tabHeight);
  }

  JSON? _itemList;
  final _edgeInsets     = EdgeInsets.fromLTRB(15, 5, 15, 10);
  final _commentStyle   = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey);
  final _pageShowMax = 5;
  final _itemHeight = 90.0;
  var _isMyProfile = false;
  var _pageNow = 0;
  var _pageMax = 0;

  Future<JSON>? _dataInit;
  List<JSON> _showList = [];

  loadExtraData() {
    switch (selectedTab) {
      case ProfileContentTab.story:
        _dataInit = api.getStoryFromUserId(userInfo['id']);
        break;
      case ProfileContentTab.event:
        _dataInit = api.getPlaceEventFromUserId(userInfo['id'], true);
        break;
    }
    LOG('--> loadExtraData : ${userInfo['id']}');
  }

  refreshShowList([double itemHeight = DEFAULT_ITEM_HEIGHT]) {
    _showList.clear();
    for (var i=0; i<_pageShowMax; i++) {
      var itemIndex = _pageNow * _pageShowMax + i;
      if (itemIndex >= _itemList!.length) break;
      var key = _itemList!.keys.elementAt(itemIndex);
      _showList.add(_itemList![key]);
    }
    _pageMax = (_itemList!.length / _pageShowMax).floor() + (_itemList!.length % _pageShowMax > 0 ? 1 : 0);
    LOG('--> refreshShowList : ${_itemList!.length} - $_pageNow / $_pageMax - ${_showList.length}');
    AppData.myProfileTabViewHeight[selectedTab.index] = itemHeight * _showList.length + (_isMyProfile ? 155 : 80);
    refreshTabHeight();
  }

  refreshTabHeight() {
    LOG('--> refreshTabHeight : ${selectedTab.index} / ${AppData.myProfileTabViewHeight[selectedTab.index]}');
    Future.delayed(Duration(milliseconds: 200), () {
      if (onRefresh != null) onRefresh!(selectedTab.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _isMyProfile = userInfo['id'] == AppData.USER_ID;
    loadExtraData();
    switch (selectedTab) {
      case ProfileContentTab.place:
        return FutureBuilder(
          future: _dataInit,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _itemList = snapshot.data as JSON;
              return StatefulBuilder(
                builder: (context, setState) {
                  refreshShowList();
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: _edgeInsets,
                        itemCount: _showList.length,
                        itemBuilder: (context, index) {
                          var item = _showList[index];
                          return PlaceListCardItem(
                            item,
                            itemHeight: DEFAULT_ITEM_HEIGHT,
                            itemPadding: EdgeInsets.symmetric(vertical: 5),
                            parentInfo: AppData.currentPlaceGroup,
                            isShowLike: false,
                            onRefresh: () {
                              if (onRefresh != null) onRefresh!(selectedTab.index);
                            },
                          );
                        }
                      ),
                      if (_isMyProfile)...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: ShowContentAddButton(context, 'SPOT ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
                            AddPlaceContent(context, null, (result) {
                              if (result.isNotEmpty) {
                                setState(() {
                                  if (onRefresh != null) onRefresh!(selectedTab.index);
                                });
                              }
                            });
                          }),
                        )
                      ],
                      ShowPageControlWidget(context, _pageNow, _pageMax, (page) => {
                        setState(() {
                          _pageNow = page;
                        })
                      }, EdgeInsets.symmetric(horizontal: 15)),
                    ]
                  );
                }
              );
            } else {
              return showLoadingFullPage(context);
            }
          }
        );
      case ProfileContentTab.placeEvent:
        return FutureBuilder(
          future: _dataInit,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _itemList = snapshot.data as JSON;
              LOG('--> ProfileContentTab.placeEvent [${selectedTab.index}] : ${_itemList!.length}');
              return StatefulBuilder(
                builder: (context, setState) {
                  refreshShowList();
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: _edgeInsets,
                        itemCount: _showList.length,
                        itemBuilder: (context, index) {
                          var item = _showList[index];
                          // var controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
                          return PlaceEventCardItem(
                            item,
                            // animationController: controller,
                            isShowTheme: false,
                            isShowUser: false,
                            isShowHomeButton: false,
                            isShowLike: false,
                            itemHeight: DEFAULT_EVENT_ITEM_HEIGHT,
                            onRefresh: (updateData) {
                              setState(() {
                                _itemList![key] = updateData;
                                if (onRefresh != null) onRefresh!(selectedTab.index);
                              });
                            },
                          );
                        }
                      ),
                      if (_isMyProfile)...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child:
                            Row(
                              children: [
                                Expanded(
                                  child: ShowContentAddButton(context, 'EVENT ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
                                    AddPlaceEventContent(context, null, EventListType.events, (result) {
                                      if (result.isNotEmpty) {
                                        setState(() {
                                          if (onRefresh != null) onRefresh!(selectedTab.index);
                                        });
                                      }
                                    });
                                  }),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: ShowContentAddButton(context, 'CLASS ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
                                    AddPlaceEventContent(context, null, EventListType.classes, (result) {
                                      if (result.isNotEmpty) {
                                        setState(() {
                                          if (onRefresh != null) onRefresh!(selectedTab.index);
                                        });
                                      }
                                    });
                                  }),
                                ),
                              ]
                            )
                          )
                        ],
                        ShowPageControlWidget(context, _pageNow, _pageMax, (page) => {
                          setState(() {
                            LOG('--> _pageNow : $_pageNow');
                            _pageNow = page;
                          })
                        }, EdgeInsets.symmetric(horizontal: 15)),
                      ]
                    );
                  }
                );
              } else {
                return showLoadingFullPage(context);
              }
            }
        );
      case ProfileContentTab.story:
        return FutureBuilder(
          future: _dataInit,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _itemList = snapshot.data as JSON;
              return StatefulBuilder(
                  builder: (context, setState) {
                    // refreshShowList(DEFAULT_STORY_ITEM_HEIGHT + 100);
                    // refreshTabHeight();
                    refreshShowList(_itemHeight);
                    // AppData.myProfileTabViewHeight[selectedTab.index] = _itemHeight;
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _showList.length,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            var item = _showList[index];
                            if (JSON_NOT_EMPTY(item['imageData'])) {
                              var firstImage = item['imageData'].first;
                              item['backPic'] = firstImage.runtimeType != String ? firstImage['backPic'] : firstImage;
                              // LOG('--> image data : ${item['pic']} / ${item['imageData']}');
                            }
                            return StoryCardItem(
                              item,
                              itemHeight: _itemHeight,
                              isShowHomeButton: false,
                              isShowPlaceButton: false,
                              isShowTheme: false,
                              isShowUser: false,
                              isShowLike: false,
                              itemPadding: EdgeInsets.only(bottom: 10),
                              onRefresh: (updateData) {
                                setState(() {
                                  _itemList![updateData['id']] = updateData;
                                  if (onRefresh != null) onRefresh!(selectedTab.index);
                                });
                              }
                            );
                          }
                        ),
                        if (_isMyProfile)...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child:
                            Row(
                                children: [
                                  Expanded(
                                    child: ShowContentAddButton(context, 'SPOT\nSTORY ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
                                      AddStoryContent(context, true, (result) {
                                        if (result.isNotEmpty) {
                                          setState(() {
                                            LOG('--> AddStoryContent result [SPOT] : $result');
                                            _itemList![result['id']] = result;
                                            if (onRefresh != null) onRefresh!(selectedTab.index);
                                          });
                                        }
                                      });
                                    }),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: ShowContentAddButton(context, 'EVENT\nSTORY ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
                                      AddStoryContent(context, false, (result) {
                                        if (result.isNotEmpty) {
                                          setState(() {
                                            LOG('--> AddStoryContent result [EVENT] : $result');
                                            _itemList![result['id']] = result;
                                            if (onRefresh != null) onRefresh!(selectedTab.index);
                                          });
                                        }
                                      });
                                    }),
                                  ),
                                ]
                            )
                          )
                        ],
                        ShowPageControlWidget(context, _pageNow, _pageMax, (page) => {
                          setState(() {
                            _pageNow = page;
                          })
                        }, EdgeInsets.symmetric(horizontal: 15)),
                      ]
                    );
                  }
              );
              // return StatefulBuilder(
              //   builder: (context, setState) {
              //     // refreshShowList(DEFAULT_STORY_ITEM_HEIGHT + 100);
              //     // refreshTabHeight();
              //     refreshShowList(_itemHeight);
              //     AppData.myProfileTabViewHeight[selectedTab.index] = _itemHeight;
              //     return ListView.builder(
              //         // shrinkWrap: true,
              //         scrollDirection: Axis.horizontal,
              //         itemCount: _showList.length,
              //         padding: EdgeInsets.only(left: 20),
              //         itemBuilder: (BuildContext context, int index) {
              //           var item = _showList[index];
              //           if (JSON_NOT_EMPTY(item['imageData'])) {
              //             var firstImage = item['imageData'].first;
              //             item['backPic'] = firstImage.runtimeType != String ? firstImage['backPic'] : firstImage;
              //             // LOG('--> image data : ${item['pic']} / ${item['imageData']}');
              //           }
              //           return Row(
              //             children: [
              //               if (index == 0)...[
              //                 Column(
              //                     children: [
              //                       Expanded(
              //                         child: ShowContentAddButton(context, 'SPOT\nSTORY ADD', padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
              //                           AddStoryContent(context, true, (result) {
              //                             if (result.isNotEmpty) {
              //                               setState(() {
              //                                 LOG('--> _itemList SPOT STORY add : $result');
              //                                 _itemList![result['id']] = result;
              //                                 refreshShowList();
              //                                 // if (onRefresh != null) onRefresh!(selectedTab.index);
              //                               });
              //                             }
              //                           });
              //                         }),
              //                       ),
              //                       Expanded(
              //                         child: ShowContentAddButton(context, 'EVENT\nSTORY ADD', padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
              //                           AddStoryContent(context, false, (result) {
              //                             if (result.isNotEmpty) {
              //                               setState(() {
              //                                 LOG('--> _itemList EVENT STORY add : $result');
              //                                 _itemList![result['id']] = result;
              //                                 refreshShowList();
              //                                 // if (onRefresh != null) onRefresh!(selectedTab.index);
              //                               });
              //                             }
              //                           });
              //                         }),
              //                       ),
              //                     ]
              //                   ),
              //                    SizedBox(width: 10),
              //                 ],
              //                 StoryVerCardItem(
              //                   item,
              //                   itemHeight: _itemHeight,
              //                   itemWidth: _itemHeight * 0.5,
              //                   isShowHomeButton: false,
              //                   isShowPlaceButton: true,
              //                   isShowTheme: false,
              //                   isShowUser: false,
              //                   isShowLike: false,
              //                   itemPadding: EdgeInsets.only(right: 10),
              //                   onRefresh: (updateData) {
              //                     setState(() {
              //                       _showList[index] = updateData;
              //                     });
              //                   }
              //                 )
              //               // return CommentListExItem(
              //               //     item, CommentType.story, AppData.userInfo, isShowDivider: false,
              //               //     height: DEFAULT_STORY_ITEM_HEIGHT,
              //               //     paddingSide: 10,
              //               //     maxLine: 1,
              //               //     isAuthor: true,
              //               //     isShowAuthor: false,
              //               //     isShowMenu: false,
              //               //     onChanged: (itemData, status) {
              //               //       setState(() {
              //               //         if (status == 2) {
              //               //           _itemList!.remove(itemData['id']);
              //               //         } else {
              //               //           _itemList![itemData['id']] = itemData;
              //               //         }
              //               //         loadExtraData();
              //               //       });
              //               //     }
              //               // );
              //               ]
              //             );
              //           }
              //       //   if (_isMyProfile)...[
              //       //     Container(
              //       //         width: double.infinity,
              //       //         padding: EdgeInsets.symmetric(horizontal: 15),
              //       //         child: ShowContentAddButton(context, 'STORY ADD', padding: EdgeInsets.symmetric(
              //       //             vertical: 5), onPressed: (_) {
              //       //           AddStoryContent(context, false, (result) {
              //       //             if (result.isNotEmpty) {
              //       //               setState(() {
              //       //                 if (onRefresh != null) onRefresh!(selectedTab.index);
              //       //               });
              //       //             }
              //       //           });
              //       //         })
              //       //     )
              //       //   ],
              //       //   ShowPageControlWidget(context, _pageNow, _pageMax, (page) => {
              //       //     setState(() {
              //       //       LOG('--> _pageNow : $_pageNow');
              //       //       _pageNow = page;
              //       //     })
              //       //   }, EdgeInsets.symmetric(horizontal: 15)),
              //     //   ]
              //     // )
              //     );
              //   }
              // );
            } else {
              return showLoadingFullPage(context);
            }
          }
        );
      }
    }
  }

class ShowHistoryDetail extends StatefulWidget {
  ShowHistoryDetail(this.homeItem, { Key? key })
      : super(key: key);

  HomeItem homeItem;

  @override
  ShowHistoryDetailState createState() => ShowHistoryDetailState();
}

class ShowHistoryDetailState extends State<ShowHistoryDetail> {
  late MainHomeCard _card;
  final topHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _card = MainHomeCard(widget.homeItem, isEditMode: widget.homeItem.user!['id'] == AppData.userInfo['id'], isMainMode: false);
    _card.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        body: Stack(
        children: [
          _card,
          Positioned(
            top: Platform.isAndroid ? 20 : 0,
            left: 10,
            child: Container(
                height: 40,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back_ios, size: 30, color: Colors.white)
                    )
                  ],
                )
            )
          ),
        ],
      )
    );
  }
}