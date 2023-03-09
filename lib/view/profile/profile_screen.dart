
import 'package:flutter/material.dart';
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
import '../setup/setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({ Key? key, this.isShowBack = false }) : super(key: key);

  bool isShowBack;

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth = Get.find<AuthService>();
  final _viewModel = UserViewModel();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    _viewModel.initUserModel(AppData.userInfo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.setContext(context);
    return SafeArea(
      top: false,
      child: ChangeNotifierProvider<UserViewModel>.value(
        value: _viewModel,
        child: Consumer<UserViewModel>(
          builder: (context, viewModel, _) {
            LOG('--> UserViewModel redraw');
            return DefaultTabController(
              length: viewModel.tabList.length,
              child: Scaffold(
                key: _key,
                appBar: AppBar(
                  title: Text(viewModel.isMyProfile ? 'MY'.tr : ''),
                  titleTextStyle: AppBarTitleStyle(context),
                  titleSpacing: UI_HORIZONTAL_SPACE,
                  toolbarHeight: UI_APPBAR_TITLE_SPACE,
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
                        // showAlertYesNoDialog(context, 'SIGN OUT'.tr, 'Would you like to sign out now?'.tr, '', 'Cancel'.tr, 'OK'.tr).then((result) {
                        //   if (result == 1) {
                        //     auth.signOut();
                        //   }
                        // });
                      },
                      icon: Icon(Icons.settings)
                    ),
                  ],
                  bottom: TabBar(
                    onTap: (index) {
                      viewModel.currentTab = index;
                    },
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    labelColor: Theme.of(context).primaryColor,
                    labelStyle: ItemTitleStyle(context),
                    unselectedLabelColor: Theme.of(context).hintColor,
                    unselectedLabelStyle: ItemTitleStyle(context),
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: List<Widget>.from(viewModel.tabList.map((item) => item.getTab()).toList()),
                  ),
                ),
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: List<Widget>.from(viewModel.tabList),
                ),
                endDrawer: Drawer(
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
                            SizedBox(width: 10),
                            Icon(Icons.settings, size: 30),
                            SizedBox(width: 10),
                            Text('Setup'.tr, style: AppBarTitleStyle(context))
                          ],
                        ),
                      ),
                      ...showSetupList((refresh) {
                        if (refresh) {
                          viewModel.initUserModel(AppData.userInfo);
                          viewModel.refresh();
                        }
                      }),
                    ]
                  ),
                ),
              ),
            );
          }
        )
      )
    );
  }
}
