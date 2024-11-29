// providers/building_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/building.dart';
import '../models/unit.dart';
import '../services/api_service.dart';
// import 'package:shared_preferences.dart';
import '../services/auth_service.dart';

class BuildingProvider with ChangeNotifier {
  List<Building> _buildings = [];
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  // Getters
  List<Building> get buildings => [..._buildings];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBuildings => _buildings.isNotEmpty;

  // Find building by ID
  Building? findById(String id) {
    try {
      return _buildings.firstWhere((building) => building.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get units for a specific building
  List<Unit> unitsForBuilding(String buildingId) {
    final building = findById(buildingId);
    return building?.units ?? [];
  }

  // Fetch buildings for the logged-in admin
  Future<void> fetchBuildings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final adminId =
          await _getAdminId(); // Implement this method based on your auth storage
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/buildings/admin/$adminId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await _getAuthToken()}', // Implement this method
        },
      );

      print("Fetch Buildings by admin ID: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> buildingsData = json.decode(response.body);
        _buildings =
            buildingsData.map((json) => Building.fromJson(json)).toList();
        _error = null;
      } else if (response.statusCode == 404) {
        _buildings = [];
        _error = 'No buildings found';
      } else {
        _error = 'Failed to load buildings';
        _buildings = [];
      }
    } catch (e) {
      _error = 'Error connecting to server';
      _buildings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new building
  Future<bool> addBuilding({
    required String name,
    required String location,
    required int totalFloors,
    required int unitsPerFloor,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final adminId = await _getAdminId();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/buildings/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode({
          'name': name,
          'location': location,
          'totalFloors': totalFloors,
          'unitsPerFloor': unitsPerFloor,
          'adminId': adminId,
        }),
      );

      print(response.body);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final newBuilding = Building.fromJson(responseData['building']);
        _buildings.add(newBuilding);
        _error = null;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Failed to add building';
        return false;
      }
    } catch (e) {
      _error = 'Error connecting to server';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get admin ID from storage
  Future<String> _getAdminId() async {
    final adminId = await _authService.getAdminId();
    if (adminId == null) {
      throw Exception('Admin ID not found');
    }
    return adminId;
  }

  // Helper method to get auth token
  Future<String> _getAuthToken() async {
    final token = await _authService.getAuthToken();
    if (token == null) {
      throw Exception('Auth token not found');
    }
    return token;
  }

  // Check if admin has any buildings
  bool adminHasBuildings() {
    return _buildings.isNotEmpty;
  }

  // Get building count
  int get buildingCount => _buildings.length;

  // Clear buildings (useful for logout)
  void clearBuildings() {
    _buildings = [];
    _error = null;
    notifyListeners();
  }
}
