import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:komutan/data/services/auth_service.dart';
import 'package:komutan/data/services/socket_service.dart';

import 'chat_model.dart';

/// Fully socket-driven chat for one open thread — no REST calls at all,
/// images included:
///
/// CHAT OPEN   -> emit getAllMessages -> listen allMessagesLoaded
/// SEND TEXT   -> emit newMessage     -> listen message / newMessage
/// SEND IMAGE  -> emit newMessage with base64 image data (see `sendImage`)
class ChatController extends GetxController {
  final String receiverId;
  ChatController({required this.receiverId});

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final isSendingImage = false.obs;

  final SocketService _socket = Get.find<SocketService>();

  /// The logged-in driver's own id, used to tell which bubbles are "mine".
  String? get currentUserId => Get.isRegistered<AuthService>() ? Get.find<AuthService>().driver?.id : null;

  @override
  void onInit() {
    super.onInit();
    // ignore: avoid_print
    print('[chat] onInit receiverId=$receiverId currentUserId=$currentUserId');
    if (receiverId.isEmpty) return;

    // Defensive: normally the socket is already connected from login/splash,
    // but if this screen is reached without that flow having run (hot
    // restart onto a saved session, deep link, etc.) there'd be no socket
    // instance yet and every emit/on below would silently do nothing.
    // connect() is idempotent — a no-op if already connected with this token.
    _socket.connect();

    _socket.on('allMessagesLoaded', _handleAllMessagesLoaded);
    _socket.on('message', _handleIncomingMessage);
    _socket.on('newMessage', _handleIncomingMessage);

    fetchHistory();
  }

  /// Emits `getAllMessages`; the server replies on `allMessagesLoaded`.
  /// Payload keys match the real server contract exactly, "reciever" typo
  /// included — confirmed from the web client's live socket frames.
  void fetchHistory() {
    if (receiverId.isEmpty) return;
    final me = currentUserId;
    if (me == null || me.isEmpty) {
      // ignore: avoid_print
      print('[chat] fetchHistory skipped — no logged-in driver id yet');
      return;
    }
    isLoading.value = true;
    // ignore: avoid_print
    print('[chat] emit getAllMessages sender=$me reciever=$receiverId');
    _socket.emit('getAllMessages', {"sender": me, "reciever": receiverId});
  }

  void _handleAllMessagesLoaded(dynamic data) {
    // ignore: avoid_print
    print('[chat] allMessagesLoaded raw=$data');
    isLoading.value = false;
    final list = _extractList(data);
    messages.assignAll(list.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e as Map))));
    _sortNewestFirst();
  }

  /// The server doesn't guarantee message order (confirmed live — its list
  /// isn't reliably chronological), so sort by `createdAt` ourselves every
  /// time the list changes. Newest-first, so a `reverse: true` ListView
  /// shows the newest message at the bottom, WhatsApp-style. Messages
  /// without a timestamp sort to the oldest position rather than jumping
  /// to the top/bottom unpredictably.
  void _sortNewestFirst() {
    messages.sort((a, b) {
      final ta = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta);
    });
  }

  /// Handles both the `message` ack for a message this driver just sent and
  /// any `newMessage`/`message` push for a message the other side sent.
  /// Confirmed from live server frames: this can arrive as either a single
  /// object OR a list of one-or-more message objects — items never carry a
  /// receiver, only optionally `msgByUserId` (the shipper) or nothing at all
  /// plus `msgByUserModel: "driver"` (the driver's own send). Since a
  /// ChatController only lives while its own thread's screen is open, any
  /// push it receives is treated as belonging to that thread.
  void _handleIncomingMessage(dynamic data) {
    // ignore: avoid_print
    print('[chat] incoming message raw=$data');
    final items = data is List ? data : (data is Map ? [data] : const []);
    var changed = false;
    for (final item in items) {
      if (item is! Map) continue;
      final message = ChatMessage.fromJson(Map<String, dynamic>.from(item));
      if (message.id.isNotEmpty && messages.any((m) => m.id == message.id)) continue;
      messages.insert(0, message);
      changed = true;
    }
    if (changed) _sortNewestFirst();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) return (data['message'] ?? data['data'] ?? data['messages'] ?? []) as List? ?? [];
    return [];
  }

  /// Emits `newMessage`; the confirmed/saved copy comes back on `message`.
  /// There's no per-send ack in this flow, so `isSending` is just a short
  /// debounce to stop accidental double-taps rather than a real round-trip.
  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || receiverId.isEmpty || isSending.value) return;
    final me = currentUserId;
    if (me == null || me.isEmpty) {
      // ignore: avoid_print
      print('[chat] sendMessage skipped — no logged-in driver id yet');
      return;
    }
    isSending.value = true;
    // ignore: avoid_print
    print('[chat] emit newMessage sender=$me reciever=$receiverId text=$trimmed');
    _socket.emit('newMessage', {"sender": me, "reciever": receiverId, "text": trimmed});
    Future.delayed(const Duration(milliseconds: 400), () => isSending.value = false);
  }

  /// Reads the picked file, base64-encodes it, and emits it directly in a
  /// `newMessage` payload — no REST call, no upload step. The server
  /// (confirmed from live traffic) already stores incoming images and
  /// hands back a generated filename in `imageUrl` on every subsequent
  /// `allMessagesLoaded`/`allUserConversations` push, so it clearly does
  /// its own file handling — it just needs the bytes to arrive over the
  /// socket instead of REST.
  ///
  /// GUESSED payload shape — the field/key names below aren't confirmed
  /// against real traffic (no outgoing image frame has been captured
  /// yet). Adjust once you see what the web client actually sends when
  /// you fire an image message there and check the socket Messages tab.
  Future<void> sendImage(File imageFile) async {
    if (receiverId.isEmpty || isSendingImage.value) return;
    final me = currentUserId;
    if (me == null || me.isEmpty) {
      // ignore: avoid_print
      print('[chat] sendImage skipped — no logged-in driver id yet');
      return;
    }

    isSendingImage.value = true;
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file not found: ${imageFile.path}');
      }
      final bytes = await imageFile.readAsBytes();
      final base64Data = base64Encode(bytes);
      final fileName = imageFile.path.split(Platform.pathSeparator).last;

      // ignore: avoid_print
      print('[chat] emit newMessage (image) sender=$me reciever=$receiverId fileName=$fileName bytes=${bytes.length}');
      _socket.emit('newMessage', {
        "sender": me,
        "reciever": receiverId,
        "text": "",
        "imageUrl": base64Data,
        "fileName": fileName,
      });
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('[chat] sendImage error: $e');
      print(stackTrace);
      Get.snackbar('Error', 'Unable to send image', snackPosition: SnackPosition.TOP);
    } finally {
      isSendingImage.value = false;
    }
  }

  @override
  void onClose() {
    _socket.offHandler('allMessagesLoaded', _handleAllMessagesLoaded);
    _socket.offHandler('message', _handleIncomingMessage);
    _socket.offHandler('newMessage', _handleIncomingMessage);
    super.onClose();
  }
}
