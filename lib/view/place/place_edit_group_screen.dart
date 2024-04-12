import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../data/app_data.dart';
import '../../data/common_sizes.dart';
import '../../data/theme_manager.dart';
import '../../repository/event_repository.dart';
import '../../utils/utils.dart';
import '../../view_model/place_edit_view_model.dart';
import '../../widget/content_item_card.dart';
import '../../widget/event_group_dialog.dart';
import '../../widget/helpers/helpers/widgets/align.dart';

class PlaceEditGroupSelectScreen extends StatefulWidget {
  PlaceEditGroupSelectScreen({super.key, this.parentViewModel});
  PlaceEditViewModel? parentViewModel;

  @override
  PlaceEditGroupSelectState createState ()=> PlaceEditGroupSelectState();
}

class PlaceEditGroupSelectState extends State<PlaceEditGroupSelectScreen> {
  late final _viewModel = widget.parentViewModel ?? PlaceEditViewModel();
  final _gridController = List.generate(2, (index) => ScrollController());
  final List<Widget> _placeGridList = [];

  Future<JSON>? placeGroupInit;
  JSON placeGroupData = {};
  final repo = EventRepository();

  var contentTypeId = AppData.currentEventGroup!.contentType;
  var isGridMode = true;

  @override
  Widget build(BuildContext context) {
    var iconColor0  = Theme.of(context).disabledColor;
    var iconColor1  = Theme.of(context).primaryColor;
    var placeGroupInit = repo.getEventGroupList();

    return FutureBuilder(
        future: placeGroupInit,
        builder: (context, snapshot) {
        if (snapshot.hasData) {
          placeGroupData = snapshot.data as JSON;
          LOG('--> placeGroupData : $placeGroupData');
          refresh(context);
          return ListView(
            shrinkWrap: true,
            children: [
              SubTitleBar(context, 'CATEGORY'.tr),
              SizedBox(height: 10),
              Row(
                children: [
                  ContentTypeSelectWidget(context, contentTypeId, (result) {
                    setState(() {
                      contentTypeId = result;
                    });
                  }),
                ],
              ),
              SizedBox(height: 10),
              SubTitleBarEx(context, 'SPOT GROUP'.tr,
                child: Row(
                  children: [
                    Icon(Icons.grid_view,
                        color: isGridMode ? iconColor1 : iconColor0),
                    SizedBox(width: 10),
                    Icon(Icons.view_list_rounded,
                        color: !isGridMode ? iconColor1 : iconColor0),
                  ],
                ),
                onActionSelect: (_) {
                  setState(() {
                    isGridMode = !isGridMode;
                  });
                }
              ),
              if (isGridMode)...[
                Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: MasonryGridView.count(
                        shrinkWrap: true,
                        controller: _gridController[0],
                        itemCount: _placeGridList.length,
                        crossAxisCount: 4,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return _placeGridList[index];
                        }
                    )
                ),
              ],
              if (!isGridMode)...[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.9,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _placeGridList.length,
                    itemBuilder: (context, index) {
                      return _placeGridList[index];
                    },
                  ),
                )
              ],
            ]
          );
        } else {
          return showLoadingFullPage(context);
        }
      }
    );
  }

  refresh(BuildContext context) {
    _placeGridList.clear();
    final borderColor = Theme.of(context).primaryColor.withOpacity(0.5);
    for (var item in placeGroupData.entries) {
      final isCurrentGroup = _viewModel.editItem!.groupId == item.value.id;
      Widget addWidget;
      if (isGridMode) {
        addWidget = GestureDetector(
          onTap: () {
            _viewModel.editItem!.groupId = item.value.id;
            _viewModel.setEventGroupInfo(item.value);
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor,
                        width: isCurrentGroup ? 4 : 0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: showSizedImage(
                      item.value.pic, UI_ITEM_HEIGHT - 6),
                ),
                BottomCenterAlign(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(item.value.title.toUpperCase(),
                      style: ItemDescOutlineExStyle(
                          context, borderColor: Colors.black38),
                      maxLines: 3)
                  ),
                ),
              ]
            )
          )
        );
      } else {
        addWidget = ContentItem(
          item.value.toJson(),
          key: Key(item.key),
          showType: GoodsItemCardType.placeGroup,
          padding: EdgeInsets.all(5),
          titleStyle: ItemTitleLargeStyle(context),
          descStyle: ItemDescStyle(context),
          showOutline: isCurrentGroup,
          outlineColor: borderColor,
          isShowExtra: false,
          onShowDetail: (key, status) {
            _viewModel.editItem!.groupId = item.value.id;
            _viewModel.setEventGroupInfo(item.value);
          },
        );
      }
      _placeGridList.add(addWidget);
      LOG('--> _placeGridList : $_placeGridList');
    }
  }
}
