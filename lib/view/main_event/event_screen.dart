import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers.dart';
import 'package:kspot_002/utils/utils.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/common_sizes.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/event_view_model.dart';
import '../../widget/title_text_widget.dart';
import '../app/app_top_menu.dart';
import 'event_edit_screen.dart';

class EventScreen extends StatelessWidget {
  EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EventViewModel>.value(
      value: EventViewModel(),
      child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
        viewModel.init(context);
        return Scaffold(
          // appBar: AppBar(
          //   title: AppTopMenuBar(MainMenuID.event),
          //   automaticallyImplyLeading: false,
          //   toolbarHeight: UI_APPBAR_TOOL_HEIGHT.w,
          //   backgroundColor: Colors.transparent,
          // ),
          body: Stack(
            children: [
              FutureBuilder(
                future: viewModel.initData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FutureBuilder(
                      future: viewModel.refreshShowList(snapshot.data!),
                      builder: (context, snapshot2) {
                        if (snapshot2.hasData) {
                          return viewModel.showMainList();
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
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () {
              //     Get.to(() => EventEditScreen());
              //   },
              //   mini: true,
              //   child: Icon(Icons.add),
              // ),
            ]
          )
        );
      }),
    );
  }
}
