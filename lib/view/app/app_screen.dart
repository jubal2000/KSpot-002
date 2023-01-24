import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/main_event/event_list_screen.dart';
import 'package:kspot_002/view/main_story/main_story.dart';
import 'package:provider/provider.dart';

import '../../data/theme_manager.dart';
import '../../view_model/app_view_model.dart';

class AppScreen extends StatelessWidget {
  AppScreen({Key? key}) : super(key: key);
  final _viewModel = AppViewModel();
  final _height = 40.0.w;

  List<Widget> pages = [
    EventListScreen(),
    MainStory()
  ];

  @override
  Widget build(BuildContext context) {
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
        child: ChangeNotifierProvider<AppViewModel>.value(
        value: _viewModel,
        child: Consumer<AppViewModel>(
          builder: (context, viewModel, _) {
            return Consumer<ThemeNotifier>(
              builder: (context, theme, _) => Scaffold(
                body: IndexedStack(
                  key: ValueKey(_viewModel.mainMenuIndex),
                  index: _viewModel.mainMenuIndex,
                  children: pages,
                ),
                floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                bottomNavigationBar: Container(
                  height: UI_MENU_BG_HEIGHT,
                  child: Stack(
                    children: [
                      BottomCenterAlign(
                        child: SizedBox(
                          height: UI_MENU_HEIGHT,
                          child: BottomNavigationBar(
                            onTap: (index) {
                              _viewModel.setMainIndex(index);
                            },
                            currentIndex: _viewModel.mainMenuIndex,
                            selectedLabelStyle: TextStyle(fontSize: UI_FONT_SIZE_SS, fontWeight: FontWeight.w600),
                            unselectedLabelStyle: TextStyle(fontSize: UI_FONT_SIZE_SS, fontWeight: FontWeight.w400),
                            items: [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.event_available_outlined),
                                label: 'EVENT'.tr,
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.photo_library_outlined),
                                label: 'STORY'.tr,
                              ),
                            ]
                          ),
                        )
                      )
                    ]
                  )
                )
              )
            );
          }),
        )
      )
    );
  }
}
