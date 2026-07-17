import 'package:get/get.dart';
import 'package:komutan/app/dashboard/trip/trip_model.dart';

class TripController extends GetxController {
  final RxList<TripModel> trips = <TripModel>[].obs;
  final Rx<TripModel?> selectedTrip = Rx<TripModel?>(null);
  final RxInt selectedTabIndex = 0.obs;
  final RxInt bottomNavIndex = 1.obs;

  // Proof of delivery
  final RxList<String> deliveryPhotos = <String>[].obs;
  final RxBool hasSignature = false.obs;

  @override
  void onInit() {
    super.onInit();
    trips.assignAll(mockTrips);
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
  }

  void advanceTimeline() {
    final trip = selectedTrip.value;
    if (trip == null) return;

    // Find next uncompleted timeline event and complete it
    for (int i = 0; i < trip.timeline.length; i++) {
      if (!trip.timeline[i].completed) {
        trip.timeline[i] = TimelineEvent(status: trip.timeline[i].status, label: trip.timeline[i].label, dateTime: _currentDateTime(), completed: true);
        break;
      }
    }
    selectedTrip.refresh();
    trips.refresh();
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

  void addDeliveryPhoto(String path) {
    deliveryPhotos.add(path);
  }

  void setSignature(bool value) {
    hasSignature.value = value;
  }

  void resetPOD() {
    deliveryPhotos.clear();
    hasSignature.value = false;
  }
}
