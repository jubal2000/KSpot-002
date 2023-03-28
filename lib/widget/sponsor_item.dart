
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/data/dialogs.dart';
import 'package:kspot_002/models/sponsor_model.dart';

import '../data/app_data.dart';
import '../data/theme_manager.dart';
import '../models/event_model.dart';
import '../models/place_model.dart';
import '../repository/event_repository.dart';
import '../repository/sponsor_repository.dart';
import '../services/api_service.dart';
import '../utils/utils.dart';
import '../view_model/event_detail_view_model.dart';
import 'like_widget.dart';
import 'user_item_widget.dart';
import '../view/event/event_edit_screen.dart';

class SponsorCardItem extends StatefulWidget {
  SponsorCardItem(this.itemData,
      {Key? key,
        this.animationController,
        this.itemPadding,
        this.itemHeight = 90,
        this.isSelectable = false,
        // this.isShowTheme = true,
        this.isShowHomeButton = true,
        this.isShowPlaceButton = true,
        this.isShowUser = true,
        this.isShowLike = true,
        this.isPromotion = false,
        this.isMyItem = false,
        this.isExpired = false,
        this.selectMax = 9,
        this.onShowDetail,
        this.onRefresh}) : super(key: key);

  SponsorModel itemData;
  bool isSelectable;
  bool isShowHomeButton;
  bool isShowPlaceButton;
  // bool isShowTheme;
  bool isShowUser;
  bool isShowLike;
  bool isPromotion;
  bool isMyItem;
  bool isExpired;
  int selectMax;

  double itemHeight;
  EdgeInsets? itemPadding;
  Function(JSON)? onRefresh;
  Function(String, int)? onShowDetail;
  AnimationController? animationController;

  @override
  SponsorCardItemState createState() => SponsorCardItemState();
}

class SponsorCardItemState extends State<SponsorCardItem> {
  final repo = SponsorRepository();
  final api = Get.find<ApiService>();
  var _imageHeight = 0.0;
  List<JSON> _userListData = [];

  toggleShowStatus(context) {
    var title = widget.itemData.showStatus == 1 ? 'Hide' : 'Show';
    showAlertYesNoDialog(context, title.tr, '$title sponsored?'.tr, 'In the hide state, other users cannot see it'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
      if (value == 1) {
        if (repo.checkIsExpired(widget.itemData)) {
          showAlertDialog(context, title.tr, 'This sponsored event has expired'.tr, '', 'OK'.tr);
          return;
        }
        repo.setSponsorShowStatus(widget.itemData.id, widget.itemData.showStatus == 1 ? 0 : 1).then((result) {
          if (result) {
            setState(() {
              widget.itemData.showStatus = widget.itemData.showStatus == 1 ? 0 : 1;
              ShowToast('${widget.itemData.showStatus == 1 ? 'Show'.tr : 'Hide'.tr} ${'complete'.tr}');
              if (widget.onRefresh != null) widget.onRefresh!(widget.itemData.toJson());
            });
          }
        });
      }
    });
  }

  moveToEdit() {
  }

  deleteItem(context) {
    showAlertYesNoDialog(context, 'Delete'.tr,
      'Are you sure you want to delete it?'.tr, 'Alert) Recovery is not possible'.tr, 'Cancel'.tr, 'OK'.tr).then((value) {
      if (value == 1) {
        // showTextInputDialog(context, 'Delete confirm'.tr,
        //     'Typing \'delete now\''.tr, 'Alert) Recovery is not possible'.tr, 10, null).then((result) {
        //   if (result.toLowerCase() == 'delete now') {
        if (repo.checkIsEnabled(widget.itemData)) {
          showAlertDialog(context, 'Delete'.tr, '', 'Sponsorship has already started and cannot be deleted'.tr, 'OK'.tr);
        } else {
            repo.setSponsorStatus(widget.itemData.id, 0).then((result) {
              if (result) {
                setState(() {
                  widget.itemData.status = 0;
                  if (widget.onRefresh != null) widget.onRefresh!(widget.itemData.toJson());
                });
              }
            });
        //   }
        // });
        }
      }
    });
  }

  @override
  Widget build(context) {
    widget.itemPadding ??= EdgeInsets.symmetric(vertical: 5);
    _imageHeight = widget.itemHeight - widget.itemPadding!.top - widget.itemPadding!.bottom;
    return GestureDetector(
        onTap: () {
          unFocusAll(context);
          if (widget.onShowDetail != null) widget.onShowDetail!(widget.itemData.id, 0);
        },
        child: Container(
          height: widget.itemHeight,
          padding: widget.itemPadding,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ColorFiltered(
              colorFilter: !widget.isExpired && widget.itemData.showStatus == 1 ? ColorFilter.mode(
                Colors.transparent,
                BlendMode.multiply,
              ) : ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(widget.isShowUser ? 20 : 0)),
                  color: Theme.of(context).canvasColor,
                ),
                child: Row(
                  children: [
                    // showSizedImage(item.value['pic'] ?? _placeInfo['pic'], _height - _padding * 2),
                    if (widget.isSelectable)...[
                      Icon(Icons.arrow_forward_ios, color: AppData.listSelectData.containsKey(widget.itemData.id) ?
                      Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5)),
                      SizedBox(width: 5),
                    ],
                    SizedBox(
                      width: _imageHeight,
                      height: _imageHeight,
                      child: Stack(
                        children: [
                          showImage(widget.itemData.eventPic, Size(_imageHeight, _imageHeight)),
                          if (widget.itemData.showStatus == 0)
                            OutlineIcon(Icons.visibility_off_outlined, 20, Colors.white, x:3, y:3),
                          if (widget.isExpired)
                            Center(
                                child: Text("EXPIRED".tr, style: ItemDescOutlineStyle(context))
                            )
                        ]
                      )
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // if (widget.isShowTheme)...[
                                //   Container(
                                //     width: 12,
                                //     height: 12,
                                //     decoration: BoxDecoration(
                                //       color: Theme.of(context).primaryColor.withOpacity(0.5),
                                //       borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                //     ),
                                //   ),
                                //   SizedBox(width: 5),
                                // ],
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(STR(widget.itemData.eventTitle), style: ItemTitleStyle(context), maxLines: 1),
                                      if (widget.isPromotion)...[
                                        SizedBox(width: 2),
                                        Icon(Icons.star, size: 20, color: Theme.of(context).colorScheme.tertiary),
                                      ]
                                    ],
                                  ),
                                ),
                                if (widget.isShowLike)...[
                                  SizedBox(width: 5),
                                  LikeSmallWidget(context, 'event', widget.itemData.toJson()),
                                ],
                              ]
                            ),
                            Expanded(child:
                              Row(
                              children: [
                                Text('Sponsored period'.tr, style: ItemDescStyle(context)),
                                SizedBox(width: 10),
                                Text(DATETIME_STR(widget.itemData.startTime), style: ItemDescExStyle(context)),
                                Text(' ~ ', style: ItemDescExStyle(context)),
                                Text(DATETIME_STR(widget.itemData.endTime), style: ItemDescExStyle(context)),
                              ]
                            )
                          )
                        ],
                      )
                    )
                  ),
                  if (widget.isMyItem)
                  DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      customButton: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.centerRight,
                        color: Colors.transparent,
                        child: Icon(Icons.more_vert, color: Theme.of(context).hintColor.withOpacity(0.5)),
                      ),
                      // customItemsHeights: const [5],
                      items: [
                        if (widget.itemData.showStatus == 1)
                          ...DropdownItems.storyItems0.map(
                                (item) => DropdownMenuItem<DropdownItem>(
                              value: item,
                              child: DropdownItems.buildItem(context, item),
                            ),
                          ),
                        if (widget.itemData.showStatus == 0)
                          ...DropdownItems.storyItems1.map(
                                (item) => DropdownMenuItem<DropdownItem>(
                              value: item,
                              child: DropdownItems.buildItem(context, item),
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        var selected = value as DropdownItem;
                        LOG("--> selected.index : ${selected.type}");
                        switch (selected.type) {
                          case DropdownItemType.enable:
                          case DropdownItemType.disable:
                          toggleShowStatus(context);
                            break;
                          case DropdownItemType.edit:
                            moveToEdit();
                            break;
                          case DropdownItemType.delete:
                            deleteItem(context);
                            break;
                        }
                      },
                      itemHeight: 45,
                      dropdownWidth: 190,
                      buttonHeight: 22,
                      buttonWidth: 22,
                      itemPadding: const EdgeInsets.all(10),
                      offset: const Offset(0, 5),
                    ),
                  ),
                ],
              ),
            )
          ),
        )
      )
    );
  }
}

