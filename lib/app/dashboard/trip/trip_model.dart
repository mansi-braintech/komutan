enum TripStatus { assigned, inTransit, delivered }

enum TripTimelineStatus { accepted, reachedPickup, pickupCompleted, inTransit, delivered }

class TimelineEvent {
  final TripTimelineStatus status;
  final String label;
  final String? dateTime;
  final bool completed;

  TimelineEvent({
    required this.status,
    required this.label,
    this.dateTime,
    required this.completed,
  });
}

class TripModel {
  final String tripNo;
  final String customerName;
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
    required this.tripNo,
    required this.customerName,
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
}

List<TripModel> mockTrips = [
  TripModel(
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
    specialInstructions:
        'Handle with care. Unload at Bay 3. Contact warehouse manager Mr. Patel on arrival.',
    status: TripStatus.assigned,
    timeline: [
      TimelineEvent(
        status: TripTimelineStatus.accepted,
        label: 'Accepted',
        dateTime: '11 May, 04:34 PM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.reachedPickup,
        label: 'Reached Pickup',
        completed: false,
      ),
      TimelineEvent(
        status: TripTimelineStatus.pickupCompleted,
        label: 'Pickup Completed',
        completed: false,
      ),
      TimelineEvent(
        status: TripTimelineStatus.inTransit,
        label: 'In Transit',
        completed: false,
      ),
      TimelineEvent(
        status: TripTimelineStatus.delivered,
        label: 'Delivered',
        completed: false,
      ),
    ],
  ),
  TripModel(
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
    specialInstructions:
        'Handle with care. Unload at Bay 3. Contact warehouse manager Mr. Patel on arrival.',
    status: TripStatus.inTransit,
    timeline: [
      TimelineEvent(
        status: TripTimelineStatus.accepted,
        label: 'Accepted',
        dateTime: '9 May, 09:10 AM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.reachedPickup,
        label: 'Reached Pickup',
        dateTime: '9 May, 10:45 AM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.pickupCompleted,
        label: 'Pickup Completed',
        dateTime: '9 May, 11:20 AM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.inTransit,
        label: 'In Transit',
        dateTime: '9 May, 11:30 AM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.delivered,
        label: 'Delivered',
        completed: false,
      ),
    ],
  ),
  TripModel(
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
    specialInstructions:
        'Handle with care. Unload at Bay 3. Contact warehouse manager Mr. Patel on arrival.',
    status: TripStatus.delivered,
    timeline: [
      TimelineEvent(
        status: TripTimelineStatus.accepted,
        label: 'Accepted',
        dateTime: '7 May, 08:05 AM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.reachedPickup,
        label: 'Reached Pickup',
        dateTime: '7 May, 09:30 AM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.pickupCompleted,
        label: 'Pickup Completed',
        dateTime: '7 May, 10:00 AM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.inTransit,
        label: 'In Transit',
        dateTime: '7 May, 10:15 AM',
        completed: true,
      ),
      TimelineEvent(
        status: TripTimelineStatus.delivered,
        label: 'Delivered',
        dateTime: '7 May, 03:40 PM',
        completed: true,
      ),
    ],
  ),
];
