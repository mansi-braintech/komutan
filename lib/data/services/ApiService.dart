import 'dart:io';

import 'package:get/get.dart';

import 'auth_service.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'http://192.168.0.141:5200';
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

  Future<Response> getSignatures({required String shipmentId}) {
    return get('/api/v1/driver/signature/view?shipmentId=$shipmentId');
  }

  Future<Response> createPOD({required String shipmentId, required List<String> imagePaths}) async {
    final formData = FormData({'shipmentId': shipmentId});

    for (final path in imagePaths) {
      final file = File(path);

      if (!await file.exists()) {
        throw Exception('POD image file not found: $path');
      }

      final fileName = file.path.split(Platform.pathSeparator).last;

      final fileSize = await file.length();
            
      print(
        'POD image: $fileName '
        '(${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
      );

      final extension = fileName.split('.').last.toLowerCase();

      String? mimeType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;

        case 'png':
          mimeType = 'image/png';
          break;

        case 'webp':
          mimeType = 'image/webp';
          break;

        case 'gif':
          mimeType = 'image/gif';
          break;

        case 'avif':
          mimeType = 'image/avif';
          break;

        default:
          throw Exception('Unsupported image type: .$extension');
      }

      formData.files.add(MapEntry('images', MultipartFile(file, filename: fileName, contentType: mimeType)));
    }

    return post('/api/v1/driver/pod/create', formData, contentType: 'multipart/form-data');
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

  Future<Response> getMyDocuments() {
    return get('/api/v1/driver/get-my-document');
  }

  Future<Response> downloadDocument({required String source, required String id, required String fileName}) {
    return get(
      '/api/v1/driver/download-document'
      '?source=${Uri.encodeQueryComponent(source)}'
      '&id=${Uri.encodeQueryComponent(id)}'
      '&filename=${Uri.encodeQueryComponent(fileName)}',
    );
  }
}
