import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/comment_item_widget.dart';


class SetupServiceScreen extends StatefulWidget {
  SetupServiceScreen({Key? key}) : super(key: key);

  @override
  SetupServiceState createState() => SetupServiceState();
}

class SetupServiceState extends State<SetupServiceScreen> {
  final api = Get.find<ApiService>();
  Stream? _initService;
  List<GlobalKey> _commentKey = [];
  List<Widget> _commentList = [];
  var _isMyList = false;
  var _refreshId = '';

  onChanged(String key, String value) {
    LOG('--> onChanged : $key / $value');
  }

  initData() {
    _initService = api.getServiceQnAData();
  }

  refreshList() {
    int count = 0;
    AppData.serviceQnAData = JSON_CREATE_TIME_SORT_DESC(AppData.serviceQnAData);
    _commentKey = [];
    _commentList = [];
    // for (var i=0; i<99999; i++) {
    //   var index = _nowPage * _pageListMax + i;
      // if (count >= _pageListMax || index >= AppData.serviceQnAData.entries.length) break;
    for (var index = 0; index < AppData.serviceQnAData.entries.length; index++) {
      var item = AppData.serviceQnAData.entries
          .elementAt(index)
          .value;
      // if (_goodsId.isEmpty) _goodsId = STR(item['targetId']);
      var userInfo = {
        'id': item['userId'],
        'nickName': item['userName'],
        'pic': item['userPic'],
      };
      item['index'] = index;
      if (!JSON_NOT_EMPTY(item['parentId']) && (!_isMyList || (item['userId'] == AppData.USER_ID))) {
        _commentKey.add(GlobalKey());
        _commentList.add(CommentListItem(
          item,
          CommentType.serviceQnA,
          userInfo,
          isShowDivider: count > 0,
          key: _commentKey.last,
          isAuthor: false,
          maxLine: 3,
          onChanged: (itemData, status) {
            setState(() {
              if (status == 2) {
                AppData.serviceQnAData.remove(itemData['id']);
              } else {
                AppData.serviceQnAData[itemData['id']] = itemData;
              }
              refreshList();
            });
          },
          onItemVisible: (itemIndex, status) {
            if (status) {
              final freeCount = AppData.serviceQnAData.length - FAQ_SHOW_MAX;
              final lastItem  = AppData.serviceQnAData.entries.last.value;
              if (lastItem['createTime'] != null && _refreshId != STR(lastItem['id']) && itemIndex > freeCount) {
                LOG('--> onItemVisible refresh [$index] : $itemIndex ($freeCount) - $_refreshId / ${lastItem['id']}');
                setState(() {
                  _refreshId   = STR(AppData.serviceQnAData.entries.last.value['id']);
                  _initService = api.getServiceQnADataNext(DateTime.parse(lastItem['createTime']));
                });
              }
            }
          },
        ));
        for (var itemEx in AppData.serviceQnAData.entries) {
          if (itemEx.value['parentId'] == item['id']) {
            _commentKey.add(GlobalKey());
            _commentList.add(CommentListItem(
              itemEx.value, CommentType.serviceQnA, userInfo, isShowDivider: false, key: _commentKey.last,
              isAuthor: false,
              onChanged: (itemData, status) {
                setState(() {
                  if (status == 2) {
                    AppData.serviceQnAData.remove(itemData['id']);
                  } else {
                    AppData.serviceQnAData[itemData['id']] = itemData;
                  }
                  refreshList();
                });
              },
            ));
          }
        }
        count++;
      }
    }
  }

  @override
  void initState() {
    AppData.serviceQnAData = {};
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Contact us'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
          actions: [
            Row(
              children: [
                Switch(
                  value: _isMyList,
                  onChanged: (status) {
                    setState(() {
                      _isMyList = status;
                    });
                  }
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(_isMyList ? Icons.account_circle_outlined : Icons.list, color: Colors.grey, size: 20),
                    Text(_isMyList ? 'MY' : 'ALL', style: ItemDescExStyle(context)),
                  ]
                ),
                SizedBox(width: 15),
              ]
            )
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
          child: Stack(
            children: [
              StreamBuilder(
                stream: _initService,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString(), style: DialogDescErrorStyle(context));
                  } else {
                    var dataCount = 0;
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text('List does not exist'.tr);
                      case ConnectionState.waiting:
                        break;
                      case ConnectionState.active:
                        // _storyData.clear();
                        dataCount = List.from(FROM_SERVER_DATA(snapshot.data.docs)).length;
                        LOG('--> snapshot.data : $dataCount');
                        for (var item in snapshot.data.docs) {
                          var data = JSON.from(FROM_SERVER_DATA(item.data() as JSON));
                          AppData.serviceQnAData[data['id']] = data;
                        }
                        break;
                      case ConnectionState.done:
                        break;
                    }
                    if (AppData.serviceQnAData.isNotEmpty) {
                    }
                    refreshList();
                    return ListView(
                        children: _commentList
                    );
                  }
                }
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                child: Icon(Icons.add_comment_outlined, size: 30, color: Colors.white),
                backgroundColor: Colors.purple,
                onPressed: () {
                  JSON uploadData = {
                    "status":     1,
                    "desc":       '',
                    "imageData":  [],
                    "userId":     AppData.USER_ID,
                    "userName":   AppData.USER_NICKNAME,
                    "userPic":    AppData.USER_PIC,
                    "createTime": CURRENT_SERVER_TIME(),
                  };
                  showEditCommentDialog(context, CommentType.serviceQnA, 'Contact us'.tr, uploadData, const {}, false, false, true).then((result) {
                    setState(() {
                      refreshList();
                    });
                  });
                },
              )
            )
          ]
        )
      )
      )
    );
  }
}