import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:komutan/data/services/ApiService.dart';
import 'package:komutan/data/services/auth_service.dart';
import 'package:komutan/data/services/push_service.dart';
import 'package:komutan/data/services/socket_service.dart';
import 'package:komutan/firebase_options.dart';
import 'package:komutan/routes/app_pages.dart';
import 'package:komutan/routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // must come first

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler); // register before runApp

  await GetStorage.init();
  Get.put(ApiService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(SocketService(), permanent: true);

  // Not awaited: the notification permission dialog must not block app start.
  unawaited(PushService.init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // your design size
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'LexendDeca'),
          initialRoute: Routes.splash,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
