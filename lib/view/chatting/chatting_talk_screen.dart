
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
import 'package:provider/provider.dart';
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
import '../../view_model/chat_talk_view_model.dart';
import '../../view_model/chat_view_model.dart';
import '../../widget/card_scroll_viewer.dart';
import '../../widget/chat_item.dart';

class ChatTalkScreen extends StatefulWidget {
  ChatTalkScreen(this.roomInfo, {Key? key, this.roomTitle = ''}) : super(key: key);

  ChatRoomModel roomInfo;
  String roomTitle;

  @override
  ChatTalkScreenState createState() => ChatTalkScreenState();
}

class ChatTalkScreenState extends State<ChatTalkScreen> {
  final chatRepo    = ChatRepository();
  final _viewModel  = ChatTalkViewModel();

  @override
  void initState() {
    _viewModel.initData(widget.roomInfo);
    _viewModel.getChatData();
    _viewModel.refreshListYPos();
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
        child: ChangeNotifierProvider<ChatTalkViewModel>.value(
          value: _viewModel,
          child: Consumer<ChatTalkViewModel>(builder: (context, viewModel, _) {
            LOG('--> ChatTalkViewModel refresh');
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    if (widget.roomInfo.type == ChatType.public)...[
                      if (widget.roomInfo.pic.isNotEmpty)...[
                        Obx(() => viewModel.showTitlePic(viewModel.roomPic.value)),
                        SizedBox(width: 10),
                      ],
                      Obx(() => Expanded(child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(viewModel.roomTitle.value, style: ChatTitleStyle(context)),
                              SizedBox(width: 5),
                              Text('${viewModel.memberList.length}', style: ItemDescColorBoldStyle(context)),
                            ],
                          ),
                          viewModel.showMemberListText(),
                        ]
                      ))),
                    ],
                    if (widget.roomInfo.type == ChatType.private)...[
                      viewModel.showMemberListText(),
                    ],
                  ],
                ),
                actions: [
                  Obx(() => DropdownButtonHideUnderline(
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
                      items: viewModel.roomMenuList(),
                      onChanged: (value) {
                        var selected = value as DropdownItem;
                        viewModel.onRoomMenuAction(selected.type);
                      },
                    ),
                  )),
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
                          viewModel.showChatMainList(),
                          viewModel.showChatEditBox(),
                        ]
                      ),
                      viewModel.showChatButtonBox(),
                      if (LIST_NOT_EMPTY(viewModel.roomInfo!.noticeData))
                        viewModel.showChatNotice(),
                    ]
                  )
                )
              );
            }
          )
        )
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

