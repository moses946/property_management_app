import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _adminIdKey = 'admin_id';
  static const String _adminDataKey = 'admin_data';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Store auth data
  Future<void> setAuthData({
    required String token,
    required String adminId,
    required Map<String, dynamic> adminData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_adminIdKey, adminId),
      prefs.setString(_adminDataKey, json.encode(adminData)),
    ]);
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get admin ID
  Future<String?> getAdminId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminIdKey);
  }

  // Get admin data
  Future<Map<String, dynamic>?> getAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final adminDataString = prefs.getString(_adminDataKey);
    if (adminDataString != null) {
      return json.decode(adminDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }

  // Clear auth data (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_adminIdKey),
      prefs.remove(_adminDataKey),
    ]);
  }
}
