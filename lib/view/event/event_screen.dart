import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/utils/utils.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:kspot_002/widget/csc_picker/csc_picker.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../services/cache_service.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/event_view_model.dart';
import '../../widget/title_text_widget.dart';
import '../home/home_top_menu.dart';
import 'event_edit_screen.dart';

class EventScreen extends StatelessWidget {
  EventScreen({Key? key}) : super(key: key);
  final cache = Get.find<CacheService>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: ChangeNotifierProvider<AppViewModel>.value(
          value: AppData.appViewModel,
          child: Consumer<AppViewModel>(
            builder: (context, appViewModel, _) {
              LOG('--> AppViewModel');
              // AppData.eventViewModel.googleWidget = null;
              return Stack(
                children: [
                  FutureBuilder(
                    future: AppData.eventViewModel.getEventData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        cache.eventData = snapshot.data;
                        AppData.eventViewModel.isMapUpdate = true;
                        LOG('--> set eventData : ${cache.eventData.length}');
                        return ChangeNotifierProvider<EventViewModel>.value(
                          value: AppData.eventViewModel,
                          child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
                            return Stack(
                              children: [
                                LayoutBuilder(
                                  builder: (context, layout) {
                                    return viewModel.showMainList(layout);
                                  }
                                ),
                                viewModel.showDatePicker(),
                                viewModel.showTopMenuBar(),
                              ]
                            );
                          })
                        );
                      } else {
                        return showLoadingFullPage(context);
                      }
                    }
                  ),
                ]
              );
            }
          )
        )
      )
    );
  }
}
