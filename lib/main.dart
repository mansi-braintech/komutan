import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:komutan/data/services/ApiService.dart';
import 'package:komutan/data/services/auth_service.dart';
import 'package:komutan/routes/app_pages.dart';
import 'package:komutan/routes/routes.dart';

// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ApiService(), permanent: true);
  Get.put(AuthService(), permanent: true);
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
