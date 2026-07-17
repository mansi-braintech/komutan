import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/bottom/navigation_controller.dart';
import 'package:komutan/app/dashboard/home/home_controller.dart';
import 'package:komutan/app/dashboard/trip/trip_controller.dart';
import 'package:komutan/app/dashboard/trip/trip_detail_screen.dart';
import 'package:komutan/app/dashboard/trip/trip_model.dart';
import 'package:komutan/utils/app_colors.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 22, child: Icon(Icons.person, color: Colors.black54, size: 26)),

                      SizedBox(width: 10.w),

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome", style: TextStyle(color: Colors.grey)),
                          Text("Travis Barker", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),

                  Stack(
                    children: [
                      const Icon(Icons.notifications_none, size: 28),
                      Positioned(
                        right: 0,
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              const Text("YOUR STATUS", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13)),

              SizedBox(height: 10.h),

              /// STATUS
              Obx(
                () => Row(
                  children: controller.statuses.map((status) {
                    final isSelected = controller.selectedStatus.value == status;

                    return GestureDetector(
                      onTap: () => controller.changeStatus(status),
                      child: Container(
                        margin: EdgeInsets.only(right: 10.w),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected ? controller.getStatusColor(status).withOpacity(0.1) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? controller.getStatusColor(status) : Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: isSelected ? controller.getStatusColor(status) : Colors.grey),
                            SizedBox(width: 6.w),
                            Text(status),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 20.h),

              /// STATS
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  statCard("342", "TOTAL TRIPS", Image.asset("assets/icons/icon1.png")),

                  statCard("3", "COMPLETED", Image.asset("assets/icons/icon2.png")),

                  statCard("1", "IN TRANSIT", Image.asset("assets/icons/icon3.png")),

                  statCard("4.8", "RATING", Image.asset("assets/icons/icon4.png")),
                ],
              ),

              SizedBox(height: 20.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Active Trips", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                  GestureDetector(
                    onTap: () {
                      // Switch the bottom nav to the Trips tab.
                      if (Get.isRegistered<NavBarController>()) {
                        Get.find<NavBarController>().changeIndex(1);
                      }
                    },
                    child: const Text("View All", style: TextStyle(color: AppColors.secondary)),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              /// ACTIVE TRIP CARD
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(blurRadius: 10, offset: const Offset(0, 5), color: Colors.black.withOpacity(0.05))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TRP-20260501", style: TextStyle(color: Colors.grey)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: const Text("Assigned", style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                        ),
                      ],
                    ),

                    // SizedBox(height: 2.h),
                    const Text("Mehta Electronics Pvt Ltd", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),

                    SizedBox(height: 12.h),

                    locationStep(title: "Pickup", mainText: "New York", subText: "123 Broadway, New York, NY 10001, USA", color: Colors.green),

                    SizedBox(height: 12.h),

                    locationStep(title: "Delivery", mainText: "New York", subText: "789 Madison Avenue, New York, NY 10065, USA", color: AppColors.primary, isLast: true),

                    SizedBox(height: 12.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Image.asset("assets/icons/Frame.png"), SizedBox(width: 4), Text("Electronic")]),
                        Row(children: [Image.asset("assets/icons/Frame1.png"), SizedBox(width: 4), Text("12000 KG")]),
                        Row(children: [Image.asset("assets/icons/Frame2.png"), SizedBox(width: 4), Text("May 5")]),
                      ],
                    ),

                    SizedBox(height: 15.h),

                    GestureDetector(
                      onTap: () {
                        final tripController = Get.isRegistered<TripController>() ? Get.find<TripController>() : Get.put(TripController());
                        final TripModel activeTrip = tripController.trips.firstWhere((t) => t.status != TripStatus.delivered, orElse: () => tripController.trips.first);
                        tripController.selectTrip(activeTrip);
                        Get.to(() => const TripDetailScreen());
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget locationStep({required String title, required String mainText, required String subText, required Color color, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast) Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(mainText, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget statCard(String value, String title, Widget icon) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            // decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: icon,
          ),

          SizedBox(width: 10.w),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
