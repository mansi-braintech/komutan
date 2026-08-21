import 'package:get/get.dart';
import 'package:komutan/data/services/auth_service.dart';
import 'package:komutan/routes/routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateNext();
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final auth = Get.find<AuthService>();
    Get.offAllNamed(auth.isLoggedIn ? Routes.bottom : Routes.login);
  }
}
