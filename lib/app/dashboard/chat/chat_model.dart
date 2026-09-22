class ChatMessage {
  final String id;
  final String text;
  final bool seen;
  final String senderId;
  final String? receiverId;
  final String? imageUrl;

  final String? msgByUserModel;

  final DateTime? createdAt;

  ChatMessage({required this.id, required this.text, required this.seen, required this.senderId, this.receiverId, this.imageUrl, this.msgByUserModel, this.createdAt});

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['imageUrl']?.toString();
    return ChatMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      text: (json['text'] ?? json['message'] ?? '').toString(),
      seen: json['seen'] == true,
      senderId: (json['msgByUserId'] ?? json['senderId'] ?? json['sender'] ?? json['from'] ?? '').toString(),
      receiverId: (json['receiver'] ?? json['receiverId'] ?? json['to'])?.toString(),
      imageUrl: (rawImageUrl != null && rawImageUrl.isNotEmpty) ? rawImageUrl : null,
      msgByUserModel: json['msgByUserModel']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['timestamp'] ?? '').toString()),
    );
  }

  bool isMine(String? currentUserId) {
    if (senderId.isNotEmpty) return currentUserId != null && currentUserId.isNotEmpty && senderId == currentUserId;
    return msgByUserModel == 'driver';
  }

  // static const String _uploadsBaseUrl = 'http://192.168.0.170:5300/images/';
  static const String _uploadsBaseUrl = 'https://komutanapi.etrueconcept.com/images/';

  /// Full displayable URL for [imageUrl], or null if there's no image.
  String? get fullImageUrl {
    if (!hasImage) return null;
    final img = imageUrl!;
    if (img.startsWith('http://') || img.startsWith('https://')) return img;
    return '$_uploadsBaseUrl$img';
  }
}
