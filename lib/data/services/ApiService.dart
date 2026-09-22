import 'dart:io';

import 'package:get/get.dart';

import 'auth_service.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    // httpClient.baseUrl = 'http://192.168.0.170:5300';
    httpClient.baseUrl = 'https://komutanapi.etrueconcept.com';
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';

      final token = Get.find<AuthService>().token;

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      return request;
    });

    super.onInit();
  }

  // ---- Auth ----

  Future<Response> sendOtp(String phoneNumber) {
    return post('/api/v1/driver/send', {"phoneNumber": phoneNumber});
  }

  Future<Response> verifyOtp({required String id, required String otp}) {
    return post('/api/v1/driver/verify', {"_id": id, "otp": otp});
  }

  // ---- Dashboard ----

  Future<Response> getDashboard() {
    return get('/api/v1/driver/dashboard');
  }

  // ---- Profile ----

  Future<Response> getProfile() {
    return get('/api/v1/driver/profile');
  }

  Future<Response> updateProfileImage(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;

    final fileSize = await imageFile.length();

    print('Uploading file: $fileName');
    print('Uploading size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

    final formData = FormData({'profileImage': MultipartFile(imageFile, filename: fileName)});

    return put('/api/v1/driver/profile/update', formData, contentType: 'multipart/form-data');
  }

  /// status must be one of: available, on_trip, off_duty, inactive, offline
  Future<Response> updateDriverStatus(String status) {
    return patch('/api/v1/driver/profile/status?status=$status', {});
  }

  // ---- Shipments / Trips ----

  Future<Response> getShipment() {
    return get('/api/v1/driver/shipment/get');
  }

  Future<Response> getAllShipments() {
    return get('/api/v1/driver/shipment/getall');
  }

  /// status must be one of: confirmed, rejected, pickup_done, in_transit, delivered, completed
  Future<Response> updateShipmentStatus({required String id, required String status, String? reason}) {
    final body = {"status": status, if (reason != null && reason.isNotEmpty) "reason": reason};
    return patch('/api/v1/driver/shipment/status?id=$id', body);
  }

  Future<Response> getShipmentTracking(String id) {
    return get('/api/v1/driver/shipment/tracking?id=$id');
  }

  Future<Response> getShipmentRoute(String id) {
    return get('/api/v1/driver/shipment/route?id=$id');
  }

  // ---- Proof of Delivery ----

  // ---- Proof of Delivery ----

  Future<Response> uploadSignature({required String shipmentId, required String image}) async {
    final file = File(image);

    if (!await file.exists()) {
      throw Exception('Signature file not found: $image');
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = await file.length();

    print(
      'Uploading signature: $fileName '
      '(${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
    );

    final formData = FormData({'shipmentId': shipmentId, 'image': MultipartFile(file, filename: fileName)});

    return post('/api/v1/driver/signature/upload', formData, contentType: 'multipart/form-data');
  }

  // Upload POD image and return uploaded image URL
  Future<String?> uploadPODImage({required String shipmentId, required String imagePath}) async {
    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception('POD image not found: $imagePath');
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = await file.length();

    print(
      'Uploading POD image: $fileName '
      '(${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
    );

    final formData = FormData({'shipmentId': shipmentId, 'image': MultipartFile(file, filename: fileName)});

    final response = await post('/api/v1/driver/signature/upload', formData, contentType: 'multipart/form-data');

    print('POD image upload response: ${response.body}');

    if (response.isOk && response.body?['success'] == true) {
      return response.body?['data']?['image']?.toString();
    }

    throw Exception(response.body?['message'] ?? 'Failed to upload POD image');
  }

  // Create POD using uploaded image URLs
  Future<Response> createPOD({required String shipmentId, required List<String> imageUrls}) {
    return post('/api/v1/driver/pod/create', {'shipmentId': shipmentId, 'images': imageUrls});
  }

  Future<Response> getPOD(String id) {
    return get('/api/v1/driver/pod/get?_id=$id');
  }
  // ---- Contact ----

  Future<Response> getContact(String shipmentId) {
    return get('/api/v1/driver/contact/get?shipmentId=$shipmentId');
  }

  Future<Response> getSupportContact() {
    return get('/api/v1/driver/contact/support');
  }

  // ---- Location ----

  Future<Response> updateDriverLocation({required double latitude, required double longitude}) {
    return patch('/api/v1/driver/location/update', {"latitude": latitude, "longitude": longitude});
  }

  // ---- Chat ----

  Future<Response> getChatHistory(String receiverId) {
    return get('/api/v1/driver/chat/history?receiver=$receiverId');
  }

  Future<Response> sendChatMessage({required String receiverId, required String text}) {
    return post('/api/v1/driver/chat/send', {"receiver": receiverId, "text": text});
  }

  // ---- Notifications ----

  Future<Response> getNotifications() {
    return get('/api/v1/driver/notification/get');
  }

  Future<Response> markNotificationRead(String ids) {
    return post('/api/v1/driver/notification/isRead', {"ids": ids});
  }

  // ---- Documents ----

  Future<Response> getMyDocuments({String? shipmentId}) {
    if (shipmentId != null && shipmentId.isNotEmpty) {
      return get('/api/v1/driver/get-my-document?shipmentId=${Uri.encodeQueryComponent(shipmentId)}');
    }
    return get('/api/v1/driver/get-my-document');
  }

  /// Fetches the raw file bytes for a document. `decoder` is set to hand
  /// back the raw response instead of trying to JSON-decode a binary
  /// PDF/image body, and `response.bodyBytes` on the result is what should
  /// be written to disk.
  Future<Response> downloadDocument({required String source, required String id, required String fileName}) {
    return get(
      '/api/v1/driver/download-document'
      '?source=${Uri.encodeQueryComponent(source)}'
      '&id=${Uri.encodeQueryComponent(id)}'
      '&filename=${Uri.encodeQueryComponent(fileName)}',
      decoder: (data) => data,
    );
  }
}
