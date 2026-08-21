class SendOtpResponse {
  final String userId; // pass this back as `_id` to /verify
  final String? otpDebug; // backend currently echoes the OTP — remove reliance once it's SMS-only

  SendOtpResponse({required this.userId, this.otpDebug});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return SendOtpResponse(userId: (data['userId'] ?? '').toString(), otpDebug: data['otp']?.toString());
  }
}

class DriverModel {
  final String? id;
  final String? email;
  final String? drivingLicenseImage;
  final String? companyName;
  final String? profileImage;

  final String fullName;
  final String countryCode;
  final String phoneNumber;
  final String licenseNumber;
  final String licenseType;
  final String licenseExpiry;
  final String status;

  DriverModel({
    this.id,
    this.email,
    this.drivingLicenseImage,
    this.companyName,
    this.profileImage,
    required this.fullName,
    required this.countryCode,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.licenseType,
    required this.licenseExpiry,
    required this.status,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final owner = json['Owner'] as Map<String, dynamic>?;
    return DriverModel(
      id: json['_id']?.toString(),
      email: json['email']?.toString(),
      drivingLicenseImage: json['drivingLicenseImage']?.toString(),
      companyName: owner?['companyName']?.toString(),
      profileImage: json['profileImage']?.toString(),
      fullName: (json['fullName'] ?? '').toString(),
      countryCode: (json['countryCode'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      licenseNumber: (json['licenseNumber'] ?? '').toString(),
      licenseType: (json['licenseType'] ?? '').toString(),
      licenseExpiry: (json['licenseExpiry'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "drivingLicenseImage": drivingLicenseImage,
    "companyName": companyName,
    "profileImage": profileImage,
    "fullName": fullName,
    "countryCode": countryCode,
    "phoneNumber": phoneNumber,
    "licenseNumber": licenseNumber,
    "licenseType": licenseType,
    "licenseExpiry": licenseExpiry,
    "status": status,
  };
}

class VerifyOtpResponse {
  final String token;
  final DriverModel driver;

  VerifyOtpResponse({required this.token, required this.driver});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return VerifyOtpResponse(token: (data['token'] ?? '').toString(), driver: DriverModel.fromJson(data));
  }
}
