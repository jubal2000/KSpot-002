
import 'package:flutter/material.dart';
import 'package:helpers/helpers/widgets/align.dart';
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
    AppData.chatViewModel.init(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(bottom: UI_BOTTOM_HEIGHT),
        child: DefaultTabController(
          length: AppData.chatViewModel.tabList.length,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              bottom: TabBar(
                onTap: (index) {
                  AppData.chatViewModel.setMessageTab(index);
                },
                padding: EdgeInsets.symmetric(horizontal: 20),
                labelColor: Theme.of(context).primaryColor,
                labelStyle: ItemTitleStyle(context),
                unselectedLabelColor: Theme.of(context).hintColor,
                unselectedLabelStyle: ItemTitleStyle(context),
                indicatorColor: Theme.of(context).primaryColor,
                tabs: List<Widget>.from(AppData.chatViewModel.tabList.map((item) => item.getTab()).toList()),
              ),
            ),
            body: ChangeNotifierProvider<AppViewModel>.value(
              value: AppData.appViewModel,
              child: Consumer<AppViewModel>(
                builder: (context, appViewModel, _) {
                  LOG('--> AppViewModel');
                  return LayoutBuilder(
                    builder: (context, layout) {
                      return ChangeNotifierProvider<ChatViewModel>.value(
                          value: AppData.chatViewModel,
                          child: Consumer<ChatViewModel>(builder: (context, viewModel, _) {
                            LOG('--> ChatViewModel refresh');
                            viewModel.getChatRoomData();
                            return StreamBuilder(
                              stream: viewModel.stream!,
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                return viewModel.showMainList(layout, snapshot);
                              }
                            );
                          }
                        )
                      );
                    }
                  );
                }
              )
            ),
            floatingActionButton: FloatingActionButton.small(
              onPressed: () {
                showChattingMenu(context).then((result) {
                  if (result == 'message') {

                  } else {
                    final chatType = result == 'public' ? ChatType.public : ChatType.private;
                    AppData.chatViewModel.onChattingNew(chatType);
                  }
                });
              },
              child: Icon(Icons.add),
            ),
          )
        )
      )
    );
  }
}
