class DashboardStats {
  final int totalTrips;
  final int totalCompletedTrips;
  final int inTransit;
  final num rating;
  final String currentStatus;

  DashboardStats({required this.totalTrips, required this.totalCompletedTrips, required this.inTransit, required this.rating, this.currentStatus = ''});

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return DashboardStats(
      // Backend returns lowerCamelCase keys (totalTrips, totalCompletedTrips, inTransit),
      // not the TitleCase keys this used to look for — that mismatch meant every
      // dashboard stat silently rendered as 0.
      totalTrips: int.tryParse(data['totalTrips']?.toString() ?? '') ?? 0,
      totalCompletedTrips: int.tryParse(data['totalCompletedTrips']?.toString() ?? '') ?? 0,
      inTransit: int.tryParse(data['inTransit']?.toString() ?? '') ?? 0,
      rating: num.tryParse(data['rating']?.toString() ?? '') ?? 0,
      currentStatus: (data['currentStatus'] ?? '').toString(),
    );
  }

  static DashboardStats empty() => DashboardStats(totalTrips: 0, totalCompletedTrips: 0, inTransit: 0, rating: 0);
}
