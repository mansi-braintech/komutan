import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFBA0E22);
  static const Color secondary = Color(0xFF2463EB);
  static const Color primaryLight = Color(0xFFEF5350);
  static const Color accent = Color(0xFF1565C0);
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF10B981);
  static const Color assigned = Color(0xFF1565C0);
  static const Color inTransit = Color(0xFF9333EA);
  static const Color delivered = Color(0xFF2E7D32);
  static const Color warning = Color(0xFF92400E);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color pickupGreen = Color(0xFF43A047);
  static const Color deliveryRed = Color(0xFFE53935);
  static const Color timelinePending = Color(0xFFBDBDBD);
  static const Color cardBg = Colors.white;
  static const Color navBg = Colors.white;
  static const Color tagAssignedBg = Color(0xFFE3F2FD);
  static const Color tagAssignedText = Color(0xFF1565C0);
  static const Color tagInTransitBg = Color.fromARGB(255, 234, 223, 243);
  static const Color tagInTransitText = Color(0xFFE65100);
  static const Color tagDeliveredBg = Color(0xFFE8F5E9);
  static const Color tagDeliveredText = Color(0xFF10B981);
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color darkgrey = Color(0xFF51627B);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: false,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14),
    ),
  );
}
