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
  CommentTabWidget(this.parentInfo, this.type, {Key? key}) : super(key: key);

  JSON parentInfo;
  String type;

  List<GlobalKey> _tabKeyList = [];
  List<CommentGroupTab> _tabList = [];
  var _tabviewHeight = 200.0;
  var _tabviewHeightOrg = 0.0;
  var _currentTab = 0;
  Map<int, double> _tabHeight = {};

  @override
  _CommenetTabState createState() => _CommenetTabState();
}

class _CommenetTabState extends State<CommentTabWidget> {
  var _isManager = false;

  refreshCommentTabData() {
    LOG('---> refreshInfoTabData');
    if (widget._tabList.isEmpty) {
      widget._tabKeyList.add(GlobalKey());
      widget._tabList.add(CommentGroupTab(
        widget.type, CommentType.story, 'STORY'.tr,
        widget.parentInfo,
        key: widget._tabKeyList.last,
        isAuthor: STR(widget.parentInfo['userId']) == AppData.USER_ID,
        isManager: _isManager,
        onChanged: (data) {
          // firestoreCacheData['goodsData'][_placeInfo['id']] = _placeInfo;
        },
        onRefreshHeight: setTabHeight,
      ));
      widget._tabKeyList.add(GlobalKey());
      widget._tabList.add(CommentGroupTab(
        widget.type, CommentType.comment, 'COMMENT'.tr,
        widget.parentInfo,
        key: widget._tabKeyList.last,
        isAuthor: STR(widget.parentInfo['userId']) == AppData.USER_ID,
        isManager: _isManager,
        onChanged: (data) {
          // firestoreCacheData['goodsData'][_placeInfo['id']] = _placeInfo;
        },
        onRefreshHeight: setTabHeight,
      ));
      widget._tabKeyList.add(GlobalKey());
      widget._tabList.add(CommentGroupTab(
        widget.type, CommentType.qna, 'QnA'.tr,
        widget.parentInfo,
        key: widget._tabKeyList.last,
        isAuthor: STR(widget.parentInfo['userId']) == AppData.USER_ID,
        isManager: _isManager,
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
        widget._tabviewHeight = height;
        widget._tabviewHeightOrg = widget._tabviewHeight;
        widget._tabHeight[widget._currentTab] = height;
      });
    }
  }

  refreshTabHeight() {
    Future.delayed(const Duration(milliseconds: 500), () {
      var tmpHeight = 0.0;
      if (widget._tabHeight[widget._currentTab] != null) {
        tmpHeight = widget._tabHeight[widget._currentTab]!;
      } else {
        var _item = widget._tabKeyList[widget._currentTab].currentState as CommentGroupTabState?;
        if (_item != null) {
          tmpHeight = _item
              .getWidgetSize()
              .height;
          widget._tabHeight[widget._currentTab] = tmpHeight;
        }
      }
      if (widget._tabviewHeightOrg == tmpHeight) return;
      setState(() {
        widget._tabviewHeight = tmpHeight;
        widget._tabviewHeightOrg = widget._tabviewHeight;
      });
    });
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      refreshTabHeight();
    });
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: DefaultTabController(
        length: widget._tabList.length,
        child: Column(
          children: [
            showHorizontalDivider(Size(double.infinity, 20), color: Colors.grey.withOpacity(0.25)),
            SizedBox(
              height: 40,
              child: TabBar(
                labelPadding: EdgeInsets.zero,
                onTap: (index) {
                  widget._currentTab = index;
                  refreshTabHeight();
                },
                automaticIndicatorColorAdjustment: false,
                labelColor: Theme.of(context).primaryColor,
                labelStyle: ItemTitleStyle(context),
                unselectedLabelColor: Theme.of(context).hintColor,
                unselectedLabelStyle: ItemTitleStyle(context),
                indicatorColor: Theme.of(context).primaryColor,
                tabs: widget._tabList.map((item) => item.getTab()).toList(),
              ),
            ),
            SizedBox(
              height: widget._tabviewHeight,
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: widget._tabList,
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
  List<CommentListExItem> _commentList = [];
  List<GoodsInfoTextItem> _textList = [];

  List<GlobalKey> _commentKey = [];
  List<GlobalKey> _textKey = [];
  int _tabIndex = 0;
  int _nowPage = 0;
  int _maxPage = 0;
  int _showCount = 0;
  final _divSpace = 10.0;
  final _pageListMax = 3;

  final _padding = EdgeInsets.fromLTRB(0, 10, 0, 0);
  final TextStyle _descStyle   = TextStyle(fontSize: 16, color: Colors.black , fontWeight: FontWeight.w300, height: 1.5);
  final _sizeInfoKey = GlobalKey();

  Future<JSON>? _initListData;
  JSON _listData = {};

  initData() {
    switch(widget.commentType) {
      case CommentType.comment:
        _initListData = api.getCommentFromTargetId(widget.type, widget.parentInfo['id']);
        break;
      case CommentType.qna:
        _initListData = api.getQnaFromTargetId(widget.type, widget.parentInfo['id']);
        break;
      case CommentType.story:
        _initListData = api.getStoryFromTargetId(widget.parentInfo['id']);
        break;
    }
  }

  refreshList() {
    _showCount = 0;
    _commentKey = [];
    _commentList = [];

    // _maxPage = widget.pageMax ~/ _pageListMax + (widget.pageMax % _pageListMax != 0 ? 1 : 0) + 1;
    _maxPage = (_listData.length / _pageListMax + (_listData.length % _pageListMax > 0.0 ? 1 : 0)).toInt();
    LOG("--> refreshList page [$_nowPage] : ${_listData.length} / $_pageListMax -> $_maxPage / ${_listData.length}");

    int count = 0;
    int parentCount = 0;
    _listData = JSON_UPDATE_TIME_SORT_DESC(_listData);

    for (var i=0; i<_listData.entries.length; i++) {
      if (parentCount >= _pageListMax) break;
      var item = _listData.entries.elementAt(i).value;
      // if (_goodsId.isEmpty) _goodsId = STR(item['targetId']);
      if (JSON_EMPTY(item['parentId'])) {
        if (++count >= _nowPage * _pageListMax) {
          _commentKey.add(GlobalKey());
          _commentList.add(CommentListExItem(
              item, widget.commentType, widget.parentInfo, isShowDivider: _commentList.isNotEmpty, key: _commentKey.last,
              paddingSide: 10,
              isAuthor: item['userId'] == widget.parentInfo['userId'],
              isShowMenu: widget.commentType != CommentType.story,
              onChanged: (itemData, status) {
                setState(() {
                  if (status == 2) {
                    _listData.remove(itemData['id']);
                  } else {
                    _listData[itemData['id']] = itemData;
                  }
                  if (widget.onChanged != null) widget.onChanged!(_listData);
                  refreshList();
                });
              }
          ));
          for (var itemEx in _listData.entries) {
            if (itemEx.value['parentId'] == item['id']) {
              _commentKey.add(GlobalKey());
              _commentList.add(CommentListExItem(
                  itemEx.value, widget.commentType, widget.parentInfo, isShowDivider: false, key: _commentKey.last,
                  paddingSide: 10,
                  isAuthor: itemEx.value['userId'] == widget.parentInfo['userId'],
                  isShowMenu: widget.commentType != CommentType.story,
                  onChanged: (itemData, status) {
                    setState(() {
                      if (status == 2) {
                        _listData.remove(itemData['id']);
                      } else {
                        _listData[itemData['id']] = itemData;
                      }
                      if (widget.onChanged != null) widget.onChanged!(_listData);
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
    for (var itemKey in _commentKey) {
      var state = itemKey.currentState as CommentListExItemState?;
      if (state != null && state.mounted) {
        width  += state.getWidgetSize().width;
        height += state.getWidgetSize().height;
      }
    }
    if (_listData['desc'] != null) height += _divSpace;
    if (widget.isCanNewAdd) {
      height += 50;
    }
    if (_maxPage > 1) {
      height += 40;
    }
    height += _padding.top + _padding.bottom;
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return FutureBuilder(
        future: _initListData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _listData = snapshot.data as JSON;
            LOG("--> refreshList ready [${widget.commentType}]: $_maxPage / ${_listData.length}");
            refreshList();
            LOG("--> refreshList done [${widget.commentType}]: $_maxPage / ${_listData.length}");
            return Container(
              height: double.infinity,
                padding: _padding,
                child: SingleChildScrollView(
                    child: Column(
                        children: [
                          // show comment & qna..
                          if (_commentList.isNotEmpty)...[
                            Column(
                              children: _commentList,
                            ),
                            SizedBox(height: _divSpace),
                          ],
                          if (_maxPage > 1)...[
                            ShowPageControlWidget(context, _nowPage, _maxPage, (page) {
                              setState(() {
                                LOG('--> now page : $page / $_maxPage');
                                _nowPage = page;
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
                                      _listData[newId] = result;
                                      refreshList();
                                      if (widget.onChanged != null) widget.onChanged!(_listData);
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