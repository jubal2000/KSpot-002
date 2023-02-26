
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../data/app_data.dart';
import '../data/common_sizes.dart';
import '../data/dialogs.dart';
import '../data/theme_manager.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import 'card_scroll_viewer.dart';

class ChatItem extends StatefulWidget {
  ChatItem(this.messageItem,
      { Key? key,
        this.openCount = 0, this.isOwner = false, this.isOpened = false,
        this.isShowFace = true, this.isShowDate = true, this.isChatMode = true,
        this.onSelected, this.onSetOpened }) : super(key: key);
  JSON messageItem;
  int  openCount;
  bool isOwner;
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
  final radiusSize = 12.0;
  final imageSize = 80.0;
  final faceSize = 40.0;
  final JSON imageData = {};

  init() {
    if (LIST_NOT_EMPTY(widget.messageItem['thumbData'])) {
      LOG("--> thumbData : ${widget.messageItem['thumbData']}");
      widget.messageItem['thumbData'].forEach((item) {
        LOG("--> thumbData item : $item");
        var index = widget.messageItem['thumbData'].indexOf(item);
        var key = Uuid().v1();
        imageData[key] = {'id': key, 'url': item};
        if (widget.messageItem['picData'][index] != null) {
          imageData[key]['linkPic'] = widget.messageItem['picData'][index];
        }
      });
    }
    LOG('--> ChatItemState init [${widget.messageItem['desc']}]: ${widget.isOwner} / ${widget.isOpened} / ${widget.openCount} => ${widget.messageItem['openList']}');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    init();
    if (INT(widget.messageItem['action']) > 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: faceSize + 10, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(STR(widget.messageItem['senderName']), style: ItemDescColorStyle(context, Colors.yellowAccent)),
            Text(' ${'has left the room'.tr}', style: ItemDescStyle(context)),
            SizedBox(width: 10),
            Text(SERVER_TIME_STR(widget.messageItem['createTime']), style: ItemChatTimeStyle(context)),
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
                          Text(widget.isOpened ? 'READ'.tr : '${widget.openCount} ${'READ'.tr}',
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
                                .width * 0.65,
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
                              if (imageData.isNotEmpty)...[
                                SizedBox(
                                  width: imageData.length * imageSize,
                                  child: CardScrollViewer(
                                    imageData,
                                    itemWidth: imageSize,
                                    itemHeight: imageSize,
                                    itemRound: radiusSize,
                                    sidePadding: 0,
                                    isImageExView: true,
                                    backgroundPadding: EdgeInsets.zero,
                                    onActionCallback: (key, status) {
                                      LOG('--> onActionCallback : $key / $status');
                                      showImageSlideDialog(context,
                                          List<String>.from(widget.messageItem['picData'].map((item) {
                                            LOG('--> imageData item : ${item.runtimeType} / $item');
                                            return item.runtimeType == String ? STR(item) : item['url'] ??
                                                item['image'];
                                          }).toList()), 0, true);
                                    },
                                  ),
                                ),
                                SizedBox(height: 5),
                              ],
                              VisibilityDetector(
                                onVisibilityChanged: (value) {
                                  if (value.visibleFraction > 0 && !widget.isOwner && !widget.isOpened) {
                                    LOG('--> check opened : ${widget.messageItem['desc']} / ${widget
                                        .messageItem['openList']}');
                                    widget.messageItem['openList'] ??= [];
                                    if (!widget.messageItem['openList'].contains(AppData.USER_ID)) {
                                      widget.messageItem['openList'].add(AppData.USER_ID);
                                    }
                                    if (widget.onSetOpened != null) widget.onSetOpened!(widget.messageItem);
                                  }
                                },
                                key: GlobalKey(),
                                child: Text(DESC(widget.messageItem['desc']), maxLines: null, style: Theme
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
                              Text(widget.isOpened ? 'READ'.tr : '${'READ'.tr} ${widget.openCount}',
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

  showUserPic(context) {
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
}