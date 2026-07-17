import 'package:get/get.dart';
import 'package:komutan/routes/routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateNext();
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));

    // TODO: once real auth/session storage exists, check for a saved
    // token here and route to Routes.bottom if the driver is already
    // logged in. For now every launch goes through login -> OTP.
    Get.offAllNamed(Routes.login);
  }
}
