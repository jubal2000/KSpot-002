import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:kspot_002/services/api_service.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';
import '../view/main_my/target_profile.dart';

class UserCardWidget extends StatefulWidget {
  UserCardWidget(this.userInfo, { Key? key,
    this.faceSize = FACE_CIRCLE_SIZE_M,
    this.faceCircleSize = 2.0,
    this.nameHeight = 20,
    this.padding = EdgeInsets.zero,
    this.circleColor,
    this.backgroundColor,
    this.onEdited,
    this.onSelected,
    this.onProfileChanged,
    this.isEditable = false,
    this.isCanFollow = true,
    this.isBottomName = false,
    this.isShowTime = false,
    this.isShowName = true,
  }) : super(key: key);

  JSON userInfo;

  double faceSize;
  double faceCircleSize;
  double nameHeight;
  EdgeInsets padding;
  Color? circleColor;
  Color? backgroundColor;
  Function(String, int)? onEdited;
  Function(String)? onSelected;
  Function(JSON)? onProfileChanged;

  bool isEditable;
  bool isCanFollow;
  bool isBottomName;
  bool isShowTime;
  bool isShowName;

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCardWidget> {
  var _isMyProfile = false;

  refreshData() {
    _isMyProfile = false;
    if (STR(widget.userInfo['userName']).isEmpty && STR(widget.userInfo['nickName']).isNotEmpty) {
      widget.userInfo['userName'] = widget.userInfo['nickName'];
    }
    if (STR(widget.userInfo['userPic']).isEmpty && STR(widget.userInfo['pic']).isNotEmpty) {
      widget.userInfo['userPic'] = widget.userInfo['pic'];
    }
    if (STR(widget.userInfo['userId']) == AppData.USER_ID) {
      _isMyProfile = true;
      if (widget.userInfo['userPic'] != AppData.USER_PIC || widget.userInfo['userName'] != AppData.USER_NICKNAME) {
        // LOG('--> UserCardWidget Pic Update : ${widget.userInfo['userPic']} / ${AppData.USER_PIC}');
        widget.userInfo['userPic' ] = AppData.USER_PIC;
        widget.userInfo['userName'] = AppData.USER_NICKNAME;
        if (widget.onProfileChanged != null) widget.onProfileChanged!(widget.userInfo);
      }
    }
    LOG('--> check me [$_isMyProfile] : ${widget.userInfo['userId']} / ${AppData.USER_ID} - ${widget.userInfo['userName']}');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshData();
    return GestureDetector(
        onTap: () {
          LOG('--> UserCardWidget onSelected : ${widget.userInfo}');
          if (widget.onSelected != null) widget.onSelected!(widget.userInfo['userId'] ?? widget.userInfo['id']);
        },
        child: Container(
            padding: widget.padding,
            child: Row(
              children: [
                Container(
                  width: widget.faceSize,
                  height: widget.faceSize,
                  child: Column(
                    children: [
                      Container(
                        width:  widget.faceSize - (widget.isBottomName ? widget.nameHeight : 0),
                        height: widget.faceSize - (widget.isBottomName ? widget.nameHeight : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(widget.faceSize)),
                          border: Border.all(
                            color: widget.circleColor ?? Theme.of(context).primaryColor.withOpacity(0.8),
                            width: widget.faceCircleSize,
                          ),
                          color: widget.backgroundColor,
                        ),
                        child: ClipOval(
                          child: showImageFit(widget.userInfo['pic'] ?? widget.userInfo['userPic']),
                        ),
                      ),
                      if (widget.isShowName && widget.isBottomName)...[
                        Container(
                            width: double.infinity,
                            height: widget.nameHeight,
                            padding: EdgeInsets.only(top: 5),
                            child: Text(STR(widget.userInfo['userName']), textAlign: TextAlign.center, maxLines: 1,
                              style: ItemDescBoldStyle(context),
                            )
                        )
                      ]
                    ],
                  ),
                ),
                if (widget.isShowName)...[
                  SizedBox(width: 10),
                ],
                if (widget.isShowName && !widget.isBottomName)...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(STR(widget.userInfo['userName']), style: _isMyProfile ? DescNameMyStyle(context) : DescNameStyle(context)),
                      if (widget.isCanFollow && !_isMyProfile)...[
                        SizedBox(height: 3),
                        UserFollowWidget(widget.userInfo),
                      ],
                      if (widget.isShowTime)
                        Text(SERVER_TIME_STR(widget.userInfo['updateTime'] ?? widget.userInfo['createTime']),
                            style: DescBodyInfoStyle(context)),
                    ],
                  )
                ],
              ],
            )
        )
    );
  }
}

class UserFollowWidget extends StatefulWidget {
  UserFollowWidget(this.userInfo, {Key? key, this.fontSize = 12, this.isShowMe = false}) : super(key: key);

  JSON userInfo;
  double fontSize;
  bool isShowMe;

  @override
  _UserFollowState createState() => _UserFollowState();
}

class _UserFollowState extends State<UserFollowWidget> {
  final api = Get.find<ApiService>();
  var _followType = 0;
  var _userId = '';
  onFollowButton() {
    LOG('--> addFollowTarget : ${widget.userInfo}');
    showAlertYesNoDialog(context, 'Follow'.tr, 'Would you like to follow?'.tr, '${'Target'.tr}: ${STR(widget.userInfo['userName'] ?? widget.userInfo['nickName'])}', '아니오', '예').then((result) async {
      if (result == 1) {
        var addItem = await api.addFollowTarget(AppData.userInfo.toJson(), widget.userInfo);
        if (addItem != null) {
          setState(() {
            _followType = _followType == 2 ? 3 : 2;
          });
        }
      }
    });
  }

  @override
  void initState() {
    _userId = widget.userInfo['userId'] ?? widget.userInfo['id'];
    _followType = CheckFollowUser(_userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LOG('--> UserFollowWidget : $_userId');
    return GestureDetector(
        onTap: () {
          if (_followType == 0 || _followType == 1) {
            onFollowButton();
          }
        },
        child: GetFollowBtnStr(context, _userId, fontSize: widget.fontSize)
    );
  }
}

class UserIdCardOneWidget extends StatefulWidget {
  UserIdCardOneWidget(this.userId, { Key? key,
    this.size = 35,
    this.faceCircleSize = 2.0,
    this.padding = const EdgeInsets.all(3),
    this.spacePadding = 0,
    this.isCanExtend = true,
    this.textColor,
    this.backColor,
    this.borderColor,
    this.onEdited,
    this.onSelected,
    this.onProfileChanged,
  }) : super(key: key);

  String userId;

  double faceCircleSize;
  double size;
  EdgeInsets padding;
  double spacePadding;
  bool isCanExtend;
  Color? textColor;
  Color? backColor;
  Color? borderColor;
  Function(String, int)? onEdited;
  Function(String)? onSelected;
  Function(JSON)? onProfileChanged;

  @override
  _UserIdCardOneState createState() => _UserIdCardOneState();
}

class _UserIdCardOneState extends State<UserIdCardOneWidget> {
  var userRepo = UserRepository();
  Future<UserModel?>? userInit;
  UserModel userInfo = UserModelEx.empty('');
  var isMyProfile = false;
  var isOpen = false;

  initData() {
    userInit = userRepo.getUserInfo(widget.userId);
  }

  refreshData() {
    LOG('--> UserIdCardWidget refresh : ${userInfo!.id} / ${AppData.USER_ID}');
    if (userInfo.id == AppData.USER_ID) {
      isMyProfile = true;
      // if (_userInfo['pic'] != AppData.USER_PIC || _userInfo['nickName'] != AppData.USER_NICKNAME) {
      //   LOG('--> UserListCardWidget Pic Update : ${_userInfo['pic']} / ${AppData.USER_PIC}');
      //   _userInfo['pic' ] = AppData.USER_PIC;
      //   _userInfo['nickName'] = AppData.USER_NICKNAME;
      //   if (widget.onProfileChanged != null) widget.onProfileChanged!(_userInfo);
      // }
    }
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (widget.onSelected != null) {
            widget.onSelected!(userInfo.id);
          } else {
            Get.to(() => TargetProfileScreen(userInfo))!.then((value) {
              setState(() {});
            });
          }
        },
        child: FutureBuilder(
            future: userInit,
            builder: (context, snapshot) {
              if (snapshot.hasData || userInfo.id.isNotEmpty) {
                if (snapshot.hasData) {
                  userInfo = snapshot.data as UserModel;
                }
                if (userInfo.id.isEmpty) {
                  return Container();
                }
                refreshData();
                return AnimatedSize(
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: !isOpen ? widget.size : null,
                    height: widget.size,
                    padding: EdgeInsets.only(right: widget.spacePadding),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.size),
                      child: Container(
                        color: widget.backColor ?? Theme
                            .of(context)
                            .primaryColor
                            .withOpacity(0.2),
                        child: Row(
                          children: [
                            if (STR(userInfo.pic).isNotEmpty)...[
                              if (!widget.isCanExtend)
                                Container(
                                  width: widget.size,
                                  height: widget.size,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(widget.size)),
                                    border: Border.all(
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                      width: widget.faceCircleSize,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: showImageFit(userInfo.pic),
                                  ),
                                ),
                              if (widget.isCanExtend)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isOpen = !isOpen;
                                    });
                                  },
                                  child: Container(
                                    width: widget.size,
                                    height: widget.size,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(widget.size)),
                                      border: Border.all(
                                        color: widget.borderColor ?? Theme.of(context).colorScheme.secondary,
                                        width: widget.faceCircleSize,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: showImageFit(userInfo.pic),
                                    ),
                                  ),
                                )
                            ],
                            if (isOpen)...[
                              SizedBox(width: 5),
                              Text(userInfo.nickName, style: CardNameStyle(context), maxLines: 2),
                              SizedBox(width: 10),
                            ],
                          ],
                        )
                      )
                    )
                  )
                );
              } else {
                return Container();
              }
            }
        )
    );
  }
}

class UserIdCardWidget extends StatefulWidget {
  UserIdCardWidget(this.userList, { Key? key,
    this.size = const Size(120, 35),
    this.faceCircleSize = 1.0,
    this.padding = const EdgeInsets.all(3),
    this.isCanExtend = true,
    this.onEdited,
    this.onSelected,
    this.onProfileChanged,
  }) : super(key: key);

  List<JSON> userList;

  bool isCanExtend;
  double faceCircleSize;
  Size   size;
  EdgeInsets padding;
  Function(String, int)? onEdited;
  Function(String)? onSelected;

  Function(JSON)? onProfileChanged;

  @override
  _UserIdCardState createState() => _UserIdCardState();
}

class _UserIdCardState extends State<UserIdCardWidget> {
  Future? _userInit;
  List<Widget> _itemList = [];
  var _isMyProfile = false;

  refreshData() {
    // LOG('--> UserInfoListCardWidget refreshData : ${widget.userList.length}');
    _itemList.clear();
    for (var user in widget.userList) {
      if (user['id'] == AppData.USER_ID) {
        _isMyProfile = true;
        if (user['pic'] != AppData.USER_PIC || user['nickName'] != AppData.USER_NICKNAME) {
          // LOG('--> UserListCardWidget Pic Update : ${user['pic']} / ${AppData.USER_PIC}');
          user['pic'] = AppData.USER_PIC;
          user['nickName'] = AppData.USER_NICKNAME;
          if (widget.onProfileChanged != null) widget.onProfileChanged!(user);
        }
      }
      _itemList.add(UserIdCardOneWidget(user['userId'] ?? user['id'], size: widget.size.height, isCanExtend: widget.isCanExtend, spacePadding: widget.userList.last == user ? 0 : 3));
    }
    // LOG('--> UserInfoListCardWidget result : ${_itemList.length}');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshData();
    if (widget.isCanExtend) {
      return FittedBox(
          fit: BoxFit.fill,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size.height),
              child: Container(
                  color: Theme
                      .of(context)
                      .primaryColor
                      .withOpacity(0.2),
                  padding: widget.padding,
                  child: Row(
                      children: _itemList
                  )
              )
          )
      );
    } else {
      var _itemSize = widget.size.height * 0.5;
      var _xPos = -_itemSize;
      LOG('--> _itemSize : $_itemSize / ${_itemList.length}');
      return Container(
          width: _itemList.length * _itemSize + widget.size.height * 0.5 + widget.padding.horizontal,
          height: widget.size.height + widget.padding.vertical,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size.height),
              child: Container(
                  color: Theme
                      .of(context)
                      .primaryColor
                      .withOpacity(0.2),
                  padding: widget.padding,
                  child: Stack(
                    children: _itemList.map((item) => Positioned(
                        left: _xPos += _itemSize,
                        child: item)).toList(),
                  )
              )
          )
      );
    }
  }
}

class UserInfoListCardWidget extends StatefulWidget {
  UserInfoListCardWidget(this.userList, { Key? key,
    this.size = const Size(120, 30),
    this.faceCircleSize = 1.0,
    this.padding = const EdgeInsets.all(3),
    this.onEdited,
    this.onSelected,
    this.onProfileChanged,
  }) : super(key: key);

  List<JSON> userList;

  double faceCircleSize;
  Size   size;
  EdgeInsets padding;
  Function(String, int)? onEdited;
  Function(String)? onSelected;
  Function(JSON)? onProfileChanged;

  @override
  _UserInfoListCardState createState() => _UserInfoListCardState();
}

class _UserInfoListCardState extends State<UserInfoListCardWidget> {
  final api = Get.find<ApiService>();
  Future? _userInit;
  List<JSON> _userList = [];
  List<Widget> _itemList = [];

  getUserDataFromList() async {
    LOG('--> getUserDataFromList : ${widget.userList.length}');
    _userList.clear();
    for (var item in widget.userList) {
      final user = await api.getUserInfoFromId(item['userId']);
      if (user != null) {
        _userList.add(user);
      }
    }
    LOG('--> getUserDataFromList result : ${_userList.length}');
    return _userList;
  }

  initData() {
    _userInit = getUserDataFromList();
  }

  refreshData() {
    LOG('--> UserInfoListCardWidget refreshData : ${_userList.length}');
    _itemList.clear();
    for (var user in _userList) {
      // refresh user info..
      if (AppData.userInfo.checkOwner(user['id'])) {
        if (user['pic'] != AppData.USER_PIC || user['nickName'] != AppData.USER_NICKNAME) {
          LOG('--> UserListCardWidget Pic Update : ${user['pic']} / ${AppData.USER_PIC}');
          user['pic'] = AppData.USER_PIC;
          user['nickName'] = AppData.USER_NICKNAME;
          if (widget.onProfileChanged != null) widget.onProfileChanged!(user);
        }
      }
      _itemList.add(GestureDetector(
          onTap: () {
            if (widget.onSelected != null) {
              widget.onSelected!(user['id']);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  TargetProfileScreen(UserModel.fromJson(user)))).then((value) {
                setState(() {});
              });
            }
          },
          child: Container(
            width: widget.size.height ,
            height: widget.size.height ,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(widget.size.height)),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: widget.faceCircleSize,
              ),
            ),
            child: ClipOval(
              child: showImageFit(user['pic']),
            ),
          )
      )
      );
    }
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FittedBox(
            fit: BoxFit.fill,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.size.height),
                child: FutureBuilder(
                    future: _userInit,
                    builder: (context, snapshot) {
                      if (snapshot.hasData || _userList.isNotEmpty) {
                        refreshData();
                        return Container(
                            color: Theme
                                .of(context)
                                .primaryColor
                                .withOpacity(0.2),
                            padding: widget.padding,
                            child: Row(
                                children: _itemList
                            )
                        );
                      } else {
                        return showLoadingImageSquare(widget.size.height);
                      }
                    }
                )
            )
        )
    );
  }
}

isFollowUser(String userId) {
  final status = CheckFollowUser(userId);
  return status > 0;
}

// ignore: non_constant_identifier_names
CheckFollowUser(String userId) {
  var result = 0;
  // LOG('--> CheckFollowUser : $userId / ${AppData.USER_ID}');
  if (userId == AppData.USER_ID) return -1;
  for (var item in AppData.followData.entries) {
    // LOG('--> CheckFollowUser item : ${item.value['userId']} / ${item.value['targetId']}');
    if (item.value.userId   == userId) result = result == 2 ? 3 : 1; // following..
    if (item.value.targetId == userId) result = result == 1 ? 3 : 2; // follower..
  }
  // LOG('--> CheckFollowUser result : $result');
  return result;
}

// ignore: non_constant_identifier_names
GetFollowBtnStr(BuildContext context, String userId, {double fontSize = 12, bool isShowMe = false}) {
  var _textStyle0 = TextStyle(fontSize: fontSize, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700);
  var _textStyle1 = TextStyle(fontSize: fontSize, color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w600);
  var _textStyle2 = TextStyle(fontSize: fontSize, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w800);
  var _textStylex = TextStyle(fontSize: fontSize, color: Theme.of(context).hintColor, fontWeight: FontWeight.w400);
  switch(CheckFollowUser(userId)) {
    case 0:
      return Text('Follow+'.tr, style: _textStyle0);
    case 1:
      return Text('Follow1'.tr, style: _textStyle1);
    case 2:
      return Text('Follow2'.tr, style: _textStyle1);
    case 3:
      return Text('Follow*'.tr, style: _textStyle2);
  }
  return Text(isShowMe ? 'Me'.tr : '', style: _textStylex);
}

// ignore: non_constant_identifier_names
GetFollowIconBtnStr(BuildContext context, String userId, {double fontSize = 12}) {
  var _textStyle0 = TextStyle(fontSize: fontSize, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700);
  var _textStyle1 = TextStyle(fontSize: fontSize, color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w600);
  var _textStyle2 = TextStyle(fontSize: fontSize, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600);
  var _textStylex = TextStyle(fontSize: fontSize, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w800);
  switch(CheckFollowUser(userId)) {
    case 0:
      return Row(
        children: [
          Icon(Icons.add_box_outlined, size: fontSize + 5, color: Theme.of(context).primaryColor),
          SizedBox(width: 3),
          Text('Follow+'.tr, style: _textStyle1)
        ],
      );
  // return Text('Follow+', style: _textStyle0);
    case 1:
      return Row(
        children: [
          Icon(Icons.record_voice_over_outlined, size: fontSize + 5, color: Theme.of(context).primaryColor),
          SizedBox(width: 3),
          Text('Follow2'.tr, style: _textStyle1)
        ],
      );
  // return Text('Follow', style: _textStyle1);
    case 2:
      return Row(
        children: [
          Icon(Icons.hail, size: fontSize + 5, color: Theme.of(context).primaryColor),
          SizedBox(width: 3),
          Text('Follow1'.tr, style: _textStyle1)
        ],
      );
    case 3:
      return Row(
        children: [
          Icon(Icons.cached, size: fontSize + 5, color: Theme.of(context).primaryColor),
          SizedBox(width: 3),
          Text('Follow*'.tr, style: _textStyle2)
        ],
      );
  }
  return Row(
    children: [
      Icon(Icons.tag_faces_sharp, size: fontSize + 5, color: Theme.of(context).primaryColor),
      SizedBox(width: 3),
      Text('Me'.tr, style: _textStylex)
    ],
  );
}