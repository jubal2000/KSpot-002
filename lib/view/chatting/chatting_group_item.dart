
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/widgets.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/etc_model.dart';
import 'package:kspot_002/services/cache_service.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/chat_model.dart';
import '../../repository/user_repository.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../view_model/chat_view_model.dart';
import '../../widget/user_item_widget.dart';
import '../profile/target_profile.dart';

class ChatGroupItem extends StatelessWidget {
  ChatGroupItem(this.groupItem,
      {Key? key,
        this.unOpenCount = 0,
        this.isBlocked = false,
        this.roomType = 0,
        this.onMenuSelected,
        this.onSelected}) : super(key: key);

  ChatRoomModel? groupItem;
  int roomType;
  int unOpenCount;    // no read message count..
  bool isBlocked;

  Function(DropdownItemType, String)? onMenuSelected;
  Function(String)? onSelected;

  final cache = Get.find<CacheService>();
  final showMemberMax = 4;
  var itemHeight = 65.0;
  var isEnter = false;
  var fixIndex = -1;
  var isAdmin = false;
  List<MemberData> showList = [];

  initData() {
    isEnter = groupItem!.memberList.contains(AppData.USER_ID);
    itemHeight = roomType == ChatRoomType.public ? 50 : 65;
    fixIndex = cache.getRoomIndexTop(roomType, groupItem!.id);
    isAdmin = groupItem!.userId == AppData.USER_ID;
    showList.clear();
    for (var i=0; i<groupItem!.memberData.length; i++) {
      if (i > showMemberMax) return;
      showList.add(groupItem!.memberData[i]);
    }
    // LOG('--> ChatGroupItem initData [${groupItem!.id}] : $fixIndex / $itemHeight');
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return Container(
      width: double.infinity,
      height: itemHeight,
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(UI_ROUND_RADIUS)),
        color: Theme.of(context).cardColor
      ),
      child: Row(
        children: [
          if (groupItem!.type == 0 && groupItem!.pic.isNotEmpty)...[
            GestureDetector(
              onTap: () async {
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: itemHeight - 10,
                  constraints: BoxConstraints (
                    maxWidth: itemHeight * 1.5,
                  ),
                  child: showImageFit(groupItem!.pic),
                )
              ),
            ),
          ],
        if (groupItem!.type == 1 && groupItem!.memberData.length != 2)...[
          Container(
            width: itemHeight - 10,
            height: itemHeight - 10,
            child: MasonryGridView.count(
              shrinkWrap: true,
              itemCount: showList.length,
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              itemBuilder: (BuildContext context, int index) {
                return ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: showImageWidget(showList[index].pic, BoxFit.fill),
                );
              }
            ),
          )
        ],
        if (groupItem!.type == 1 && groupItem!.memberData.length == 2)...[
          Container(
            width: itemHeight - 10,
            height: itemHeight - 10,
            child: Stack(
              children: [
                TopLeftAlign(
                  child: SizedBox(
                    width: itemHeight * 0.5,
                    height: itemHeight * 0.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: showImageWidget(showList[0].pic, BoxFit.fill),
                    )
                  )
                ),
                BottomRightAlign(
                  child: Container(
                    width: itemHeight * 0.5,
                    height: itemHeight * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: Theme.of(context).cardColor)
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: showImageWidget(showList[1].pic, BoxFit.fill),
                    )
                  )
                )
              ],
            ),
          )
        ],
        SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isBlocked && onSelected != null) onSelected!(groupItem!.id);
              },
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isAdmin)...[
                          Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary, size: 18),
                          SizedBox(width: 5),
                        ],
                        if (groupItem!.type == ChatType.public)
                          Row(
                            children: [
                              Text(STR(groupItem!.title), style: isBlocked ? ItemTitleDisableStyle(context) : ItemTitleStyle(context), maxLines: 1),
                              if (!isBlocked)...[
                                SizedBox(width: 10),
                                Text('${groupItem!.memberData.length}', style: ItemTitleBoldStyle(context)),
                              ],
                            ]
                          ),
                        if (groupItem!.type == ChatType.private)
                          Row(
                            children: [
                              for (var item in showList)
                                Text(showList.indexOf(item) > 0 ? ', ${item.nickName}' : item.nickName, style: ItemTitleStyle(context)),
                              SizedBox(width: 10),
                              Text('${groupItem!.memberData.length}', style: ItemTitleBoldStyle(context)),
                            ],
                          ),
                        Expanded(child: SizedBox(height: 1)),
                        if (roomType != ChatRoomType.public && unOpenCount > 0)...[
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            constraints: BoxConstraints(
                              minWidth: 16,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Theme.of(context).colorScheme.error
                            ),
                            child: Text('$unOpenCount',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                                    color: Theme.of(context).cardColor)),
                          ),
                        ],
                        if (fixIndex >= 0)...[
                          SizedBox(width: 5),
                          Icon(Icons.bookmark_border, color: Theme.of(context).colorScheme.tertiary, size: 18),
                        ],
                      ],
                    ),
                    if (roomType != ChatRoomType.public && !isBlocked)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(STR(groupItem!.lastMessage), maxLines: 1, style: ItemDescStyle(context), overflow: TextOverflow.ellipsis),
                          ),
                          Text(SERVER_TIME_STR(groupItem!.updateTime, true), style: ItemDescExStyle(context)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: Container(
                width: 24,
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
                if (isBlocked)...[
                  DropdownMenuItem<DropdownItem>(value: userMenuMsgUnReport, child: DropdownItems.buildItem(context, userMenuMsgUnReport)),
                ],
                if (!isBlocked)...[
                  if (!isEnter)...[
                    ...DropdownItems.chatRoomMenu0.map((item) => DropdownMenuItem<DropdownItem>(
                      value: item,
                      child: DropdownItems.buildItem(context,item),
                    )),
                    if (roomType != ChatRoomType.publicMy)...[
                      DropdownMenuItem<DropdownItem>(value: userMenuMsgReport, child: DropdownItems.buildItem(context, userMenuMsgReport)),
                    ],
                  ],
                  if (isEnter)...[
                    if (!isAdmin)
                      ...DropdownItems.chatRoomMenu1.map((item) => DropdownMenuItem<DropdownItem>(
                        value: item,
                        child: DropdownItems.buildItem(context, item),
                      )),
                    if (roomType != ChatRoomType.public)
                      ...alarmMenu(context),
                  ],
                  ...indexMenu(context),
                ],
              ],
              onChanged: (value) {
                var selected = value as DropdownItem;
                if (onMenuSelected != null) onMenuSelected!(selected.type, groupItem!.id);
              },
            ),
          )
        ],
      ),
    );
  }

  List<DropdownMenuItem> alarmMenu(context) {
    var item = cache.roomAlarmData.contains(groupItem!.id) ? dropMenuAlarmOff : dropMenuAlarmOn;
    return [
        DropdownMenuItem<DropdownItem>(value: item, child: DropdownItems.buildItem(context, item)),
    ];
  }

  List<DropdownMenuItem> indexMenu(context) {
    return [
      if (fixIndex != 0)
        DropdownMenuItem<DropdownItem>(value: dropMenuIndexBkOn, child: DropdownItems.buildItem(context, dropMenuIndexBkOn)),
      if (fixIndex >= 0)
        DropdownMenuItem<DropdownItem>(value: dropMenuIndexBkOff, child: DropdownItems.buildItem(context, dropMenuIndexBkOff)),
    ];
  }
}