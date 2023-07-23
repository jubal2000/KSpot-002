import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/message/message_screen.dart';
import 'package:kspot_002/view/profile/profile_screen.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../services/api_service.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/event_view_model.dart';
import '../../widget/title_text_widget.dart';
import '../../widget/user_item_widget.dart';
import '../event/event_edit_screen.dart';

class HomeTopMenuBar extends StatefulWidget {
  HomeTopMenuBar(this.menuMode,
    {Key? key,
      this.isShowDatePick = true,
      this.isHideMenu = false,
      this.isDateOpen = true,
      this.height = UI_TOP_MENU_HEIGHT,
      this.onCountryChanged,
      this.onDateChange}) : super(key: key);
  int menuMode;
  double height;
  bool isShowDatePick;
  bool isDateOpen;
  bool isHideMenu;
  Function()? onCountryChanged;
  Function(bool)? onDateChange;

  @override
  HomeTopMenuBarState createState() => HomeTopMenuBarState();
}

class HomeTopMenuBarState extends State<HomeTopMenuBar> {
  var iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    LOG('--> AppTopMenuBar : ${widget.menuMode} / ${AppData.appViewModel.appbarMenuMode}');

    AppData.appViewModel.setStatusBarColor();
    final isLongState = AppData.currentState.length > 12;

    return Container(
      child: Visibility(
        visible: AppData.appViewModel.appbarMenuMode != MainMenuID.hide,
        child: Stack(
          children: [
            if (!widget.isHideMenu && AppData.appViewModel.appbarMenuMode == MainMenuID.back)
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios_new,
                          size: widget.height * 0.5,
                          color: Theme.of(context).hintColor
                      ),
                    ],
                  )
                )
              ),
              if (!widget.isHideMenu && AppData.appViewModel.appbarMenuMode != MainMenuID.back)
                Container(
                  height: widget.height,
                  margin: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE, 30, UI_HORIZONTAL_SPACE, 0),
                  child: Row(
                    children: [
                      if (AppData.appViewModel.appbarMenuMode != MainMenuID.my)...[
                        GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: AppData.currentState.isNotEmpty ? 10.w : 0),
                            constraints: BoxConstraints(
                              maxHeight: widget.height * 0.8,
                              minWidth: widget.height * 0.8,
                              maxWidth: isLongState ? Get.width * 0.35 : double.infinity,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(widget.height * 0.5)),
                              color: Colors.black26,
                            ),
                            child: Row(
                              children: [
                                Text(STR_FLAG_ONLY(AppData.currentCountryFlag), style: TextStyle(fontSize: 26)),
                                if (AppData.currentState.isNotEmpty)...[
                                  SizedBox(width: 5),
                                  if (isLongState)
                                    Expanded(child:
                                      Text(AppData.currentState, style: ItemDescStyle(context), maxLines: 3)),
                                  if (!isLongState)
                                  Text(AppData.currentState, style: ItemTitleBoldStyle(context), maxLines: 3),                                                              ],
                              ]
                            )
                          ),
                          onTap: () {
                            LOG('--> showCountrySelect');
                            AppData.appViewModel.showCountrySelect(context, widget.onCountryChanged);
                          },
                        ),
                        if (widget.isShowDatePick && widget.isDateOpen)
                          GestureDetector(
                            child: Container(
                              alignment: Alignment.center,
                              height: widget.height * 0.8,
                              margin: EdgeInsets.only(left: 5),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(widget.height * 0.5)),
                                color: AppData.currentDate.isToday() ? Theme.of(context).primaryColor : Colors.black26,
                              ),
                              child: Text('TODAY', style: ItemDescStyle(context)),
                            ),
                            onTap: () {
                              setState(() {
                                AppData.currentDate = DateTime.now();
                                if (widget.onDateChange != null) widget.onDateChange!(widget.isDateOpen);
                              });
                            },
                          ),
                        if (widget.isShowDatePick)
                          GestureDetector(
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 5),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              constraints: BoxConstraints(
                                maxHeight: widget.height * 0.8,
                                minWidth: widget.height * 0.8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(widget.height * 0.5)),
                                color: Colors.black26,
                              ),
                              child: widget.isDateOpen ? Icon(Icons.close, size: 24) : showDatePickerText(context, AppData.currentDate),
                            ),
                            onTap: () {
                              setState(() {
                                widget.isDateOpen = !widget.isDateOpen;
                                if (widget.onDateChange != null) widget.onDateChange!(widget.isDateOpen);
                              });
                            },
                          ),
                        Expanded(
                          child: Container(
                            color: Colors.transparent,
                          )
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: AppData.currentState.isNotEmpty ? 10 : 0),
                          constraints: BoxConstraints(
                            maxHeight: widget.height * 0.8,
                            minWidth: widget.height * 0.8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(widget.height * 0.5)),
                            color: Colors.black26,
                          ),
                          child: AppData.appViewModel.showAddMenu(iconSize),
                        ),
                        SizedBox(width: 5),
                        if (AppData.appViewModel.appbarMenuMode == MainMenuID.event)
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: AppData.currentState.isNotEmpty ? 10 : 0),
                            constraints: BoxConstraints(
                              maxHeight: widget.height * 0.8,
                              minWidth: widget.height * 0.8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(widget.height * 0.5)),
                              color: Colors.black26,
                            ),
                            child: AppData.eventViewModel.showEventListType(),
                          ),
                        // if (AppData.appViewModel.appbarMenuMode == MainMenuID.story)
                        //   Container(
                        //     alignment: Alignment.center,
                        //     padding: EdgeInsets.symmetric(horizontal: AppData.currentState.isNotEmpty ? 10 : 0),
                        //     constraints: BoxConstraints(
                        //       maxHeight: widget.height * 0.8,
                        //       minWidth: widget.height * 0.8,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.all(Radius.circular(widget.height * 0.5)),
                        //       color: Theme.of(context).canvasColor.withOpacity(0.55),
                        //     ),
                        //     child: AppData.storyViewModel.showStoryListType(),
                        //   ),
                      ],
                      // if (AppData.appViewModel.appbarMenuMode == MainMenuID.my)...[
                      //   Container(
                      //     // color: Colors.red,
                      //     height: iconSize,
                      //     width: iconSize,
                      //     child: IconButton(
                      //       icon: Icon(Icons.mail_outline_outlined, color: iconColor),
                      //       onPressed: () {
                      //         Get.to(() => MessageScreen());
                      //       },
                      //     )
                      //   ),
                      //   SizedBox(width: 5),
                      //   if (APP_STORE_OPEN)...[
                      //     Container(
                      //       height: iconSize,
                      //       width: iconSize,
                      //       child: IconButton(
                      //         icon: Icon(Icons.store_outlined, color: iconColor),
                      //         onPressed: () {
                      //         },
                      //       )
                      //     ),
                      //     SizedBox(width: 5),
                      //   ],
                      //   Container(
                      //     // color: Colors.red,
                      //     height: iconSize,
                      //     width: iconSize,
                      //     child: IconButton(
                      //       icon: Icon(Icons.settings, color: iconColor),
                      //       onPressed: () {
                      //       },
                      //     )
                      //   ),
                      // ],
                    ],
                  ),
                ),
              DropdownAlert(
                successImage: 'assets/ui/app_icon_01.png',
                successBackground: Theme.of(context).dialogBackgroundColor,
              ),
            ]
          )
        )
      );
  }
}
