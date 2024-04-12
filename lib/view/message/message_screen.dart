
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/message_view_model.dart';
import '../home/home_top_menu.dart';

class MessageScreen extends StatelessWidget {
  MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Message'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
        ),
        body: Container(
          padding: EdgeInsets.only(bottom: UI_BOTTOM_HEIGHT),
          child: ChangeNotifierProvider<AppViewModel>.value(
            value: AppData.appViewModel,
            child: Consumer<AppViewModel>(
              builder: (context, appViewModel, _) {
                LOG('--> AppViewModel');
                return LayoutBuilder(
                  builder: (context, layout) {
                    return ChangeNotifierProvider<MessageViewModel>.value(
                        value: AppData.messageViewModel,
                        child: Consumer<MessageViewModel>(builder: (context, viewModel, _) {
                          LOG('--> MessageViewModel refresh');
                          AppData.messageViewModel.getMessageData();
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
          )
        ),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Theme.of(context).primaryColor,
        //   onPressed: () {
        //   },
        //   child: Icon(Icons.add_comment_outlined, size: 30, color: Colors.white),
        // ),
      )
    );
  }
}
