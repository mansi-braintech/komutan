import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komutan/app/dashboard/bottom/navigation_controller.dart';
import 'package:komutan/app/dashboard/home/home_controller.dart';
import 'package:komutan/app/dashboard/trip/trip_controller.dart';
import 'package:komutan/data/models/auth_response.dart';
import 'package:komutan/data/services/ApiService.dart';
import 'package:komutan/data/services/auth_service.dart';
import 'package:komutan/routes/routes.dart';
import 'package:komutan/utils/app_colors.dart';

class ProfileController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthService _auth = Get.find<AuthService>();

  final isLoading = false.obs;
  final isUploadingImage = false.obs;
  final Rx<DriverModel?> driver = Rx<DriverModel?>(null);

  String get name => driver.value?.fullName ?? '';
  String get email => driver.value?.email ?? '';
  String get phone => driver.value == null ? '' : '${driver.value!.countryCode} ${driver.value!.phoneNumber}';
  String get licenseNumber => driver.value?.licenseNumber ?? '';
  String get companyName => driver.value?.companyName ?? '';

  // Adjust the path prefix below to wherever the backend actually serves
  // uploaded files from (e.g. '/uploads/'). The API only returns the
  // filename, not a full URL.
  String? get profileImageUrl {
    final img = driver.value?.profileImage;
    if (img == null || img.isEmpty) return null;
    return img;
  }

  @override
  void onInit() {
    super.onInit();
    driver.value = _auth.driver;
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _api.getProfile();
      if (response.isOk && response.body?['success'] == true) {
        final data = DriverModel.fromJson(response.body['data']);
        driver.value = data;
        print(response.body);
        await _auth.updateDriver(data);
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to load profile', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }                                                                                             
  }

  Future<void> updateProfileImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 1200, maxHeight: 1200);
 
    if (picked == null) return;

    final imageFile = File(picked.path);

    final fileSize = await imageFile.length();

    print('========================================');
    print('Profile image upload');
    print('Path: ${imageFile.path}');
    print('Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
    print('Size: $fileSize bytes');
    print('========================================');

    isUploadingImage.value = true;

    try {
      final response = await _api.updateProfileImage(imageFile);

      print('Profile image response: ${response.body}');

      if (response.isOk && response.body?['success'] == true) {
        final data = DriverModel.fromJson(response.body['data']);

        driver.value = data;

        await _auth.updateDriver(data);

        Get.snackbar('Success', 'Profile photo updated', snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to update photo', snackPosition: SnackPosition.TOP);
      }
    } catch (e, stackTrace) {
      print('Profile image upload error: $e');
      print(stackTrace);

      Get.snackbar('Error', 'Unable to upload profile photo', snackPosition: SnackPosition.TOP);
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Fetches and displays the support contact via `GET /driver/contact/support`.
  Future<void> contactSupport() async {
    try {
      final response = await _api.getSupportContact();
      if (response.isOk && response.body?['success'] == true) {
        final data = response.body['data'] ?? {};
        Get.defaultDialog(
          title: (data['name'] ?? 'Support').toString(),
          middleText: '${data['countryCode'] ?? ''} ${data['phoneNumber'] ?? ''}\n${data['email'] ?? ''}'.trim(),
          textConfirm: 'Close',
          onConfirm: () => Get.back(),
        );
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to load support contact', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

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
            onPressed: () async {
              await _auth.logout();
              // Force-remove the dashboard/trip/nav controllers so the next
              // login starts clean: fresh dashboard data and the Home tab
              // selected, instead of whatever was cached from this session.
              if (Get.isRegistered<NavBarController>()) Get.delete<NavBarController>(force: true);
              if (Get.isRegistered<DashboardController>()) Get.delete<DashboardController>(force: true);
              if (Get.isRegistered<TripController>()) Get.delete<TripController>(force: true);
              Get.offAllNamed(Routes.login);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
