
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view/place/place_list_screen.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/theme_manager.dart';
import '../../models/event_model.dart';
import '../../models/place_model.dart';
import '../../services/cache_service.dart';
import '../../utils/utils.dart';
import '../../view_model/event_edit_view_model.dart';
import '../../view_model/story_edit_view_model.dart';
import '../../widget/event_group_dialog.dart';
import '../../widget/content_item_card.dart';
import '../../widget/title_text_widget.dart';
import '../event/event_list_screen.dart';

class StoryEditEventScreen extends StatelessWidget {
  StoryEditEventScreen({super.key, this.parentViewModel});

  StoryEditViewModel? parentViewModel;
  late final _viewModel = parentViewModel ?? StoryEditViewModel();
  final cache = Get.find<CacheService>();

  @override
  Widget build(BuildContext context) {
    LOG('--> _viewModel : ${_viewModel.stepIndex} / ${_viewModel.eventInfo}');
    return ListView(
      shrinkWrap: true,
      children: [
        SubTitle(context, 'EVENT SELECT'.tr),
        Row(
          children: [
            if (_viewModel.eventInfo != null)...[
              Expanded(
                child: ContentItem(_viewModel.eventInfo!.toJson(),
                    padding: EdgeInsets.zero,
                    showType: GoodsItemCardType.normal,
                    descMaxLine: 2,
                    isShowExtra: false,
                    outlineColor: Theme.of(context).colorScheme.tertiary,
                    titleStyle: ItemTitleLargeStyle(context), descStyle: ItemDescStyle(context)),
              ),
            ],
            contentAddButton(context,
                'EVENT\nSELECT'.tr,
                icon: Icons.settings,
                onPressed: (_) {
                  List<String> list = [];
                  if (_viewModel.eventInfo != null) {
                    list.add(_viewModel.eventInfo!.id);
                  }
                  Get.to(() => EventListScreen(true, isSelectable: true, listSelectData: list))!.then((result) {
                    if (result != null && result.isNotEmpty) {
                      EventModel eventInfo = result.first;
                      LOG('--> EventListScreen result : ${eventInfo.toJson()}');
                      _viewModel.setEventInfo(eventInfo);
                    }
                  });
                }
              ),
            ]
        ),
        // if (_viewModel.eventInfo != null)...[
        //   SizedBox(height: 10),
        //   Text(_viewModel.eventInfo!.address.desc, style: DescBodyTextStyle(context)),
        // ],
        // showHorizontalDivider(Size(Get.width, 30)),
      ]
    );
  }
}
