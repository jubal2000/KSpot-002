import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/app_data.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/common_sizes.dart';
import '../../data/style.dart';
import '../../data/theme_manager.dart';
import '../../models/event_model.dart';
import '../../models/place_model.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/card_scroll_viewer.dart';
import '../../widget/edit/edit_component_widget.dart';
import '../../widget/edit/edit_list_widget.dart';
import '../../widget/goods_item_card.dart';
import '../../widget/title_text_widget.dart';
import '../app/app_top_menu.dart';
import '../place/place_item.dart';
import '../place/place_list_screen.dart';

class EventEditInputScreen extends StatefulWidget {
  EventEditInputScreen({Key? key, this.eventItem, this.placeInfo, this.parentViewModel}) : super(key: key);

  EventModel? eventItem;
  PlaceModel? placeInfo;
  EventEditViewModel? parentViewModel;

  @override
  _EventEditInputScreenState createState ()=> _EventEditInputScreenState();
}

class _EventEditInputScreenState extends State<EventEditInputScreen> {
  late final _viewModel = widget.parentViewModel ?? EventEditViewModel();

  @override
  void initState () {
    if (widget.eventItem != null) {
      _viewModel.setEditItem(widget.eventItem!);
    }
    if (AppData.userInfo.id.isEmpty) { // TODO : for Dev..
      AppData.userInfo.id = 'lBSiD1qEBhvcPu49W56q';
      AppData.userInfo.nickName = '주발Tester';
    }
    super.initState ();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.init(context);
    if (widget.eventItem != null) {
      _viewModel.editItem  = widget.eventItem;
      _viewModel.placeInfo = widget.placeInfo;
    }
    return Scaffold(
      appBar: AppBar(
        title: TopTitleText(context, widget.eventItem != null ? 'Event Edit'.tr : 'Event Add'.tr),
        titleSpacing: 0,
        toolbarHeight: UI_APPBAR_TOOL_HEIGHT,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          if (widget.eventItem != null)...[
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
            SizedBox(height: UI_LIST_TEXT_SPACE_S),
          ],
          _viewModel.showImageSelector(),
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          SubTitle(context, 'INFO'.tr),
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          EditTextField(context, 'TITLE'.tr, _viewModel.editItem!.title, hint: 'TITLE'.tr, maxLength: TITLE_LENGTH,
              onChanged: (value) {

          }),
          EditTextField(context, 'DESC'.tr, _viewModel.editItem!.desc, hint: 'DESC'.tr, maxLength: DESC_LENGTH,
              maxLines: null, keyboardType: TextInputType.multiline, onChanged: (value) {

          }),
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          EditListWidget(_viewModel.editManagerToJSON, EditListType.manager, _viewModel.onItemAdd,
              _viewModel.onItemSelected),
          SizedBox(height: UI_LIST_TEXT_SPACE),
          EditListSortWidget(_viewModel.editEventToJSON, EditListType.timeRange, _viewModel.onItemAdd,
              _viewModel.onItemSelected),
        ],
      )
    );
  }
}
