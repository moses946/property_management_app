import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:property_management_app/models/tenant.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  final String jwtToken; // For handling authentication

  ApiService({required this.jwtToken});

  // Method to fetch all tenants
  Future<List<Tenant>> fetchAllTenants() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tenants'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> tenantList = json.decode(response.body);
      return tenantList.map((tenant) => Tenant.fromJson(tenant)).toList();
    } else {
      throw Exception('Failed to fetch tenants');
    }
  }

  // Method to add a new tenant
  Future<Tenant> addTenant(Tenant newTenant) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: json.encode(newTenant.toJson()),
    );

    if (response.statusCode == 201) {
      return Tenant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add tenant');
    }
  }

  // Method to update tenant information
  Future<Tenant> updateTenant(Tenant updatedTenant) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tenants/${updatedTenant.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: json.encode(updatedTenant.toJson()),
    );

    if (response.statusCode == 200) {
      return Tenant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update tenant');
    }
  }

  // Method to update the status of the tenant to "vacated"
  Future<void> updateTenantStatus(String tenantId, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/tenants/$tenantId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: json.encode({'status': status}), // Update tenant status
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update tenant status');
    }
  }

  // Method to update unit availability (when a tenant vacates a unit)
  Future<void> updateUnitAvailability(String unitId, bool isAvailable) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/units/$unitId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body:
          json.encode({'isAvailable': isAvailable}), // Update unit availability
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update unit availability');
    }
  }

  // Method to handle the deletion of a tenant record
  Future<void> deleteTenant(String tenantId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tenants/$tenantId'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete tenant');
    }
  }
}
