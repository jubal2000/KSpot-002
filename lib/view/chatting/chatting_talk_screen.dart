
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/models/etc_model.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../repository/chat_repository.dart';
import '../../repository/message_repository.dart';
import '../../services/api_service.dart';
import '../../services/cache_service.dart';
import '../../utils/local_utils.dart';
import '../../utils/utils.dart';
import '../../widget/card_scroll_viewer.dart';

class ChattingTalkScreen extends StatefulWidget {
  ChattingTalkScreen(this.roomInfo, {Key? key, this.roomTitle = ''}) : super(key: key);

  ChatRoomModel roomInfo;
  String roomTitle;

  final textController    = TextEditingController();
  final scrollController  = ScrollController();

  @override
  ChattingTalkScreenState createState() => ChattingTalkScreenState();
}

class ChattingTalkScreenState extends State<ChattingTalkScreen> {
  final userRepo          = UserRepository();
  final chatRepo          = ChatRepository();
  final api               = Get.find<ApiService>();
  final cache             = Get.find<CacheService>();
  final _formKey          = GlobalKey<FormState>();
  final _minText          = 1;
  final _iconSize         = 24.0;
  final _imageMax         = 3;

  var  _sendText = '';
  JSON _addItem = {};
  JSON _showList = {};
  JSON _imageData = {};


  initData() {
    _showList = {};
    if (JSON_NOT_EMPTY(cache.chatData)) {
      for (var item in cache.chatData!.entries) {
        _showList[item.key] = item.value.toJson();
      }
    }
    LOG('--> initData :${_showList.length}');
    chatRepo.startChatStreamData(widget.roomInfo.id, (result) {
      if (mounted) {
        _showList = result;
        if (_showList.isNotEmpty) {
          setState(() {
            _showList = JSON_CREATE_TIME_SORT_ASCE(_showList);
            AppData.isMainActive = true;
            var lastItem = _showList.entries.last.value as JSON;
            var lastKey = widget.roomInfo.id;
            AppData.chatReadLog[lastKey] = {'id': lastKey, 'lastId': lastItem['id'], 'createTime': SERVER_TIME_STR(lastItem['createTime'])};
            // AppData.localInfo['chatReadLog'] ??= {};
            // AppData.localInfo['chatReadLog'].addAll(AppData.messageReadLog);
            // LOG('--> startChatStreamData result : ${_showList.length}');
            // writeLocalInfo();
            // _showList.forEach((key, value) async {
            //   LOG('--> _showList item : ${CheckOwner(value['id'])} / ${value['memberData']}');
            //   if (STR(value['openTime']).isEmpty) {
            //     await api.setChatInfo(key, {
            //       'openTime': CURRENT_SERVER_TIME(),
            //     });
            //   }
            // });
          });
        }
      }
    });
  }

  createAddItem() {
    _addItem = {
      "status":     1,
      "roomId":     widget.roomInfo.id,
      "senderId":   STR(AppData.USER_ID),
      "senderName": STR(AppData.USER_NICKNAME),
      "senderPic":  STR(AppData.USER_PIC),
      "picData":  [],
      "fileData":  [], // TODO: need file add..
      "desc": "",
    };
  }

  refresh(JSON pushData) {
    // LOG('--> MessageItemListState refresh : $pushData / $mounted');
    // setState(() {
    //   refreshList();
    // });
  }

  refreshList() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 200), () {
        widget.scrollController.jumpTo(0);
      });
    });
  }

  getUserInfo() async {
    for (var item in widget.roomInfo.memberData) {
      var result = await userRepo.getUserInfo(item.id);
      if (result != null) {
        item = MemberData.fromJson(result.toJson());
      }
    }
    // if (widget.targetName.isEmpty) widget.targetName = _targetUser['nickName'];
    // if (widget.targetPic.isEmpty ) widget.targetPic  = _targetUser['pic'];
  }

  showMemberList() {
    return Row(
      children: [
        for (var item in widget.roomInfo.memberData)
          Text(widget.roomInfo.memberData.indexOf(item) > 0 ? ', ${item.nickName}' : item.nickName, style: ItemDescStyle(context)),
        SizedBox(width: 10),
        Text('${widget.roomInfo.memberData.length}', style: ItemTitleBoldStyle(context)),
      ],
    );
  }

  @override
  void initState() {
    initData();
    refreshList();
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: WillPopScope(
            onWillPop: () async {
              chatRepo.stopChatStreamData();
              return true;
            },
            child: Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      if (widget.roomInfo.type == 0)...[
                        if (widget.roomInfo.pic.isNotEmpty)...[
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: showImageFit(widget.roomInfo.pic),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(STR(widget.roomInfo.title), style: AppBarTitleStyle(context)),
                            showMemberList(),
                          ]
                        ),
                      ],
                      if (widget.roomInfo.type == 1)...[
                        if (widget.roomInfo.pic.isNotEmpty)...[
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(150),
                              child: showImageFit(widget.roomInfo.pic),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                        showMemberList(),
                      ],
                    ],
                  ),
                  titleSpacing: 0,
                  toolbarHeight: 55,
                ),
                body: Container(
                    height: Get.height,
                    child: Stack(
                        children: [
                          Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                      reverse: true,
                                      controller: widget.scrollController,
                                      child: Column(
                                        children: [
                                          for (var item in _showList.entries)
                                            MessageItem(item.value),
                                          SizedBox(height: 10),
                                        ],
                                      )
                                  ),
                                ),
                                Container(
                                    width: Get.width,
                                    constraints: BoxConstraints(
                                      minHeight: _imageData.isEmpty ? 90 : 140,
                                    ),
                                    padding: EdgeInsets.all(10),
                                    color: Theme.of(context).canvasColor,
                                    child: Column(
                                        children: [
                                          if (_imageData.isNotEmpty)...[
                                            Row(
                                              children: [
                                                ImageEditScrollViewer(
                                                  _imageData,
                                                  itemWidth: 40.0,
                                                  itemHeight: 40.0,
                                                  isEditable: true,
                                                  sidePadding: 0,
                                                  onActionCallback: (key, status) {
                                                    LOG('--> onActionCallback : $key / $status');
                                                    if (status == 2) {
                                                      _imageData.remove(key);
                                                      refreshImageData();
                                                    }
                                                  },
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    showAlertDialog(context, 'Remove'.tr, 'Remove all images?'.tr, '', 'OK'.tr).then((result) {
                                                      if (result == 1) {
                                                        _imageData.clear();
                                                        refreshImageData();
                                                      }
                                                    });
                                                  },
                                                  icon: Icon(Icons.close)
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                          Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: TextFormField(
                                                      controller: widget.textController,
                                                      decoration: inputChatSuffix(context),
                                                      keyboardType: TextInputType.multiline,
                                                      maxLines: null,
                                                      maxLength: 500,
                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor),
                                                      onChanged: (value) {
                                                        _sendText = value;
                                                        widget.scrollController.jumpTo(0);
                                                      },
                                                    )
                                                ),
                                                Container(
                                                    width: 80,
                                                    height: 40,
                                                    padding: EdgeInsets.only(left: 10),
                                                    child: ElevatedButton(
                                                        onPressed: () async {
                                                          if (!AppData.isMainActive || (_sendText.isEmpty && _imageData.isEmpty)) return;
                                                          if (_imageData.length >= _imageMax) {
                                                            showAlertDialog(context, 'Image'.tr,
                                                                'You can\'t add any more'.tr, '${'Max'.tr}: $_imageMax', 'OK'.tr);
                                                            return;
                                                          }
                                                          AppData.isMainActive = false;
                                                          createAddItem();
                                                          _addItem['desc'] = _sendText;
                                                          _addItem['picData'] = [];
                                                          _addItem['fileData'] = [];
                                                          _addItem['thumbData'] = [];
                                                          _addItem['memberList'] = widget.roomInfo.memberList;
                                                          _addItem['createTime'] = CURRENT_SERVER_TIME();
                                                          var upCount = 0;
                                                          for (var item in _imageData.entries) {
                                                            var result = await api.uploadImageData(item.value as JSON, 'chat_img');
                                                            if (result != null) {
                                                              _addItem['picData'].add(result);
                                                              upCount++;
                                                            }
                                                          }
                                                          LOG('--> upload image result : $upCount / ${_addItem['picData']}');
                                                          upCount = 0;
                                                          for (var item in _imageData.entries) {
                                                            var result = await api.uploadImageData(
                                                                {'id': item.key, 'data': item.value['thumb']}, 'chat_img_p');
                                                            if (result != null) {
                                                              _addItem['thumbData'].add(result);
                                                              upCount++;
                                                            }
                                                          }
                                                          LOG('--> upload thumb result : $upCount / ${_addItem['thumbData']}');
                                                          List<JSON> targetUser = [];
                                                          for (var item in widget.roomInfo.memberData) {
                                                            if (item.id != AppData.USER_ID) {
                                                              targetUser.add(item.toJson());
                                                            }
                                                            LOG('--> targetUser : ${targetUser.length} / ${targetUser.toString()}');
                                                          }
                                                          chatRepo.addChatItem(_addItem, targetUser).then((result) {
                                                            setState(() {
                                                              _showList[result['id']] = result;
                                                              _showList = JSON_CREATE_TIME_SORT_ASCE(_showList);
                                                              cache.setChatItem(ChatModel.fromJson(result));
                                                              AppData.isMainActive = true;
                                                              LOG('--------> add chat result [${result['id']}]');
                                                            });
                                                          });
                                                          widget.textController.text = '';
                                                          _sendText = '';
                                                          _imageData.clear();
                                                        },
                                                        style: ButtonStyle(
                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                              )
                                                          ),
                                                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                                                        ),
                                                        child: Text('Send'.tr,
                                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.inversePrimary))
                                                    )
                                                )
                                              ]
                                          )
                                        ]
                                    )
                                )
                              ]
                          ),
                          Positioned(
                              left: 15,
                              bottom: 0,
                              child: Container(
                                  padding: EdgeInsets.only(bottom: 7),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          addSendImages(context);
                                        },
                                        child: Icon(Icons.photo_library_outlined, size: _iconSize, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                                      ),
                                      SizedBox(width: 15),
                                      // GestureDetector(
                                      //   onTap: () {
                                      //   },
                                      //   child: Icon(Icons.alternate_email, size: _iconSize, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                                      // ),
                                      // SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () async {
                                          // paste..
                                          ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
                                          if (cdata != null) {
                                            _sendText = cdata.text.toString();
                                            widget.textController.text = _sendText;
                                          }
                                        },
                                        child: Icon(Icons.paste, size: _iconSize, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                                      ),
                                    ],
                                  )
                              )
                          ),
                        ]
                    )
                )
            )
        )
    );
  }

  addSendImages(BuildContext context) async {
    AppData.isMainActive = false;
    _imageData.clear();
    List<XFile>? imageList = await ImagePicker().pickMultiImage();
    if (LIST_NOT_EMPTY(imageList)) {
      showLoadingDialog(context, 'Processing now...'.tr);
      for (var i = 0; i < imageList.length; i++) {
        var image = imageList[i];
        var imageData = await ReadFileByte(image.path);
        var thumbData = await resizeImage(imageData!.buffer.asUint8List(), 256) as Uint8List;
        var key = Uuid().v1();
        _imageData[key] = {'id': key, 'data': imageData, 'thumb': thumbData};
      }
      Navigator.of(dialogContext!).pop();
      refreshImageData();
    }
    AppData.isMainActive = true;
  }

  refreshImageData() {
    setState(() {
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class MessageItem extends StatefulWidget {
  MessageItem(this.messageItem, {Key? key}) : super(key: key);
  JSON messageItem;

  @override
  MessageItemState createState() => MessageItemState();
}

class MessageItemState extends State<MessageItem> {
  // final _descStyle = TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400);
  // final _timeStyle = TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w400);
  final api = Get.find<ApiService>();
  final _radiusSize = 18.0;
  final _imageSize = 80.0;
  final JSON _imageData = {};
  var _isOwner = true;

  @override
  void initState() {
    _isOwner = CheckOwner(widget.messageItem['senderId']);
    if (LIST_NOT_EMPTY(widget.messageItem['thumbData'])) {
      widget.messageItem['thumbData'].forEach((item) {
        var index = widget.messageItem['thumbData'].indexOf(item);
        var key = Uuid().v1();
        _imageData[key] = {'id': key, 'url': item};
        if (widget.messageItem['picData'][index] != null) {
          _imageData[key]['linkPic'] = widget.messageItem['data'][index];
        }
      });
    }
    LOG("--> _imageData : $_imageData / ${widget.messageItem}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // TODO: 메시지 터치했을경우 처리 필요.. (삭제/수정등)
        },
        child: VisibilityDetector(
          onVisibilityChanged: (value) {
            if (STR(widget.messageItem['openTime']).isEmpty) {
              widget.messageItem['openTime'] = CURRENT_SERVER_TIME();
              api.setChatInfo(widget.messageItem['id'], {
                'openTime': widget.messageItem['openTime'],
              });
            }
          },
          key: GlobalKey(),
          child: Row(
            children: [
              if (_isOwner)
                Expanded(child: SizedBox(height: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal:20, vertical:10),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: _isOwner ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.inversePrimary,
                        borderRadius:  BorderRadius.only(
                          topLeft:     Radius.circular(_radiusSize),
                          topRight:    Radius.circular(_radiusSize),
                          bottomLeft:  Radius.circular(_isOwner ? _radiusSize : 0),
                          bottomRight: Radius.circular(_isOwner ? 0 : _radiusSize),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            spreadRadius: 0,
                            blurRadius: 3,
                            offset: Offset(0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                          crossAxisAlignment: _isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (_imageData.isNotEmpty)...[
                              Container(
                                width: _imageData.length * _imageSize,
                                child: CardScrollViewer(
                                  _imageData,
                                  itemWidth: _imageSize,
                                  itemHeight: _imageSize,
                                  itemRound: 3,
                                  sidePadding: 0,
                                  backgroundPadding: EdgeInsets.zero,
                                  onActionCallback: (key, status) {
                                    LOG('--> onActionCallback : $key / $status');
                                  },
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                            Text(DESC(widget.messageItem['desc']), maxLines: null, style: Theme.of(context).textTheme.bodyText2),
                            SizedBox(height: 5),
                            FittedBox(
                                child: Row(
                                  children: [
                                    Text(SERVER_TIME_STR(widget.messageItem['createTime']), style: Theme.of(context).textTheme.bodySmall),
                                    if (!_isOwner && STR(widget.messageItem['openTime']).isNotEmpty)...[
                                      SizedBox(width: 5),
                                      Text('READ'.tr, style: ItemDescEx2Style(context))
                                    ]
                                  ],
                                )
                            )
                          ]
                      )
                  ),
                ),
              ),
              if (!_isOwner)
                Expanded(child: SizedBox(height: 1)),
            ]
        )
      )
    );
  }
}