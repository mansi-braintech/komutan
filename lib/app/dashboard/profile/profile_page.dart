import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/profile/profile_controller.dart';
import 'package:komutan/utils/app_colors.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _ProfileHeader(controller: controller),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'General',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 10),
                  _SettingsTile(icon: Icons.shield_outlined, title: 'License Number', subtitle: 'License: DL-1420160012345', onTap: () {}),

                  Divider(),

                  _SettingsTile(icon: Icons.local_shipping_outlined, title: 'Vehicle Details', subtitle: 'Tata LPT 1613 • MH 12 AB 1234', onTap: () {}),

                  Divider(),

                  _SettingsTile(icon: Icons.settings_outlined, title: 'App Settings', subtitle: 'Notifications, language, theme', onTap: () {}),

                  Divider(),

                  _SettingsTile(icon: Icons.help_outline_rounded, title: 'Help & Support', subtitle: 'FAQs, contact support', onTap: () {}),
                  const SizedBox(height: 16),
                  _LogoutButton(onTap: controller.logout),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileController controller;

  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.only(top: statusBarHeight + 8, left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // Profile is also shown as a bottom-nav tab (not a pushed
                  // route), so only pop if there's actually a route to pop.
                  
                  if (Navigator.of(context).canPop()) Get.back();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Color(0xFFECF0F4), borderRadius: BorderRadius.circular(30)),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.black),
                ),
              ),
              const Text(
                'Profile',
                style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.white, size: 20),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Avatar + name
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5, style: BorderStyle.solid),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: AppColors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.name.value,
                      style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 3),
                    Text(controller.email.value, style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Info pills
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.phone_outlined, text: controller.phone.value),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.credit_card_outlined, text: 'License: ${controller.licenseNumber.value}'),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.local_shipping_outlined, text: '${controller.vehicleType.value} • ${controller.vehicleNumber.value}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        // decoration: BoxDecoration(
        //   color: AppColors.white,
        //   borderRadius: BorderRadius.circular(12),
        //   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        // ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Color.fromARGB(255, 236, 220, 222), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            // const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'LOGOUT',
              style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
