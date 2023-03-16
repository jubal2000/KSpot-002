import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:kspot_002/utils/utils.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../profile/profile_target_screen.dart';

class SetupBlockScreen extends StatefulWidget {
  SetupBlockScreen({Key? key}) : super(key: key);

  @override
  SetupBlockState createState() => SetupBlockState();
}

class SetupBlockState extends State<SetupBlockScreen> {
  final api = Get.find<ApiService>();
  final userRepo = UserRepository();
  final _tabTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black);
  List<SetupBlockTab> _tabList = [];
  Future<bool>? _blockInit;

  refreshTab() {
    _tabList = [
      SetupBlockTab(0, "Block list".tr),
      SetupBlockTab(1, "Report list".tr),
    ];
  }

  Future<bool> getBlockData() async {
    if (AppData.blockUserData.isEmpty) {
      await userRepo.getBlockData();
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _blockInit = getBlockData();
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Declare/Report list'.tr, style: AppBarTitleStyle(context)),
          toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
          titleSpacing: 0,
        ),
        body: Material(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: FutureBuilder(
              future: _blockInit,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data != null) {
                  refreshTab();
                  return DefaultTabController(
                    length: _tabList.length,
                    child: Scaffold(
                      appBar: TabBar(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        labelColor: Theme.of(context).primaryColor,
                        labelStyle: ItemTitleStyle(context),
                        unselectedLabelColor: Theme.of(context).hintColor,
                        unselectedLabelStyle: ItemTitleStyle(context),
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: _tabList.map((item) => item.getTab()).toList(),
                        onTap: (value) {
                        },
                      ),
                      body: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: _tabList,
                      ),
                    ),
                  );
                } else {
                  return showLoadingFullPage(context);
                }
              }
            )
          )
        )
      )
    );
  }
}

class SetupBlockTab extends StatefulWidget {
  SetupBlockTab(this.index, this.title, {Key? key}) : super(key: key);

  int index;
  String title;

  Widget getTab() {
    return Tab(text: title, height: 50);
  }

  @override
  SetupBlockTabState createState() => SetupBlockTabState();
}

class SetupBlockTabState extends State<SetupBlockTab> {
  final api = Get.find<ApiService>();
  final userRepo = UserRepository();

  final _noUserText = TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.grey);
  JSON _itemData = {};
  List<Widget> _itemList = [];
  Future<JSON>? _initData;

  onMenuSelected(menu, key, userInfo) {
    var menuType = menu as DropdownItemType;
    LOG('--> onMenuSelected : $menu / $key => $menuType');
    var itemData = {};
    if (menuType == DropdownItemType.showDeclar || menuType == DropdownItemType.reDeclar || menuType == DropdownItemType.unDeclar) {
      for (var type in _itemData.keys) {
        for (var item in _itemData[type].entries) {
          if (item.value['id'] == key) {
            itemData = item.value;
            break;
          }
        }
      }
    }
    switch(menuType) {
      case DropdownItemType.unblock:
        showAlertYesNoDialog(context, 'Unblock'.tr,
          'Do you want to unblock?'.tr, '${'Target'.tr}: ${userInfo['nickName']}', 'Cancel'.tr, 'OK'.tr).then((value) {
          if (value == 1) {
            showLoadingDialog(context, 'processing now...'.tr);
            api.setBlockItemStatus(key, 0).then((result) {
              hideLoadingDialog();
              if (result) {
                setState(() {
                  ShowToast('Unblocking is complete'.tr);
                  _itemData.remove(userInfo['id']);
                  refreshItemList();
                });
              }
            });
          }
        });
        break;
      case DropdownItemType.showDeclar:
        if (itemData.isNotEmpty) {
          showTextInputLimitExDialog(context,
            'View report'.tr, '', itemData['desc'], 1, 9999, 6, TextInputType.multiline, null, 'Update'.tr).then((message) async {
            var desc = STR(message['desc']).toString();
            if (desc.isNotEmpty && message['exButton'] != null) {
              showLoadingDialog(context, 'processing now...'.tr);
              userRepo.setReportDesc(key, desc).then((result) {
                hideLoadingDialog();
                if (result) {
                  setState(() {
                    ShowToast('Update has been completed'.tr);
                    refreshItemList();
                  });
                }
              });
            }
          });
        }
        break;
      case DropdownItemType.reDeclar:
        if (itemData.isNotEmpty) {
          var descInfo = AppData.INFO_DECLAR[itemData['replayType']];
          if (descInfo != null) {
            showAlertDialog(context, TR(descInfo['title']), TR(descInfo['desc']), DESC(itemData['replayDesc']), 'OK'.tr);
          } else {
            ShowToast('Report is pending'.tr);
          }
        }
        break;
      case DropdownItemType.unDeclar:
        if (itemData.isNotEmpty) {
          if (itemData['replayType'] == 'done') {
            showAlertDialog(context, 'Report'.tr, 'Processing is complete'.tr, '', 'OK'.tr);
          } else {
            showAlertYesNoDialog(context, 'Report cancel'.tr,
              'Are you sure you want to cancel it?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
              if (result == 1) {
                showLoadingDialog(context, 'processing now...'.tr);
                api.setReportItemStatus(key, 0).then((result2) {
                  hideLoadingDialog();
                  if (result2) {
                    setState(() {
                      ShowToast('Processing is complete'.tr);
                      LOG('--> _itemData [${itemData['targetId']}] : ${_itemData.toString()}');
                      _itemData['report'].remove(itemData['targetId']);
                      refreshItemList();
                    });
                  }
                });
              }
            });
          }
        }
        break;
    }
  }

  initItemList() {
    if (widget.index == 0) {
      _initData = userRepo.getBlockData();
    } else {
      _initData = userRepo.getReportData();
    }
  }

  refreshItemList() {
    _itemList = [];
    if (widget.index == 0) {
      for (var item in _itemData.entries) {
        LOG('--> add block item :${item.value}');
        _itemList.add(UserListItem(UserListType.block,
            item.value, onMenuSelected: onMenuSelected));
      }
    } else {
      for (var type in _itemData.keys) {
        for (var item in _itemData[type].entries) {
          LOG('--> add report item : $type / ${item.value}');
          _itemList.add(UserListItem(UserListType.report,
              item.value, height: 80, padding: EdgeInsets.fromLTRB(20, 10, 10, 10), onMenuSelected: onMenuSelected));
        }
      }
    }
  }

  @override
  void initState() {
    initItemList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FutureBuilder(
        future: _initData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _itemData = snapshot.data as JSON;
            refreshItemList();
            return Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_itemList.isNotEmpty)
                      Column(
                        children: _itemList,
                      ),
                    if (_itemList.isEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Center(
                          child: Text('List does not exist'.tr, style: ItemTitleLargeStyle(context), textAlign: TextAlign.center),
                        )
                      )
                  ],
                ),
              )
            );
          } else {
            return showLoadingCircleSquare(30);
          }
        }
      )
    );
  }
}

enum UserListType {
  normal,
  block,
  report,
}

class UserListItem extends StatefulWidget {
  UserListItem(this.type, this.itemInfo, {Key? key,
    this.isSelectable = false,
    this.isShowMenu = true,
    this.height = 70.0,
    this.padding = const EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE, vertical: 5),
    this.onMenuSelected}) : super(key: key);

  UserListType type;
  JSON itemInfo;
  bool isSelectable;
  bool isShowMenu;
  double height;
  EdgeInsets padding;

  Function(DropdownItemType, String, JSON)? onMenuSelected;

  @override
  UserListItemState createState() => UserListItemState();
}

class UserListItemState extends State<UserListItem> {
  final api = Get.find<ApiService>();
  final userRepo = UserRepository();
  Future<JSON?>? _userInit;
  var _id = '';
  var _isChecked = false;
  var _replayType = '';
  var dateText = '';
  JSON _userInfo = {};

  @override
  void initState() {
    _id = widget.itemInfo['targetId'] != null ? STR(widget.itemInfo['targetId']) : widget.itemInfo['id'];
    if (widget.type == UserListType.report) {
      _replayType = STR(widget.itemInfo['replayType']);
    } else {
      _userInit = api.getUserInfoFromId(_id);
    }
    dateText = widget.type == UserListType.block ? '${'Block date'.tr}: ' : widget.type == UserListType.report ? '${'Report date'.tr}: ' : '';
    LOG('--> widget.type : ${widget.type}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        color: Theme.of(context).canvasColor,
      ),
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: widget.padding,
      child: FutureBuilder(
        future: _userInit,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData || widget.type == UserListType.report) {
            _userInfo = snapshot.data;
            return Row(
              children: [
                if (widget.type == UserListType.block && widget.isSelectable)
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                        if (_isChecked) {
                          AppData.listSelectData[_id] = _userInfo;
                        } else {
                          AppData.listSelectData.remove(_id);
                        }
                      });
                    }
                  ),
                if (widget.type != UserListType.report) ...[
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: ClipOval(
                        child: showImageFit(_userInfo['pic'] ?? 'assets/ui/main_picture_00.png')
                    ),
                  ),
                  SizedBox(width: 10),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => ProfileTargetScreen(UserModel.fromJson(_userInfo)));
                      // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      //     TargetProfileScreen(_userInfo)));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.type != UserListType.report) ...[
                              Text(STR(_userInfo['nickName']), style: ItemTitleStyle(context)),
                            ],
                            if (widget.type == UserListType.report) ...[
                              Text(STR(widget.itemInfo['targetTitle']), style: ItemTitleStyle(context)),
                            ],
                            if (_replayType.isNotEmpty && AppData.INFO_DECLAR[_replayType] != null)...[
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.all(3),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.blueAccent,
                                ),
                                child: Text(TR(AppData.INFO_DECLAR[_replayType]['title']),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    )
                                ),
                              )
                            ]
                          ],
                        ),
                        if (widget.type == UserListType.normal && STR(_userInfo['message']).isNotEmpty) ...[
                          SizedBox(height: 5),
                          Text(DESC(_userInfo['message']), maxLines: 2, style: ItemDescStyle(context)),
                        ],
                        if (widget.type == UserListType.block || widget.type == UserListType.report) ...[
                          if (STR(widget.itemInfo['desc']).isNotEmpty) ...[
                            SizedBox(height: 5),
                            Text(DESC(widget.itemInfo['desc']), maxLines: 2, style: ItemDescStyle(context)),
                          ],
                          SizedBox(height: 5),
                          Text('$dateText${SERVER_TIME_STR(widget.itemInfo['createTime'])}',
                              maxLines: 2, style: ItemDescStyle(context)),
                        ]
                      ],
                    ),
                  )
                ),
                SizedBox(width: 10),
                EditMenuWidget(),
              ],
            );
          } else {
            return showLoadingFullPage(context);
          }
        }
      )
    );
  }

  EditMenuWidget() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Container(
          width: 24,
          height: double.infinity,
          alignment: Alignment.centerRight,
          child: Icon(Icons.more_vert_outlined, size: 22),
        ),
        // customItemsIndexes: widget.type == UserListType.block ? const[9] : const [2],
        // customItemsHeights: const [5],
        itemHeight: 45,
        dropdownWidth: 160,
        buttonHeight: 30,
        buttonWidth: 30,
        itemPadding: const EdgeInsets.only(left: 12, right: 12),
        offset: const Offset(0, 8),
        items: [
          if (widget.type == UserListType.block)
            ...UserMenuItems.blockMenu.map((item) =>
              DropdownMenuItem<DropdownItem>(
                value: item,
                child: DropdownItems.buildItem(context, item),
              ),
            ),
          if (widget.type == UserListType.report)
            ...UserMenuItems.declarMenu.map((item) =>
                DropdownMenuItem<DropdownItem>(
                  value: item,
                  child: DropdownItems.buildItem(context, item),
                ),
            ),
        ],
        onChanged: (value) {
          var selected = value as DropdownItem;
          if (widget.onMenuSelected != null) widget.onMenuSelected!(selected.type, widget.itemInfo['id'], _userInfo);
        },
      ),
    );
  }
}