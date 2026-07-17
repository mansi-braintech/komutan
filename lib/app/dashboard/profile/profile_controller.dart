import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/utils/app_colors.dart';

class ProfileController extends GetxController {
  final RxString name = 'Travis Barker'.obs;
  final RxString email = 'travisbarkar@example.com'.obs;
  final RxString phone = '+91 98765 43210'.obs;
  final RxString licenseNumber = 'DL-1420160012345'.obs;
  final RxString vehicleType = '20ft Container Truck'.obs;
  final RxString vehicleNumber = 'MH 12 AB 1234'.obs;
  final RxString vehicleModel = 'Tata LPT 1613'.obs;

  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Logged out', 'You have been logged out.',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
