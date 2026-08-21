import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/notification/notification_controller.dart';
import 'package:komutan/app/dashboard/notification/notification_screen.dart';
import 'package:komutan/app/dashboard/trip/trip_controller.dart';
import 'package:komutan/utils/app_colors.dart';
import 'package:komutan/widgets/common_widgets.dart';

class PODPreviewScreen extends StatelessWidget {
  const PODPreviewScreen({super.key});

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
        title: const Text('Preview'),
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
              // Review header
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 40, color: Color(0xFF5C6BC0)),
                    SizedBox(height: 8),
                    Text(
                      'Review Before Submitting',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text('Please verify all details are correct', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),

              // Trip Summary
              _SectionBlock(
                title: 'Trip Summary',
                child: Column(
                  children: [
                    _InfoRow(label: 'Trip No.', value: trip.tripNo),
                    _InfoRow(label: 'Customer', value: trip.customerName),
                    _InfoRow(label: 'Cargo', value: '${trip.cargoType} • ${trip.weight}'),
                  ],
                ),
              ),

              // Location & Time
              _SectionBlock(
                title: 'Location & Time',
                child: Column(
                  children: [
                    _IconInfoRow(icon: Icons.access_time_outlined, iconColor: const Color(0xFF2E7D32), label: 'Timestamp', value: '11 May 2026, 06:40:06 PM'),
                    const SizedBox(height: 10),
                    _IconInfoRow(icon: Icons.location_on_outlined, iconColor: AppColors.secondary, label: 'GPS Location (Geo-tagged)', value: '19.0641°N, 73.1236°E'),
                  ],
                ),
              ),

              // Delivery Photos
              Obx(
                () => _SectionBlock(
                  title: 'Delivery Photos (${controller.deliveryPhotos.length})',
                  child: controller.deliveryPhotos.isEmpty
                      ? const Text('No photos captured', style: TextStyle(fontSize: 13, color: AppColors.secondary))
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: controller.deliveryPhotos.map((path) => _PreviewPhoto(path: path)).toList(),
                        ),
                ),
              ),

              // Customer Signature
              _SectionBlock(
                title: 'Customer Signature',
                child: Obx(
                  () => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: controller.hasSignature.value && controller.signaturePath.value != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(controller.signaturePath.value!), height: 90, fit: BoxFit.contain),
                            )
                          : const Text('No Signature Captured', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Obx(
                () => PrimaryButton(
                  label: controller.isSubmittingPOD.value ? 'Submitting...' : 'Confirm & Submit POD',
                  icon: Icons.check_circle_outline,
                  onPressed: controller.isSubmittingPOD.value
                      ? () {}
                      : () async {
                          final success = await controller.submitProofOfDelivery();
                          if (success && context.mounted) _showSuccessDialog(context, controller);
                        },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, TripController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(color: Color(0xFF10B981), borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.resetPOD();
                    Get.until((route) => route.isFirst);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Confetti-like decoration
              Stack(
                alignment: Alignment.center,
                children: [
                  ..._confettiItems(),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.celebration, size: 34, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                controller.selectedTrip.value?.tripNo ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Delivery Complete!',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'POD submitted successfully. Your delivery proof has been received and verified.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    controller.resetPOD();
                    Get.until((route) => route.isFirst);
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('GO BACK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _confettiItems() {
    final items = [
      {'color': Colors.yellow, 'top': -20.0, 'left': -20.0, 'size': 12.0},
      {'color': Colors.orange, 'top': -15.0, 'right': -25.0, 'size': 10.0},
      {'color': Colors.lightGreen, 'bottom': -20.0, 'left': -15.0, 'size': 10.0},
      {'color': Colors.amber, 'bottom': -15.0, 'right': -20.0, 'size': 8.0},
    ];
    return items
        .map(
          (item) => Positioned(
            top: item['top'] as double?,
            left: item['left'] as double?,
            right: item['right'] as double?,
            bottom: item['bottom'] as double?,
            child: Container(
              width: (item['size'] as double),
              height: (item['size'] as double),
              decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle),
            ),
          ),
        )
        .toList();
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionBlock({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: AppColors.black),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _IconInfoRow({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }
}

class _PreviewPhoto extends StatelessWidget {
  final String path;
  const _PreviewPhoto({required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(File(path), width: 80, height: 80, fit: BoxFit.cover),
    );
  }
}
