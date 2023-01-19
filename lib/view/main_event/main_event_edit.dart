import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/app_data.dart';
import 'package:kspot_002/view_model/event_view_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/common_sizes.dart';
import '../../data/style.dart';
import '../../models/event_model.dart';
import '../../utils/utils.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/card_scroll_viewer.dart';
import '../../widget/edit/edit_component_widget.dart';
import '../../widget/edit/edit_list_widget.dart';
import '../../widget/title_text_widget.dart';
import '../app/app_top_menu.dart';

class MainEventEdit extends StatefulWidget {
  MainEventEdit({Key? key, this.eventItem}) : super(key: key);

  EventModel? eventItem;

  @override
  _MainEventEditState createState ()=> _MainEventEditState();
}

class _MainEventEditState extends State<MainEventEdit> {
  // String  id;
  // int     status;         // 상태 (0:removed, 1:active, 2:disable, 3:ready)
  // String  title;
  // String  desc;
  // String  pic;            // 대표 이미지 (Small Size)
  // String  groupId;        // 그룹 ID
  // String  placeId;        // 장소 ID
  // double  enterFee;       // 현장 입장료
  // String  reserveFee;     // 예매 입장료
  // String  currency;       // 통화단위 (KRW, USD..)
  // String  country;        // 국가
  // String  countryState;   // 도시
  // String  userId;         // 소유 유저
  // int     reservePeriod;  // 예약 기간 (0:예약불가)
  // int     likeCount;      // 종아요 횟수
  // int     voteCount;      // 추천 횟수
  // String  updateTime;     // 수정 시간
  // String  createTime;     // 생성 시간
  //
  // List<String>        tagData;        // tag
  // List<String>        managerData;    // 관리자 ID 목록
  // List<String>        searchData;     // 검색어 목록
  // List<PicData>       picData;        // 메인 이미지 목록
  // List<TimeData>      eventTime;      // 시간 정보 목록
  // List<OptionData>    optionData;     // 옵션 정보
  // List<PromotionData> promotionData;  // 광고설정 정보

  final _viewModel = EventViewModel();

  @override
  void initState () {
    widget.eventItem ??= EventModeEx.empty('', title: 'test title', desc: 'test desc..');
    _viewModel.init(context);
    _viewModel.setEditItem(widget.eventItem!);
    super.initState ();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TopTitleText(context, widget.eventItem != null ? 'Event Edit'.tr : 'Event Add'.tr),
        titleSpacing: 0,
        toolbarHeight: UI_APPBAR_TOOL_HEIGHT.w,
      ),
      body: ChangeNotifierProvider<EventViewModel>.value(
        value: _viewModel,
        child: Consumer<EventViewModel>(builder: (context, viewModel, _) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w),
            children: [
              viewModel.showImageSelector(),
              SizedBox(height: UI_LIST_TEXT_SPACE.w),
              EditTextField(context, 'TITLE'.tr, viewModel.editItem!.title, hint: 'TITLE'.tr, maxLength: TITLE_LENGTH,
                  onChanged: (value) {

              }),
              EditTextField(context, 'DESC'.tr, viewModel.editItem!.desc, hint: 'DESC'.tr, maxLength: DESC_LENGTH,
                  maxLines: null, keyboardType: TextInputType.multiline, onChanged: (value) {

              }),
              EditListSortWidget(viewModel.editEventToJSON, EditListType.timeRange, onAddAction: viewModel.onItemAdd,
                  onSelected: viewModel.onItemSelected),
            ],
          );
        }),
      )
    );
  }
}
