import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flash/flash.dart';
import 'package:kspot_002/view/app/app.dart';
import '/view/intro/intro.dart';
import 'view_model/app_view_model.dart';
import '/services/api_service.dart';
import '/services/local_service.dart';
import '/services/firebase_service.dart';
import 'data/routes.dart';
import 'data/themes.dart';
import 'data/utils.dart';
import 'data/words.dart';

Future<void> main() async {
  await GetStorage.init();
  await Get.putAsync(() => FirebaseService().init());
  await Get.putAsync(() => ApiService().init());
  await Get.putAsync(() => LocalService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
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
      initialRoute: Routes.INTRO,
      getPages: [
        GetPage(
          name: Routes.INTRO,
          page: () => Intro(),
        ),
        GetPage(
          name: Routes.APP,
          page: () => App(),
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
    );
  }
}
