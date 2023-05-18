import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/app_data.dart';
import 'package:kspot_002/view/event/event_list_screen.dart';
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
import '../../view_model/story_edit_view_model.dart';
import '../../widget/card_scroll_viewer.dart';
import '../../widget/edit/edit_component_widget.dart';
import '../../widget/edit/edit_list_widget.dart';
import '../../widget/edit/edit_setup_widget.dart';
import '../../widget/content_item_card.dart';
import '../../widget/title_text_widget.dart';
import '../place/place_item.dart';
import '../place/place_list_screen.dart';

class StoryEditInputScreen extends StatefulWidget {
  StoryEditInputScreen({Key? key, this.parentViewModel}) : super(key: key);

  StoryEditViewModel? parentViewModel;

  @override
  _StoryEditInputScreenState createState ()=> _StoryEditInputScreenState();
}

class _StoryEditInputScreenState extends State<StoryEditInputScreen> {
  late final _viewModel = widget.parentViewModel ?? StoryEditViewModel();
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
    // if (_viewModel.editItem!.managerData == null || _viewModel.editItem!.managerData!.isEmpty) {
    //   final addItem = ManagerData(
    //     id: AppData.userInfo.id,
    //     nickName: AppData.userInfo.nickName,
    //     pic: AppData.userInfo.pic,
    //     status: 1,
    //   );
    //   _viewModel.editItem!.managerData = [addItem];
    //   _viewModel.managerData[addItem.id] = addItem.toJson();
    // }
    return ListView(
        shrinkWrap: true,
        children: [
          if (_viewModel.isEditMode)...[
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
                    // Map<String, EventModel> list = {};
                    // if (_viewModel.eventInfo != null) {
                    //   list[_viewModel.eventInfo!.id] = _viewModel.eventInfo!;
                    // }
                    Navigator.of(context).push(createAniRoute(EventListScreen(false, selectMax: 1, listSelectData: []))).then((result) {
                      if (result != null && result.isNotEmpty) {
                        EventModel eventInfo = result.first;
                        LOG('--> PlaceListScreen result : ${eventInfo.toJson()}');
                        _viewModel.setEventInfo(eventInfo);
                      } else {
                        _viewModel.setEventInfo(null);
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
          EditTextField(context, 'DESC'.tr, _viewModel.editItem!.desc, hint: 'Story Description'.tr, maxLength: DESC_LENGTH,
              maxLines: null, keyboardType: TextInputType.multiline, onChanged: (value) {
              _viewModel.editItem!.desc = value;
          }),
          TagTextField(_viewModel.editItem!.tagData, (value) {
            _viewModel.editItem!.tagData = value;
          }),
          SizedBox(height: UI_LIST_TEXT_SPACE),
          EditSetupWidget('OPTIONS'.tr, _viewModel.editOptionToJSON, AppData.INFO_STORY_OPTION,
              key:_setupKey,
              onDataChanged: _viewModel.onSettingChanged),
          SizedBox(height: UI_LIST_TEXT_SPACE_L),
        ],
    );
  }
}
