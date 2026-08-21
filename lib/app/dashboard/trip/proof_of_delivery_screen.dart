import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/notification/notification_controller.dart';
import 'package:komutan/app/dashboard/notification/notification_screen.dart';
import 'package:komutan/app/dashboard/trip/trip_controller.dart';
import 'package:komutan/utils/app_colors.dart';
import 'package:komutan/widgets/common_widgets.dart';

import 'pod_preview_screen.dart';

class ProofOfDeliveryScreen extends StatelessWidget {
  const ProofOfDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();
    final trip = controller.selectedTrip.value!;
    final notificationController = Get.isRegistered<NotificationController>() ? Get.find<NotificationController>() : Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Get.back()),
        title: const Text('Proof of Delivery'),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_none, size: 26), onPressed: () => Get.to(() => const NotificationScreen())),
              Obx(
                () => notificationController.unreadCount.value > 0
                    ? Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // Trip header
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip.tripNo, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(
                              trip.customerName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusBadge(status: trip.status),
                            const SizedBox(height: 4),
                            Text(trip.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    NavigateCallButtons(onNavigate: controller.fetchRoute, onCall: controller.fetchContact),
                  ],
                ),
              ),

              // Delivery Photos
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Photos',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    // Upload area — opens the gallery to pick real photos
                    Obx(
                      () => GestureDetector(
                        onTap: controller.isPickingPhoto.value ? null : controller.pickDeliveryPhotos,
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.divider, style: BorderStyle.solid, width: 1.5),
                          ),
                          child: controller.isPickingPhoto.value
                              ? const Center(child: CircularProgressIndicator())
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload_outlined, size: 28, color: AppColors.textSecondary),
                                    SizedBox(height: 6),
                                    Text('Upload Photos', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Photo thumbnails (actual picked images)
                    Obx(
                      () => controller.deliveryPhotos.isEmpty
                          ? const SizedBox()
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(
                                controller.deliveryPhotos.length,
                                (index) => _PhotoThumbnail(path: controller.deliveryPhotos[index], onRemove: () => controller.removeDeliveryPhoto(index)),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // Customer Signature
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Signature',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Obx(
                        () => controller.hasSignature.value && controller.signaturePath.value != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(controller.signaturePath.value!), width: double.infinity, height: 120, fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: controller.clearSignature,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: controller.pickSignatureFromGallery,
                                child: const Center(
                                  child: Text('Tap to add signature', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Timestamp & location
                    const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Timestamp', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text('5/22/2026, 6:03:16 PM', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text('19.0641°N, 73.1236°E', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: PrimaryButton(
                label: 'Submit Proof Of Delivery',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  if (controller.deliveryPhotos.isEmpty) {
                    Get.snackbar('Photo Required', 'Please add at least one delivery photo before submitting.', snackPosition: SnackPosition.TOP);
                    return;
                  }
                  if (!controller.hasSignature.value) {
                    Get.snackbar('Signature Required', 'Please capture the customer signature before submitting.', snackPosition: SnackPosition.TOP);
                    return;
                  }
                  Get.to(() => const PODPreviewScreen());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _PhotoThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _PhotoThumbnail({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(path), width: 72, height: 72, fit: BoxFit.cover),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
