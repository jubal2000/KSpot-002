
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/models/event_model.dart';
import 'package:kspot_002/models/story_model.dart';
import 'package:kspot_002/view/bookmark/bookmark_screen.dart';
import 'package:kspot_002/view/like/like_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/app_data.dart';
import '../../data/dialogs.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/user_view_model.dart';
import '../../widget/credit_widget.dart';
import '../../widget/like_widget.dart';
import '../../widget/page_widget.dart';
import '../../widget/event_item.dart';
import '../follow/follow_screen.dart';
import '../story/story_item.dart';

class ProfileTabScreen extends StatefulWidget {
  ProfileTabScreen(
      this.selectedTab,
      this.title,
      this.userViewModel,
      { Key? key }) : super(key: key);

  ProfileMainTab selectedTab;
  String title;
  UserViewModel userViewModel;

  Widget getTab() {
    return Tab(text: title, height: 40);
  }

  @override
  ProfileTapState createState() => ProfileTapState();
}

class ProfileTapState extends State<ProfileTabScreen> {
  final _scrollController = PageController(viewportFraction: 1, keepPage: true);

  refresh() {
    if (mounted) {
      setState(() {
        LOG("--> MainMyTabState update");
      });
    }
  }

  getSNSItemFromUser(String snsId, JSON snsData) {
    return snsData[snsId] ?? {};
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.userViewModel.init(context);
    switch (widget.selectedTab) {
      case ProfileMainTab.profile: {
        return ChangeNotifierProvider<UserViewModel>.value(
          value: widget.userViewModel,
          child: Consumer<UserViewModel>(
            builder: (context, viewModel, _) {
              LOG('--> UserViewModel redraw');
              return SingleChildScrollView(
                controller: _scrollController,
                // physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: UI_TOP_SPACE.w),
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: UI_HORIZONTAL_SPACE.w),
                            constraints: BoxConstraints(
                              maxWidth: Get.width * 0.45,
                            ),
                            child: Column(
                              children : [
                                viewModel.showUserPic(),
                                SizedBox(height: UI_LIST_TEXT_SPACE.w),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(viewModel.userInfo!.nickName, style: ItemTitleLargeStyle(context)),
                                      ]
                                    ),
                                    if (viewModel.userInfo!.email.isNotEmpty)...[
                                      SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: STR(viewModel.userInfo!.email)));
                                          ShowToast('copied to clipboard'.tr);
                                        },
                                        child: Text(viewModel.userInfo!.email, style: ItemDescStyle(context), maxLines: 3),
                                      ),
                                    ]
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(UI_HORIZONTAL_SPACE.w, 10, UI_HORIZONTAL_SPACE.w, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!viewModel.isMyProfile)...[
                                        showSendMessageWidget(context, viewModel.userInfo!, title: 'TALK'.tr),
                                        SizedBox(width: 2),
                                      ],
                                      if (viewModel.isMyProfile)...[
                                        CreditWidget(context, viewModel.userInfo!.toJson()),
                                        SizedBox(width: 2),
                                      ],
                                      LikeWidget(context, 'user', viewModel.userInfo!.toJson(), showCount: true, isEnabled: !viewModel.isMyProfile),
                                    ],
                                    // children: _shareLink,
                                  ),
                                ),
                                if (viewModel.snsData.isNotEmpty)...[
                                  viewModel.showSnsData(),
                                ]
                              ]
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 10.w, right: UI_HORIZONTAL_SPACE.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children : [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(NUMBER_K(viewModel.userInfo!.followCount), style: ItemTitleStyle(context)),
                                              Text("FOLLOWING".tr, style: ItemTitleStyle(context)),
                                            ],
                                          )
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(NUMBER_K(viewModel.userInfo!.followerCount), style: ItemTitleStyle(context)),
                                              Text("FOLLOWER".tr, style: ItemTitleStyle(context)),
                                            ],
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: UI_LIST_TEXT_SPACE.w),
                                  viewModel.showMessageBox(),
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    viewModel.showUserContentList(),
                  ]
                ),
              );
            }
          )
        );
      }
      case ProfileMainTab.follow: {
        return FollowScreen(AppData.userInfo, isShowAppBar: false);
      }
      case ProfileMainTab.bookmark: {
        return BookmarkScreen(AppData.userInfo, isShowAppBar: false);
      }
      case ProfileMainTab.like: {
        return LikeScreen(AppData.userInfo, isShowAppBar: false);
      }
    }
    return Container();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

