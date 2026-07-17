import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';

class OtpController extends GetxController {
  /// One controller/focus node per OTP digit box.
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final isLoading = false.obs;
  final errorText = RxnString();
  final secondsRemaining = 30.obs;

  String get _otpCode => otpControllers.map((c) => c.text).join();

  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }

  /// Handles auto-advance / auto-back-focus as the driver types each digit.
  void onChanged(int index, String value) {
    if (errorText.value != null) errorText.value = null;

    if (value.isNotEmpty && index < otpControllers.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Auto-submit once all 6 digits are filled in.
    if (_otpCode.length == 6) {
      FocusManager.instance.primaryFocus?.unfocus();
      verifyOtp();
    }
  }

  Future<void> verifyOtp() async {
    final code = _otpCode;

    if (code.length != 6) {
      errorText.value = 'Please enter the complete 6-digit OTP';
      return;
    }

    isLoading.value = true;
    try {
      // API Call Here (verify code with backend)
      await Future.delayed(const Duration(seconds: 1));

      // Clear the whole stack so the driver can't navigate "back" into
      // login/OTP with the back button once they're inside the app.
      Get.offAllNamed(Routes.bottom);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendTimer() {
    secondsRemaining.value = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (isClosed) return false;
      if (secondsRemaining.value <= 0) return false;
      secondsRemaining.value--;
      return secondsRemaining.value > 0;
    });
  }

  void resendOtp() {
    if (secondsRemaining.value > 0) return;

    for (final c in otpControllers) {
      c.clear();
    }
    errorText.value = null;
    focusNodes.first.requestFocus();

    // API Call Here (resend code)
    Get.snackbar('OTP Sent', 'A new OTP has been sent to your phone', snackPosition: SnackPosition.BOTTOM);
    _startResendTimer();
  }

  @override
  void onClose() {
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
