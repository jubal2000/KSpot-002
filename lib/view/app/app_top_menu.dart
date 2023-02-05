import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/main_my/profile_screen.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../services/api_service.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/user_item_widget.dart';
import '../main_event/event_edit_screen.dart';

class AppTopMenuBar extends StatelessWidget {
  AppTopMenuBar(this.menuMode, {Key? key, this.height = 65.0, this.iconColor = Colors.black, this.onCountryChanged}) : super(key: key);
  int menuMode;
  double height;
  Function? onCountryChanged;
  var   iconColor = Colors.black;
  var   iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    LOG('--> AppData.currentState: ${AppData.currentState}');
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE, 30, UI_HORIZONTAL_SPACE, 0),
      child: Visibility(
                visible: AppData.appViewModel.appbarMenuMode != MainMenuID.hide,
                child: Stack(
                  children: [
                    if (AppData.appViewModel.appbarMenuMode == MainMenuID.back)
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_ios_new,
                                  size: height * 0.5,
                                  color: Theme.of(context).hintColor
                              ),
                            ],
                          )
                        )
                      ),
                      if (AppData.appViewModel.appbarMenuMode != MainMenuID.back)
                        Row(
                          children: [
                            if (AppData.appViewModel.appbarMenuMode == MainMenuID.event || AppData.appViewModel.appbarMenuMode == MainMenuID.story)...[
                              GestureDetector(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: AppData.currentState.isNotEmpty ? 10 : 0),
                                  constraints: BoxConstraints(
                                    maxHeight: height * 0.8,
                                    minWidth: height * 0.8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(height * 0.5)),
                                    color: Theme.of(context).canvasColor.withOpacity(0.55),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(STR_FLAG_ONLY(AppData.currentCountryFlag), style: TextStyle(fontSize: 26)),
                                      if (AppData.currentState.isNotEmpty)...[
                                        SizedBox(width: 5),
                                        Text(AppData.currentState, style: ItemTitleBoldStyle(context), maxLines: 2),
                                      ],
                                    ]
                                  )
                                ),
                                onTap: () {
                                  LOG('--> showCountrySelect');
                                  AppData.appViewModel.showCountrySelect(context, onCountryChanged);
                                },
                              ),
                            ],
                            if (AppData.appViewModel.appbarMenuMode == MainMenuID.my)
                              Container(
                                // color: Colors.red,
                                height: iconSize,
                                width: iconSize,
                                child: IconButton(
                                  icon: Icon(Icons.settings, color: iconColor),
                                  onPressed: () {
                                  },
                                )
                              ),
                            Expanded(
                              child: Container(
                                color: Colors.transparent,
                              )
                            ),
                            Container(
                              child: Row(
                                 mainAxisAlignment: MainAxisAlignment.end,
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: [
                                   AppData.appViewModel.showAddMenu(iconColor, iconSize),
                                   SizedBox(width: 8),
                                   Badge(
                                     position: BadgePosition(top:1, end:5),
                                     badgeContent: Text('3', style: TextStyle(fontSize:10, fontWeight: FontWeight.bold, color: Colors.white)),
                                     showBadge: true,
                                     child: IconButton(
                                       icon: Icon(Icons.message_outlined, color: iconColor),
                                       onPressed: () {
                                       },
                                     )
                                   ),
                                   SizedBox(width: 8),
                                   UserCardWidget(AppData.userInfo.toJson(),
                                    isShowName: false,
                                    faceSize: UI_MENU_CIRCLE_SIZE,
                                    circleColor: Theme.of(context).canvasColor,
                                    backgroundColor: Theme.of(context).canvasColor,
                                    onSelected: (_) {
                                      Get.to(() => ProfileScreen());
                                    }),
                                ]
                              )
                            ),
                            // Container(
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       AppData.appViewModel.showAddMenu(iconColor, iconSize),
                            //       SizedBox(width: 8),
                            //       SizedBox(
                            //         width: 35,
                            //         child: IconButton(
                            //           icon: Icon(Icons.message_outlined, color: iconColor),
                            //           onPressed: () {
                            //           },
                            //         )
                            //       ),
                            //       Badge(
                            //         position: BadgePosition(top:0, end:0),
                            //         badgeContent: Text('3', style: TextStyle(fontSize:10, fontWeight: FontWeight.bold, color: Colors.white)),
                            //         showBadge: true,
                            //         child: IconButton(
                            //           icon: Icon(Icons.event_available, color: iconColor),
                            //           onPressed: () {
                            //           },
                            //         )
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        )
                    ]
                  )
            )
      );
  }
}
