import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/auth_response.dart';

class AuthService extends GetxService {
  final _box = GetStorage();

  static const _tokenKey = 'auth_token';
  static const _driverKey = 'driver_profile';

  String? get token => _box.read<String>(_tokenKey);

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  DriverModel? get driver {
    final raw = _box.read(_driverKey);
    if (raw == null) return null;
    return DriverModel.fromJson(jsonDecode(raw));
  }

  Future<void> saveSession(VerifyOtpResponse response) async {
    await _box.write(_tokenKey, response.token);
    await _box.write(_driverKey, jsonEncode(response.driver.toJson()));
  }

  /// Refreshes the cached driver profile (e.g. after GET /driver/profile)
  /// without touching the auth token.
  Future<void> updateDriver(DriverModel driver) async {
    await _box.write(_driverKey, jsonEncode(driver.toJson()));
  }

  Future<void> logout() async {
    await _box.remove(_tokenKey);
    await _box.remove(_driverKey);
  }
}
