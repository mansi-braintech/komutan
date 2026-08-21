import 'package:get/get.dart';
import 'package:komutan/data/services/ApiService.dart';

import 'notification_model.dart';

class NotificationController extends GetxController {
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final isLoading = false.obs;

  final ApiService _api = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// `GET /driver/notification/get` — list + unread count, used both for the
  /// notification screen and for the bell badge shown across the app.
  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final response = await _api.getNotifications();
      if (response.isOk && response.body?['success'] == true) {
        final data = response.body['data'] ?? {};
        final list = (data['getData'] as List?) ?? [];
        notifications.assignAll(list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
        unreadCount.value = (data['unreadCount'] as num?)?.toInt() ?? notifications.where((n) => !n.isRead).length;
      } else if (!silent) {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to load notifications', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (!silent) Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// `POST /driver/notification/isRead` — marks a single notification read
  /// and updates local state/badge optimistically.
  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    try {
      final response = await _api.markNotificationRead(notification.id);
      if (response.isOk && response.body?['success'] == true) {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) notifications[index] = notification.copyWith(isRead: true);
        if (unreadCount.value > 0) unreadCount.value--;
      }
    } catch (_) {
      // Non-fatal: leave state as-is if marking read fails.
    }
  }

  /// Marks every currently-unread notification read, one at a time (the API
  /// only documents marking a single id, so this avoids assuming batch support).
  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    for (final notification in unread) {
      await markAsRead(notification);
    }
  }
}
