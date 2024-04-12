import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/place_model.dart';
import 'package:kspot_002/view_model/place_view_model.dart';
import 'package:kspot_002/widget/image_scroll_viewer.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../models/event_group_model.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../view_model/place_detail_view_model.dart';
import '../../widget/comment_widget.dart';


class PlaceDetailScreen extends StatefulWidget {
  PlaceDetailScreen(this.placeInfo, this.groupInfo, {Key? key,
    this.topTitle = '', this.isPreview = false, this.isShowHome = false}) : super(key: key);

  PlaceModel placeInfo;
  EventGroupModel? groupInfo;
  String topTitle;
  bool isPreview;
  bool isShowHome;

  @override
  PlaceDetailState createState() => PlaceDetailState();
}

class PlaceDetailState extends State<PlaceDetailScreen> with TickerProviderStateMixin {
  final _viewModel = PlaceDetailViewModel();

  initData() {
    _viewModel.setPlaceData(widget.placeInfo);
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LOG('---> PlaceDetailState');
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topTitle, style: AppBarTitleStyle(context)),
          titleSpacing: 0,
          toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
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
        body: ChangeNotifierProvider<PlaceDetailViewModel>.value(
          value: _viewModel,
          child: Consumer<PlaceDetailViewModel>(builder: (context, viewModel, _) {
            return Container(
              child: ListView(
                shrinkWrap: true,
                controller: viewModel.scrollController,
                children: [
                  if (JSON_NOT_EMPTY(widget.placeInfo.picData))...[
                    viewModel.showImageList()
                  ],
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Row(
                          children: [
                            viewModel.showPicture(),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    viewModel.showTitle()
                                  ]
                              ),
                            ),
                            if (!widget.isPreview)...[
                              SizedBox(height: 20),
                              viewModel.showShareBox(),
                            ],
                          ]
                        ),
                        SizedBox(height: 20),
                        if (viewModel.placeInfo!.desc.isNotEmpty)...[
                          viewModel.showDesc(),
                        ],
                        SizedBox(height: 10),
                        showHorizontalDivider(Size(double.infinity * 0.9, 40), color: LineColor(context)),
                        viewModel.showLocation(),
                        showHorizontalDivider(Size(double.infinity * 0.9, 40), color: LineColor(context)),
                        viewModel.showEventList(),
                        SizedBox(height: 20),
                      ]
                    )
                  )
                ]
              )
            );
          })
        )
      )
    );
  }
}
