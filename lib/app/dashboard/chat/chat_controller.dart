import 'dart:async';

import 'package:get/get.dart';
import 'package:komutan/data/services/ApiService.dart';
import 'package:komutan/data/services/auth_service.dart';

import 'chat_model.dart';

class ChatController extends GetxController {
  final String receiverId;
  ChatController({required this.receiverId});

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;

  final ApiService _api = Get.find<ApiService>();

  /// The logged-in driver's own id, used to tell which bubbles are "mine".
  String? get currentUserId => Get.find<AuthService>().driver?.id;

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    // Poll for new messages while the chat screen is open. There's no
    // socket connection here, so this keeps the thread reasonably live.
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => fetchHistory(silent: true));
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  /// `GET /driver/chat/history` — returns the full thread, newest first.
  /// That ordering is kept as-is so a `reverse: true` ListView shows the
  /// newest message at the bottom without any extra sorting.
  Future<void> fetchHistory({bool silent = false}) async {
    if (receiverId.isEmpty) return;
    if (!silent) isLoading.value = true;
    try {
      final response = await _api.getChatHistory(receiverId);
      if (response.isOk && response.body?['success'] == true) {
        final list = (response.body['data'] as List?) ?? [];
        messages.assignAll(list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)));
      } else if (!silent) {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to load chat', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (!silent) Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// `POST /driver/chat/send` — sends a message, then reconciles with the
  /// backend's copy (for the real `_id`/`createdAt`) instead of trusting a
  /// locally-built optimistic message.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || receiverId.isEmpty || isSending.value) return;
    isSending.value = true;
    try {
      final response = await _api.sendChatMessage(receiverId: receiverId, text: trimmed);
      if (response.isOk && response.body?['success'] == true) {
        final data = response.body['data'] as Map<String, dynamic>?;
        if (data != null) {
          messages.insert(0, ChatMessage.fromJson(data));
        } else {
          await fetchHistory(silent: true);
        }
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to send message', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isSending.value = false;
    }
  }
}
