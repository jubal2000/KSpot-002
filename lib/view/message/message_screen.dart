
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../view_model/message_view_model.dart';

class MessageScreen extends StatelessWidget {
  MessageScreen({Key? key}) : super(key: key);
  final _viewModel = MessageViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MessageViewModel>.value(
      value: _viewModel,
      child: Consumer<MessageViewModel>(builder: (context, appViewModel, _) {
        _viewModel.init(context);
        return Scaffold(
            body: Stack(
                children: [
                  // FutureBuilder(
                  //     future: _viewModel.initData,
                  //     builder: (context, snapshot) {
                  //       if (snapshot.hasData) {
                  //         _viewModel.eventData = snapshot.data;
                  //         return FutureBuilder(
                  //             future: _viewModel.setShowList(),
                  //             builder: (context, snapshot2) {
                  //               if (snapshot2.hasData) {
                  //                 _viewModel.eventShowList = snapshot2.data!;
                  //                 return ChangeNotifierProvider<EventViewModel>.value(
                  //                     value: _viewModel,
                  //                     child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
                  //                       return viewModel.showMainList();
                  //                     })
                  //                 );
                  //               } else {
                  //                 return showLoadingFullPage(context);
                  //               }
                  //             }
                  //         );
                  //       } else {
                  //         return showLoadingFullPage(context);
                  //       }
                  //     }
                  // ),
                ]
            )
        );
      }),
    );
  }
}
