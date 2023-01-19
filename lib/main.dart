import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flash/flash.dart';
import 'package:kspot_002/view/app/app.dart';
import 'package:kspot_002/view/main_event/main_event_edit.dart';
import 'package:kspot_002/view/sign_up/sign_up.dart';
import 'package:provider/provider.dart';
import '/view/intro/intro.dart';
import 'data/app_data.dart';
import 'data/theme_manager.dart';
import 'view_model/app_view_model.dart';
import '/services/api_service.dart';
import '/services/local_service.dart';
import '/services/firebase_service.dart';
import 'data/routes.dart';
import 'data/themes.dart';
import 'utils/utils.dart';
import 'data/words.dart';

Future<void> main() async {
  await GetStorage.init();
  await Get.putAsync(() => FirebaseService().init());
  await Get.putAsync(() => ApiService().init());
  await Get.putAsync(() => LocalService().init());

  final api = Get.find<ApiService>();

  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(),
    child: FutureBuilder(
      future: api.getInfoData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          AppData.infoData = snapshot.data as JSON;
          LOG('--> infoData : ${AppData.infoData['customField']}');
          return MyApp();
        } else {
          return showLogoLoadingPage(context);
        }
      }
    )
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Make Fullscreen Mode..
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,/* set Status bar icons color in Android devices.*/
    ));

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: ((context, child) {
        return Consumer<ThemeNotifier>(
          builder: (context, theme, _) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            translations: Words(), // 번역들
            locale: Get.deviceLocale,
            fallbackLocale: Locale('en', 'US'), // 잘못된 지역이 선택된 경우 복구될 지역을 지정
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            theme: theme.getTheme(),
            // darkTheme: darkTheme,
            // themeMode: ThemeMode.system,
            builder: (context, _) {
              var child = _!;
              final navigatorKey = GlobalKey<NavigatorState>();
              // final navigatorKey = child.key as GlobalKey<NavigatorState>;
              child = Toast(
                navigatorKey: navigatorKey,
                alignment: Alignment(0, 0.8),
                child: child,
              );
              return child;
            },
            // initialRoute: AppData.loginInfo.loginId.isEmpty ? Routes.INTRO : Routes.APP,
            initialRoute: Routes.EVENT_EDIT,
            getPages: [
              GetPage(
                name: Routes.INTRO,
                page: () => Intro(),
              ),
              GetPage(
                name: Routes.APP,
                page: () => App(),
              ),
              GetPage(
                name: Routes.SIGNUP,
                page: () => SignUp(),
              ),
              GetPage(
                name: Routes.EVENT_EDIT,
                page: () => MainEventEdit(),
              ),
              // GetPage(
              //   name: Routes.MAP_SCREEN,
              //   page: () => MapScreen(),
              //   arguments: JSON,
              //   binding: BindingsBuilder(
              //         () => {Get.put(MapScreenController())},
              //   ),
              // ),
              ],
            ),
          );
        }
      )
    );
  }
}
