import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/view/main_event/main_event.dart';
import 'package:provider/provider.dart';

import '../../view_model/app_view_model.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final _viewModel = AppViewModel();

  List<Widget> pages = [
    MainEvent(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppViewModel>(
      create: (BuildContext context) => _viewModel,
      child: Consumer<AppViewModel>(builder: (context, viewModel, _) {
        return Scaffold(
          body: IndexedStack(
            key: ValueKey(_viewModel.mainIndex),
            index: _viewModel.mainIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            height: UI_BOTTOM_HEIGHT,
          )
        );
      }),
    );
  }
}
