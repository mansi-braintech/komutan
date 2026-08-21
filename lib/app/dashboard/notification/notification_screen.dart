import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/utils/app_colors.dart';

import 'notification_controller.dart';
import 'notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationController>() ? Get.find<NotificationController>() : Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Get.back()),
        title: const Text('Notifications'),
        actions: [
          Obx(
            () => controller.unreadCount.value > 0
                ? TextButton(onPressed: controller.markAllAsRead, child: const Text('Mark all read'))
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchNotifications(),
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.notifications.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No notifications yet', style: TextStyle(color: AppColors.textSecondary))),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _NotificationCard(notification: notification, onTap: () => controller.markAsRead(notification));
            },
          );
        }),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.white : AppColors.tagAssignedBg.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(color: notification.isRead ? Colors.transparent : AppColors.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title.isNotEmpty ? notification.title : 'Notification',
                    style: TextStyle(fontSize: 14, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(notification.message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  if (notification.shipmentOrderId != null) ...[
                    const SizedBox(height: 6),
                    Text('Order: ${notification.shipmentOrderId}', style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                  ],
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(_formatDate(notification.createdAt!), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${months[local.month]} ${local.year}, ${hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} $amPm';
  }
}
