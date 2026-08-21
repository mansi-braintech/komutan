import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/data/services/ApiService.dart';

import '../../../data/models/auth_response.dart';
import '../../../routes/routes.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  final ApiService _api = Get.find<ApiService>();

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return 'Please enter valid 10 digit phone number';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final phone = phoneController.text.trim();
      final response = await _api.sendOtp(phone);

      if (response.isOk && response.body?['success'] == true) {
        final data = SendOtpResponse.fromJson(response.body);
        print(response.body);

        Get.snackbar("Success", response.body['message'] ?? 'OTP sent successfully', snackPosition: SnackPosition.TOP);

        Get.toNamed(Routes.otp, arguments: {"id": data.userId, "phone": phone});
      } else {
        Get.snackbar("Error", response.body?['message'] ?? 'Failed to send OTP', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
