import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpers/helpers.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widget/comment_widget.dart';


class PlaceDetailScreen extends StatefulWidget {
  PlaceDetailScreen(this.placeInfo, this.groupInfo, {Key? key,
    this.topTitle = '', this.isPreview = false, this.isShowHome = true}) : super(key: key);

  JSON placeInfo;
  JSON? groupInfo;
  String topTitle;
  bool isPreview;
  bool isShowHome;

  @override
  PlaceDetailState createState() => PlaceDetailState();
}

class PlaceDetailState extends State<PlaceDetailScreen> with TickerProviderStateMixin {
  final api = Get.find<ApiService>();
  Future<JSON>? _initPlaceInfo;
  List<JSON> _addressList = [];

  List<AnimationController> _aniController = [];
  final _scrollController = AutoScrollController();
  final _topHeight = 50.0;

  JSON _placeInfo = {};

  initData() {
    _placeInfo.clear();
    _placeInfo.addAll(widget.placeInfo);
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.topTitle, style: AppBarTitleStyle(context)),
        titleSpacing: 0,
        toolbarHeight: _topHeight,
        actions: [
          if (widget.isShowHome)...[
            GestureDetector(
              child: Icon(Icons.home),
              onTap: () {
                Navigator.of(context).pop('home');
              },
            ),
          ],
          SizedBox(width: 15),
        ],
      ),
      body: FutureBuilder(
        future: _initPlaceInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _placeInfo = snapshot.data as JSON;
          }
          return ListView(
              controller: _scrollController,
              children: [
              ]
            );
          }
        )
      )
    );
  }
}
