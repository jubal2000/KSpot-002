
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/view_model/place_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../models/place_model.dart';
import '../../utils/utils.dart';
import '../../widget/edit/edit_component_widget.dart';
import '../../widget/edit/edit_list_widget.dart';
import '../../widget/content_item_card.dart';
import '../app/app_top_menu.dart';

class PlaceEditScreen extends StatefulWidget {
  PlaceEditScreen({Key? key, this.placeItem}) : super(key: key);

  PlaceModel? placeItem;

  @override
  _PlaceEditScreenState createState ()=> _PlaceEditScreenState();
}

class _PlaceEditScreenState extends State<PlaceEditScreen> {
  final _viewModel = PlaceViewModel();
  final isEdited = false;

  @override
  void initState () {
    widget.placeItem ??= PlaceModelEx.empty('', title: 'test title', desc: 'test desc..');
    _viewModel.init(context);
    _viewModel.setEditItem(widget.placeItem!);
    super.initState ();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
          onWillPop: () async {
            if (isEdited) {
              var result = await showBackAgreeDialog(context);
              switch (result) {
                case 1:
                  break;
                default:
                  return false;
              }
            }
            return true;
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.placeItem == null ? 'PLACE ADD'.tr : 'PLACE EDIT'.tr, style: AppBarTitleStyle(context)),
                titleSpacing: 0,
                toolbarHeight: 50.w,
              ),
              body: ChangeNotifierProvider<PlaceViewModel>.value(
              value: PlaceViewModel(),
                child: Consumer<PlaceViewModel>(builder: (context, viewModel, _) {
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
                    children: [
                      SubTitle(context, 'PLACE GROUP'.tr),
                      Row(
                        children: [
                          if (JSON_NOT_EMPTY(AppData.currentEventGroup))
                            Expanded(
                              child: ContentItem(AppData.currentEventGroup!.toJson(),
                                  padding: EdgeInsets.zero,
                                  showType: GoodsItemCardType.placeGroup,
                                  descMaxLine: 2,
                                  isShowExtra: false,
                                  titleStyle: ItemTitleLargeStyle(context), descStyle: ItemDescStyle(context)),
                            ),
                          // showEventGroupAddButton(context, Size(80,60), () {
                          //   setState(() {
                          //     if (AppData.listSelectData.isNotEmpty) {
                          //       widget.placeItem!.groupId = AppData.listSelectData.entries.first.key;
                          //     }
                          //   });
                          // }),
                        ],
                      ),
                      viewModel.showImageSelector(),
                      SizedBox(height: UI_LIST_TEXT_SPACE_S.w),
                      SubTitle(context, 'INFO'.tr),
                      SizedBox(height: UI_LIST_TEXT_SPACE_S.w),
                      EditTextField(context, 'TITLE'.tr, viewModel.editItem!.title, hint: 'TITLE'.tr, maxLength: TITLE_LENGTH,
                      onChanged: (value) {

                      }),
                      EditTextField(context, 'DESC'.tr, viewModel.editItem!.desc, hint: 'DESC'.tr, maxLength: DESC_LENGTH,
                      maxLines: null, keyboardType: TextInputType.multiline, onChanged: (value) {

                      }),
                    ],
                  );
                }
            )
          )
        )
      ),
    );
  }
}
