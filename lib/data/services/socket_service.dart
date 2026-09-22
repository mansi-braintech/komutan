import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'auth_service.dart';

/// Shared socket connection used for chat (and anything else moved off
/// REST in future). Registered permanent in main.dart; connect() is called
/// once a driver token exists (after OTP verify / on splash auto-login) and
/// disconnect() on logout.
class SocketService extends GetxService {
  // static const String _socketUrl = 'http://192.168.0.170:5300';
  static const String _socketUrl = 'https://komutanapi.etrueconcept.com';

  io.Socket? _socket;
  String? _connectedToken;

  final RxBool isConnected = false.obs;

  bool get isReady => _socket != null;

  /// Opens the connection authenticated with the current driver token.
  /// Safe to call more than once — it's a no-op if already connected with
  /// the same token, and reconnects if the token changed (e.g. new login).
  void connect() {
    final token = Get.isRegistered<AuthService>() ? Get.find<AuthService>().token : null;
    if (token == null || token.isEmpty) return;

    if (_socket != null) {
      if (_connectedToken == token && _socket!.connected) return;
      _socket!.dispose();
      _socket = null;
    }

    _connectedToken = token;
    _socket = io.io(_socketUrl, io.OptionBuilder().setTransports(['websocket']).setAuth({'token': token}).setExtraHeaders({'Authorization': 'Bearer $token'}).disableAutoConnect().build());

    _socket!.onConnect((_) {
      isConnected.value = true;
      // ignore: avoid_print
      print('[socket] connected to $_socketUrl');
    });
    _socket!.onDisconnect((reason) {
      isConnected.value = false;
      // ignore: avoid_print
      print('[socket] disconnected: $reason');
    });
    _socket!.onConnectError((err) {
      isConnected.value = false;
      // ignore: avoid_print
      print('[socket] connect error: $err');
    });
    _socket!.onError((err) {
      // ignore: avoid_print
      print('[socket] error: $err');
    });

    // ignore: avoid_print
    print('[socket] connecting to $_socketUrl ...');
    _socket!.connect();
  }

  /// Closes the connection and drops all listeners. Call this on logout so
  /// the next login starts a clean socket with no stale handlers.
  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _connectedToken = null;
    isConnected.value = false;
  }

  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  void on(String event, void Function(dynamic data) handler) {
    _socket?.on(event, handler);
  }

  /// Removes a specific handler. Prefer this over `off(event)` when more
  /// than one controller might listen on the same event name.
  void offHandler(String event, void Function(dynamic data) handler) {
    _socket?.off(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
