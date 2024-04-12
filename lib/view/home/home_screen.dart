import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/event/event_screen.dart';
import 'package:kspot_002/view/profile/profile_screen.dart';
import 'package:kspot_002/view/story/story_screen.dart';
import 'package:kspot_002/widget/title_text_widget.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../utils/push_utils.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/event_group_dialog.dart';
import '../../widget/helpers/helpers/widgets/align.dart';
import '../chatting/chatting_screen.dart';
import '../message/message_screen.dart';
import 'home_top_menu.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final _height = 40.0;
  final _iconSize = 24.0;
  final _fontSize = UI_FONT_SIZE_SS;
  final _radiusSize = 20.0;

  final List<Widget> _mainPages = [
    EventScreen(),
    StoryScreen(),
    ChattingScreen(),
    MyProfileScreen(),
  ];

  NavigatorButton(context, viewModel, index, icon, label) {
    final isOn = viewModel.menuIndex == index;
    return GestureDetector(
      onTap: () {
        viewModel.setMainIndex(index);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: _iconSize, color: isOn ? Theme.of(context).primaryColor : Theme.of(context).hintColor),
            Text(label, style: TextStyle(fontSize: _fontSize,
                color: isOn ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LOG('--> HomeScreen');
    return WillPopScope(
      onWillPop: () async => await showAlertYesNoDialog(context,
          'APP EXIT'.tr,
          'Are you sure you want to quit the app?'.tr,
          '',
          'Cancel'.tr,
          'OK'.tr
      ).then((result) {
        return result == 1;
      }),
      child: SafeArea(
        top: false,
        child: ChangeNotifierProvider<AppViewModel>.value(
        value: AppData.appViewModel,
        child: Consumer<AppViewModel>(
          builder: (context, viewModel, _) {
            return Consumer<ThemeNotifier>(
              builder: (context, theme, _) => Scaffold(
                body: Stack(
                  children: [
                    // Expanded(
                    //   child: Container(
                    //     padding: EdgeInsets.only(bottom: UI_MENU_BG_HEIGHT),
                    //     child: pages[viewModel.menuIndex],
                    //   )
                    // ),
                    IndexedStack(
                      index: viewModel.menuIndex,
                      children: _mainPages,
                    ),
                    // pages[viewModel.menuIndex],
                    viewModel.showMainTopMenu(),
                    BottomCenterAlign(
                      child: Container(
                        height: UI_MENU_BG_HEIGHT,
                        child: Container(
                          height: UI_MENU_HEIGHT,
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  height: UI_MENU_HEIGHT,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft:  Radius.circular(_radiusSize),
                                    ),
                                    color: Theme.of(context).bottomAppBarColor,
                                  ),
                                  padding: EdgeInsets.only(left: UI_HORIZONTAL_SPACE, right: UI_HORIZONTAL_SPACE_ES),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      NavigatorButton(context, viewModel, 0, Icons.event_available_outlined, 'EVENT'.tr),
                                      NavigatorButton(context, viewModel, 1, Icons.photo_library_outlined, 'STORY'.tr),
                                    ],
                                  )
                                )
                              ),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  BottomCenterAlign(
                                    child: Container(
                                      width: UI_MENU_BG_HEIGHT - 8,
                                      height: UI_MENU_HEIGHT,
                                      color: Theme.of(context).bottomAppBarColor,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      viewModel.showGroupSelect();
                                    },
                                    child: Container(
                                      width:  UI_MENU_BG_HEIGHT - 10,
                                      height: UI_MENU_BG_HEIGHT - 10,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(80)),
                                        border: Border.all(color: Theme.of(context).bottomAppBarColor, width: 5.0,),
                                        color: Theme.of(context).bottomAppBarColor
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipOval(
                                            child: Container(
                                              width:  UI_MENU_BG_HEIGHT - 10,
                                              height: UI_MENU_BG_HEIGHT - 10,
                                              child: showImageWidget(AppData.currentEventGroup!.pic, BoxFit.fill),
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                              Expanded(
                                child: Container(
                                  height: UI_MENU_HEIGHT,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(_radiusSize)),
                                    color: Theme.of(context).bottomAppBarColor,
                                  ),
                                  padding: EdgeInsets.only(left: UI_HORIZONTAL_SPACE_ES, right: UI_HORIZONTAL_SPACE),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      NavigatorButton(context, viewModel, 2, Icons.message_outlined, 'CHATTING'.tr),
                                      NavigatorButton(context, viewModel, 3, Icons.account_circle_outlined, 'MY'.tr),
                                    ],
                                  )
                                )
                              )
                            ]
                          )
                        )
                      )
                    ),
                    BottomRightAlign(
                      widthFactor: 7.2,
                      heightFactor: 14,
                      child: FloatingActionButton(
                        onPressed: () {
                          // sendFcmTestData();
                          // sendMultiFcmTestData();
                          theme.setFlexSchemeRotate();
                        },
                        child: Icon(Icons.color_lens_outlined),
                      ),
                    )
                  ]
                ),
              )
            );
          }),
        )
      )
    );
  }
}
