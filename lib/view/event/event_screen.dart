import 'package:flutter/material.dart';
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
import 'event_edit_screen.dart';

class EventScreen extends StatelessWidget {
  EventScreen({Key? key}) : super(key: key);
  final cache = Get.find<CacheService>();

  @override
  Widget build(BuildContext context) {
    AppData.eventViewModel.init(context);

    return SafeArea(
      top: false,
      child: Scaffold(
        body: ChangeNotifierProvider<AppViewModel>.value(
          value: AppData.appViewModel,
          child: Consumer<AppViewModel>(
          builder: (context, appViewModel, _) {
          LOG('--> AppViewModel');
          // AppData.eventViewModel.googleWidget = null;
          return LayoutBuilder(
            builder: (context, layout) {
              return Stack(
                children: [
                  if (AppData.eventViewModel.showList.isEmpty)
                    FutureBuilder(
                      future: AppData.eventViewModel.getEventList(),
                      builder: (context, snapshot) {
                        if (cache.eventData != null) {
                          LOG('--> set eventData : ${cache.eventData!.length}');
                          return ChangeNotifierProvider<EventViewModel>.value(
                              value: AppData.eventViewModel,
                              child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
                                LOG('--> EventViewModel 1');
                            return viewModel.showMainList(layout);
                            })
                          );
                        } else {
                          return showLoadingFullPage(context);
                        }
                      }
                    ),
                    if (AppData.eventViewModel.showList.isNotEmpty)
                      ChangeNotifierProvider<EventViewModel>.value(
                        value: AppData.eventViewModel,
                        child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
                          LOG('--> EventViewModel 2');
                          return viewModel.showMainList(layout);
                        })
                      )
                    ]
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
