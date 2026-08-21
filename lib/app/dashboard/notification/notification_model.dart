class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final String? senderName;
  final String? senderProfileImage;
  final String? shipmentId;
  final String? shipmentOrderId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
    this.senderName,
    this.senderProfileImage,
    this.shipmentId,
    this.shipmentOrderId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final sender = json['senderdetail'] as Map<String, dynamic>?;
    final shipment = json['shipmentDetail'] as Map<String, dynamic>?;
    return AppNotification(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      senderName: sender?['fullName']?.toString(),
      senderProfileImage: sender?['profileImage']?.toString(),
      shipmentId: shipment?['_id']?.toString(),
      shipmentOrderId: shipment?['orderId']?.toString(),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      shipmentId: shipmentId,
      shipmentOrderId: shipmentOrderId,
    );
  }
}
