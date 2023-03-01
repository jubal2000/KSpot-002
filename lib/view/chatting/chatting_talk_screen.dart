
import 'dart:collection';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/etc_model.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:kspot_002/widget/user_card_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/chat_model.dart';
import '../../repository/chat_repository.dart';
import '../../repository/message_repository.dart';
import '../../services/api_service.dart';
import '../../services/cache_service.dart';
import '../../utils/local_utils.dart';
import '../../utils/utils.dart';
import '../../widget/card_scroll_viewer.dart';
import '../../widget/chat_item.dart';

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
  final showMemberMax     = 4;

  var  sendText = '';
  JSON showList = {};
  JSON imageData = {};
  JSON chatItemData = {};
  var  memberList = [].obs;
  var  isManager = false;

  initData() {
    DateTime? startTime;
    for (var item in widget.roomInfo.memberData) {
      LOG('--> widget.roomInfo.memberData :${item.toJson()}');
      if (item.id == AppData.USER_ID && item.createTime != null) {
        startTime = DateTime.parse(item.createTime!);
        isManager = item.status == 2;
      }
    }
    chatRepo.startChatStreamData(widget.roomInfo.id, startTime ?? DateTime.now(), (result) {
      if (mounted) {
        showList = result;
        if (showList.isNotEmpty) {
          setState(() {
            cache.setChatItemData(result);
            var lastItem = showList.entries.last.value as JSON;
            var lastKey = widget.roomInfo.id;
            AppData.isMainActive = true;
            AppData.chatReadLog[lastKey] = {'id': lastKey, 'lastId': lastItem['id'], 'createTime': SERVER_TIME_STR(lastItem['createTime'])};
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
    return Obx(() => Row(
      children: [
        for (var i=0; i<memberList.length; i++)
          Text(i > 0 ? ', ${memberList[i]}' : memberList[i], style: ItemDescStyle(context)),
        SizedBox(width: 10),
        Text('${memberList.length}', style: ItemTitleBoldStyle(context)),
      ],
    ));
  }

  // refreshMemberList() {
  //   var isUpdated = false;
  //   // memberList.value = widget.roomInfo.memberData.map((item) => item.nickName).toList();
  //   final reverseM = JSON.from(LinkedHashMap.fromEntries(showList.entries.toList().reversed));
  //   for (var item in reverseM.entries) {
  //     LOG('--> refreshMemberList item [${item.value['desc']} / ${reverseM.entries.length}] : ${item.value.toString()}');
  //     // exit member..
  //     if (INT(item.value['action']) == 2) {
  //       // memberList.remove(item.value['senderName']);
  //       if (widget.roomInfo.memberList.contains(item.value['senderId'])) {
  //         widget.roomInfo.removeMemberData(item.value['senderId']);
  //       }
  //       isUpdated = true;
  //       break;
  //     }
  //   }
  //   if (isUpdated) {
  //     memberList.value = [];
  //     for (var item in widget.roomInfo.memberData) {
  //       memberList.add(item.nickName);
  //     }
  //     memberList.refresh();
  //     cache.chatRoomData[widget.roomInfo.id] = widget.roomInfo;
  //   }
  //   LOG('--> refreshMemberList : ${widget.roomInfo.memberData.toString()} / ${widget.roomInfo.memberList.toString()} => ${memberList.toString()}');
  // }

  refreshMemberList() {
    memberList.value = [];
    final reverseM = JSON.from(LinkedHashMap.fromEntries(showList.entries.toList().reversed));
    for (var item in reverseM.entries) {
      LOG('--> reverseM item : ${item.value.toString()}');
      if (INT(item.value['action']) != 0 && LIST_NOT_EMPTY(item.value['memberData'])) {
        for (var member in item.value['memberData']) {
          memberList.add(member['nickName']);
          widget.roomInfo.addMemberData(member);
        }
        cache.chatRoomData[widget.roomInfo.id] = widget.roomInfo;
        memberList.refresh();
        LOG('--> refreshMemberList : ${memberList.toString()} / ${item.value['memberList'].toString()}');
        return;
      }
    }
    if (memberList.isEmpty && LIST_NOT_EMPTY(reverseM.entries)) {
      for (var member in widget.roomInfo.memberData) {
        memberList.add(member.nickName);
      }
      memberList.refresh();
    }
  }

  showChatList() {
    List<Widget> result = [];
    var parentId = '';
    // showList = JSON_CREATE_TIME_SORT_ASCE(showList);
    refreshMemberList();
    // LOG('--> showChatList memberList : ${memberList.length} / ${memberList.toString()}');
    for (var i=0; i<showList.length; i++) {
      var isShowDate = true;
      var item = showList.entries.elementAt(i);
      var action = INT(item.value['action']);
      if (action >= 0) {
        if (i+1 < showList.length) {
          var nextItem = showList.entries.elementAt(i+1);
          isShowDate = item.value['senderId'] != nextItem.value['senderId'];
        }
        var isOwner = CheckOwner(item.value['senderId']);
        var isOpened = false;
        var openCount = 0;
        if (item.value['memberList'] != null && item.value['memberList'].length > 1) {
          if (LIST_NOT_EMPTY(item.value['openList'])) {
            for (var member in item.value['memberList']) {
              LOG('--> member item : $member / ${item.value['memberList'].toString()} / ${item.value['openList'].toString()}');
              if (item.value['openList'].contains(member)) {
                openCount++;
              }
            }
            // LOG('--> isOpened : $isOpened / ${widget.roomInfo.memberList.length - 1} / $openCount');
            isOpened = item.value['memberList'].length - 1 <= openCount;
          }
        }
        var isShowFace = parentId != item.value['senderId'];
        ChatItem? addItem = chatItemData[item.key];
        // LOG('-----> showList check [${STR(item.value['desc'])}] : $isOwner / $isOpened / [$openCount / ${addItem != null} ? ${addItem != null ? addItem.openCount : 0}]');
        if (addItem == null || addItem.openCount != openCount) {
          addItem = ChatItem(
            item.value,
            openCount: openCount,
            isOwner: isOwner,
            isManager: isManager,
            isOpened: isOpened,
            isShowFace: isShowFace,
            isShowDate: isShowDate,
            onSelected: (key, status) {

            }, onSetOpened: (message) {
              api.addChatOpenItem(message['id'], AppData.USER_ID);
            }
          );
        }
        result.add(addItem);
        chatItemData[item.key] = addItem;
        if (INT(item.value['action']) == 0) {
          parentId = item.value['senderId'];
        }
      }
    }
    return result;
  }

  @override
  void initState() {
    initData();
    refreshList();
    // getUserInfo();
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
                  actions: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton2(
                        customButton: Container(
                          width: 30,
                          height: double.infinity,
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.more_vert_outlined, size: 22, color: Theme.of(context).indicatorColor),
                        ),
                        // customItemsIndexes: const [1],
                        // customItemsHeight: 6,
                        itemHeight: kMinInteractiveDimension,
                        dropdownWidth: 140,
                        buttonHeight: 30,
                        buttonWidth: 30,
                        itemPadding: const EdgeInsets.only(left: 12, right: 12),
                        offset: const Offset(0, 8),
                        items: [
                          ...DropdownItems.chatRoomMenu1.map((item) => DropdownMenuItem<DropdownItem>(
                            value: item,
                            child: DropdownItems.buildItem(context, item),
                          )),
                        ],
                        onChanged: (value) {
                          var selected = value as DropdownItem;
                          switch(selected.type) {
                            case DropdownItemType.exit:
                              showAlertYesNoCheckDialog(context, widget.roomTitle, 'Would you like to leave the chat room?'.tr,
                                  'Leave quietly'.tr, 'Cancel'.tr, 'OK'.tr).then((result) {
                                if (result > 0) {
                                  chatRepo.exitChatRoom(widget.roomInfo.id, result == 1).then((result2) {
                                    if (result2 != null && JSON_EMPTY(result2['error'])) {
                                      Get.back();
                                    }
                                  });
                                }
                              });
                              break;
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
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
                                          ...showChatList(),
                                          SizedBox(height: 10),
                                        ],
                                      )
                                  ),
                                ),
                                Container(
                                    width: Get.width,
                                    constraints: BoxConstraints(
                                      minHeight: imageData.isEmpty ? 90 : 140,
                                    ),
                                    padding: EdgeInsets.all(10),
                                    color: Theme.of(context).canvasColor,
                                    child: Column(
                                        children: [
                                          if (imageData.isNotEmpty)...[
                                            Row(
                                              children: [
                                                ImageEditScrollViewer(
                                                  imageData,
                                                  itemWidth: 40.0,
                                                  itemHeight: 40.0,
                                                  isEditable: true,
                                                  sidePadding: 0,
                                                  onActionCallback: (key, status) {
                                                    LOG('--> onActionCallback : $key / $status');
                                                    if (status == 2) {
                                                      imageData.remove(key);
                                                      refreshImageData();
                                                    }
                                                  },
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    showAlertDialog(context, 'Remove'.tr, 'Remove all images?'.tr, '', 'OK'.tr).then((result) {
                                                      if (result == 1) {
                                                        imageData.clear();
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
                                                          if (!AppData.isMainActive || (sendText.isEmpty && imageData.isEmpty)) return;
                                                          if (imageData.length >= _imageMax) {
                                                            showAlertDialog(context, 'Image'.tr,
                                                                'You can\'t add any more'.tr, '${'Max'.tr}: $_imageMax', 'OK'.tr);
                                                            return;
                                                          }
                                                          AppData.isMainActive = false;
                                                          // var addItem = {
                                                          //   'id':         '',
                                                          //   'status':     1,
                                                          //   'roomId':     widget.roomInfo.id,
                                                          //   'senderId':   STR(AppData.USER_ID),
                                                          //   'senderName': STR(AppData.USER_NICKNAME),
                                                          //   'senderPic':  STR(AppData.USER_PIC),
                                                          //   'desc':       sendText,
                                                          //   'memberList': widget.roomInfo.memberList,
                                                          //   'createTime': CURRENT_SERVER_TIME(),
                                                          // };
                                                          // var upCount = 0;
                                                          // for (var item in imageData.entries) {
                                                          //   var result = await api.uploadImageData(item.value as JSON, 'chat_img');
                                                          //   if (result != null) {
                                                          //     addItem['picData'] ??= [];
                                                          //     addItem['picData'].add(result);
                                                          //     upCount++;
                                                          //   }
                                                          // }
                                                          // LOG('--> upload image result : $upCount / ${addItem['picData']}');
                                                          // upCount = 0;
                                                          // for (var item in imageData.entries) {
                                                          //   var result = await api.uploadImageData(
                                                          //       {'id': item.key, 'data': item.value['thumb']}, 'chat_img_p');
                                                          //   if (result != null) {
                                                          //     addItem['thumbData'] ??= [];
                                                          //     addItem['thumbData'].add(result);
                                                          //     upCount++;
                                                          //   }
                                                          // }
                                                          // LOG('--> upload thumb result : $upCount / ${addItem['thumbData']}');
                                                          chatRepo.createChatItem(widget.roomInfo, sendText, imageData).then((result) {
                                                            AppData.isMainActive = true;
                                                          });
                                                          widget.textController.text = '';
                                                          sendText = '';
                                                          imageData.clear();
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
    if (AppData.isMainActive) return;
    AppData.isMainActive = false;
    imageData.clear();
    List<XFile>? imageList = await ImagePicker().pickMultiImage();
    if (LIST_NOT_EMPTY(imageList)) {
      showLoadingDialog(context, 'Processing now...'.tr);
      for (var i = 0; i < imageList.length; i++) {
        var image = imageList[i];
        var data = await ReadFileByte(image.path);
        if (data != null) {
          var thumbData = await resizeImage(data.buffer.asUint8List(), 256) as Uint8List;
          var key = Uuid().v1();
          imageData[key] = {'id': key, 'data': data, 'thumb': thumbData};
        }
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

