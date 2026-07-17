import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Get.back()),
        title: const Text('Proof of Delivery'),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_none, size: 26), onPressed: () {}),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
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
                    const NavigateCallButtons(),
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
                    // Upload area
                    GestureDetector(
                      onTap: () {
                        // Simulate adding a photo
                        controller.addDeliveryPhoto('photo_${controller.deliveryPhotos.length + 1}');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider, style: BorderStyle.solid, width: 1.5),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_outlined, size: 28, color: AppColors.textSecondary),
                            SizedBox(height: 6),
                            Text('Upload Photos', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Photo thumbnails
                    Obx(
                      () => controller.deliveryPhotos.isEmpty
                          ? const SizedBox()
                          : Wrap(spacing: 8, runSpacing: 8, children: List.generate(controller.deliveryPhotos.length, (index) => _PhotoThumbnail(index: index))),
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
                        () => controller.hasSignature.value
                            ? Center(
                                child: CustomPaint(size: const Size(200, 80), painter: _SignaturePainter()),
                              )
                            : GestureDetector(
                                onTap: () => _showSignatureDialog(context, controller),
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
                    Get.snackbar('Photo Required', 'Please add at least one delivery photo before submitting.', snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  if (!controller.hasSignature.value) {
                    Get.snackbar('Signature Required', 'Please capture the customer signature before submitting.', snackPosition: SnackPosition.BOTTOM);
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

  void _showSignatureDialog(BuildContext context, TripController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Signature'),
        content: const Text('Signature capture simulated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.setSignature(true);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final int index;
  const _PhotoThumbnail({required this.index});

  @override
  Widget build(BuildContext context) {
    // Show different placeholder colors to simulate photos
    final colors = [const Color(0xFF78909C), const Color(0xFF8D6E63)];
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(color: colors[index % 2], borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          // Simulate delivery photo
          Center(child: Icon(index == 0 ? Icons.handshake_outlined : Icons.inventory_2_outlined, color: Colors.white70, size: 30)),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(20, 60);
    path.cubicTo(40, 20, 60, 80, 80, 40);
    path.cubicTo(100, 10, 120, 70, 140, 50);
    path.cubicTo(160, 30, 170, 60, 190, 55);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
