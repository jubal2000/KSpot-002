import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
        body: FutureBuilder(
          future: AppData.eventViewModel.getEventData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              cache.eventData = snapshot.data;
              AppData.eventViewModel.isMapUpdate = true;
              LOG('--> cache.eventData : ${cache.eventData.length}');
              return ChangeNotifierProvider<EventViewModel>.value(
                value: AppData.eventViewModel,
                child: Consumer<EventViewModel>(
                  builder: (context, viewModel, _) {
                    return viewModel.showEventMain();
                  })
              );
            } else {
              return showLoadingFullPage(context);
            }
          }
        )
      )
    );
  }
}
