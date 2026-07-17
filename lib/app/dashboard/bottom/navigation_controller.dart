import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/document/documents_page.dart';
import 'package:komutan/app/dashboard/home/home_view.dart';
import 'package:komutan/app/dashboard/profile/profile_page.dart';
import 'package:komutan/app/dashboard/trip/trips_screen.dart';
import 'package:komutan/utils/app_images.dart';

class NavBarController extends GetxController {
  /// Reactive variable to track selected index
  final currentIndex = 0.obs;

  /// Change bottom nav index
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  /// List of screens for navigation
  final List<Widget> screens = [DashboardView(), TripsScreen(), DocumentsPage(), ProfilePage()];

  /// Labels for bottom navigation
  final List<String> labels = const ['Home', 'Trip', 'Doc', 'Profile'];

  /// Icons for bottom navigation
  final List<String> iconPaths = [AppImages.home, AppImages.trip, AppImages.doc, AppImages.profile];

  /// Reset to Home tab
  void backToHome() {
    changeIndex(0);
  }
}
