// providers/unit_provider.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/unit.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;

class UnitProvider with ChangeNotifier {
  List<Unit> _units = [];
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Unit> get units => [..._units];

  Future<void> fetchUnitsForBuilding(String buildingId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/units/building/$buildingId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<Unit> loadedUnits = [];
        final extractedData = json.decode(response.body) as List;

        // Check for buildings with no registered units.
        if (extractedData.isNotEmpty) {
          for (var unitData in extractedData) {
            loadedUnits.add(Unit.fromJson(unitData));
          }
          _units = loadedUnits;
          _error = '';
        } else {
          _error = '';
          _units = [];
        }
      } else {
        _error = 'Failed to load units';
        _units = [];
      }
    } catch (e) {
      print(e);
      _error = 'Error connecting to server';
      _units = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Unit> getUnitById(String unitId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/units/$unitId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Unit.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load unit');
      }
    } catch (e) {
      print('Error fetching unit: $e');
      throw Exception('Failed to fetch unit');
    }
  }

  Future<void> addUnit(Map<String, dynamic> unitData) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/units/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(unitData),
      );
      if (response.statusCode == 201) {
        final newUnit = Unit.fromJson(json.decode(response.body)["unit"]);
        _units.add(newUnit);
        notifyListeners();
      } else {
        throw Exception('Failed to add unit');
      }
    } catch (e) {
      print('Error adding unit: $e');
      throw Exception('Failed to add unit');
    }
  }

  Future<void> updateUnit(String unitId, Map<String, dynamic> unitData) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/units/$unitId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(unitData),
      );
      if (response.statusCode == 200) {
        final newUnit = json.decode(response.body)["unit"];
        final updatedUnit = Unit.fromJson(newUnit);
        final unitIndex = _units.indexWhere((unit) => unit.id == unitId);
        if (unitIndex >= 0) {
          _units[unitIndex] = updatedUnit;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update unit');
      }
    } catch (e) {
      print('Error updating unit: $e');
      throw Exception('Failed to update unit');
    }
  }

  Future<void> deleteUnit(String unitId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/units/$unitId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _units.removeWhere((unit) => unit.id == unitId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete unit');
      }
    } catch (e) {
      print('Error deleting unit: $e');
      throw Exception('Failed to delete unit');
    }
  }

  // Clear units (useful when leaving building view)
  void clearUnits() {
    _units = [];
    _error = null;
    notifyListeners();
  }
}
