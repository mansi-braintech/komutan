import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/data/services/ApiService.dart';

import '../../../data/models/auth_response.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/routes.dart';

class OtpController extends GetxController {
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final isLoading = false.obs;
  final errorText = RxnString();
  final secondsRemaining = 30.obs;

  final ApiService _api = Get.find<ApiService>();
  final AuthService _auth = Get.find<AuthService>();

  late String _driverRefId; // the `userId` value returned by /send
  late String _phone;

  String get _otpCode => otpControllers.map((c) => c.text).join();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _driverRefId = args["id"] ?? '';
    _phone = args["phone"] ?? '';
    _startResendTimer();
  }

  void onChanged(int index, String value) {
    if (errorText.value != null) errorText.value = null;

    if (value.isNotEmpty && index < otpControllers.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

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
      final response = await _api.verifyOtp(id: _driverRefId, otp: code);

      if (response.isOk && response.body?['success'] == true) {
        final data = VerifyOtpResponse.fromJson(response.body);
        print(response.body);
        await _auth.saveSession(data);

        Get.offAllNamed(Routes.bottom);
      } else {
        errorText.value = response.body?['message'] ?? 'Invalid OTP';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
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

  Future<void> resendOtp() async {
    if (secondsRemaining.value > 0) return;

    for (final c in otpControllers) {
      c.clear();
    }
    errorText.value = null;
    focusNodes.first.requestFocus();

    try {
      final response = await _api.sendOtp(_phone);
      if (response.isOk && response.body?['success'] == true) {
        final data = SendOtpResponse.fromJson(response.body);
        print(response.body);
        _driverRefId = data.userId; // /send issues a fresh id each time
        Get.snackbar('OTP Sent', response.body['message'] ?? 'A new OTP has been sent to your phone', snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to resend OTP', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    }

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
