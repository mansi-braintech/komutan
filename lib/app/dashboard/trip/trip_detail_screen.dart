import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/notification/notification_controller.dart';
import 'package:komutan/app/dashboard/notification/notification_screen.dart';
import 'package:komutan/app/dashboard/trip/trip_controller.dart';
import 'package:komutan/app/dashboard/trip/trip_model.dart';
import 'package:komutan/utils/app_colors.dart';
import 'package:komutan/widgets/common_widgets.dart';

import '../chat/chat_screen.dart';
import 'proof_of_delivery_screen.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();
    final notificationController = Get.isRegistered<NotificationController>() ? Get.find<NotificationController>() : Get.put(NotificationController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Get.back()),
        title: const Text('Trips'),
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
      body: Obx(() {
        final trip = controller.selectedTrip.value;
        if (trip == null) return const SizedBox();
        final completedCount = controller.getCompletedTimelineCount();
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // Trip Header Card
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
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
                      AddressRow(isPickup: true, city: trip.pickupCity, address: trip.pickupAddress),
                      const SizedBox(height: 10),
                      AddressRow(isPickup: false, city: trip.deliveryCity, address: trip.deliveryAddress),
                      const SizedBox(height: 14),
                      NavigateCallButtons(onNavigate: controller.fetchRoute, onCall: controller.fetchContact),
                    ],
                  ),
                ),

                // Cargo Details
                _CargoDetailsSection(trip: trip),

                // Trip Timeline (shown after start)
                if (completedCount > 0) _TimelineSection(trip: trip),

                // Chat & Documents (shown before start)
              ],
            ),
            // Bottom Action Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(color: AppColors.background, padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), child: _buildActionButton(context, controller, completedCount)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton(BuildContext context, TripController controller, int completedCount) {
    final labels = [
      ('Start Trip', Icons.check_circle_outline),
      // ('Reached Pickup', Icons.location_on_outlined),
      ('Confirm Pickup', Icons.inventory_2_outlined),
      ('Start Transit', Icons.local_shipping_outlined),
      ('Mark Delivered', Icons.camera_alt_outlined),
    ];

    if (completedCount >= labels.length) return const SizedBox();

    final (label, icon) = labels[completedCount];
    return Obx(
      () => PrimaryButton(
        label: controller.isUpdatingStatus.value ? 'Updating...' : label,
        icon: icon,
        onPressed: controller.isUpdatingStatus.value
            ? () {}
            : () async {
                await controller.advanceTimeline();
                if (completedCount == labels.length - 1) {
                  // Mark Delivered → go to POD
                  Get.to(() => const ProofOfDeliveryScreen());
                }
              },
      ),
    );
  }
}

class _CargoDetailsSection extends StatelessWidget {
  final TripModel trip;
  const _CargoDetailsSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Removes top & bottom divider
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: const Text(
            'Cargo Details',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TYPE',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(trip.cargoType, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'WEIGHT',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(trip.weight, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(trip.description, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SPECIAL INSTRUCTIONS',
                          style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 6),
                        Text(trip.specialInstructions, style: const TextStyle(fontSize: 13, color: AppColors.warning)),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (trip.customerId.isEmpty) {
                                Get.snackbar('Chat unavailable', 'No customer contact found for this trip', snackPosition: SnackPosition.TOP);
                                return;
                              }
                              Get.to(() => ChatScreen(receiverId: trip.customerId, receiverName: trip.customerName));
                            },
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: const Text('Chat'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.divider),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.description_outlined, size: 18),
                            label: const Text('Documents'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.divider),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final TripModel trip;

  const _TimelineSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Removes top & bottom divider
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          title: const Text(
            'Trip Timeline',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TimelineWidget(events: trip.timeline),
            ),
          ],
        ),
      ),
    );
  }
}
