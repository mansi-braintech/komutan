import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komutan/utils/app_colors.dart';

import 'chat_controller.dart';
import 'chat_model.dart';

class ChatScreen extends StatelessWidget {
  final String receiverId;
  final String receiverName;
  const ChatScreen({super.key, required this.receiverId, required this.receiverName});

  @override
  Widget build(BuildContext context) {
    // Re-create the controller for this receiver every time the screen
    // opens, so switching between trips/customers never shows a stale
    // thread or leaves old socket listeners registered in the background.
    if (Get.isRegistered<ChatController>(tag: receiverId)) {
      Get.delete<ChatController>(tag: receiverId, force: true);
    }
    final controller = Get.put(ChatController(receiverId: receiverId), tag: receiverId);
    final textController = TextEditingController();

    void handleSend() {
      final text = textController.text;
      if (text.trim().isEmpty) return;
      controller.sendMessage(text);
      textController.clear();
    }

    Future<void> handlePickImage() async {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 1600, maxHeight: 1600);
      if (picked == null) return;
      controller.sendImage(File(picked.path));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Get.back()),
        title: Text(receiverName.isNotEmpty ? receiverName : 'Chat'),
      ),
      body: receiverId.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Chat isn\'t available for this trip yet.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.messages.isEmpty) {
                      return const Center(child: Text('No messages yet. Say hello!', style: TextStyle(color: AppColors.textSecondary)));
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        final isMe = message.isMine(controller.currentUserId);
                        return _ChatBubble(message: message, isMe: isMe);
                      },
                    );
                  }),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    decoration: const BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.divider))),
                    child: Row(
                      children: [
                        Obx(
                          () => IconButton(
                            onPressed: controller.isSendingImage.value ? null : handlePickImage,
                            icon: controller.isSendingImage.value
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: textController,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            ),
                            onSubmitted: (_) => handleSend(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(
                          () => Material(
                            color: AppColors.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: controller.isSending.value ? null : handleSend,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: controller.isSending.value
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.send, size: 18, color: Colors.white),
                              ),
                            ),
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: isMe ? null : Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  message.fullImageUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(width: 200, height: 150, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 200,
                    height: 150,
                    color: AppColors.background,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                  ),
                ),
              ),
              if (message.text.isNotEmpty) const SizedBox(height: 6),
            ],
            if (message.text.isNotEmpty) Text(message.text, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14)),
            if (message.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(_formatTime(message.createdAt!), style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} $amPm';
  }
}
