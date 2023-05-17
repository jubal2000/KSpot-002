import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../utils/utils.dart';

class UserCardWidget extends StatefulWidget {
  UserCardWidget(this.userInfo, { Key? key,
    this.faceSize = FACE_CIRCLE_SIZE_M,
    this.faceCircleSize = 2.0,
    this.nameHeight = 20,
    this.padding = EdgeInsets.zero,
    this.onEdited,
    this.onSelected,
    this.onProfileChanged,
    this.isEditable = false,
    this.isCanFollow = true,
    this.isBottomNameShow = false,
    this.isSideNameShow = false,
    this.isShowTime = false,
  }) : super(key: key);

  JSON userInfo;

  double faceSize;
  double faceCircleSize;
  double nameHeight;
  EdgeInsets padding;
  Function(String, int)? onEdited;
  Function(String)? onSelected;
  Function(JSON)? onProfileChanged;

  bool isEditable;
  bool isCanFollow;
  bool isBottomNameShow;
  bool isSideNameShow;
  bool isShowTime;

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
    // LOG('--> check me [$_isMyProfile] : ${widget.userInfo['userId']} / ${AppData.USER_ID} - ${widget.userInfo['userName']}');
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
          if (widget.onSelected != null) widget.onSelected!(widget.userInfo['userId']);
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
                        width:  widget.faceSize - (widget.isBottomNameShow ? widget.nameHeight : 0),
                        height: widget.faceSize - (widget.isBottomNameShow ? widget.nameHeight : 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(widget.faceSize)),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.8),
                            width: widget.faceCircleSize,
                          ),
                        ),
                        child: ClipOval(
                          child: showImageFit(widget.userInfo['pic'] ?? widget.userInfo['userPic']),
                        ),
                      ),
                      if (widget.isBottomNameShow)...[
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
                if (widget.isSideNameShow)...[
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(STR(widget.userInfo['userName']), style: _isMyProfile ? DescNameMyStyle(context, fontSize: 14) : DescNameStyle(context, fontSize: 14)),
                      if (widget.isCanFollow && !_isMyProfile)...[
                        SizedBox(height: 3),
                        // UserFollowWidget(widget.userInfo),
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