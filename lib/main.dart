import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flash/flash.dart';
import 'package:kspot_002/services/auth_service.dart';
import 'package:kspot_002/services/cache_service.dart';
import 'package:kspot_002/view/home/home_screen.dart';
import 'package:kspot_002/view/intro/splash_screen.dart';
import 'package:kspot_002/view/event/event_edit_input_screen.dart';
import 'package:kspot_002/view/event/event_edit_screen.dart';
import 'package:kspot_002/view/sign/sign_in_screen.dart';
import 'package:kspot_002/view/sign/sign_up_screen.dart';
import 'package:kspot_002/view_model/event_edit_view_model.dart';
import 'package:provider/provider.dart';
import '/view/intro/intro_screen.dart';
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
  final cache = await Get.putAsync(() => CacheService().init());
  final api   = await Get.putAsync(() => ApiService().init());
  final fire  = await Get.putAsync(() => FirebaseService().init());
  final auth  = await Get.putAsync(() => AuthService().init());
  final local = await Get.putAsync(() => LocalService().init());

  api.initFirebase();

  Future getInfoData() async {
    return api.getInfoData();
  }

  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => AppData.themeNotifier,
    child: FutureBuilder(
      future: getInfoData(),
      builder: (context, snapshot) {
        unFocusAll(context);
        if (snapshot.hasData) {
          AppData.initStartInfo(snapshot.data as JSON);
          LOG('--> MyApp Start : ${AppData.userInfo.id}');
          return MyApp();
        } else {
          return Container();
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
    AppData.setStatusBarColor(true);

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
            // theme: lightTheme,
            // The Mandy red, dark theme.
            // darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
            // Use dark or light theme based on system setting.
            // themeMode: ThemeMode.dark,
            // builder: (context, _) {
            //   var child = _!;
            //   final navigatorKey = GlobalKey<NavigatorState>();
            //   // final navigatorKey = child.key as GlobalKey<NavigatorState>;
            //   child = Toast(
            //     navigatorKey: navigatorKey,
            //     alignment: Alignment(0, 0.8),
            //     child: child,
            //   );
            //   return child;
            // },
            initialRoute: Routes.SPLASH,
            getPages: [
              GetPage(
                name: Routes.SPLASH,
                page: () => SplashScreen(),
              ),
              GetPage(
                name: Routes.INTRO,
                page: () => IntroScreen(),
              ),
              GetPage(
                name: Routes.HOME,
                page: () => HomeScreen(),
              ),
              GetPage(
                name: Routes.SIGN_IN,
                page: () => SignInScreen(),
              ),
              GetPage(
                name: Routes.SIGN_UP,
                page: () => SignUpScreen(),
              ),
              GetPage(
                name: Routes.EVENT_EDIT,
                page: () => EventEditScreen(),
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
