enum TripStatus { assigned, inTransit, delivered }

enum TripTimelineStatus { accepted, reachedPickup, pickupCompleted, inTransit, delivered }

class TimelineEvent {
  final TripTimelineStatus status;
  final String label;
  final String? dateTime;
  final bool completed;

  TimelineEvent({required this.status, required this.label, this.dateTime, required this.completed});
}

class TripModel {
  final String id; // shipment `_id`, used for all shipment-scoped API calls
  final String rawStatus; // raw backend status string (e.g. "pickup_done")
  final String tripNo;
  final String customerName;
  final String customerId; // createdBy `_id`, used as the chat `receiver`
  final String date;
  final String pickupCity;
  final String pickupAddress;
  final String deliveryCity;
  final String deliveryAddress;
  final String cargoType;
  final String weight;
  final String description;
  final String specialInstructions;
  final TripStatus status;
  List<TimelineEvent> timeline;

  TripModel({
    required this.id,
    required this.rawStatus,
    required this.tripNo,
    required this.customerName,
    this.customerId = '',
    required this.date,
    required this.pickupCity,
    required this.pickupAddress,
    required this.deliveryCity,
    required this.deliveryAddress,
    required this.cargoType,
    required this.weight,
    required this.description,
    required this.specialInstructions,
    required this.status,
    required this.timeline,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final pickup = json['pickup'] as Map<String, dynamic>? ?? {};
    final delivery = json['delivery'] as Map<String, dynamic>? ?? {};
    final createdBy = json['createdBy'] as Map<String, dynamic>? ?? {};

    final status = _statusFromString(json['status']?.toString());

    return TripModel(
      id: (json['_id'] ?? '').toString(),
      rawStatus: (json['status'] ?? '').toString(),
      tripNo: (json['orderId'] ?? json['_id'] ?? '').toString(),
      customerName: (createdBy['fullName'] ?? '').toString(),
      customerId: (createdBy['_id'] ?? '').toString(),
      date: _formatDate(pickup['date']?.toString()),
      pickupCity: (pickup['city'] ?? '').toString(),
      pickupAddress: _formatAddress(pickup),
      deliveryCity: (delivery['city'] ?? '').toString(),
      deliveryAddress: _formatAddress(delivery),
      cargoType: (json['loadType'] ?? json['transportMode'] ?? '').toString(),
      weight: json['weightKg'] != null ? '${json['weightKg']} KG' : '',
      description: (json['cargoDescription'] ?? '').toString(),
      specialInstructions: (json['specialHandling'] ?? '').toString(),
      status: status,
      // The backend only exposes the current `status`, not a per-step
      // timeline with timestamps, so the individual events below are
      // inferred (completed up to the current status) rather than
      // pulled from real event data.
      timeline: _timelineFromStatus(status),
    );
  }

  static String _formatAddress(Map<String, dynamic> location) {
    final parts = [location['address'], location['city'], location['state'], location['country']].where((p) => p != null && p.toString().trim().isNotEmpty).map((p) => p.toString()).toList();
    return parts.join(', ');
  }

  static String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${parsed.day} ${months[parsed.month]} ${parsed.year}';
  }

  static TripStatus _statusFromString(String? status) {
    switch (status) {
      case 'in_transit':
      case 'inTransit':
      case 'picked_up':
        return TripStatus.inTransit;
      case 'delivered':
      case 'completed':
        return TripStatus.delivered;
      case 'assigned':
      default:
        return TripStatus.assigned;
    }
  }

  static List<TimelineEvent> _timelineFromStatus(TripStatus status) {
    final order = [TripTimelineStatus.accepted, TripTimelineStatus.reachedPickup, TripTimelineStatus.pickupCompleted, TripTimelineStatus.inTransit, TripTimelineStatus.delivered];
    final labels = {
      TripTimelineStatus.accepted: 'Accepted',
      TripTimelineStatus.reachedPickup: 'Reached Pickup',
      TripTimelineStatus.pickupCompleted: 'Pickup Completed',
      TripTimelineStatus.inTransit: 'In Transit',
      TripTimelineStatus.delivered: 'Delivered',
    };

    // How far along `order` counts as "completed" for a given trip status.
    final completedUpTo = switch (status) {
      TripStatus.assigned => 0, // just "Accepted"
      TripStatus.inTransit => 3, // through "In Transit"
      TripStatus.delivered => 4, // all steps
    };

    return List.generate(order.length, (i) {
      return TimelineEvent(status: order[i], label: labels[order[i]]!, completed: i <= completedUpTo);
    });
  }

  /// Builds a real timeline from `GET /driver/shipment/tracking`, which
  /// returns the driver's actual per-step progress (label/completed/timestamp)
  /// instead of the inferred-from-status placeholder above.
  static List<TimelineEvent> timelineFromTracking(List<dynamic> timeline) {
    return timeline.map((e) {
      final map = e as Map<String, dynamic>;
      return TimelineEvent(
        status: TripTimelineStatus.accepted, // display only relies on label/completed here
        label: (map['label'] ?? '').toString(),
        dateTime: _formatTimestamp(map['timestamp']?.toString()),
        completed: map['completed'] == true,
      );
    }).toList();
  }

  static String? _formatTimestamp(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return null;
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return null;
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final amPm = parsed.hour >= 12 ? 'PM' : 'AM';
    return '${parsed.day} ${months[parsed.month]}, ${hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')} $amPm';
  }
}

List<TripModel> mockTrips = [
  TripModel(
    id: 'mock-1',
    rawStatus: '',
    tripNo: 'TRP-20260501',
    customerName: 'Mehta Electronics Pvt Ltd',
    date: '8 May 2026',
    pickupCity: 'New York',
    pickupAddress: '123 Broadway, New York, NY 10001, USA',
    deliveryCity: 'New York',
    deliveryAddress: '789 Madison Avenue, New York, NY 10065, USA',
    cargoType: 'Electronic',
    weight: '12000 KG',
    description: 'Samsung LED TV panels - 240 units',
    specialInstructions: 'Handle with care. Unload at Bay 3. Contact warehouse manager Mr. Patel on arrival.',
    status: TripStatus.assigned,
    timeline: [
      TimelineEvent(status: TripTimelineStatus.accepted, label: 'Accepted', dateTime: '11 May, 04:34 PM', completed: true),
      TimelineEvent(status: TripTimelineStatus.reachedPickup, label: 'Reached Pickup', completed: false),
      TimelineEvent(status: TripTimelineStatus.pickupCompleted, label: 'Pickup Completed', completed: false),
      TimelineEvent(status: TripTimelineStatus.inTransit, label: 'In Transit', completed: false),
      TimelineEvent(status: TripTimelineStatus.delivered, label: 'Delivered', completed: false),
    ],
  ),
  TripModel(
    id: 'mock-2',
    rawStatus: '',
    tripNo: 'TRP-20260428',
    customerName: 'Mehta Electronics Pvt Ltd',
    date: '8 May 2026',
    pickupCity: 'New York',
    pickupAddress: '123 Broadway, New York, NY 10001, USA',
    deliveryCity: 'New York',
    deliveryAddress: '789 Madison Avenue, New York, NY 10065, USA',
    cargoType: 'Electronic',
    weight: '12000 KG',
    description: 'Samsung LED TV panels - 240 units',
    specialInstructions: 'Handle with care. Unload at Bay 3. Contact warehouse manager Mr. Patel on arrival.',
    status: TripStatus.inTransit,
    timeline: [
      TimelineEvent(status: TripTimelineStatus.accepted, label: 'Accepted', dateTime: '9 May, 09:10 AM', completed: true),
      TimelineEvent(status: TripTimelineStatus.reachedPickup, label: 'Reached Pickup', dateTime: '9 May, 10:45 AM', completed: true),
      TimelineEvent(status: TripTimelineStatus.pickupCompleted, label: 'Pickup Completed', dateTime: '9 May, 11:20 AM', completed: true),
      TimelineEvent(status: TripTimelineStatus.inTransit, label: 'In Transit', dateTime: '9 May, 11:30 AM', completed: true),
      TimelineEvent(status: TripTimelineStatus.delivered, label: 'Delivered', completed: false),
    ],
  ),
  TripModel(
    id: 'mock-3',
    rawStatus: '',
    tripNo: 'TRP-20260415',
    customerName: 'Mehta Electronics Pvt Ltd',
    date: '8 May 2026',
    pickupCity: 'New York',
    pickupAddress: '123 Broadway, New York, NY 10001, USA',
    deliveryCity: 'New York',
    deliveryAddress: '789 Madison Avenue, New York, NY 10065, USA',
    cargoType: 'Electronic',
    weight: '12000 KG',
    description: 'Samsung LED TV panels - 240 units',
    specialInstructions: 'Handle with care. Unload at Bay 3. Contact warehouse manager Mr. Patel on arrival.',
    status: TripStatus.delivered,
    timeline: [
      TimelineEvent(status: TripTimelineStatus.accepted, label: 'Accepted', dateTime: '7 May, 08:05 AM', completed: true),
      TimelineEvent(status: TripTimelineStatus.reachedPickup, label: 'Reached Pickup', dateTime: '7 May, 09:30 AM', completed: true),
      TimelineEvent(status: TripTimelineStatus.pickupCompleted, label: 'Pickup Completed', dateTime: '7 May, 10:00 AM', completed: true),
      TimelineEvent(status: TripTimelineStatus.inTransit, label: 'In Transit', dateTime: '7 May, 10:15 AM', completed: true),
      TimelineEvent(status: TripTimelineStatus.delivered, label: 'Delivered', dateTime: '7 May, 03:40 PM', completed: true),
    ],
  ),
];
