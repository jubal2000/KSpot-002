
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view/place/place_list_screen.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/theme_manager.dart';
import '../../models/place_model.dart';
import '../../utils/utils.dart';
import '../../view_model/event_edit_view_model.dart';
import '../../widget/event_group_dialog.dart';
import '../../widget/content_item_card.dart';
import '../../widget/title_text_widget.dart';

class EventEditPlaceScreen extends StatelessWidget {
  EventEditPlaceScreen({super.key, this.parentViewModel});

  EventEditViewModel? parentViewModel;
  late final _viewModel = parentViewModel ?? EventEditViewModel();

  @override
  Widget build(BuildContext context) {
    LOG('--> _viewModel : ${_viewModel.stepIndex} / ${_viewModel.placeInfo != null ? _viewModel.placeInfo!.address.toJson() : ''}');
    return ListView(
      shrinkWrap: true,
      children: [
        SubTitle(context, 'EVENT GROUP SELECT'.tr),
        Row(
          children: [
            if (AppData.currentEventGroup != null)...[
              Expanded(
                child: ContentItem(AppData.currentEventGroup!.toJson(),
                    padding: EdgeInsets.zero,
                    showType: GoodsItemCardType.placeGroup,
                    descMaxLine: 2,
                    isShowExtra: false,
                    outlineColor: Theme.of(context).colorScheme.tertiary,
                    titleStyle: ItemTitleLargeStyle(context), descStyle: ItemDescStyle(context)),
              ),
            ],
            contentAddButton(context,
              'GROUP\nSELECT'.tr,
              icon: Icons.settings,
              onPressed: (_) {
              LOG('--> EventGroupSelectDialog : ${AppData.currentEventGroup} / ${AppData.currentContentType}');
              EventGroupSelectDialog(context,
                  AppData.currentEventGroup != null ? AppData.currentEventGroup!.id : '',
                  AppData.currentContentType ).then((result) {
                if (result != null) {
                  LOG('--> EventGroupSelectDialog result : ${result.toJson()}');
                  _viewModel.setEventGroup(result);
                }
              });
            }),
          ]
        ),
        showHorizontalDivider(Size(Get.width, 30)),
        SubTitle(context, 'EVENT PLACE SELECT'.tr),
        Row(
          children: [
            if (_viewModel.placeInfo != null)...[
              Expanded(
                child: ContentItem(_viewModel.placeInfo!.toJson(),
                    padding: EdgeInsets.zero,
                    showType: GoodsItemCardType.normal,
                    descMaxLine: 2,
                    isShowExtra: false,
                    outlineColor: Theme.of(context).colorScheme.tertiary,
                    titleStyle: ItemTitleLargeStyle(context), descStyle: ItemDescStyle(context)),
              ),
            ],
            contentAddButton(context,
                'PLACE\nSELECT'.tr,
                icon: Icons.settings,
                onPressed: (_) {
                  Map<String, PlaceModel> list = {};
                  if (_viewModel.placeInfo != null) {
                    list[_viewModel.placeInfo!.id] = _viewModel.placeInfo!;
                  }
                  Get.to(() => PlaceListScreen(isSelectable: true, listSelectData: list))!.then((result) {
                    if (result != null && result.isNotEmpty) {
                      PlaceModel placeInfo = result.entries.first.value;
                      LOG('--> PlaceListScreen result : ${placeInfo.toJson()}');
                      _viewModel.setPlaceInfo(placeInfo);
                    } else {
                      _viewModel.setPlaceInfo(null);
                    }
                  });
                }
              ),
            ]
        ),
        if (_viewModel.placeInfo != null)...[
          SizedBox(height: 10),
          Text(_viewModel.placeInfo!.address.desc, style: DescBodyTextStyle(context)),
        ],
        showHorizontalDivider(Size(Get.width, 30)),
      ]
    );
  }
}
