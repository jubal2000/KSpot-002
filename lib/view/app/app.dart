import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/main_event/main_event.dart';
import 'package:kspot_002/view/main_story/main_story.dart';
import 'package:provider/provider.dart';

import '../../data/theme_manager.dart';
import '../../view_model/app_view_model.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final _viewModel = AppViewModel();
  final _height = 40.0;

  List<Widget> pages = [
    MainEvent(),
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
      child: ChangeNotifierProvider<AppViewModel>(
        create: (BuildContext context) => _viewModel,
        child: Consumer<AppViewModel>(builder: (context, viewModel, _) {
          return Consumer<ThemeNotifier>(
            builder: (context, theme, _) => Scaffold(
              body: IndexedStack(
                key: ValueKey(_viewModel.mainMenuIndex),
                index: _viewModel.mainMenuIndex,
                children: pages,
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                            fontSize: 16.0
                        );
                      },
                      child: SizedBox(
                        height: _height,
                        width: _height,
                        child: Icon(Icons.visibility_outlined),
                      )
                  ),
                  SizedBox(width: 10),
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
                            fontSize: 16.0
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
                height: UI_BOTTOM_HEIGHT,
                child: BottomNavigationBar(
                  onTap: (index) {
                    _viewModel.setMainIndex(index);
                  },
                  currentIndex: _viewModel.mainMenuIndex,
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
          );
        }),
      )
    );
  }
}
