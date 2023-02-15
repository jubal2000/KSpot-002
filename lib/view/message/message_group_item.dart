
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/models/message_model.dart';
import 'package:kspot_002/services/cache_service.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../repository/user_repository.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/user_item_widget.dart';
import '../profile/target_profile.dart';

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

  @override
  void initState() {
    followType = CheckFollowUser(widget.targetId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 7),
      color: Colors.transparent,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              var userInfo = await userRepo.getUserInfo(widget.targetId);
              if (JSON_NOT_EMPTY(userInfo)) {
                Get.to(() => TargetProfileScreen(userInfo!))!.then((value) {});
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                              children: [
                                Text(STR(widget.targetName), style: Theme.of(context).textTheme.subtitle1),
                                if (followType > 0)...[
                                  SizedBox(width: 5),
                                  Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    child: Text(followType == 1 ? 'Following'.tr : followType == 2 ? 'Follower'.tr : 'Follow'.tr,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        )
                                    ),
                                  )
                                ],
                              ]
                          ),
                        ),
                        Text(widget.messageItem.createTime, style: ItemDescExStyle(context)),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(DESC(widget.messageItem.desc), maxLines: 2, style: ItemDescStyle(context)),
                          ),
                          if (widget.unOpenCount > 0)
                            Container(
                              height: 20,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(3),
                              constraints: BoxConstraints(
                                minWidth: 20,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Theme.of(context).colorScheme.primary
                              ),
                              child: Text('${widget.unOpenCount}',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                      color: AppData.currentThemeMode ? Colors.white : Colors.black)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
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
                  child: UserMenuItems.buildItem(item),
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