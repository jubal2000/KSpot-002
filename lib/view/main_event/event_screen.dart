import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/utils/utils.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/event_view_model.dart';
import '../../widget/title_text_widget.dart';
import '../app/app_top_menu.dart';
import 'event_edit_screen.dart';

class EventScreen extends StatelessWidget {
  EventScreen({Key? key}) : super(key: key);
  final _viewModel = EventViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppViewModel>.value(
      value: AppData.appViewModel,
      child: Consumer<AppViewModel>(builder: (context, appViewModel, _) {
        _viewModel.init(context);
        return Scaffold(
          body: Stack(
            children: [
              FutureBuilder(
                future: _viewModel.initData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _viewModel.eventData = snapshot.data;
                    return FutureBuilder(
                      future: _viewModel.setShowList(),
                      builder: (context, snapshot2) {
                        if (snapshot2.hasData) {
                          _viewModel.eventShowList = snapshot2.data!;
                          return ChangeNotifierProvider<EventViewModel>.value(
                              value: _viewModel,
                              child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
                            return viewModel.showMainList();
                            })
                          );
                          } else {
                            return showLoadingFullPage(context);
                          }
                        }
                      );
                  } else {
                    return showLoadingFullPage(context);
                  }
                }
              ),
            ]
          )
        );
      }),
    );
  }
}
