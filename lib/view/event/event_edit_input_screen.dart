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
import '../../models/etc_model.dart';
import '../../models/event_model.dart';
import '../../models/place_model.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/card_scroll_viewer.dart';
import '../../widget/edit/edit_component_widget.dart';
import '../../widget/edit/edit_list_widget.dart';
import '../../widget/edit/edit_setup_widget.dart';
import '../../widget/content_item_card.dart';
import '../../widget/title_text_widget.dart';
import '../place/place_item.dart';
import '../place/place_list_screen.dart';

class EventEditInputScreen extends StatefulWidget {
  EventEditInputScreen({Key? key, this.parentViewModel}) : super(key: key);

  EventEditViewModel? parentViewModel;

  @override
  _EventEditInputScreenState createState ()=> _EventEditInputScreenState();
}

class _EventEditInputScreenState extends State<EventEditInputScreen> {
  late final _viewModel = widget.parentViewModel ?? EventEditViewModel();
  final _setupKey = GlobalKey();

  @override
  void initState () {
    // if (AppData.userInfo.id.isEmpty) { // TODO : for Dev..
    //   AppData.userInfo.id       = 'lBSiD1qEBhvcPu49W56q';
    //   AppData.userInfo.loginId  = 'e0lVUcIw4NV0XM5uX9mDjHdk91m2';
    //   AppData.userInfo.nickName = '주발Tester';
    // }
    super.initState ();
  }

  @override
  Widget build(BuildContext context) {
    // auto add manager..
    if (_viewModel.editItem!.managerData == null || _viewModel.editItem!.managerData!.isEmpty) {
      final addItem = MemberData(
        id: AppData.userInfo.id,
        status: 1,
        nickName: AppData.userInfo.nickName,
        pic: AppData.userInfo.pic,
        createTime: DateTime.now(),
      );
      _viewModel.editItem!.managerData = [addItem];
      _viewModel.managerData[addItem.id] = addItem.toJson();
    }
    LOG('--> _viewModel.editManagerToJSON : ${_viewModel.editManagerToJSON}');
    return ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: UI_LIST_TEXT_SPACE_L),
          if (_viewModel.isEditMode)...[
            SubTitle(context, 'EVENT SPOT SELECT'.tr),
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
                  'SPOT\nSELECT'.tr,
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
            SizedBox(height: UI_LIST_TEXT_SPACE),
            showHorizontalDivider(Size(Get.width, 1))
          ],
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          _viewModel.showImageSelector(),
          SizedBox(height: UI_LIST_TEXT_SPACE),
          showHorizontalDivider(Size(Get.width, 1)),
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          SubTitle(context, 'INFO'.tr),
          SizedBox(height: UI_LIST_TEXT_SPACE),
          EditTextField(context, 'TITLE'.tr, _viewModel.editItem!.title, hint: 'Event Title *'.tr, maxLength: TITLE_LENGTH,
            maxLines: 1, keyboardType: TextInputType.multiline, onChanged: (value) {
              _viewModel.editItem!.title = value;
          }),
          EditTextField(context, 'DESC'.tr, _viewModel.editItem!.desc, hint: 'Event Description'.tr, maxLength: DESC_LENGTH,
              maxLines: null, keyboardType: TextInputType.multiline, onChanged: (value) {
              _viewModel.editItem!.desc = value;
          }),
          TagTextField(_viewModel.editItem!.tagData, (value) {
            _viewModel.editItem!.tagData = value;
          }),
          SizedBox(height: UI_LIST_TEXT_SPACE),
          showHorizontalDivider(Size(Get.width, 1)),
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          EditListWidget(_viewModel.editManagerToJSON, title:'MANAGER *', EditListType.manager, _viewModel.onItemAdd,
              _viewModel.onItemSelected),
          SizedBox(height: UI_LIST_TEXT_SPACE),
          showHorizontalDivider(Size(Get.width, 1)),
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          EditListSortWidget(_viewModel.editEventToJSON, title:'TIME SETTING *', EditListType.timeRange, _viewModel.onItemAdd,
              _viewModel.onItemSelected),
          SizedBox(height: UI_LIST_TEXT_SPACE),
          showHorizontalDivider(Size(Get.width, 1)),
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          EditListSortWidget(_viewModel.editCustomToJSON, EditListType.customField, _viewModel.onItemAdd,
              _viewModel.onItemSelected, onListItemChanged: _viewModel.onItemChanged),
          SizedBox(height: UI_LIST_TEXT_SPACE),
          showHorizontalDivider(Size(Get.width, 1)),
          SizedBox(height: UI_LIST_TEXT_SPACE_S),
          EditSetupWidget('OPTIONS'.tr, _viewModel.editOptionToJSON, AppData.INFO_EVENT_OPTION,
              key:_setupKey,
              customData: _viewModel.editCustomToJSON,
              showOption: [
                {'showId': 'reserv' , 'value': _viewModel.checkCustomField('reserve', true)},
              ],
              onDataChanged: _viewModel.onSettingChanged),
          SizedBox(height: UI_LIST_TEXT_SPACE_L),
        ],
    );
  }
}
