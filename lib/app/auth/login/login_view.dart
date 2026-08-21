import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:komutan/app/auth/login/login_controller.dart';
import 'package:komutan/utils/app_colors.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset("assets/images/login_bg.png", fit: BoxFit.fill, height: 300.h),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, const Color.from(alpha: 1, red: 0.196, green: 0.086, blue: 0.086).withOpacity(0.05)],
                ),
              ),
            ),
          ),

          /// 📱 MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(child: Image.asset("assets/images/login.png", fit: BoxFit.contain)),
                  ),

                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title
                        Text(
                          "Sign In",
                          style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C28)),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          "Login and enjoy quick delivery.",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),

                        SizedBox(height: 15.h),

                        Form(
                          key: controller.formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: controller.phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                validator: controller.validatePhone,
                                decoration: const InputDecoration(counterText: '', hintText: "Enter your phone number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.call)),
                              ),

                              SizedBox(height: 20.h),

                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  height: 55.h,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                    ),
                                    onPressed: controller.isLoading.value ? null : controller.login,
                                    child: controller.isLoading.value
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            "Sign In",
                                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // SizedBox(height: 30.h),

                        // SizedBox(
                        //   width: double.infinity,
                        //   height: 55.h,
                        //   child: ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColors.primary,
                        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        //       elevation: 0,
                        //     ),
                        //     onPressed: () {},
                        //     child: Text(
                        //       "Sign In",
                        //       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
