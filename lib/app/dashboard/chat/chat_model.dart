class ChatMessage {
  final String id;
  final String text;
  final bool seen;
  final String senderId; // `msgByUserId` from the API
  final DateTime? createdAt;

  ChatMessage({required this.id, required this.text, required this.seen, required this.senderId, this.createdAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['_id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      seen: json['seen'] == true,
      senderId: (json['msgByUserId'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
