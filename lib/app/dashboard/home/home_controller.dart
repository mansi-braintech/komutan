import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/utils/app_colors.dart';

class DashboardController extends GetxController {
  RxString selectedStatus = "Available".obs;
  RxInt currentIndex = 0.obs;

  final List<String> statuses = ["Available", "Busy", "Offline"];

  void changeStatus(String status) {
    selectedStatus.value = status;
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Available":
        return Colors.green;
      case "Busy":
        return Colors.orange;
      case "Offline":
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }
}
