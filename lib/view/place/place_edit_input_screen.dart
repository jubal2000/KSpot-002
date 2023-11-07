import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/app_data.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:kspot_002/widget/event_group_dialog.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/common_sizes.dart';
import '../../data/style.dart';
import '../../data/theme_manager.dart';
import '../../models/etc_model.dart';
import '../../models/event_group_model.dart';
import '../../models/event_model.dart';
import '../../models/place_model.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/place_edit_view_model.dart';
import '../../widget/card_scroll_viewer.dart';
import '../../widget/edit/edit_component_widget.dart';
import '../../widget/edit/edit_list_widget.dart';
import '../../widget/edit/edit_setup_widget.dart';
import '../../widget/content_item_card.dart';
import '../../widget/title_text_widget.dart';
import '../place/place_item.dart';
import '../place/place_list_screen.dart';

class PlaceEditInputScreen extends StatefulWidget {
  PlaceEditInputScreen({Key? key, this.parentViewModel}) : super(key: key);

  PlaceEditViewModel? parentViewModel;

  @override
  _PlaceEditInputScreenState createState ()=> _PlaceEditInputScreenState();
}

class _PlaceEditInputScreenState extends State<PlaceEditInputScreen> {
  late final _viewModel = widget.parentViewModel ?? PlaceEditViewModel();
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
        SubTitle(context, 'SPOT GROUP'.tr),
        Row(
          children: [
            if (_viewModel.groupInfo != null)...[
              Expanded(
                child: ContentItem(_viewModel.groupInfo!.toJson(),
                  padding: EdgeInsets.zero,
                  showType: GoodsItemCardType.normal,
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
                EventGroupSelectDialog(context,
                    _viewModel.groupInfo!.id,
                    _viewModel.groupInfo!.contentType).then((result) {
                  if (result != null) {
                    LOG('--> EventGroupSelectDialog result : ${result.toJson()}');
                    _viewModel.setEventGroupInfo(result);
                  }
                });
              }
            ),
          ]
        ),
        SizedBox(height: UI_LIST_TEXT_SPACE),
        _viewModel.showImageSelector(),
        SizedBox(height: UI_LIST_TEXT_SPACE),
        SubTitle(context, 'INFO'.tr),
        SizedBox(height: UI_LIST_TEXT_SPACE),
        EditTextField(context, 'TITLE'.tr, _viewModel.editItem!.title,
            hint: 'Spot title *'.tr, maxLength: TITLE_LENGTH,
            maxLines: 1, keyboardType: TextInputType.multiline, onChanged: (value) {
              _viewModel.editItem!.title = value;
            }),
        EditTextField(context, 'DESC'.tr, _viewModel.editItem!.desc,
            hint: 'Spot message'.tr, maxLength: DESC_LENGTH,
            maxLines: null, keyboardType: TextInputType.multiline, onChanged: (value) {
              _viewModel.editItem!.desc = value;
            }),
        TagTextField(_viewModel.editItem!.tagData, (value) {
          _viewModel.editItem!.tagData = value;
        }),
        SizedBox(height: UI_LIST_TEXT_SPACE),
        _viewModel.showCountrySelect(context),
        SizedBox(height: UI_LIST_TEXT_SPACE),
        _viewModel.showAddressInput(context),
        SizedBox(height: UI_LIST_TEXT_SPACE),
        _viewModel.showContactInput(context),
        SizedBox(height: UI_LIST_TEXT_SPACE),
        EditListWidget(_viewModel.editManagerToJSON, title:'MANAGER *', EditListType.manager, _viewModel.onItemAdd,
            _viewModel.onItemSelected),
        SizedBox(height: UI_LIST_TEXT_SPACE),
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
