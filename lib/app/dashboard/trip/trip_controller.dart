import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komutan/app/dashboard/trip/trip_model.dart';
import 'package:komutan/data/services/ApiService.dart';
import 'package:url_launcher/url_launcher.dart';

class TripController extends GetxController {
  final RxList<TripModel> trips = <TripModel>[].obs;
  final Rx<TripModel?> selectedTrip = Rx<TripModel?>(null);
  final RxInt selectedTabIndex = 0.obs;
  final RxInt bottomNavIndex = 1.obs;
  final isLoading = false.obs;
  final isUpdatingStatus = false.obs;
  final isSubmittingPOD = false.obs;
  final isPickingPhoto = false.obs;

  // Proof of delivery — local file paths of images picked from the gallery.
  final RxList<String> deliveryPhotos = <String>[].obs;
  final RxBool hasSignature = false.obs;
  final Rx<String?> signaturePath = Rx<String?>(null);

  final ImagePicker _picker = ImagePicker();

  // Customer contact fetched via `GET /driver/contact/get`
  final Rx<Map<String, dynamic>?> customerContact = Rx<Map<String, dynamic>?>(null);

  final ApiService _api = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    isLoading.value = true;
    try {
      final response = await _api.getAllShipments();
      if (response.isOk && response.body?['success'] == true) {
        final list = (response.body['data'] as List?) ?? [];
        print(response.body);
        trips.assignAll(list.map((e) => TripModel.fromJson(e as Map<String, dynamic>)));
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to load trips', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  List<TripModel> get filteredTrips {
    switch (selectedTabIndex.value) {
      case 1:
        return trips.where((t) => t.status == TripStatus.inTransit).toList();
      case 2:
        return trips.where((t) => t.status == TripStatus.delivered).toList();
      default:
        return trips;
    }
  }

  void selectTrip(TripModel trip) {
    selectedTrip.value = trip;
    customerContact.value = null;
    // Don't hit the tracking API just for opening the trip. Only refresh
    // tracking for trips that have already been started at least once —
    // `advanceTimeline()` fetches tracking itself right after each status
    // update (including the first "Start Trip" press), so a freshly
    // assigned, not-yet-started trip shouldn't call the API here at all.
    if (trip.id.isNotEmpty && trip.timeline.any((e) => e.completed)) {
      fetchTracking(trip.id);
    }
  }

  /// Refreshes the selected trip's timeline from `GET /driver/shipment/tracking`,
  /// which reflects the driver's real per-step progress on the backend.
  Future<void> fetchTracking(String shipmentId) async {
    try {
      final response = await _api.getShipmentTracking(shipmentId);
      if (response.isOk && response.body?['success'] == true) {
        final data = response.body['data'] ?? {};
        print(response.body);
        final timeline = (data['timeline'] as List?) ?? [];
        if (timeline.isNotEmpty && selectedTrip.value?.id == shipmentId) {
          selectedTrip.value!.timeline = TripModel.timelineFromTracking(timeline);
          selectedTrip.refresh();
        }
      }
    } catch (_) {
      // Non-fatal: keep the locally inferred timeline if tracking is unavailable.
    }
  }

  /// "Navigate" on Trip Detail — opens the pickup → delivery route in the
  /// native Google Maps app (falls back to the browser if Maps isn't
  /// installed). Google Maps draws the driving route/polyline itself once
  /// origin and destination are given, so no in-app map or API key call is
  /// needed here. Works the same on Android and iOS via url_launcher.
  Future<void> fetchRoute() async {
    final trip = selectedTrip.value;
    if (trip == null) return;

    String pickupAddress = trip.pickupAddress;
    String deliveryAddress = trip.deliveryAddress;

    // Best-effort: refresh with the latest addresses from the backend
    // (`GET /driver/shipment/route`) before opening Maps.
    if (trip.id.isNotEmpty) {
      try {
        final response = await _api.getShipmentRoute(trip.id);
        if (response.isOk && response.body?['success'] == true) {
          final data = response.body['data'] ?? {};
          final pickup = (data['pickup']?['address'] ?? '').toString();
          final delivery = (data['delivery']?['address'] ?? '').toString();
          if (pickup.isNotEmpty) pickupAddress = pickup;
          if (delivery.isNotEmpty) deliveryAddress = delivery;
        }
      } catch (_) {
        // Non-fatal — fall back to the trip's own address fields.
      }
    }

    if (pickupAddress.isEmpty || deliveryAddress.isEmpty) {
      Get.snackbar('Route unavailable', 'Pickup or delivery address is missing for this trip', snackPosition: SnackPosition.TOP);
      return;
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'origin': pickupAddress, 'destination': deliveryAddress, 'travelmode': 'driving'});

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open Google Maps', snackPosition: SnackPosition.TOP);
    }
  }

  /// Fetches the customer contact for the selected trip
  /// (`GET /driver/contact/get`) and shows it to the driver.
  Future<void> fetchContact() async {
    final trip = selectedTrip.value;
    if (trip == null || trip.id.isEmpty) return;

    try {
      final response = await _api.getContact(trip.id);

      if (response.isOk && response.body?['success'] == true) {
        final contact = (response.body['data']?['contact'] as Map<String, dynamic>?) ?? {};

        customerContact.value = contact;

        final countryCode = (contact['countryCode'] ?? '').toString();
        final phoneNumber = (contact['phoneNumber'] ?? '').toString();

        final phone = '$countryCode$phoneNumber';

        if (phoneNumber.isNotEmpty) {
          final Uri phoneUri = Uri(scheme: 'tel', path: phone);

          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          } else {
            Get.snackbar('Error', 'Could not open phone dialer', snackPosition: SnackPosition.TOP);
          }
        } else {
          Get.snackbar('Error', 'Customer phone number not available', snackPosition: SnackPosition.TOP);
        }

        print(response.body);
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to load contact', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
      print(e.toString());
    }
  }

  static const Map<int, String> _statusForStep = {0: 'confirmed', 1: 'pickup_done', 2: 'in_transit', 3: 'delivered'};

  Future<void> advanceTimeline() async {
    final trip = selectedTrip.value;
    if (trip == null) return;

    final completedCount = getCompletedTimelineCount();
    final backendStatus = _statusForStep[completedCount];

    if (backendStatus != null && trip.id.isNotEmpty) {
      isUpdatingStatus.value = true;
      try {
        final response = await _api.updateShipmentStatus(id: trip.id, status: backendStatus);
        if (!(response.isOk && response.body?['success'] == true)) {
          Get.snackbar('Error', response.body?['message'] ?? 'Failed to update trip status', snackPosition: SnackPosition.TOP);
          return;
        }
      } catch (e) {
        Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
        return;
      } finally {
        isUpdatingStatus.value = false;
      }
    }

    for (int i = 0; i < trip.timeline.length; i++) {
      if (!trip.timeline[i].completed) {
        trip.timeline[i] = TimelineEvent(status: trip.timeline[i].status, label: trip.timeline[i].label, dateTime: _currentDateTime(), completed: true);
        break;
      }
    }
    selectedTrip.refresh();
    trips.refresh();

    // Then reconcile with the backend's authoritative tracking timeline.
    if (trip.id.isNotEmpty) fetchTracking(trip.id);
  }

  String _currentDateTime() {
    final now = DateTime.now();
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    return '${now.day} ${months[now.month]}, ${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $amPm';
  }

  int getCompletedTimelineCount() {
    return selectedTrip.value?.timeline.where((e) => e.completed).length ?? 0;
  }

  String getNextActionLabel() {
    final count = getCompletedTimelineCount();
    switch (count) {
      case 0:
        return 'Start Trip';
      case 1:
        return 'Reached Pickup';
      case 2:
        return 'Confirm Pickup';
      case 3:
        return 'Start Transit';
      case 4:
        return 'Mark Delivered';
      default:
        return 'Complete';
    }
  }

  /// Opens the gallery so the driver can pick one or more delivery photos.
  Future<void> pickDeliveryPhotos() async {
    if (deliveryPhotos.length >= 5) {
      Get.snackbar('Photo Limit', 'You can upload a maximum of 5 delivery photos.', snackPosition: SnackPosition.TOP);
      return;
    }

    isPickingPhoto.value = true;

    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1600, maxHeight: 1600);

      if (picked.isEmpty) return;

      final remaining = 5 - deliveryPhotos.length;

      final selected = picked.take(remaining);

      deliveryPhotos.addAll(selected.map((file) => file.path));

      if (picked.length > remaining) {
        Get.snackbar('Photo Limit', 'Only 5 delivery photos can be uploaded.', snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open gallery: $e', snackPosition: SnackPosition.TOP);
    } finally {
      isPickingPhoto.value = false;
    }
  }

  void removeDeliveryPhoto(int index) {
    if (index < 0 || index >= deliveryPhotos.length) return;
    deliveryPhotos.removeAt(index);
  }

  /// Opens the gallery so the driver can pick the customer's signature image.
  Future<void> pickSignatureFromGallery() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1200, maxHeight: 1200);
      if (picked == null) return;
      signaturePath.value = picked.path;
      hasSignature.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to open gallery: $e', snackPosition: SnackPosition.TOP);
    }
  }

  void clearSignature() {
    signaturePath.value = null;
    hasSignature.value = false;
  }

  void resetPOD() {
    deliveryPhotos.clear();
    hasSignature.value = false;
    signaturePath.value = null;
  }

  String _fileToBase64(String path) => base64Encode(File(path).readAsBytesSync());

  /// Submits the proof of delivery: uploads the signature (if captured) via
  /// `POST /driver/signature/upload`, then creates the POD record via
  /// `POST /driver/pod/create`. Returns true only if the POD was created.
  Future<bool> submitProofOfDelivery() async {
    final trip = selectedTrip.value;

    if (trip == null || trip.id.isEmpty) {
      Get.snackbar('Error', 'Invalid trip information', snackPosition: SnackPosition.TOP);
      return false;
    }

    if (deliveryPhotos.isEmpty) {
      Get.snackbar('Photo Required', 'Please add at least one delivery photo.', snackPosition: SnackPosition.TOP);
      return false;
    }

    if (!hasSignature.value || signaturePath.value == null) {
      Get.snackbar('Signature Required', 'Please capture the customer signature.', snackPosition: SnackPosition.TOP);
      return false;
    }

    isSubmittingPOD.value = true;

    try {
      // ============================================================
      // 1. Upload customer signature
      // ============================================================

      final signatureResponse = await _api.uploadSignature(shipmentId: trip.id, image: signaturePath.value!);

      print('Signature response: ${signatureResponse.body}');

      if (!(signatureResponse.isOk && signatureResponse.body?['success'] == true)) {
        Get.snackbar('Error', signatureResponse.body?['message'] ?? 'Failed to upload signature', snackPosition: SnackPosition.TOP);
        return false;
      }

      // ============================================================
      // 2. Upload POD images
      // ============================================================

      final imageUrls = <String>[];

      for (final imagePath in deliveryPhotos) {
        try {
          final imageUrl = await _api.uploadPODImage(shipmentId: trip.id, imagePath: imagePath);

          if (imageUrl != null && imageUrl.isNotEmpty) {
            imageUrls.add(imageUrl);
          }
        } catch (e) {
          print('Failed to upload POD image: $e');

          Get.snackbar('Error', 'Failed to upload one of the delivery images.', snackPosition: SnackPosition.TOP);

          return false;
        }
      }

      print('Uploaded POD image URLs: $imageUrls');

      // Make sure all images were uploaded
      if (imageUrls.isEmpty) {
        Get.snackbar('Error', 'No POD images were uploaded.', snackPosition: SnackPosition.TOP);
        return false;
      }

      // ============================================================
      // 3. Create POD with image URLs
      // ============================================================
      print(trip.id);
      final podResponse = await _api.createPOD(shipmentId: trip.id, imageUrls: imageUrls);

      print('POD response: ${podResponse.body}');

      if (podResponse.isOk && podResponse.body?['success'] == true) {
        return true;
      }

      Get.snackbar('Error', podResponse.body?['message'] ?? 'Failed to submit proof of delivery', snackPosition: SnackPosition.TOP);

      return false;
    } catch (e) {
      print('POD submission error: $e');

      Get.snackbar('Error', 'Failed to submit proof of delivery: $e', snackPosition: SnackPosition.TOP);

      return false;
    } finally {
      isSubmittingPOD.value = false;
    }
  }
}
