import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;

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
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final phone = phoneController.text.trim();

      print(phone);

      // API Call Here

      Get.snackbar("Success", "OTP sent successfully", snackPosition: SnackPosition.BOTTOM);
      Get.toNamed(Routes.otp);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
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
