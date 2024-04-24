import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/widget/csc_picker/csc_picker.dart';
import 'package:kspot_002/widget/scrollview_widget.dart';
import 'package:kspot_002/widget/vote_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'dart:developer';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../view/story/story_screen.dart';

class CommentListItem extends StatefulWidget {
  CommentListItem(
      this.commentData,
      this.commentType,
      this.targetUser,
      {Key? key,
        this.height = 100,
        this.paddingSide = 0,
        this.isShowDivider = true,
        this.isEditable = false,
        this.isAuthor = false,
        this.maxLine = 10,
        this.onChanged,
        this.onItemVisible
      }) : super (key: key);

  JSON        commentData;
  CommentType commentType;
  JSON        targetUser;

  double  height;
  double  paddingSide;
  bool    isShowDivider;
  bool    isEditable;
  bool    isAuthor;
  int     maxLine;

  void Function(JSON, int)? onChanged;
  void Function(int, bool)? onItemVisible;

  @override
  CommentListItemState createState() => CommentListItemState();
}

class CommentListItemState extends State<CommentListItem> {
  // final _nameStyle    = TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black);
  // final _nameStyle2   = TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blueAccent);
  // final _descStyle    = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black);
  // final _dateStyle    = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey);
  // final _buttonStyle  = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black);
  // final _authorStyle  = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.purple);
  var   _isParent = false;
  var   _isWriter = false;
  final _key = GlobalKey();
  JSON _addData = {};
  List<String> _imageList = [];

  onChangeValue(JSON data, int status) {
    if (widget.onChanged != null) {
      widget.onChanged!(data, status);
    }
  }

  refreshImage() {
    if (widget.commentData['picData'] != null) {
      _imageList = List<String>.from(widget.commentData['picData']
          .map((value) => value.toString())
          .toList());
    }
  }

  @override
  void initState() {
    super.initState();
    // AppData.USER_LEVEL = 1; // for Dev..
    _isParent   = STR(widget.commentData['parentId']).toString().isEmpty;
    _isWriter   = widget.commentData['userId'] == AppData.USER_ID || AppData.userInfo.status > 1;
    refreshImage();
  }

  getWidgetSize() {
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    var size = renderBox.size; // or _widgetKey.currentContext?.size
    return Size(size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    // var _authorStyle  = TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor);
    // var _nameStyle    = TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).hintColor);
    // var _editStyle    = TextStyle(color: Theme.of(context).colorScheme.secondary);
    var _authorStyle  = TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.tertiary);
    var _nameStyle    = TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary);
    var _descStyle    = TextStyle(color: Theme.of(context).indicatorColor);
    var _dateStyle    = TextStyle(color: Theme.of(context).hintColor.withOpacity(0.5), fontSize: 12);
    var _editStyle    = TextStyle(color: Theme.of(context).hintColor);
    var _userName     = STR(widget.commentData['userName']);
    var _userNameStr  = widget.isAuthor ? '[${'MANAGER'.tr}]' : _isWriter ? '[$_userName]' : _userName;

    return VisibilityDetector(
      key: GlobalKey(),
      onVisibilityChanged: (info) {
      if (widget.onItemVisible != null) widget.onItemVisible!(INT(widget.commentData['index']), info.visibleFraction > 0);
      },
      child: Container(
        key: _key,
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            SizedBox(height: 10),
            if (_isParent && widget.isShowDivider)...[
              showHorizontalDivider(Size(double.infinity, 2), color: Theme.of(context).secondaryHeaderColor),
              SizedBox(height: 10),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isParent) ...[
                  Image.asset('assets/ui/sub_line_01.png', width: 20, height: 25, color: Theme.of(context).primaryColor.withOpacity(0.25)),
                  SizedBox(width: 10),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_userNameStr, style: widget.isAuthor ? _authorStyle : _isWriter ? SubTitleExStyle(context) : _nameStyle),
                        if (_isParent && !widget.isAuthor && widget.commentType == CommentType.comment)...[
                          SizedBox(width: 10),
                          VoteWidget(widget.commentData['vote'] ?? 1),
                        ],
                      ],
                    ),
                    if (_imageList.isNotEmpty && (!BOL(widget.commentData['isHidden']) || AppData.userInfo.status > 1))...[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - (_isParent ? 30 : 60) - widget.paddingSide,
                        child: CommentImageScrollViewer(_imageList),
                      ),
                    ],
                    if (STR(widget.commentData['desc']).isNotEmpty)...[
                      if (BOL(widget.commentData['isHidden']) && AppData.userInfo.status < 2)...[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.lock, size: 20, color: Theme.of(context).colorScheme.error),
                              SizedBox(width: 5),
                              Text('This is a secret...'.tr, style: _descStyle, maxLines: 1),
                            ],
                          ),
                        ),
                      ],
                      if (!BOL(widget.commentData['isHidden']) || AppData.userInfo.status > 1)...[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              if (AppData.USER_LEVEL > 1 && BOL(widget.commentData['isHidden']))...[
                                Icon(Icons.lock, color: Colors.black, size: 20),
                                SizedBox(width: 5),
                              ],
                              Text(DESC(widget.commentData['desc']), style: _descStyle, maxLines: widget.maxLine),
                            ],
                          ),
                        ),
                      ],
                    ],
                    Row(
                      children: [
                        Text(SERVER_TIME_STR(widget.commentData['updateTime'] ?? widget.commentData['createTime']), style: _dateStyle),
                        SizedBox(width: 10),
                        if (_isParent && (widget.commentType != CommentType.serviceQnA || AppData.USER_LEVEL > 1)) ...[
                          GestureDetector(
                            child: Text(widget.commentType != CommentType.qna || widget.commentType != CommentType.serviceQnA ?
                              '[${'COMMENT'.tr}]' : '[${'REPLY'.tr}]', style: _editStyle),
                            onTap: () {
                              log('--> showEditCommentDialog : ${widget.commentData}');
                              _addData = {};
                              _addData['status'] = 1;
                              _addData['desc'] = '';
                              _addData['picData']   = [];
                              _addData['targetType']  = widget.commentData['targetType'];
                              _addData['targetId']    = widget.commentData['targetId'];
                              _addData['parentId']    = widget.commentData['id'];
                              _addData['descOrg']     = widget.commentData['desc'];
                              _addData['userId']      = AppData.USER_ID;
                              _addData['userName']    = AppData.USER_NICKNAME;
                              showEditCommentDialog(context,
                                  widget.commentType,
                                  widget.commentType == CommentType.comment ? 'COMMENT'.tr : 'REPLY'.tr, _addData,
                                  widget.targetUser,
                                  false, false, true).then((result) {
                                log('--> showEditCommentDialog result : $result');
                                if (JSON_NOT_EMPTY(result)) {
                                  setState(() {
                                    _addData = result!;
                                    onChangeValue(_addData, 1);
                                  });
                                }
                              });
                            },
                          ),
                        ],
                        // if (!widget.isAuthor) ...[
                        //   GestureDetector(
                        //     child: Text('[신고/차단]', style: _dateStyle),
                        //     onTap: () {
                        //     },
                        //   ),
                        // ],
                        SizedBox(width: 5),
                        if (_isWriter) ...[
                          GestureDetector(
                            child: Text('[${'Edit/Del'.tr}]', style: _editStyle),
                            onTap: () {
                              LOG('--> showEditCommentDialog : ${widget.commentData}');
                              showEditCommentDialog(context,
                                  widget.commentType, 'EDIT'.tr,
                                  widget.commentData,
                                  widget.targetUser,
                                  true,
                                  !_isParent,
                                  true).then((result) {
                                LOG('--> showEditCommentDialog result : $result');
                                if (JSON_NOT_EMPTY(result) && mounted) {
                                  setState(() {
                                    if (result!['delete'] != null) {
                                      onChangeValue(widget.commentData, 2);
                                    } else {
                                      widget.commentData = result;
                                      refreshImage();
                                      log('--> widget.infoData[newId] : ${widget.commentData}');
                                      onChangeValue(widget.commentData, 0);
                                    }
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ]
                    ),
                  ]
                )
              ]
            )
          ]
        )
      )
    );
  }
}

class CommentListExItem extends StatefulWidget {
  CommentListExItem(
      this.commentData,
      this.commentType,
      this.targetData,
      {Key? key,
        this.height = 100,
        this.paddingSide = 0,
        this.isShowDivider = true,
        this.isEditable = false,
        this.isAuthor = false,
        this.isShowMenu = true,
        this.isShowAuthor = true,
        this.maxLine = 10,
        this.onChanged
      }) : super (key: key);

  JSON        commentData;
  CommentType commentType;
  JSON        targetData;

  double  height;
  double  paddingSide;
  bool    isShowDivider;
  bool    isEditable;
  bool    isAuthor;
  bool    isShowAuthor;
  bool    isShowMenu;
  int     maxLine;

  void Function(JSON, int)? onChanged;

  @override
  CommentListExItemState createState() => CommentListExItemState();
}

class CommentListExItemState extends State<CommentListExItem> {
  final api = Get.find<ApiService>();
  var   _isParent = false;
  var   _isWriter = false;
  final _key = GlobalKey();
  JSON _addData = {};
  List<dynamic> _imageList = [];

  onChangeValue(JSON data, int status) {
    if (widget.onChanged != null) {
      widget.onChanged!(data, status);
    }
  }

  refreshImage() {
    if (widget.commentData['picData'] != null) {
      _imageList = widget.commentData['picData'].toList();
    }
  }

  @override
  void initState() {
    super.initState();
    // AppData.USER_LEVEL = 1; // for Dev..
    _isParent   = STR(widget.commentData['parentId']).toString().isEmpty;
    _isWriter   = widget.commentData['userId'] == AppData.USER_ID || AppData.USER_LEVEL > 1;
    refreshImage();
  }

  getWidgetSize() {
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    var size = renderBox.size; // or _widgetKey.currentContext?.size
    return Size(size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    var _authorStyle  = TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.tertiary);
    var _nameStyle    = TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary);
    var _descStyle   = TextStyle(color: Theme.of(context).indicatorColor);
    var _editStyle   = TextStyle(color: Theme.of(context).hintColor);
    var _dateStyle   = TextStyle(fontSize: 12, color: Theme.of(context).hintColor.withOpacity(0.5));
    LOG('--> CommentListExItem item : ${widget.commentData}');

    return GestureDetector(
      onTap: () {
        // if (widget.commentType == CommentType.story) {
        //   LOG('--> CommentListExItem selected : ${widget.commentData['id']}');
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => StoryDetailScreen(widget.commentData)));
        // }
      },
      child: LayoutBuilder(
      builder: (context, layout) {
      return Container(
        key: _key,
        width: Get.width,
        margin: EdgeInsets.symmetric(vertical: 3),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isParent) ...[
                Image.asset('assets/ui/sub_line_01.png', width: 30, height: 25, color: Theme.of(context).hintColor),
                SizedBox(width: 5),
              ],
              // if (JSON_NOT_EMPTY(widget.commentData['picData']))...[
              //   showImage(widget.commentData['picData'].first.runtimeType == String ?
              //     widget.commentData['picData'].first : widget.commentData['picData'].first['url'],
              //     Size(widget.height - 20, widget.height - 20)),
              // ],
              // SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_imageList.isNotEmpty && (!BOL(widget.commentData['isHidden']) || AppData.USER_LEVEL > 1))...[
                    SizedBox(
                      width: layout.maxWidth - 20 - (!_isParent ? 35 : 0),
                      child: CommentImageScrollViewer(_imageList),
                    ),
                  ],
                  if (_isParent && !widget.isAuthor && widget.commentType == CommentType.comment) ...[
                    SizedBox(width: 10),
                    VoteWidget(widget.commentData['vote'] ?? 1),
                  ],
                  if (widget.commentData['desc'] != null)...[
                    if (BOL(widget.commentData['isHidden']) && AppData.USER_LEVEL < 2)...[
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.lock, size: 20, color: Theme.of(context).colorScheme.error),
                            SizedBox(width: 5),
                            Text('This is a secret...'.tr, style: _descStyle, maxLines: 1),
                          ],
                        ),
                      ),
                    ],
                    if (!BOL(widget.commentData['isHidden']) || AppData.IS_ADMIN)...[
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            if (AppData.IS_ADMIN && BOL(widget.commentData['isHidden']))...[
                              Icon(Icons.lock, color: Colors.black, size: 20),
                              SizedBox(width: 5),
                            ],
                            Text(DESC(widget.commentData['desc']), style: _descStyle, maxLines: widget.maxLine),
                          ],
                        ),
                      ),
                    ],
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(SERVER_TIME_STR(widget.commentData['updateTime'] ?? widget.commentData['createTime']),
                          style: _dateStyle),
                      SizedBox(width: 10),
                      if (widget.isShowAuthor)
                        Text(widget.isAuthor ? '[${'MANAGER'.tr}]' : STR(widget.commentData['userName']),
                            style: widget.isAuthor ? _authorStyle : _isWriter ? SubTitleExStyle(context) : _nameStyle),
                      if (widget.isShowMenu)...[
                        SizedBox(width: 10),
                        if (_isParent && (widget.commentType != CommentType.serviceQnA || AppData.USER_LEVEL > 1)) ...[
                          GestureDetector(
                            child: Text(widget.commentType == CommentType.qna ? '[Answer]'.tr : '[Comment]'.tr, style: _editStyle),
                            onTap: () async {
                              log('--> showEditCommentDialog : ${widget.commentData} / ${widget.targetData}');
                              var targetUser = await api.getUserInfoFromId(widget.targetData['userId']);
                              if (targetUser != null) {
                                _addData = {};
                                _addData['status'] = 1;
                                _addData['desc'] = '';
                                _addData['picData'] = [];
                                _addData['targetType'] = widget.commentData['targetType'];
                                _addData['targetId'] = widget.commentData['targetId'];
                                _addData['parentId'] = widget.commentData['id'];
                                _addData['descOrg'] = widget.commentData['desc'];
                                _addData['userId'] = AppData.USER_ID;
                                _addData['userName'] = AppData.USER_NICKNAME;
                                showEditCommentDialog(
                                  context,
                                  widget.commentType,
                                  widget.commentType == CommentType.qna ? 'Answer'.tr : 'Comment'.tr,
                                  _addData,
                                  targetUser,
                                  false,
                                  false,
                                  widget.commentType != CommentType.story).then((result) {
                                log('--> showEditCommentDialog result : $result');
                                if (JSON_NOT_EMPTY(result)) {
                                  setState(() {
                                    _addData = result!;
                                    onChangeValue(_addData, 1);
                                  });
                                }
                              });
                            } else {
                              showAlertDialog(context, 'Error'.tr, 'Can not find user information'.tr, '', 'OK'.tr);
                            }
                          },
                        ),
                      ],
                      // if (!widget.isAuthor) ...[
                      //   GestureDetector(
                      //     child: Text('[신고/차단]', style: _dateStyle),
                      //     onTap: () {
                      //     },
                      //   ),
                      // ],
                      SizedBox(width: 5),
                      if (_isWriter) ...[
                        GestureDetector(
                          child: Text('[Del/Edit]'.tr, style: _editStyle),
                          onTap: () async {
                            log('--> showEditCommentDialog : ${widget.commentData}');
                            var targetUser = await api.getUserInfoFromId(widget.targetData['userId']);
                            if (targetUser != null) {
                              showEditCommentDialog(
                                  context,
                                  widget.commentType,
                                  'Comment'.tr,
                                  widget.commentData,
                                  targetUser,
                                  widget.commentType != CommentType.story,
                                  !_isParent,
                                  true).then((result) {
                                log('--> showEditCommentDialog result : $result');
                                if (JSON_NOT_EMPTY(result)) {
                                  setState(() {
                                    if (result!['delete'] != null) {
                                      onChangeValue(widget.commentData, 2);
                                    } else {
                                      widget.commentData = result!;
                                      refreshImage();
                                      log('--> widget.infoData[newId] : ${widget.commentData}');
                                      onChangeValue(widget.commentData, 0);
                                    }
                                  });
                                }
                              });
                            } else {
                              showAlertDialog(context, 'Error'.tr, 'Can not find user information'.tr, '', 'OK'.tr);
                            }
                          },
                        ),
                      ],
                    ]
                  ]
                ),
              ]
            )
          ]
        )
      );
    }
      )
    );
  }
}

class GoodsInfoTextItem extends StatefulWidget {
  GoodsInfoTextItem(this.index, this.itemData, { Key? key }) : super(key: key);

  int index;
  JSON itemData;

  @override
  GoodsInfoTextItemState createState() => GoodsInfoTextItemState();
}

class GoodsInfoTextItemState extends State<GoodsInfoTextItem> {
  final TextStyle _textStyle = TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w300);
  final _key = GlobalKey();
  List<Widget> _itemList = [];

  @override
  void initState() {
    super.initState();
  }

  getWidgetSize() {
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    final Size size = renderBox.size; // or _widgetKey.currentContext?.size
    return size;
  }

  @override
  Widget build(BuildContext context) {
    log('--> GoodsInfoTextItem : ${widget.itemData}');
    widget.itemData.forEach((key, value) {
      switch(key) {
        case 'image': _itemList.add(showImage(value, Size(200,200))); break;
        case 'text' : _itemList.add(Text(value, style: _textStyle)); break;
        case 'space': _itemList.add(SizedBox(height: double.parse(value.toString()))); break;
      }
    });

    return Container(
      key: _key,
      padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: Column(
        children: _itemList,
      ),
    );
  }
}