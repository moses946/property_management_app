// providers/tenant_provider.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:property_management_app/providers/unit_provider.dart';
import '../models/tenant.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TenantProvider with ChangeNotifier {
  List<Tenant> _tenants = [];
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Tenant> get tenants => [..._tenants];

  // Get tenant by ID
  Tenant? getTenantById(String id) {
    try {
      return _tenants.firstWhere((tenant) => tenant.id == id);
    } catch (e) {
      return null; // Return null if tenant not found
    }
  }

  // Fetch tenants for a specific building
  Future<void> fetchBuildingTenants(String buildingId, {String? status}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      String url = '${ApiService.baseUrl}/tenants/building/$buildingId';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response: ${response.body}');
      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> tenantsData = json.decode(response.body);
        _tenants = tenantsData.map((data) => Tenant.fromJson(data)).toList();
        _error = null;
      } else if (response.statusCode == 404) {
        _error = 'No tenants found.';
        _tenants = [];
      } else {
        _error = 'Failed to load tenants';
        _tenants = [];
      }
    } catch (e) {
      print('Error fetching tenants: $e');
      _error = 'Error connecting to server';
      _tenants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new tenant
  Future<void> addTenant(Map<String, dynamic> tenantData) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/tenants/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(tenantData),
      );
      print('Response: ${response.body}');
      print(response.statusCode);

      if (response.statusCode == 201) {
        final newTenant =
            Tenant.fromJson(json.decode(response.body)['formattedTenant']);
        _tenants.add(newTenant);
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add tenant');
      }
    } catch (e) {
      print('Error adding tenant: $e');
      throw Exception('Failed to add tenant');
    }
  }

  // Update tenant details
  Future<void> updateTenant(
      String tenantId, Map<String, dynamic> tenantData) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/tenants/$tenantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(tenantData),
      );

      if (response.statusCode == 200) {
        // Update the tenant in the local list
        final updatedTenant = Tenant.fromJson(json.decode(response.body));
        final index = _tenants.indexWhere((t) => t.id == tenantId);
        if (index >= 0) {
          _tenants[index] = updatedTenant;
        }
        notifyListeners();
      } else {
        throw Exception('Failed to update tenant');
      }
    } catch (e) {
      print('Error updating tenant: $e');
      throw Exception('Failed to update tenant');
    }
  }

  // Update tenant status (e.g., mark as vacated)
  Future<void> updateTenantStatus(Tenant tenant, String status) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      tenant.printTenant();
      final unitProvider = UnitProvider();
      unitProvider.updateUnit(tenant.unit['_id'], {"status": "Vacant"});

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/tenants/${tenant.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'tenancyStatus': status}),
      );

      if (response.statusCode == 200) {
        final updatedTenant =
            Tenant.fromJson(json.decode(response.body)['tenant']);
        final index = _tenants.indexWhere((t) => t.id == tenant.id);
        if (index >= 0) {
          _tenants[index] = updatedTenant;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update tenant status');
      }
    } catch (e) {
      print('Error updating tenant status: $e');
      throw Exception('Failed to update tenant status');
    }
  }

  // Delete tenant
  Future<void> deleteTenant(String tenantId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/tenants/$tenantId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _tenants.removeWhere((tenant) => tenant.id == tenantId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete tenant');
      }
    } catch (e) {
      print('Error deleting tenant: $e');
      throw Exception('Failed to delete tenant');
    }
  }

  // Clear tenants (useful when logging out or changing buildings)
  void clearTenants() {
    _tenants = [];
    _error = null;
    notifyListeners();
  }
}
