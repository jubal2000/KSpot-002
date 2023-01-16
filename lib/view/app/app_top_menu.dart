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
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../services/api_service.dart';
import '../../view_model/app_view_model.dart';

class AppTopMenuBar extends StatelessWidget {
  AppTopMenuBar(this.menuMode, {Key? key}) : super(key: key);
  int menuMode;
  final _height = 50.0.h;
  final _iconSize = 24.0.h;
  final _viewModel = AppViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppViewModel>(
        create: (BuildContext context) => _viewModel,
        child: Consumer<AppViewModel>(builder: (context, viewModel, _) {
          viewModel.appbarMenuMode = menuMode;
          return Visibility(
                visible: viewModel.appbarMenuMode != MainMenuID.hide,
                child: Stack(
                  children: [
                    if (viewModel.appbarMenuMode == MainMenuID.back)
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_ios_new,
                                  size: _height * 0.5,
                                  color: Theme.of(context).hintColor
                              ),
                            ],
                          )
                        )
                      ),
                      if (viewModel.appbarMenuMode != MainMenuID.back)
                        Row(
                          children: [
                            if (viewModel.appbarMenuMode == MainMenuID.event || viewModel.appbarMenuMode == MainMenuID.story)...[
                              GestureDetector(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  constraints: BoxConstraints(
                                    minWidth: 200.w,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(STR_FLAG_ONLY(AppData.currentCountryFlag), style: TextStyle(fontSize: 26)),
                                      SizedBox(width: 5),
                                      Text(AppData.currentState, style: SubTitleStyle(context), maxLines: 2),
                                    ]
                                  )
                                ),
                                onTap: () {
                                  LOG('--> showCountrySelect');
                                  viewModel.showCountrySelect(context);
                                },
                              ),
                            ],
                            if (viewModel.appbarMenuMode == MainMenuID.my)
                              Container(
                                // color: Colors.red,
                                height: _iconSize,
                                width: _iconSize,
                                child: IconButton(
                                  icon: Icon(Icons.settings, color: Theme.of(context).hintColor),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // if (widget.currentMenu == MainMenuID.home || widget.currentMenu == MainMenuID.my)...[
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      customButton: Center(
                                        child: Icon(Icons.add, color: Theme.of(context).iconTheme.color!.withOpacity(0.65)),
                                      ),
                                      items: [
                                        if (viewModel.appbarMenuMode == MainMenuID.story)
                                          ...DropdownItems.homeAddItem0.map(
                                                (item) =>
                                                DropdownMenuItem<DropdownItem>(
                                                  value: item,
                                                  child: DropdownItems.buildItem(context, item),
                                                ),
                                          ),
                                        if (viewModel.appbarMenuMode == MainMenuID.event)
                                          ...DropdownItems.homeAddItem2.map(
                                                (item) =>
                                                DropdownMenuItem<DropdownItem>(
                                                  value: item,
                                                  child: DropdownItems.buildItem(context, item),
                                                ),
                                          ),
                                        if (viewModel.appbarMenuMode == MainMenuID.my)
                                          ...DropdownItems.homeAddItems.map(
                                                (item) =>
                                                DropdownMenuItem<DropdownItem>(
                                                  value: item,
                                                  child: DropdownItems.buildItem(context, item),
                                                ),
                                          ),
                                      ],
                                      onChanged: (value) {
                                        // if (!isCreatorMode()) {
                                        //   showAlertYesNoDialog(context, 'CREATOR MODE', 'You need creator mode ON', 'Move to setting screen?', 'No', 'Yes').then((result) {
                                        //     if (result == 1) {
                                        //       Navigator.of(AppData.topMenuContext!).popUntil((r) => r.isFirst);
                                        //       Navigator.of(AppData.topMenuContext!).push(SecondPageRoute(SetupScreen(moveTo: 'creator')));
                                        //     }
                                        //   });
                                        //   return;
                                        // }
                                        var selected = value as DropdownItem;
                                        LOG("--> selected.index : ${selected.type}");
                                        switch (selected.type) {
                                          case DropdownItemType.event:
                                            break;
                                          case DropdownItemType.story:
                                            break;
                                        }
                                      },
                                      itemHeight: 45,
                                      dropdownWidth: 190,
                                      buttonHeight: _iconSize,
                                      buttonWidth: _iconSize,
                                      itemPadding: const EdgeInsets.all(10),
                                      offset: const Offset(0, 5),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  // ],
                                  SizedBox(
                                    width: 35,
                                    child: IconButton(
                                      icon: Icon(Icons.message_outlined, color: Theme.of(context).iconTheme.color!.withOpacity(0.65)),
                                      onPressed: () {
                                      },
                                    )
                                  ),
                                  Badge(
                                    position: BadgePosition(top:-2.5, end:-2.5),
                                    badgeContent: Text('3', style: TextStyle(fontSize:10, fontWeight: FontWeight.bold, color: Colors.white)),
                                    showBadge: true,
                                    child: IconButton(
                                      icon: Icon(Icons.event_available, color: Theme.of(context).iconTheme.color!.withOpacity(0.65)),
                                      onPressed: () {
                                      },
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                    ]
                  )
            );
          }
      )
    );
  }
}
