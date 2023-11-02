import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/place_edit_view_model.dart';
import '../../widget/content_item_card.dart';
import '../../widget/event_group_dialog.dart';

class PlaceEditGroupSelectScreen extends StatelessWidget {
  PlaceEditGroupSelectScreen({super.key, this.parentViewModel});

  PlaceEditViewModel? parentViewModel;
  late final _viewModel = parentViewModel ?? PlaceEditViewModel();

  @override
  Widget build(BuildContext context) {
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
                          _viewModel.setEventGroupInfo(result);
                        }
                      });
                    }),
              ]
          ),
        ]
    );
  }
}
