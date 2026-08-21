import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/data/models/dashboard_response.dart';
import 'package:komutan/data/services/ApiService.dart';
import 'package:komutan/data/services/auth_service.dart';
import 'package:komutan/utils/app_colors.dart';

class DashboardController extends GetxController {
  RxString selectedStatus = "Available".obs;
  RxInt currentIndex = 0.obs;

  final List<String> statuses = ["Available", "Busy", "Offline"];

  final ApiService _api = Get.find<ApiService>();
  final AuthService _auth = Get.find<AuthService>();

  final isLoading = false.obs;
  final Rx<DashboardStats> stats = DashboardStats.empty().obs;

  String get driverName => _auth.driver?.fullName ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }
                                                                                                
  Future<void> fetchDashboard() async {
    isLoading.value = true;
    try {
      final response = await _api.getDashboard();
      if (response.isOk && response.body?['success'] == true) {
        stats.value = DashboardStats.fromJson(response.body);
        print(response.body);
        if (stats.value.currentStatus.isNotEmpty) {
          selectedStatus.value = _uiStatusFor(stats.value.currentStatus);
        }
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to load dashboard', snackPosition: SnackPosition.TOP);
        print("jfdvhj ${response.body}");
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
      print("jfdvhj ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates the driver's status via `PATCH /driver/profile/status`, reverting 
  /// the local selection if the call fails.
  Future<void> changeStatus(String status) async {
    final previous = selectedStatus.value;
    if (previous == status) return;
    selectedStatus.value = status;

    try {
      final response = await _api.updateDriverStatus(_backendStatusFor(status));
      if (!(response.isOk && response.body?['success'] == true)) {
        selectedStatus.value = previous;
        print("jfdvhj ${response.body}");
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to update status', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      selectedStatus.value = previous;
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

  // Backend enum: available, on_trip, off_duty, inactive, offline.
  // UI only exposes three states, so "Busy" maps to on_trip and anything
  // else offline-ish collapses to "Offline".
  String _backendStatusFor(String uiStatus) {
    switch (uiStatus) {
      case 'Busy':
        return 'on_trip';
      case 'Offline':
        return 'offline';
      case 'Available':
      default:
        return 'available';
    }
  }

  String _uiStatusFor(String backendStatus) {
    switch (backendStatus) {
      case 'on_trip':
        return 'Busy';
      case 'available':
        return 'Available';
      case 'off_duty':
      case 'inactive':
      case 'offline':
        return 'Offline';
      default:
        return 'Available';
    }
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
