import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/payment.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class PaymentProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  TenantLedger? _ledger;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  TenantLedger? get ledger => _ledger;

  Future<void> fetchTenantLedger(String tenantId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/tenants/$tenantId/ledger'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _ledger = TenantLedger.fromJson(data);
      } else {
        throw Exception('Failed to load ledger');
      }
    } catch (e) {
      _error = 'Failed to load ledger: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPayment(
      String tenantId, double amount, String description) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/tenants/$tenantId/payments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'description': description,
          'type': 'payment',
        }),
      );

      if (response.statusCode == 201) {
        await fetchTenantLedger(tenantId);
      } else {
        throw Exception('Failed to add payment');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCharge(
      String tenantId, double amount, String description) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/tenants/$tenantId/charges'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'description': description,
          'type': 'charge',
        }),
      );

      if (response.statusCode == 201) {
        await fetchTenantLedger(tenantId);
      } else {
        throw Exception('Failed to add charge');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
