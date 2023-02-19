
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/message_model.dart';
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

class ChatGroupItem extends StatefulWidget {
  ChatGroupItem(this.groupItem,
      {Key? key, this.unOpenCount = 0, this.onMenuSelected, this.onSelected}) : super(key: key);

  ChatRoomModel? groupItem;
  int unOpenCount;

  Function(DropdownItemType, String)? onMenuSelected;
  Function(String)? onSelected;

  @override
  ChatGroupItemState createState() => ChatGroupItemState();
}

class ChatGroupItemState extends State<ChatGroupItem> {
  refresh() {
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65.w,
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.all(5.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(UI_ROUND_RADIUS)),
        color: Theme.of(context).cardColor
      ),
      child: Row(
        children: [
          if (widget.groupItem!.pic.isNotEmpty)...[
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
                child: showImageFit(widget.groupItem!.pic),
              ),
            ),
            SizedBox(width: 10),
          ],
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.onSelected != null) widget.onSelected!(widget.groupItem!.id);
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
                        Expanded(
                          child: Text(STR(widget.groupItem!.title), style: ItemTitleStyle(context), maxLines: 1),
                        ),
                        Text(SERVER_TIME_STR(widget.groupItem!.updateTime, true), style: ItemDescExStyle(context)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(DESC(widget.groupItem!.lastMessage), maxLines: 1, style: ItemDescStyle(context), overflow: TextOverflow.ellipsis),
                        ),
                        if (widget.unOpenCount > 0)...[
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
                            child: Text('${widget.unOpenCount}',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                                    color: Theme.of(context).cardColor)),
                          ),
                        ],
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
              itemHeight: 45,
              dropdownWidth: 160,
              buttonHeight: 30,
              buttonWidth: 30,
              itemPadding: const EdgeInsets.only(left: 12, right: 12),
              offset: const Offset(0, 8),
              items: [
                ...UserMenuItems.chatRoomMenu.map((item) => DropdownMenuItem<DropdownItem>(
                  value: item,
                  child: UserMenuItems.buildItem(item),
                )),
              ],
              onChanged: (value) {
                var selected = value as DropdownItem;
                if (widget.onMenuSelected != null) widget.onMenuSelected!(selected.type, widget.groupItem!.id);
              },
            ),
          )
        ],
      ),
    );
  }
}