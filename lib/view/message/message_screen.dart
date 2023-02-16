
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/message_view_model.dart';

class MessageScreen extends StatelessWidget {
  MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppData.messageViewModel.init(context);
    return SafeArea(
      top: false,
      child: Scaffold(
        body: ChangeNotifierProvider<AppViewModel>.value(
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
                        AppData.messageViewModel.startMessageStreamToMe();
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
      )
    );
  }
}
