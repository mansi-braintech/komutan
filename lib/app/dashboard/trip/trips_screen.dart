import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/trip/trip_controller.dart';
import 'package:komutan/app/dashboard/trip/trip_detail_screen.dart';
import 'package:komutan/app/dashboard/trip/trip_model.dart';
import 'package:komutan/utils/app_colors.dart';
import 'package:komutan/widgets/common_widgets.dart';

class TripsScreen extends StatelessWidget {
  TripsScreen({super.key});

  final TripController controller = Get.put(TripController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () {}),
        title: const Text('Trips'),
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
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            child: Obx(() => _TripsTabBar(selectedIndex: controller.selectedTabIndex.value, onTap: (index) => controller.selectedTabIndex.value = index)),
          ),
          Expanded(
            child: Obx(() {
              final trips = controller.filteredTrips;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  return _TripCard(
                    trip: trips[index],
                    onTap: () {
                      controller.selectTrip(trips[index]);
                      Get.to(() => const TripDetailScreen());
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  const _TripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                      trip.date,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                StatusBadge(status: trip.status),
              ],
            ),
            const SizedBox(height: 12),
            AddressRow(isPickup: true, city: trip.pickupCity, address: trip.pickupAddress),
            const SizedBox(height: 8),
            AddressRow(isPickup: false, city: trip.deliveryCity, address: trip.deliveryAddress),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 10),
            TripInfoChips(cargoType: trip.cargoType, weight: trip.weight, date: trip.date),
          ],
        ),
      ),
    );
  }
}

class _TripsTabBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _TripsTabBar({required this.selectedIndex, required this.onTap});

  @override
  State<_TripsTabBar> createState() => _TripsTabBarState();
}

class _TripsTabBarState extends State<_TripsTabBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.selectedIndex);
    // Tab changes are reported through TabBar's own `onTap` below; the
    // controller here only exists to sync animations, so no listener is
    // needed and we avoid firing widget.onTap twice per tap.
  }

  @override
  void didUpdateWidget(_TripsTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _tabController.animateTo(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: _tabController,
      onTap: widget.onTap,
      labelColor: AppColors.primary,
      indicatorColor: AppColors.primary,
      tabs: const [
        Tab(text: 'All'),
        Tab(text: 'Active'),
        Tab(text: 'Completed'),
      ],
    );
  }
}
