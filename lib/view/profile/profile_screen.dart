
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kspot_002/data/common_sizes.dart';
import 'package:kspot_002/data/dialogs.dart';
import 'package:kspot_002/services/auth_service.dart';
import 'package:kspot_002/view/message/message_screen.dart';
import 'package:kspot_002/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../data/theme_manager.dart';
import '../../utils/utils.dart';
import '../../view_model/setup_view_model.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({ Key? key, this.isShowBack = false }) : super(key: key);

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
    AppData.userViewModel.initUserModel(AppData.userInfo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppData.userViewModel.init(context);
    _setupViewModel.init(context);
    return SafeArea(
      top: false,
      child: DefaultTabController(
        length: AppData.userViewModel.tabList.length,
        child: Scaffold(
          key: _key,
          appBar: AppBar(
            toolbarHeight: 30.w,
            automaticallyImplyLeading: widget.isShowBack,
            actions: [
              IconButton(
                onPressed: () {
                  Get.to(() => MessageScreen());
                },
                icon: Icon(Icons.mail_outline)
              ),
              IconButton(
                onPressed: () {
                  _key.currentState!.openEndDrawer();
                },
                icon: Icon(Icons.menu)
              ),
              SizedBox(width: 5.w),
            ],
            bottom: TabBar(
              onTap: (index) {
                AppData.userViewModel.currentTab = index;
              },
              padding: EdgeInsets.symmetric(horizontal: 20),
              labelColor: Theme.of(context).primaryColor,
              labelStyle: ItemTitleStyle(context),
              unselectedLabelColor: Theme.of(context).hintColor,
              unselectedLabelStyle: ItemTitleStyle(context),
              indicatorColor: Theme.of(context).primaryColor,
              tabs: List<Widget>.from(AppData.userViewModel.tabList.map((item) => item.getTab()).toList()),
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: List<Widget>.from(AppData.userViewModel.tabList),
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
                          AppData.userViewModel.initUserModel(AppData.userInfo);
                          AppData.userViewModel.refresh();
                        }
                      }),
                    ]
                  ),
                );
              }
            )
          )
        ),
      )
    );
  }
}
