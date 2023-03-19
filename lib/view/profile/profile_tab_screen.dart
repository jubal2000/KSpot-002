
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/event_model.dart';
import 'package:kspot_002/models/story_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/user_view_model.dart';
import '../../widget/like_widget.dart';
import '../../widget/page_widget.dart';
import '../event/event_item.dart';
import '../follow/follow_screen.dart';
import '../story/story_item.dart';

class MainMyTab extends StatefulWidget {
  MainMyTab(
      this.selectedTab,
      this.title,
      this.userViewModel,
      { Key? key }) : super(key: key);

  ProfileMainTab selectedTab;
  String title;
  UserViewModel userViewModel;

  Widget getTab() {
    return Tab(text: title, height: 40);
  }

  @override
  MainMyTabState createState() => MainMyTabState();
}

class MainMyTabState extends State<MainMyTab> {
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
    _isMyProfile  = AppData.userInfo.checkOwner(widget.userViewModel.userInfo!.id);
    _snsData      = widget.userViewModel.userInfo!.snsDataMap;
    _tabList = [
      MyProfileTab(ProfileContentTab.event, _isMyProfile ? 'MY EVENT'.tr: 'EVENT'.tr, widget.userViewModel, onRefresh: refreshTab),
      MyProfileTab(ProfileContentTab.story, _isMyProfile ? 'MY STORY'.tr: 'STORY'.tr, widget.userViewModel, onRefresh: refreshTab),
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
        JSON imageInfo = {'id': widget.userViewModel.userInfo!.id, 'data': imageData};
        var upResult = await widget.userViewModel.repo.uploadImageData(imageInfo, 'user_img');
        if (upResult == null) {
          showAlertDialog(context, 'Profile image'.tr, 'Image update is failed'.tr, '', 'OK'.tr);
        }
        widget.userViewModel.userInfo!.pic = upResult!;
        var setResult = await widget.userViewModel.repo.setUserInfoItem(widget.userViewModel.userInfo!, 'pic');
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
    showTextInputLimitDialog(context, 'Edit message'.tr, '', widget.userViewModel.userInfo!.message, 1, 200, 6, null).then((result) async {
      if (result.isNotEmpty) {
        widget.userViewModel.userInfo!.message = result;
        showLoadingDialog(context, 'Now Uploading...');
        var setResult = await widget.userViewModel.repo.setUserInfoItem(widget.userViewModel.userInfo!, 'message');
        Navigator.of(dialogContext!).pop();
        if (setResult) {
          setState(() {
            AppData.userInfo.message = widget.userViewModel.userInfo!.message;
            setUserMessage();
          });
        }
      }
    });
  }

  setUserMessage() {
    if (widget.userViewModel.userInfo!.message.isEmpty) {
      _msgTextController.text = _isMyProfile ? 'Enter your message to show here'.tr : '';
      widget.userViewModel.userInfo!.message = '';
    } else {
      _msgTextController.text = widget.userViewModel.userInfo!.message;
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
    if (mounted) {
      setState(() {
        _currentTab = tab;
      });
    }
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
              Container(
                padding: EdgeInsets.symmetric(vertical: UI_TOP_SPACE.w),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: UI_HORIZONTAL_SPACE.w),
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
                                        width: UI_FACE_SIZE.w,
                                        height: UI_FACE_SIZE.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff7c94b6),
                                          borderRadius: BorderRadius.all(Radius.circular(UI_FACE_SIZE.w)),
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.secondary,
                                            width: 4.0,
                                          ),
                                        ),
                                        child: getCircleImage(widget.userViewModel.userInfo!.pic, UI_FACE_SIZE.w),
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
                                                    Icon(Icons.edit, color: Colors.white, size: UI_MENU_ICON_SIZE.w),
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
                                      Text(widget.userViewModel.userInfo!.nickName, style: ItemTitleLargeStyle(context)),
                                      // if (_isMyProfile)...[
                                      //   SizedBox(width: 5),
                                      //   GestureDetector(
                                      //     child: Icon(Icons.edit, color: Colors.grey, size: 20),
                                      //     onTap: () {
                                      //       showTextInputLimitDialog(context, '닉네임 수정', '', widget.userViewModel.userInfo!['nickName'], 1, 12, 1, null).then((result) async {
                                      //         if (result.isNotEmpty) {
                                      //           widget.userViewModel.userInfo!['nickName'] = result;
                                      //           showLoadingDialog(context, 'Now Uploading...');
                                      //           var setResult = await setUserInfoItem(widget.userViewModel.userInfo!, 'nickName');
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
                                if (widget.userViewModel.userInfo!.email.isNotEmpty)...[
                                  SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: STR(widget.userViewModel.userInfo!.email)));
                                      ShowToast('copied to clipboard'.tr);
                                    },
                                    child: Text(widget.userViewModel.userInfo!.email, style: ItemDescStyle(context), maxLines: 3),
                                  ),
                                ]
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE.w, 10, UI_HORIZONTAL_SPACE.w, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!_isMyProfile)...[
                                    showSendMessageWidget(context, widget.userViewModel.userInfo!, title: 'TALK'.tr),
                                    SizedBox(width: 2),
                                  ],
                                  LikeWidget(context, 'user', widget.userViewModel.userInfo!.toJson(), showCount: true, isEnabled: !_isMyProfile),
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
                                    for (var item in _snsData.entries)...[
                                      if (_snsData.containsKey(STR(item.value['id'])))...[
                                        GestureDetector(
                                            onTap: () async {
                                              final snsItem = getSNSItemFromUser(STR(item.value['id']), _snsData);
                                              var protocolUrl = '';
                                              var launchMode = LaunchMode.platformDefault;
                                              LOG('--> SNS select : $snsItem');
                                              switch(STR(item.value['id'])) {
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
                                            child: showImage(STR(item.value['icon']), Size(_snsPicSize, _snsPicSize), color: Theme.of(context).hintColor)
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
                                            Text(NUMBER_K(widget.userViewModel.userInfo!.followCount), style: ItemTitleStyle(context)),
                                            Text("FOLLOW".tr, style: _followTextStyle),
                                          ],
                                        )
                                    ),
                                    Expanded(
                                        child: Column(
                                          children: [
                                            Text(NUMBER_K(widget.userViewModel.userInfo!.followerCount), style: ItemTitleStyle(context)),
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
                                    maxLines: 6,
                                    decoration: inputLabel(context, '', ''),
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
                            // if (_isWaiting) return;
                            // _isWaiting = true;
                            // setState(() {
                            //   _tabviewHeight = 1000;
                            //   AppData.myProfileTabViewHeightReload = true;
                            //   Future.delayed(Duration(milliseconds: 200), () {
                            //     setState(() {
                            //       _currentTab = index;
                            //       _tabviewHeight = AppData.myProfileTabViewHeight[index];
                            //       _isWaiting = false;
                            //       log("--> onTap _tabviewHeight : $_tabviewHeight} / $index");
                            //     });
                            //   });
                            // });
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
                        height: widget.userViewModel.tabListHeight,
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
    }
    return Container();
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

class MyProfileTab extends StatelessWidget {
  MyProfileTab(this.selectedTab, this.title, this.userViewModel,
      {Key? key, this.isSelectable = false, this.onRefresh})
      : super(key: key);

  ProfileContentTab selectedTab;
  String title;
  UserViewModel userViewModel;
  Function(int)? onRefresh;

  var tabHeight    = 40.0;
  var isSelectable = false;

  Widget getTab() {
    return Tab(text: title, height: tabHeight);
  }

  JSON? _itemList;
  final _edgeInsets     = EdgeInsets.fromLTRB(15, 5, 15, 10);
  final _commentStyle   = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey);
  final _pageShowMax = 5;
  final _itemHeight = 90.0;
  var _pageNow = 0;
  var _pageMax = 0;

  Future<JSON>? _dataInit;
  List<JSON> _showList = [];

  loadExtraData() {
    switch (selectedTab) {
      case ProfileContentTab.event:
        _dataInit = userViewModel.getEventData(true);
        break;
      case ProfileContentTab.story:
        _dataInit = userViewModel.getStoryData();
        break;
    }
    LOG('--> loadExtraData : $selectedTab');
  }

  refreshShowList([double itemHeight = UI_ITEM_HEIGHT]) {
    _showList.clear();
    for (var i=0; i<_pageShowMax; i++) {
      var itemIndex = _pageNow * _pageShowMax + i;
      if (itemIndex >= _itemList!.length) break;
      var key = _itemList!.keys.elementAt(itemIndex);
      _showList.add(_itemList![key].toJson());
    }
    _pageMax = (_itemList!.length / _pageShowMax).floor() + (_itemList!.length % _pageShowMax > 0 ? 1 : 0);
    // LOG('--> refreshShowList : ${_itemList!.length} - $_pageNow / $_pageMax - ${userViewModel.isMyProfile}');
    userViewModel.tabListHeight = (itemHeight * _showList.length + (userViewModel.isMyProfile ? 155.0 : 80.0) + 120.0);
    refreshTabHeight();
  }
  //
  refreshTabHeight() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (onRefresh != null) onRefresh!(selectedTab.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    loadExtraData();
    switch (selectedTab) {
      case ProfileContentTab.event:
        return FutureBuilder(
            future: _dataInit,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _itemList = snapshot.data as JSON;
                LOG('--> ProfileContentTab.placeEvent [${selectedTab.index}] : ${_itemList!.length}');
                refreshShowList();
                return StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        padding: _edgeInsets,
                        child: Column(
                          children: [
                             ..._showList.map((item) => EventCardItem(
                                EventModel.fromJson(item),
                                // animationController: controller,
                                isShowTheme: false,
                                isShowUser: false,
                                isShowHomeButton: false,
                                isShowLike: false,
                                itemHeight: _itemHeight,
                                onRefresh: (updateData) {
                                  setState(() {
                                    // _itemList![key] = updateData;
                                    if (onRefresh != null) onRefresh!(selectedTab.index);
                                  });
                                },
                              )).toList(),
                              if (userViewModel.isMyProfile)...[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child:
                                  Row(
                                    children: [
                                      Expanded(
                                        child: contentAddButton(context, 'EVENT ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
                                        }),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: contentAddButton(context, 'CLASS ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
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
                        )
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
              LOG('--> snapshot : ${snapshot.hasData}');
              if (snapshot.hasData) {
                _itemList = snapshot.data as JSON;
                refreshShowList();
                return StatefulBuilder(
                    builder: (context, setState) {
                      // refreshShowList(_itemHeight);
                      return Container(
                          padding: _edgeInsets,
                          child: Column(
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: _showList.length,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  var item = _showList[index];
                                  if (JSON_NOT_EMPTY(item['picData'])) {
                                    var firstImage = item['picData'].first;
                                    item['url'] = firstImage.runtimeType != String ? firstImage['url'] : firstImage;
                                    // LOG('--> image data : ${item['pic']} / ${item['picData']}');
                                  }
                                  return StoryCardItem(
                                      StoryModel.fromJson(item),
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
                            if (userViewModel.isMyProfile)...[
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child:
                                  Row(
                                      children: [
                                        // Expanded(
                                        //   child: contentAddButton(context, 'SPOT\nSTORY ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
                                        //     // AddStoryContent(context, true, (result) {
                                        //     //   if (result.isNotEmpty) {
                                        //     //     setState(() {
                                        //     //       LOG('--> AddStoryContent result [SPOT] : $result');
                                        //     //       _itemList![result['id']] = result;
                                        //     //       if (onRefresh != null) onRefresh!(selectedTab.index);
                                        //     //     });
                                        //     //   }
                                        //     // });
                                        //   }),
                                        // ),
                                        // SizedBox(width: 5),
                                        Expanded(
                                          child: contentAddButton(context, 'EVENT\nSTORY ADD'.tr, padding: EdgeInsets.symmetric(vertical: 5), onPressed: (_) {
                                            // AddStoryContent(context, false, (result) {
                                            //   if (result.isNotEmpty) {
                                            //     setState(() {
                                            //       LOG('--> AddStoryContent result [EVENT] : $result');
                                            //       _itemList![result['id']] = result;
                                            //       if (onRefresh != null) onRefresh!(selectedTab.index);
                                            //     });
                                            //   }
                                            // });
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
                        )
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
                //           if (JSON_NOT_EMPTY(item['picData'])) {
                //             var firstImage = item['picData'].first;
                //             item['url'] = firstImage.runtimeType != String ? firstImage['url'] : firstImage;
                //             // LOG('--> image data : ${item['pic']} / ${item['picData']}');
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