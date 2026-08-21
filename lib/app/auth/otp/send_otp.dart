import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:komutan/app/auth/otp/otp_controller.dart';
import 'package:komutan/utils/app_colors.dart';

class OtpView extends StatelessWidget {
  OtpView({super.key});

  final OtpController controller = Get.put(OtpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 40.r,
                      width: 40.r,
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                Image.asset("assets/images/otp.png", height: 180.h, fit: BoxFit.contain),

                SizedBox(height: 15.h),

                Text(
                  "OTP Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C28)),
                ),

                SizedBox(height: 8.h),

                Text(
                  "We are Sending you an OTP to Verify Your\nPhone Number",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),

                SizedBox(height: 25.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Obx(
                      () => SizedBox(
                        width: 45.w,
                        height: 50.h,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: controller.errorText.value != null ? AppColors.primary : Colors.grey.shade400, width: 1.5)),
                          ),
                          child: TextField(
                            controller: controller.otpControllers[index],
                            focusNode: controller.focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(counterText: "", border: InputBorder.none, contentPadding: EdgeInsets.zero),
                            onChanged: (value) => controller.onChanged(index, value),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                Obx(
                  () => controller.errorText.value != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              controller.errorText.value!,
                              style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                            ),
                          ),
                        )
                      : SizedBox(height: 8.h),
                ),

                SizedBox(height: 15.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      "Edit Phone Number ?",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ),
                ),

                SizedBox(height: 25.h),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        elevation: 0,
                      ),
                      onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                      child: controller.isLoading.value
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              "Verified Mobile",
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 25.h),

                Obx(
                  () => GestureDetector(
                    onTap: controller.resendOtp,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "I Don't Receive a Code! ",
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        children: [
                          TextSpan(
                            text: controller.secondsRemaining.value > 0 ? "Resend in ${controller.secondsRemaining.value}s" : "Resend Code",
                            style: TextStyle(color: controller.secondsRemaining.value > 0 ? Colors.grey : AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
