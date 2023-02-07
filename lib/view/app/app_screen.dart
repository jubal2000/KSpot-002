import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/main_event/event_screen.dart';
import 'package:kspot_002/view/main_my/profile_screen.dart';
import 'package:kspot_002/view/main_story/story_screen.dart';
import 'package:kspot_002/widget/title_text_widget.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/event_group_dialog.dart';
import '../message/message_screen.dart';
import 'app_top_menu.dart';

class AppScreen extends StatelessWidget {
  AppScreen({Key? key}) : super(key: key);
  final _height = 40.0;
  final _iconSize = 24.0;
  final _fontSize = UI_FONT_SIZE_SS;

  List<Widget> pages = [
    EventScreen(),
    StoryScreen(),
    MessageScreen(),
    ProfileScreen(),
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
    AppData.appViewModel.init(context);
    return WillPopScope(
      onWillPop: () async => await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('App exit'.tr),
            content: Text('Are you sure you want to quit the app?'.tr),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('Cancel'.tr),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Ok'.tr),
              )
            ]
          );
        }
      ),
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
                    pages[viewModel.menuIndex],
                    // IndexedStack(
                    //   key: ValueKey(viewModel.menuIndex),
                    //   index: viewModel.menuIndex,
                    //   children: pages,
                    // ),
                    // TopCenterAlign(
                    //   child: SizedBox(
                    //     height: UI_TOP_MENU_HEIGHT * 1.7,
                    //     child: AppTopMenuBar(MainMenuID.event, height: UI_TOP_MENU_HEIGHT),
                    //   )
                    // ),
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
                                  color: Theme.of(context).bottomAppBarColor,
                                  padding: EdgeInsets.only(left: UI_HORIZONTAL_SPACE_S),
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
                                      width: UI_MENU_BG_HEIGHT,
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
                                          // BottomCenterAlign(
                                          //   child: Text(AppData.currentEventGroup!.title,
                                          //       style: GroupTitleOutlineStyle(context, Theme.of(context).bottomAppBarColor),
                                          //       maxLines: 4,
                                          //       textAlign: TextAlign.center),
                                          // )
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                              Expanded(
                                child: Container(
                                  height: UI_MENU_HEIGHT,
                                  color: Theme.of(context).bottomAppBarColor,
                                  padding: EdgeInsets.only(right: UI_HORIZONTAL_SPACE_S),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      NavigatorButton(context, viewModel, 2, Icons.message_outlined, 'MESSAGE'.tr),
                                      NavigatorButton(context, viewModel, 3, Icons.account_circle_outlined, 'MY'.tr),
                                    ],
                                  )
                                )
                              )
                              //     child: BottomNavigationBar(
                              //       onTap: (index) {
                              //         viewModel.setMainIndex(index);
                              //       },
                              //       type: BottomNavigationBarType.fixed,
                              //       currentIndex: viewModel.menuIndex,
                              //       selectedLabelStyle: TextStyle(fontSize: UI_FONT_SIZE_SS, fontWeight: FontWeight.w600),
                              //       unselectedLabelStyle: TextStyle(fontSize: UI_FONT_SIZE_SS, fontWeight: FontWeight.w400),
                              //       items: [
                              //         BottomNavigationBarItem(
                              //           icon: Icon(Icons.event_available_outlined),
                              //           label: 'EVENT'.tr,
                              //         ),
                              //         BottomNavigationBarItem(
                              //           icon: Icon(Icons.photo_library_outlined),
                              //           label: 'STORY'.tr,
                              //         ),
                              //         BottomNavigationBarItem(
                              //           icon: Icon(Icons.message_outlined),
                              //           label: 'MESSAGE'.tr,
                              //         ),
                              //         BottomNavigationBarItem(
                              //           icon: Icon(Icons.account_circle_outlined),
                              //           label: 'MY'.tr,
                              //         ),
                              //       ]
                              //   ),
                              // ),
                            ]
                          )
                        )
                      )
                    ),
                    BottomRightAlign(
                      heightFactor: 17.5,
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 30.w),
                        GestureDetector(
                            onTap: () {
                              var mode = theme.toggleSchemeMode();
                              Fluttertoast.showToast(
                                  msg: mode,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: theme.getMode() ? Colors.white : Colors.black,
                                  textColor: theme.getMode() ? Colors.black : Colors.white,
                                  fontSize: 16.0.sp
                              );
                            },
                            child: SizedBox(
                              height: _height,
                              width: _height,
                              child: Icon(Icons.visibility_outlined),
                            )
                        ),
                        SizedBox(width: 5.w),
                        GestureDetector(
                            onTap: () {
                              var mode = theme.setFlexSchemeRotate();
                              Fluttertoast.showToast(
                                  msg: mode,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: theme.getMode() ? Colors.white : Colors.black,
                                  textColor: theme.getMode() ? Colors.black : Colors.white,
                                  fontSize: 16.0.sp
                              );
                            },
                            child: SizedBox(
                              height: _height,
                              width: _height,
                              child: Icon(Icons.color_lens_outlined),
                            )
                        ),
                      ],
                    ),
                    )
                  ]
                ),
                // floatingActionButton: Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     SizedBox(width: 30.w),
                //     GestureDetector(
                //       onTap: () {
                //         var mode = theme.toggleSchemeMode();
                //         Fluttertoast.showToast(
                //             msg: mode,
                //             toastLength: Toast.LENGTH_SHORT,
                //             gravity: ToastGravity.CENTER,
                //             timeInSecForIosWeb: 1,
                //             backgroundColor: theme.getMode() ? Colors.white : Colors.black,
                //             textColor: theme.getMode() ? Colors.black : Colors.white,
                //             fontSize: 16.0.sp
                //         );
                //       },
                //       child: SizedBox(
                //         height: _height,
                //         width: _height,
                //         child: Icon(Icons.visibility_outlined),
                //       )
                //   ),
                //   SizedBox(width: 5.w),
                //   GestureDetector(
                //       onTap: () {
                //         var mode = theme.setFlexSchemeRotate();
                //         Fluttertoast.showToast(
                //             msg: mode,
                //             toastLength: Toast.LENGTH_SHORT,
                //             gravity: ToastGravity.CENTER,
                //             timeInSecForIosWeb: 1,
                //             backgroundColor: theme.getMode() ? Colors.white : Colors.black,
                //             textColor: theme.getMode() ? Colors.black : Colors.white,
                //             fontSize: 16.0.sp
                //         );
                //       },
                //       child: SizedBox(
                //         height: _height,
                //         width: _height,
                //         child: Icon(Icons.color_lens_outlined),
                //       )
                //     ),
                //   ],
                // ),
                // bottomNavigationBar: Container(
                //   height: UI_MENU_HEIGHT,
                //   color: Colors.transparent,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       SizedBox(
                //         width: 80,
                //         child: Icon(Icons.photo_library_outlined),
                //       ),
                //       SizedBox(
                //         width: 300,
                //         child: BottomNavigationBar(
                //             onTap: (index) {
                //               viewModel.setMainIndex(index);
                //             },
                //             type: BottomNavigationBarType.fixed,
                //             currentIndex: viewModel.menuIndex,
                //             selectedLabelStyle: TextStyle(fontSize: UI_FONT_SIZE_SS, fontWeight: FontWeight.w600),
                //             unselectedLabelStyle: TextStyle(fontSize: UI_FONT_SIZE_SS, fontWeight: FontWeight.w400),
                //             backgroundColor: Colors.transparent,
                //             items: [
                //               BottomNavigationBarItem(
                //                 icon: Icon(Icons.event_available_outlined),
                //                 label: 'EVENT'.tr,
                //               ),
                //               BottomNavigationBarItem(
                //                 icon: Icon(Icons.photo_library_outlined),
                //                 label: 'STORY'.tr,
                //               ),
                //               BottomNavigationBarItem(
                //                 icon: Icon(Icons.message_outlined),
                //                 label: 'MESSAGE'.tr,
                //               ),
                //               BottomNavigationBarItem(
                //                 icon: Icon(Icons.account_circle_outlined),
                //                 label: 'MY'.tr,
                //               ),
                //             ]
                //           ),
                //       ),
                //     ]
                //   )
                // )
              )
            );
          }),
        )
      )
    );
  }
}
