import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';

class SetupNoticeScreen extends StatefulWidget {
  SetupNoticeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SetupNoticeState();
}

class SetupNoticeState extends State<SetupNoticeScreen> {
  Future<JSON>? noticeInit;
  List<Widget> itemList = [];

  refreshList(BuildContext context) {
    itemList = [];
    AppData.infoData['notice'] = JSON_CREATE_TIME_SORT_DESC(AppData.INFO_NOTICE);

    for (var item in AppData.INFO_NOTICE.entries) {
      itemList.add(
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            color: Theme.of(context).canvasColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DESC(item.value['desc']), style: ItemTitleStyle(context)),
              SizedBox(height: 5),
              Text(SERVER_TIME_STR(item.value['createTime']), style: ItemDescExStyle(context)),
            ],
          )
        )
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    refreshList(context);
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notice'.tr, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
        ),
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE, vertical: 10),
          child: ListView(
            children: itemList,
          ),
        )
      )
    );
  }
}