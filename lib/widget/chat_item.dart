
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/upload_model.dart';
import 'package:kspot_002/repository/user_repository.dart';
import 'package:kspot_002/view/profile/target_profile.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../repository/chat_repository.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../utils/utils.dart';
import 'card_scroll_viewer.dart';

class ChatItem extends StatefulWidget {
  ChatItem(this.messageItem,
      { Key? key,
        this.openCount = 0, this.isOwner = false, this.isManager = false, this.isOpened = false,
        this.isShowFace = true, this.isShowDate = true, this.isChatMode = true,
        this.onSelected, this.onSetOpened }) : super(key: key);
  JSON messageItem;
  int  openCount;
  bool isOwner;
  bool isManager;
  bool isOpened;
  bool isShowFace;
  bool isShowDate;
  bool isChatMode;
  Function(String, int)? onSelected;
  Function(JSON)? onSetOpened;

  @override
  ChatItemState createState() => ChatItemState();
}

class ChatItemState extends State<ChatItem> {
  final api = Get.find<ApiService>();
  final cache = Get.find<CacheService>();
  final userRepo = UserRepository();
  final chatRepo = ChatRepository();
  final radiusSize = 12.0;
  final imageSize = 80.0;
  final faceSize = 40.0;
  final JSON fileData = {};
  var action = 0;

  init() {
    if (LIST_NOT_EMPTY(widget.messageItem['fileData'])) {
      // LOG("--> thumbList : ${widget.messageItem['fileData']}");
      widget.messageItem['fileData'].forEach((item) {
        final fileItem = UploadFileModel.fromJson(item);
        // LOG("--> fileData item : ${fileItem.toJson()}");
        JSON addItem = {'id': fileItem.id};
        if (IS_IMAGE_FILE(fileItem.extension)) {
          addItem['url'] = fileItem.thumb;
          addItem['linkPic'] = fileItem.url;
        } else {
          addItem['url'] = 'assets/file_icons/icon_${fileItem.extension}.png';
          addItem['linkPic'] = addItem['url'];
          addItem['title'] = fileItem.name;
        }
        fileData[fileItem.id] = addItem;
      });
    }
    // LOG('--> ChatItemState init [${widget.messageItem['desc']}]: ${widget.isOwner} / ${widget.isOpened} / ${widget.openCount} => ${widget.messageItem['openList']}');
  }

  @override
  void initState() {
    action = INT(widget.messageItem['action']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    init();
    if (action > 0) {
      var text = '';
      var color = Colors.yellowAccent;
      switch(action) {
        case 1:
          text = 'has enter the room';
          break;
        case 2:
        case 4:
          text = 'has left the room';
          color = Colors.lightBlueAccent;
          break;
        case 3:
          text = 'has [admin] the room';
          color = Colors.purpleAccent;
          break;
      }
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(STR(widget.messageItem['senderName']), style: ItemDescColorBoldStyle(context, color)),
            Text(' ${text.tr}', style: ItemDescStyle(context)),
            SizedBox(width: 10),
            Text(SERVER_TIME_STR(widget.messageItem['createTime'], true), style: ItemChatTimeStyle(context)),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (widget.onSelected != null) widget.onSelected!(widget.messageItem['id'], 0);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE_ES, 0, UI_HORIZONTAL_SPACE_ES, 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isOwner)
                Expanded(child: SizedBox(height: 1)),
              if (!widget.isOwner)...[
                if (widget.isShowFace)
                  showUserPic(context),
                SizedBox(width: widget.isShowFace ? 5 : faceSize + 5),
              ],
              FittedBox(
                fit: BoxFit.cover,
                child: Column(
                  crossAxisAlignment: widget.isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (widget.isShowFace)...[
                      Text(STR(widget.messageItem['senderName']),
                          style: ItemChatNameStyle(context, widget.isOwner)),
                      SizedBox(height: 5),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.isOwner)...[
                          Text(widget.isOpened ? 'READ'.tr : '${widget.openCount}',
                              style: ItemChatReadStyle(context, widget.isOpened)),
                          SizedBox(width: 5),
                          if (widget.isShowDate)...[
                            Row(
                              children: [
                                Text(SERVER_TIME_STR(widget.messageItem['createTime'], true),
                                    style: ItemChatTimeStyle(context)),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery
                                .of(context)
                                .size
                                .width * 0.6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isOwner ? Theme
                                .of(context)
                                .colorScheme
                                .inversePrimary : Theme
                                .of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(widget.isOwner ? radiusSize : 0),
                              topRight: Radius.circular(widget.isOwner ? 0 : radiusSize),
                              bottomLeft: Radius.circular(radiusSize),
                              bottomRight: Radius.circular(radiusSize),
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
                            crossAxisAlignment: widget.isOwner
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (fileData.isNotEmpty)...[
                                SizedBox(
                                  width: fileData.length * imageSize,
                                  child: CardScrollViewer(
                                    fileData,
                                    itemWidth: imageSize,
                                    itemHeight: imageSize,
                                    itemRound: radiusSize,
                                    sidePadding: 0,
                                    isImageExView: true,
                                    backgroundPadding: EdgeInsets.zero,
                                    onActionCallback: (key, status) {
                                      LOG('--> onActionCallback : $key / $status');
                                      showImageSlideDialog(context, fileData.entries.map((e) => STR(e.value['linkPic']).toString()).toList(), 0, true);
                                    },
                                  ),
                                ),
                                SizedBox(height: 5),
                              ],
                              VisibilityDetector(
                                onVisibilityChanged: (value) {
                                  if (value.visibleFraction > 0 && !widget.isOwner && !widget.isOpened) {
                                    // LOG('--> check opened : ${widget.messageItem['desc']} / ${widget.messageItem['openList']}');
                                    widget.messageItem['openList'] ??= [];
                                    if (!widget.messageItem['openList'].contains(AppData.USER_ID)) {
                                      widget.messageItem['openList'].add(AppData.USER_ID);
                                      if (widget.onSetOpened != null) widget.onSetOpened!(widget.messageItem);
                                    }
                                  }
                                },
                                key: GlobalKey(),
                                child: Text(cache.blockData[widget.messageItem['senderId']] != null ? '....' :
                                    DESC(widget.messageItem['desc']), maxLines: null, style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText2),
                              ),
                            ]
                          )
                        ),
                        if (!widget.isOwner)...[
                          Row(
                            children: [
                              SizedBox(width: 5),
                              if (widget.isShowDate)...[
                                SizedBox(width: 5),
                                Text(SERVER_TIME_STR(widget.messageItem['createTime'], true),
                                    style: ItemChatTimeStyle(context)),
                              ],
                              SizedBox(width: 5),
                              Text(widget.isOpened ? 'READ'.tr : '${widget.openCount}',
                                  style: ItemChatReadStyle(context, widget.isOpened)),
                            ],
                          )
                        ],
                      ]
                    )
                  ]
                ),
              ),
              if (widget.isOwner)...[
                SizedBox(width: widget.isShowFace ? 5 : faceSize + 5),
                if (widget.isShowFace)
                  showUserPic(context),
              ],
            ]
          )
        )
      );
    }
  }

  onSelected(type) async {
    Navigator.pop(context, {});
    JSON userInfo = {
      'id': STR(widget.messageItem['senderId']),
      'nickName': STR(widget.messageItem['senderName']),
      'pic': STR(widget.messageItem['senderPic']),
    };
    var roomId      = STR(widget.messageItem['roomId']);
    var targetId    = STR(widget.messageItem['senderId']);
    var targetName  = STR(widget.messageItem['senderName']);
    switch(type) {
      case DropdownItemType.profile:
        var userInfo = await userRepo.getUserInfo(targetId);
        if (userInfo != null) {
          Get.to(() => TargetProfileScreen(userInfo))!.then((value) {
          });
        } else {
          showUserAlertDialog(context, '${'Target user'.tr} : ${widget.messageItem['senderName']}');
        }
        break;
      case DropdownItemType.block:
        userRepo.addBlockUser(context, userInfo, (result) {
          setState(() {
            if (widget.onSelected != null) widget.onSelected!(widget.messageItem['id'], 9);
          });
        });
        break;
      case DropdownItemType.report:
        userRepo.addReportItem(context, 'user', userInfo, (result) {
          setState(() {
            if (widget.onSelected != null) widget.onSelected!(widget.messageItem['id'], 9);
          });
        });
        break;
      case DropdownItemType.admin:
        showAlertYesNoCheckDialog(context, 'Change Admin'.tr,
          'Do you want to change admin?'.tr,
          'Admin change confirmation'.tr, 'Cancel'.tr, 'OK'.tr, needCheck: true).then((result) {
          if (result > 1) {
            chatRepo.setChatRoomAdmin(roomId, targetId, targetName).then((result2) {
              if (result2 != null) {
                LOG('--> admin changed : ${result2.toString()}');
                cache.setChatRoomItem(ChatRoomModel.fromJson(result2), true);
                if (widget.onSelected != null) widget.onSelected!(widget.messageItem['id'], 8);
              }
            });
          }
        });
        break;
      case DropdownItemType.kick:
        showAlertYesNoDialog(context, 'Drop Out'.tr, 'Are you sure you want to kick the target?'.tr,
          '', 'Cancel'.tr, 'OK'.tr).then((result) {
          if (result > 0) {
            chatRepo.setChatRoomKickUser(roomId, targetId, targetName).then((result2) {
              if (result2 != null) {
                LOG('--> admin changed : ${result2.toString()}');
                cache.setChatRoomItem(ChatRoomModel.fromJson(result2), true);
                if (widget.onSelected != null) widget.onSelected!(widget.messageItem['id'], 8);
              }
            });
          }
        });
        break;
    }
  }

  showUserPic(context) {
    if (widget.isOwner) {
      return Container(
        width:  faceSize,
        height: faceSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: showImageFit(widget.messageItem['senderPic']),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        if (widget.isOwner) return;
        unFocusAll(context);
        List<Widget> btnList = [
          ...UserMenuItems.chatUserMenu.map((item) => UserMenuItems.buildItem(context, item, onSelected: onSelected)),
          if (widget.isManager)...[
            ...UserMenuItems.chatAdminMenu0.map((item) => UserMenuItems.buildItem(context, item, onSelected: onSelected)),
            if (!cache.blockData.containsKey(STR(widget.messageItem['senderId'])))
              ...UserMenuItems.chatAdminMenu1.map((item) => UserMenuItems.buildItem(context, item, onSelected: onSelected)),
          ],
        ];
        showButtonListDialog(context, btnList);
      },
      child: Container(
        width:  faceSize,
        height: faceSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: showImageFit(widget.messageItem['senderPic']),
        ),
      ),
    );

    // return DropdownButtonHideUnderline(
    //   child: DropdownButton2(
    //     customButton: Container(
    //       width:  faceSize,
    //       height: faceSize,
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.all(Radius.circular(100)),
    //         border: Border.all(
    //           color: Theme.of(context).primaryColor.withOpacity(0.8),
    //           width: 2,
    //         ),
    //       ),
    //       child: ClipOval(
    //         child: showImageFit(widget.messageItem['senderPic']),
    //       ),
    //     ),
    //     // customItemsIndexes: const [1],
    //     // customItemsHeight: 6,
    //     itemHeight: kMinInteractiveDimension,
    //     dropdownWidth: 150,
    //     buttonHeight: 30,
    //     buttonWidth: 30,
    //     itemPadding: const EdgeInsets.only(left: 12, right: 12),
    //     offset: const Offset(0, 120),
    //     items: [
    //       ...UserMenuItems.chatUserMenu.map((item) => DropdownMenuItem<DropdownItem>(
    //         value: item,
    //         child: UserMenuItems.buildItem(context, item),
    //       )),
    //       if (widget.isManager)
    //         ...UserMenuItems.chatManagerMenu.map((item) => DropdownMenuItem<DropdownItem>(
    //           value: item,
    //           child: UserMenuItems.buildItem(context, item),
    //         )),
    //     ],
    //     onChanged: (value) async {
    //       unFocusAll(context);
    //       var selected = value as DropdownItem;
    //       switch(selected.type) {
    //         case DropdownItemType.profile:
    //           var userInfo = await userRepo.getUserInfo(widget.messageItem['senderId']);
    //           if (userInfo != null) {
    //             Get.to(() => TargetProfileScreen(userInfo))!.then((value) {
    //             });
    //           } else {
    //             showUserAlertDialog(context, '${'Target user'.tr} : ${widget.messageItem['senderName']}');
    //           }
    //           break;
    //         case DropdownItemType.block:
    //           JSON user = {
    //             'id': STR(widget.messageItem['senderId']),
    //             'nickName': STR(widget.messageItem['senderName']),
    //             'pic': STR(widget.messageItem['senderPic']),
    //           };
    //           userRepo.addBlockUser(context, UserModel.fromJson(user));
    //           break;
    //         case DropdownItemType.report:
    //           break;
    //         case DropdownItemType.manager:
    //           break;
    //         case DropdownItemType.kick:
    //           break;
    //
    //       }
    //     },
    //   ),
    // );
  }
}