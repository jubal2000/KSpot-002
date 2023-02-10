import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/widget/page_widget.dart';

import '../data/app_data.dart';
import '../data/dialogs.dart';
import '../data/style.dart';
import '../data/theme_manager.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import 'comment_item_widget.dart';

class CommentTabWidget extends StatefulWidget {
  CommentTabWidget(this.parentInfo, this.type, {Key? key, this.isManager = false}) : super(key: key);

  JSON parentInfo;
  String type;
  bool isManager;

  List<GlobalKey> tabKeyList = [];
  List<CommentGroupTab> tabList = [];
  var tabviewHeight = 200.0;
  var tabviewHeightOrg = 0.0;
  var currentTab = 0;
  // Map<int, double> tabHeight = {};

  @override
  CommenetTabState createState() => CommenetTabState();
}

class CommenetTabState extends State<CommentTabWidget> {

  refreshCommentTabData() {
    LOG('---> refreshInfoTabData');
    if (widget.tabList.isEmpty) {
      widget.tabKeyList.add(GlobalKey());
      widget.tabList.add(CommentGroupTab(
        widget.type, CommentType.story, 'STORY'.tr,
        widget.parentInfo,
        key: widget.tabKeyList.last,
        isAuthor: STR(widget.parentInfo['userId']) == AppData.USER_ID,
        isManager: widget.isManager,
        onChanged: (data) {
          // firestoreCacheData['goodsData'][_placeInfo['id']] = _placeInfo;
        },
        onRefreshHeight: setTabHeight,
      ));
      widget.tabKeyList.add(GlobalKey());
      widget.tabList.add(CommentGroupTab(
        widget.type, CommentType.comment, 'COMMENT'.tr,
        widget.parentInfo,
        key: widget.tabKeyList.last,
        isAuthor: STR(widget.parentInfo['userId']) == AppData.USER_ID,
        isManager: widget.isManager,
        onChanged: (data) {
          // firestoreCacheData['goodsData'][_placeInfo['id']] = _placeInfo;
        },
        onRefreshHeight: setTabHeight,
      ));
      widget.tabKeyList.add(GlobalKey());
      widget.tabList.add(CommentGroupTab(
        widget.type, CommentType.qna, 'QnA'.tr,
        widget.parentInfo,
        key: widget.tabKeyList.last,
        isAuthor: STR(widget.parentInfo['userId']) == AppData.USER_ID,
        isManager: widget.isManager,
        onChanged: (data) {
          // firestoreCacheData['goodsData'][_placeInfo['id']] = _placeInfo;
        },
        onRefreshHeight: setTabHeight,
      ));
    }
  }

  setTabHeight(double height) {
    if (mounted) {
      setState(() {
        if (height > widget.tabviewHeight) {
          widget.tabviewHeightOrg = widget.tabviewHeight;
          widget.tabviewHeight = height;
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
    return Container(
      child: CommentTab(),
    );
  }

  Widget CommentTab() {
    refreshCommentTabData();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: DefaultTabController(
        length: widget.tabList.length,
        child: Column(
          children: [
            showHorizontalDivider(Size(double.infinity, 20), color: Colors.grey.withOpacity(0.25)),
            SizedBox(
              height: 40,
              child: TabBar(
                labelPadding: EdgeInsets.zero,
                onTap: (index) {
                  setState(() {
                    widget.currentTab = index;
                  });
                },
                automaticIndicatorColorAdjustment: false,
                labelColor: Theme.of(context).primaryColor,
                labelStyle: ItemTitleStyle(context),
                unselectedLabelColor: Theme.of(context).hintColor,
                unselectedLabelStyle: ItemTitleStyle(context),
                indicatorColor: Theme.of(context).primaryColor,
                tabs: widget.tabList.map((item) => item.getTab()).toList(),
              ),
            ),
            SizedBox(
              height: widget.tabviewHeight,
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: widget.tabList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentGroupTab extends StatefulWidget {
  CommentGroupTab(this.type, this.commentType, this.tabTitle, this.parentInfo,
      { Key? key, this.isAuthor = false, this.isManager = false, this.isCanNewAdd = true, this.onChanged, this.onRefreshHeight}) : super(key: key);

  String type;
  CommentType commentType;
  String tabTitle;
  JSON parentInfo;
  bool isAuthor;
  bool isManager;
  bool isCanNewAdd;
  List<JSON>? infoDataEx;
  Function(JSON)? onChanged;
  Function(double)? onRefreshHeight;

  Widget getTab() {
    return Tab(text: tabTitle, height: 40);
  }

  @override
  CommentGroupTabState createState() => CommentGroupTabState();
}

class CommentGroupTabState extends State<CommentGroupTab> {
  final api = Get.find<ApiService>();
  final _commentScrollController = PageController(viewportFraction: 1, keepPage: true);
  final _textScrollController = PageController(viewportFraction: 1, keepPage: true);
  List<CommentListExItem> commentList = [];

  List<GlobalKey> commentKey = [];
  int nowPage = 0;
  int maxPage = 0;
  final _divSpace = 10.0;
  final _pageListMax = 3;
  final _padding = EdgeInsets.fromLTRB(0, 10, 0, 0);

  Future<JSON>? initListData;
  JSON listData = {};

  initData() {
    switch(widget.commentType) {
      case CommentType.comment:
        LOG("--> getCommentFromTargetId [${widget.type}] : ${widget.parentInfo['id']}");
        initListData = api.getCommentFromTargetId(widget.type, widget.parentInfo['id']);
        break;
      case CommentType.qna:
        initListData = api.getQnaFromTargetId(widget.type, widget.parentInfo['id']);
        break;
      case CommentType.story:
        initListData = api.getStoryFromTargetId(widget.parentInfo['id']);
        break;
    }
  }

  refreshList() {
    commentKey = [];
    commentList = [];

    // maxPage = widget.pageMax ~/ _pageListMax + (widget.pageMax % _pageListMax != 0 ? 1 : 0) + 1;
    maxPage = (listData.length / _pageListMax + (listData.length % _pageListMax > 0.0 ? 1 : 0)).toInt();
    LOG("--> refreshList page [$nowPage] : ${listData.length} / $_pageListMax -> $maxPage / ${listData.length}");

    int count = 0;
    int parentCount = 0;
    listData = JSON_UPDATE_TIME_SORT_DESC(listData);

    for (var i=0; i<listData.entries.length; i++) {
      if (parentCount >= _pageListMax) break;
      final item = listData.entries.elementAt(i).value as JSON;
      // if (_goodsId.isEmpty) _goodsId = STR(item['targetId']);
      if (JSON_EMPTY(item['parentId'])) {
        if (++count >= nowPage * _pageListMax) {
          commentKey.add(GlobalKey());
          commentList.add(CommentListExItem(
            item,
            widget.commentType, widget.parentInfo, isShowDivider: commentList.isNotEmpty, key: commentKey.last,
            paddingSide: 10,
            isAuthor: item['userId'] == widget.parentInfo['userId'],
            isShowMenu: widget.commentType != CommentType.story,
            onChanged: (itemData, status) {
              setState(() {
                if (status == 2) {
                  listData.remove(itemData['id']);
                } else {
                  listData[itemData['id']] = itemData;
                }
                if (widget.onChanged != null) widget.onChanged!(listData);
                refreshList();
              });
            }
          ));
          for (var itemEx in listData.entries) {
            if (itemEx.value['parentId'] == item['id']) {
              commentKey.add(GlobalKey());
              commentList.add(CommentListExItem(
                  itemEx.value, widget.commentType, widget.parentInfo, isShowDivider: false, key: commentKey.last,
                  paddingSide: 10,
                  isAuthor: itemEx.value['userId'] == widget.parentInfo['userId'],
                  isShowMenu: widget.commentType != CommentType.story,
                  onChanged: (itemData, status) {
                    setState(() {
                      if (status == 2) {
                        listData.remove(itemData['id']);
                      } else {
                        listData[itemData['id']] = itemData;
                      }
                      if (widget.onChanged != null) widget.onChanged!(listData);
                      refreshList();
                    });
                  }
              ));
            }
          }
          parentCount++;
        }
      }
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (widget.onRefreshHeight != null) widget.onRefreshHeight!(getWidgetSize().height);
      // var detailStage = AppData.placeStateKey!.currentState;
      // detailStage!.setTabHeight(getWidgetSize().height);
    });
  }

  @override
  void initState() {
    refreshList();
    super.initState();
  }

  getWidgetSize() {
    var width = 0.0;
    var height = 20.0;
    for (var itemKey in commentKey) {
      var state = itemKey.currentState as CommentListExItemState?;
      if (state != null && state.mounted) {
        width  += state.getWidgetSize().width;
        height += state.getWidgetSize().height;
      }
    }
    if (listData['desc'] != null) height += _divSpace;
    if (widget.isCanNewAdd) {
      height += 50;
    }
    if (maxPage > 1) {
      height += 40;
    }
    height += _padding.top + _padding.bottom;
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return FutureBuilder(
      future: initListData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          listData = snapshot.data as JSON;
          refreshList();
          LOG("--> refreshList done [${widget.commentType}]: $maxPage / ${listData.length}");
          return Container(
            height: double.infinity,
              padding: _padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // show comment & qna..
                  if (commentList.isNotEmpty)...[
                    ...commentList,
                    SizedBox(height: _divSpace),
                  ],
                  if (maxPage > 1)...[
                    ShowPageControlWidget(context, nowPage, maxPage, (page) {
                      setState(() {
                        LOG('--> now page : $page / $maxPage');
                        nowPage = page;
                        refreshList();
                        // AppData.isMoveListBottom = true;
                      });
                    }),
                  ],
                  if (widget.isCanNewAdd)...[
                    SizedBox(height: 10),
                    RoundRectIconTextButton(context,
                        // widget.commentType == CommentType.comment ? 'ADD COMMENT' : 'ADD QUESTION',
                        '${widget.tabTitle} ${'ADD'.tr}',
                        Icons.add, () async {
                      var targetUser = await api.getUserInfoFromId(widget.parentInfo['userId']);
                      if (targetUser != null) {
                        JSON uploadData = {
                          "status": 1,
                          "targetType":   widget.type,
                          "targetTitle":  widget.parentInfo['title'],
                          "targetId":     widget.parentInfo['id'],
                          "parentId":     "",
                          "userId":       AppData.USER_ID,
                          "userName":     AppData.USER_NICKNAME,
                          "userPic":      AppData.USER_PIC,
                        };
                        showEditCommentDialog(
                            context,
                            widget.commentType,
                            // widget.commentType == CommentType.comment ? 'ADD COMMENT' : 'ADD QUESTION',
                            '${'ADD'.tr} ${widget.tabTitle}',
                            uploadData,
                            targetUser,
                            false,
                            !widget.isAuthor,
                            false).then((result) {
                          LOG('--> showEditCommentDialog comment result : $result');
                          if (result.isNotEmpty && mounted) {
                            setState(() {
                              var newId = result['id'];
                              listData[newId] = result;
                              refreshList();
                              if (widget.onChanged != null) widget.onChanged!(listData);
                            });
                          }
                        });
                      } else {
                        showAlertDialog(context, 'Error'.tr, 'Can not find user information'.tr, '', 'OK'.tr);
                      }
                    }
                  )
                ]
              ]
            )
          );
        } else {
          return showLoadingFullPage(context);
        }
      }
    );
  }

  @override
  void dispose() {
    _commentScrollController.dispose();
    _textScrollController.dispose();
    super.dispose();
  }
}

class StoryCommentItem extends StatefulWidget {
  StoryCommentItem(this.commentItem, {Key? key, this.isParent = true}) : super(key: key);
  JSON commentItem;
  bool isParent;

  @override
  _StoryCommentItemState createState() => _StoryCommentItemState();
}

class _StoryCommentItemState extends State<StoryCommentItem> {
  var _isOwner = false;

  initData() {
    _isOwner = widget.commentItem['senderId'] != null ?
    CheckOwner(widget.commentItem['senderId']) : CheckOwner(widget.commentItem['userId']);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _titleStyle1 = TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor);
    final _titleStyle2 = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary);
    final _titleStyle3 = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor.withOpacity(0.5));
    final _titleStyle4 = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor);
    final _descStyle   = Theme.of(context).textTheme.labelMedium;

    initData();
    // log('--> comment desc [${_isOwner ? 'me' : ''}] [${COMMENT_DESC(widget.commentItem['id'])}]: ${COMMENT_DESC(widget.commentItem['desc'])}');
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 2),
        child: RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
              children: [
                TextSpan(text: STR(widget.commentItem['userName']), style: _isOwner ? _titleStyle1 : _titleStyle2),
                TextSpan(text: '  ', style: _titleStyle1),
                TextSpan(text: COMMENT_DESC(widget.commentItem['desc']), style: _descStyle),
                TextSpan(text: '  ', style: _titleStyle1),
                REMIAN_TIME_TEXTSPAN(TME(widget.commentItem['updateTime']), _titleStyle3, _titleStyle4),
              ]
          ),
        )
    );
  }
}