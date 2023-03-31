
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/message_model.dart';
import 'package:kspot_002/services/cache_service.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../repository/user_repository.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/user_item_widget.dart';
import '../profile/profile_screen.dart';
import '../profile/profile_target_screen.dart';

class MessageGroupItem extends StatefulWidget {
  MessageGroupItem(this.targetId, this.targetName, this.targetPic, this.messageItem,
      {Key? key, this.unOpenCount = 0, this.onMenuSelected, this.onSelected}) : super(key: key);

  String targetId;
  String targetName;
  String targetPic;
  MessageModel messageItem;
  int unOpenCount;

  Function(DropdownItemType, String)? onMenuSelected;
  Function(String)? onSelected;

  @override
  MessageGroupItemState createState() => MessageGroupItemState();
}

class MessageGroupItemState extends State<MessageGroupItem> {
  final userRepo = UserRepository();
  var followType = -1;

  refresh() {
    setState(() {
    });
  }

  @override
  void initState() {
    followType = CheckFollowUser(widget.targetId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(UI_ROUND_RADIUS)),
        color: Theme.of(context).cardColor
      ),
      child: Row(
        children: [
          SizedBox(width: 5),
          GestureDetector(
            onTap: () async {
              var userInfo = await userRepo.getUserInfo(widget.targetId);
              if (userInfo != null) {
                Get.to(() => ProfileTargetScreen(userInfo))!.then((value) {});
              } else {
                showUserAlertDialog(context, '${'Target user'.tr} : ${widget.targetName}');
              }
            },
            child: SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: showImageFit(widget.targetPic),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.onSelected != null) widget.onSelected!(widget.messageItem.id);
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
                          child: Row(
                              children: [
                                Text(STR(widget.targetName), style: ItemTitleStyle(context)),
                                if (followType == 2)...[
                                  SizedBox(width: 5),
                                  Container(
                                    width: 14,
                                    height: 14,
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                      color: Theme.of(context).colorScheme.tertiary,
                                    ),
                                    child: Center(
                                      child: Text('F', style: ItemDescBoldStyle(context)),
                                    ),
                                    // child: Text(followType == 1 ? 'Following'.tr : followType == 2 ? 'Follower'.tr : 'Follow'.tr,
                                    //     style: TextStyle(
                                    //       fontSize: 10,
                                    //       color: Colors.white,
                                    //     )
                                    // ),
                                  ),
                                ],
                              ]
                          ),
                        ),
                        Text(SERVER_TIME_STR(widget.messageItem.updateTime, true), style: ItemDescExStyle(context)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(DESC(widget.messageItem.desc), maxLines: 1, style: ItemDescStyle(context), overflow: TextOverflow.ellipsis),
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
                ...UserMenuItems.messageMenu.map((item) => DropdownMenuItem<DropdownItem>(
                  value: item,
                  child: UserMenuItems.buildItem(context, item),
                )),
              ],
              onChanged: (value) {
                var selected = value as DropdownItem;
                if (widget.onMenuSelected != null) widget.onMenuSelected!(selected.type, widget.targetId);
              },
            ),
          )
        ],
      ),
    );
  }
}