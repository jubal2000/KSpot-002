
import 'package:flutter/material.dart';
import 'package:kspot_002/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/message_view_model.dart';
import '../home/home_top_menu.dart';

class ChattingScreen extends StatelessWidget {
  ChattingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppData.chatViewModel.init();
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(bottom: UI_BOTTOM_HEIGHT),
        // color: Theme.of(context).dialogBackgroundColor,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: UI_APPBAR_TOOL_HEIGHT - 5),
            child: DefaultTabController(
              length: AppData.chatViewModel.tabList.length,
              child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: 0,
                  backgroundColor: Colors.transparent,
                  bottom: TabBar(
                    onTap: (index) {
                      AppData.chatViewModel.setMessageTab(index);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    labelColor: Theme
                        .of(context)
                        .primaryColor,
                    labelStyle: ItemTitleStyle(context),
                    unselectedLabelColor: Theme
                        .of(context)
                        .hintColor,
                    unselectedLabelStyle: ItemTitleStyle(context),
                    indicatorColor: Theme
                        .of(context)
                        .primaryColor,
                    tabs: [
                      Tab(text: AppData.chatViewModel.tabList[0], height: 50),
                      Tab(text: AppData.chatViewModel.tabList[1], height: 50),
                    ],
                  ),
                ),
                body: Container(
                  child: ChangeNotifierProvider<AppViewModel>.value(
                    value: AppData.appViewModel,
                    child: Consumer<AppViewModel>(
                      builder: (context, appViewModel, _) {
                        LOG('--> AppViewModel');
                        return ChangeNotifierProvider<ChatViewModel>.value(
                          value: AppData.chatViewModel,
                          child: Consumer<ChatViewModel>(builder: (context, viewModel, _) {
                            LOG('--> ChatViewModel refresh');
                            return FutureBuilder(
                              future: AppData.chatViewModel.getChatRoomData(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return LayoutBuilder(
                                    builder: (context, layout) {
                                      return StreamBuilder(
                                        stream: viewModel.stream!,
                                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                                          return viewModel.showMainList(layout, snapshot);
                                        }
                                      );
                                    }
                                  );
                                } else {
                                  return Center(
                                    child: showLoadingFullPage(context),
                                  );
                                }
                              }
                            );
                          }
                        ));
                      }
                    )
                  ),
                )
                // floatingActionButton: FloatingActionButton.small(
                //   onPressed: () {
                //     showChattingMenu(context).then((result) {
                //       if (result == 'message') {
                //
                //       } else if (result != null) {
                //         final chatType = result == 'public' ? ChatType.public : ChatType.private;
                //         AppData.chatViewModel.onChattingNew(chatType);
                //       }
                //     });
                //   },
                //   child: Icon(Icons.add, size: 24),
                // ),
                // floatingActionButton: FloatingActionButton(
                //   backgroundColor: Theme.of(context).primaryColor,
                //   onPressed: () {
                //   },
                //   child: Icon(Icons.add_comment_outlined, size: 30, color: Colors.white),
                // ),
              )
            ),
          ),
          // TopCenterAlign(
          //   child: SizedBox(
          //     height: UI_APPBAR_HEIGHT,
          //       child: HomeTopMenuBar(
          //         MainMenuID.chat,
          //         isShowDatePick: false,
          //         onCountryChanged: () {
          //
          //         },
          //         onDateChange: (state) {
          //         }
          //       )
          //     )
          //   ),
          ]
        )
      )
    );
  }
}
