
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:uuid/uuid.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/message_model.dart';
import '../../repository/message_repository.dart';
import '../../services/api_service.dart';
import '../../services/cache_service.dart';
import '../../utils/local_utils.dart';
import '../../utils/utils.dart';
import '../../widget/card_scroll_viewer.dart';
import '../../widget/chat_item.dart';

class MessageTalkScreen extends StatefulWidget {
  MessageTalkScreen(this.targetId, this.targetName, this.targetPic, {Key? key}) : super(key: key);

  String targetId;
  String targetName;
  String targetPic;

  final textController   = TextEditingController();
  final scrollController = ScrollController();

  JSON chatItemData = {};

  @override
  MessageTalkScreenState createState() => MessageTalkScreenState();
}

class MessageTalkScreenState extends State<MessageTalkScreen> {
  final userRepo = UserRepository();
  final msgRepo  = MessageRepository();
  final api      = Get.find<ApiService>();
  final cache    = Get.find<CacheService>();

  final _formKey          = GlobalKey<FormState>();
  final _minText          = 1;
  final _iconSize         = 24.0;
  final _imageMax         = 3;

  var  sendText = '';
  JSON _targetUser = {};
  JSON showList = {};
  JSON _imageData = {};

  initData() {
    showList = {};
    if (JSON_NOT_EMPTY(cache.messageData)) {
      for (var item in cache.messageData!.entries) {
        showList[item.key] = item.value.toJson();
      }
    }
    LOG('--> initData :${showList.length}');
    msgRepo.startMessageStreamData(widget.targetId, (result) {
      if (mounted) {
        showList.addAll(result);
        if (showList.isNotEmpty) {
          setState(() {
            showList = JSON_CREATE_TIME_SORT_ASCE(showList);
            AppData.isMainActive = true;
            var lastItem = showList.entries.last.value as JSON;
            var lastKey = widget.targetId;
            AppData.messageReadLog[lastKey] = {'id': lastKey, 'lastId': lastItem['id'], 'createTime': SERVER_TIME_STR(lastItem['createTime'])};
            AppData.localInfo['messageReadLog'] = {};
            AppData.localInfo['messageReadLog'].addAll(AppData.messageReadLog);
            LOG('--> startMessageStream result : ${showList.length}');
            writeLocalInfo();
            // _showList.forEach((key, value) async {
            //   if (!CheckOwner(value['senderId']) && STR(value['openTime']).isEmpty) {
            //     await api.setMessageInfo(key, {
            //       'openTime': CURRENT_SERVER_TIME(),
            //     });
            //   }
            // });
          });
        }
      }
    });
  }

  refreshList() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 200), () {
        widget.scrollController.jumpTo(0);
      });
    });
  }

  showMessageList() {
    List<Widget> result = [];
    var parentId = '';
    // showList = JSON_CREATE_TIME_SORT_ASCE(showList);
    for (var i=0; i<showList.length; i++) {
      var isShowDate = true;
      var item = showList.entries.elementAt(i);
      if (i+1 < showList.length) {
        var nextItem = showList.entries.elementAt(i+1);
        isShowDate = item.value['senderId'] != nextItem.value['senderId'];
      }
      var addItem = widget.chatItemData[item.key];
      addItem ??= ChatItem(item.value, isShowFace: parentId != item.value['senderId'], isShowDate: isShowDate,
        onSelected: (key, status) {

        }, onSetOpened: (message) {
          api.setMessageInfo(message['id'], {
            'openList': message['openList'],
          });
        });
      result.add(addItem);
      widget.chatItemData[item.key] = addItem;
      parentId = item.value['senderId'];
    }
    return result;
  }

  getUserInfo() async {
    var result = await userRepo.getUserInfo(widget.targetId);
    if (result != null) {
      _targetUser = result.toJson();
    }
    if (widget.targetName.isEmpty) widget.targetName = _targetUser['nickName'];
    if (widget.targetPic.isEmpty ) widget.targetPic  = _targetUser['pic'];
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
              msgRepo.stopMessageStreamData();
              return true;
            },
            child: Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      if (widget.targetPic.isNotEmpty)...[
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: showImageFit(widget.targetPic),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                      Text(STR(widget.targetName), style: AppBarTitleStyle(context))
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
                                          SizedBox(height: 10),
                                          ...showMessageList(),
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
                                                        sendText = value;
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
                                                          if (!AppData.isMainActive || (sendText.isEmpty && _imageData.isEmpty)) return;
                                                          if (_imageData.length >= _imageMax) {
                                                            showAlertDialog(context, 'Image'.tr,
                                                                'You can\'t add any more'.tr, '${'Max'.tr}: $_imageMax', 'OK'.tr);
                                                            return;
                                                          }
                                                          AppData.isMainActive = false;
                                                          var addItem = {
                                                            'id':         '',
                                                            'status':     1,
                                                            'senderId':   AppData.USER_ID,
                                                            'senderName': AppData.USER_NICKNAME,
                                                            'senderPic':  AppData.USER_PIC,
                                                            'desc':       sendText,
                                                            'memberList': [AppData.USER_ID, widget.targetId],
                                                            'picData':    [],
                                                            'thumbData':  [],
                                                            'createTime': CURRENT_SERVER_TIME(),
                                                          };
                                                          addItem['desc'] = sendText;
                                                          addItem['picData'] = [];
                                                          addItem['thumbData'] = [];
                                                          addItem['createTime'] = CURRENT_SERVER_TIME();
                                                          var upCount = 0;
                                                          for (var item in _imageData.entries) {
                                                            var result = await api.uploadImageData(item.value as JSON, 'message_img');
                                                            if (result != null) {
                                                              addItem['picData'] ??= [];
                                                              addItem['picData'].add(result);
                                                              upCount++;
                                                            }
                                                          }
                                                          LOG('----> upload image result : $upCount / ${addItem['imageData']}');
                                                          upCount = 0;
                                                          for (var item in _imageData.entries) {
                                                            var result = await api.uploadImageData(
                                                                {'id': item.key, 'data': item.value['thumb']}, 'message_img_p');
                                                            if (result != null) {
                                                              addItem['thumbData'] ??= '';
                                                              addItem['thumbData'].add(result);
                                                              upCount++;
                                                            }
                                                          }
                                                          LOG('----> upload thumb result : $upCount / ${addItem['thumbData']}');
                                                          api.addMessageItem(addItem, _targetUser).then((result) {
                                                            AppData.isMainActive = true;
                                                          });
                                                          widget.textController.text = '';
                                                          sendText = '';
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
                                            sendText = cdata.text.toString();
                                            widget.textController.text = sendText;
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
        _imageData[key] = {'id': key, 'image': imageData, 'thumb': thumbData};
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
