import 'package:get/get.dart';
import 'package:komutan/app/auth/login/login_view.dart';
import 'package:komutan/app/auth/otp/send_otp.dart';
import 'package:komutan/app/dashboard/bottom/bottom_view.dart';
import 'package:komutan/app/dashboard/document/documents_page.dart';
import 'package:komutan/app/dashboard/home/home_view.dart';
import 'package:komutan/app/dashboard/profile/profile_page.dart';
import 'package:komutan/app/dashboard/trip/trips_screen.dart';
import 'package:komutan/app/splash/splash_binding.dart';
import 'package:komutan/app/splash/splash_view.dart';
import 'package:komutan/routes/routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.splash, page: () => SplashView(), binding: SplashBinding()),
    GetPage(name: Routes.login, page: () => LoginView()),
    GetPage(name: Routes.otp, page: () => OtpView()),
    GetPage(name: Routes.home, page: () => DashboardView()),
    GetPage(name: Routes.trip, page: () => TripsScreen()),
    GetPage(name: Routes.doc, page: () => DocumentsPage()),
    GetPage(name: Routes.profile, page: () => ProfilePage()),
    GetPage(name: Routes.bottom, page: () => NavBar()),
  ];
}
