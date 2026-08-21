import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/bottom/navigation_controller.dart';
import 'package:komutan/utils/app_colors.dart';

class NavBar extends StatelessWidget {
  NavBar({super.key});

  final NavBarController controller = Get.put(NavBarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return controller.screens[controller.currentIndex.value];
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: controller.currentIndex.value,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF7C8091),
          showUnselectedLabels: true,
          onTap: controller.changeIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,

          items: List.generate(controller.labels.length, (index) {
            return BottomNavigationBarItem(
              backgroundColor: AppColors.white,
              icon: Image.asset(controller.iconPaths[index], height: 26, width: 26, color: controller.currentIndex.value == index ? AppColors.primary : const Color(0xFF7C8091)),
              label: controller.labels[index],
            );
          }),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.primary),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: const Color(0xFF7C8091)),
        ),
      ),
    );
  }
}
