
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
      {Key? key, this.unOpenCount = 0, this.roomType = ChatRoomType.public, this.onMenuSelected, this.onSelected}) : super(key: key);

  ChatRoomModel? groupItem;
  int unOpenCount;
  ChatRoomType roomType;

  Function(DropdownItemType, String)? onMenuSelected;
  Function(String)? onSelected;

  final cache = Get.find<CacheService>();
  final showMemberMax = 4;
  var itemHeight = 0.0;
  var isEnter = false;
  List<MemberData> showList = [];

  showUserList() {
    LOG('--> showUserList [${groupItem!.id}] : ${groupItem!.memberData.length}');
    isEnter = groupItem!.memberList.contains(AppData.USER_ID);
    itemHeight = roomType == ChatRoomType.public ? 50 : 65;
    showList.clear();
    for (var i=0; i<groupItem!.memberData.length; i++) {
      if (i > showMemberMax) return;
      showList.add(groupItem!.memberData[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    showUserList();
    return Container(
      width: double.infinity,
      height: itemHeight,
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.all(5.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(UI_ROUND_RADIUS)),
        color: Theme.of(context).cardColor
      ),
      child: Row(
        children: [
          if (groupItem!.type == 0 && groupItem!.pic.isNotEmpty)...[
            GestureDetector(
              onTap: () async {
                // var userInfo = await userRepo.getUserInfo(widget.targetId);
                // if (userInfo != null) {
                //   Get.to(() => TargetProfileScreen(userInfo!))!.then((value) {});
                // } else {
                //   showUserAlertDialog(context, '${'Target user'.tr} : ${widget.targetName}');
                // }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: showImageFit(groupItem!.pic),
              ),
            ),
          ],
        if (groupItem!.type == 1 && groupItem!.memberData.length != 2)...[
          Container(
            width: itemHeight - 10.sp,
            height: itemHeight - 10.sp,
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
            width: itemHeight - 10.sp,
            height: itemHeight - 10.sp,
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
                if (onSelected != null) onSelected!(groupItem!.id);
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
                        if (groupItem!.type == 0)
                          Expanded(
                            child: Row(
                              children: [
                                Text(STR(groupItem!.title), style: ItemTitleStyle(context), maxLines: 1),
                                SizedBox(width: 10),
                                Text('${groupItem!.memberData.length}', style: ItemTitleBoldStyle(context)),
                              ]
                            )
                          ),
                        if (groupItem!.type == 1)
                          Expanded(
                            child: Row(
                              children: [
                                for (var item in showList)
                                  // Row(
                                  //   children: [
                                  //     UserCardWidget(item.toJson(), faceSize: FACE_CIRCLE_SIZE_SE, faceCircleSize: 1.0, isShowName: false),
                                  //     Text(item.nickName, style: ItemTitleBoldStyle(context)),
                                  //   ]
                                  // ),
                                  Text(showList.indexOf(item) > 0 ? ', ${item.nickName}' : item.nickName, style: ItemTitleStyle(context)),
                                SizedBox(width: 10),
                                Text('${groupItem!.memberData.length}', style: ItemTitleBoldStyle(context)),
                              ],
                            ),
                          ),
                        if (roomType != ChatRoomType.public && unOpenCount > 0)...[
                          SizedBox(width: 10),
                          Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
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
                      ],
                    ),
                    if (roomType != ChatRoomType.public)
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
          Obx (() => DropdownButtonHideUnderline(
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
                if (!isEnter)...[
                  ...UserMenuItems.chatRoomMenu0.map((item) => DropdownMenuItem<DropdownItem>(
                    value: item,
                    child: UserMenuItems.buildItem(item),
                  )),
                ],
                if (isEnter)...[
                  ...UserMenuItems.chatRoomMenu1.map((item) => DropdownMenuItem<DropdownItem>(
                    value: item,
                    child: UserMenuItems.buildItem(item),
                  )),
                ],
                if (roomType != ChatRoomType.publicMy)...[
                  DropdownMenuItem<DropdownItem>(value: dropMenuMsgReport, child: UserMenuItems.buildItem(dropMenuMsgReport)),
                ],
                if (roomType != ChatRoomType.public)...[
                  ...alarmMenu(),
                ],
                ...indexMenu(),
              ],
              onChanged: (value) {
                var selected = value as DropdownItem;
                if (onMenuSelected != null) onMenuSelected!(selected.type, groupItem!.id);
              },
            ),
          ))
        ],
      ),
    );
  }

  DropdownMenuItem showLine() {
    return DropdownMenuItem<DropdownItem>(value: dropMenuLine, child: UserMenuItems.buildItem(dropMenuLine));
  }

  List<DropdownMenuItem> alarmMenu() {
    var item = cache.roomAlarmData.contains(groupItem!.id) ? dropMenuAlarmOff : dropMenuAlarmOn;
    return [
        DropdownMenuItem<DropdownItem>(value: item, child: UserMenuItems.buildItem(item)),
    ];
  }

  List<DropdownMenuItem> indexMenu() {
    var index = cache.getRoomIndexTop(roomType.index, groupItem!.id);
    LOG('--> indexMenu index [${groupItem!.id}] => $index');
    return [
      if (index != 0)
        DropdownMenuItem<DropdownItem>(value: dropMenuIndexTop, child: UserMenuItems.buildItem(dropMenuIndexTop)),
      // if (index > 0)
      //   DropdownMenuItem<DropdownItem>(value: dropMenuIndexUp, child: UserMenuItems.buildItem(dropMenuIndexUp)),
      // DropdownMenuItem<DropdownItem>(value: dropMenuIndexDown, child: UserMenuItems.buildItem(dropMenuIndexDown)),
    ];
  }
}