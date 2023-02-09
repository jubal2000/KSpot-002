import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kspot_002/services/auth_service.dart';

import '../../data/app_data.dart';
import '../../utils/utils.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super (key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final auth = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!auth.isLoginCheckDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        auth.initUserSignIn();
      });
    }
    return SafeArea(
      top: false,
      child: Scaffold(
        body: showLogoLoadingPage(context)
      )
    );
  }
}