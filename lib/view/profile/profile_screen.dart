
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:helpers/helpers/widgets/align.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/data/dialogs.dart';
import 'package:kspot_002/services/auth_service.dart';
import 'package:kspot_002/view/message/message_screen.dart';
import 'package:kspot_002/view/profile/profile_tab_screen.dart';
import 'package:kspot_002/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../models/user_model.dart';
import '../../utils/utils.dart';
import '../../view_model/setup_view_model.dart';
import '../../widget/credit_widget.dart';
import '../../widget/like_widget.dart';

class MyProfileScreen extends StatelessWidget {
  MyProfileScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(AppData.userViewModel);
  }
}

class ProfileTargetScreen extends StatelessWidget {
  ProfileTargetScreen(this.userInfo, { Key? key }) : super(key: key);

  UserModel userInfo;

  @override
  Widget build(BuildContext context) {
    final userViewModel = UserViewModel();
    userViewModel.initUserModel(userInfo);
    return ProfileScreen(userViewModel, isShowBack: true);
  }
}

class ProfileScreen extends StatefulWidget {
  ProfileScreen(this.userViewModel, { Key? key, this.isShowBack = false }) : super(key: key);

  UserViewModel userViewModel;
  bool isShowBack;

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth = Get.find<AuthService>();
  final _setupViewModel = SetupViewModel();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _setupViewModel.init(context);
    var expandHeight = UI_PROFILE_BACK_SIZE + UI_FACE_SIZE * 0.5 + 10;
    return SafeArea(
      top: false,
      child: ChangeNotifierProvider.value(
        value: widget.userViewModel,
        child: Consumer<UserViewModel>(
          builder: (context, userViewModel, _) {
            userViewModel.init(context);
            LOG('--> UserViewModel redraw');
            return Scaffold(
              key: _key,
              body: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      pinned: true,
                      stretch: true,
                      automaticallyImplyLeading: false,
                      expandedHeight: expandHeight.w,
                      toolbarHeight: 65.w,
                      forceElevated: innerBoxIsScrolled,
                      backgroundColor: Theme.of(context).backgroundColor,
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
                        statusBarBrightness: Brightness.light, // For iOS (dark icons)
                      ),
                      leading: widget.isShowBack ? InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Row(
                            children: [
                              SizedBox(width: UI_HORIZONTAL_SPACE),
                              OutlineIcon(Icons.arrow_back, 24, Colors.white, shadowColor: Colors.black87)
                            ],
                          )
                      ) : null,
                      actions: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                if (APP_STORE_OPEN)...[
                                  InkWell(
                                      onTap: () {
                                      },
                                      child: OutlineIcon(Icons.store_outlined, 24, Colors.white, shadowColor: Colors.black87)
                                  ),
                                  SizedBox(width: 15.w),
                                ],
                                InkWell(
                                    onTap: () {
                                      Get.to(() => MessageScreen());
                                    },
                                    child: OutlineIcon(Icons.mail_outline, 24, Colors.white, shadowColor: Colors.black87)
                                ),
                                SizedBox(width: 15.w),
                                InkWell(
                                    onTap: () {
                                      _key.currentState!.openEndDrawer();
                                    },
                                    child: OutlineIcon(Icons.menu, 24, Colors.white, shadowColor: Colors.black87)
                                ),
                                SizedBox(width: UI_HORIZONTAL_SPACE),
                              ],
                            )
                          ],
                        )
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        expandedTitleScale: 1.0,
                        titlePadding: EdgeInsets.zero,
                        title: Stack(
                          children: [
                            Positioned(
                              bottom: UI_PROFILE_BACK_SIZE.w - UI_FACE_SIZE.w,
                              child: Container(
                                width: Get.width,
                                height: UI_PROFILE_BACK_SIZE.w - UI_FACE_SIZE.w,
                                  child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: userViewModel.showProfileUserBackground(),
                                )
                              )
                            ),
                            // Positioned(
                            //   top: 40.w,
                            //   right: UI_HORIZONTAL_SPACE.w,
                            //   child: Row(
                            //     children: [
                            //       if (APP_STORE_OPEN)...[
                            //         InkWell(
                            //           onTap: () {
                            //           },
                            //           child: OutlineIcon(Icons.store_outlined, 24, Colors.white, shadowColor: Colors.black87)
                            //         ),
                            //         SizedBox(width: 15.w),
                            //       ],
                            //       InkWell(
                            //         onTap: () {
                            //           Get.to(() => MessageScreen());
                            //         },
                            //         child: OutlineIcon(Icons.mail_outline, 24, Colors.white, shadowColor: Colors.black87)
                            //       ),
                            //       SizedBox(width: 15.w),
                            //       InkWell(
                            //         onTap: () {
                            //           _key.currentState!.openEndDrawer();
                            //         },
                            //         child: OutlineIcon(Icons.menu, 24, Colors.white, shadowColor: Colors.black87)
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ]
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(UI_FACE_SIZE.w),
                        child: Container(
                          width: Get.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              userViewModel.showProfileUserFace(),
                              SizedBox(height: 10.w),
                              Container(
                                height: UI_PROFILE_TEXT_SIZE.w,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(userViewModel.userInfo!.nickName, style: AppBarTitleOutlineStyle(context, color: Colors.black, Colors.white30)),
                                  ],
                                )
                              )
                            ]
                          )
                        ),
                      ),
                    ),
                  ];
                },
                body: Container(
                  padding: EdgeInsets.symmetric(horizontal: UI_HORIZONTAL_SPACE.w, vertical: 5.w),
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(DESC(userViewModel.userInfo!.message), style: ItemDescOutlineStyle(context), maxLines: 1),
                          SizedBox(height: 10.w),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!userViewModel.isMyProfile)...[
                                showSendMessageWidget(context, userViewModel.userInfo!, title: 'TALK'.tr),
                                SizedBox(width: 2),
                              ],
                              if (userViewModel.isMyProfile)...[
                                CreditWidget(context, userViewModel.userInfo!.toJson()),
                                SizedBox(width: 2),
                              ],
                              LikeWidget(context, 'user', userViewModel.userInfo!.toJson(), showCount: true, isEnabled: !userViewModel.isMyProfile),
                            ],
                              // children: _shareLink,
                          ),
                          if (userViewModel.snsData.isNotEmpty)...[
                            userViewModel.showSnsData(),
                          ]
                        ],
                      ),
                      userViewModel.showUserContentList(),
                    ],
                  )
                ) // show profile main..
              ),
              endDrawer: ChangeNotifierProvider.value(
                value: _setupViewModel,
                child: Consumer<SetupViewModel>(
                  builder: (context, viewModel, _) {
                    LOG('--> SetupViewModel redraw');
                    return Drawer(
                      backgroundColor: Theme.of(context).canvasColor,
                      child: ListView(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(10),
                            tileColor: Theme.of(context).primaryColorDark,
                            onTap: () {
                              Navigator.pop(context);
                            },
                            title: Row(
                              children: [
                                SizedBox(width: 10.w),
                                Icon(Icons.menu, size: 24.sp),
                                SizedBox(width: 10.w),
                                Text('User Menu'.tr, style: AppBarTitleStyle(context))
                              ],
                            ),
                          ),
                          ...viewModel.showSetupList((refresh) {
                            if (refresh) {
                              userViewModel.initUserModel(AppData.userInfo);
                              userViewModel.refresh();
                            }
                          }),
                        ]
                      ),
                    );
                  }
                )
              ),
            );
          }
        ),
      )
    );
  }
}
