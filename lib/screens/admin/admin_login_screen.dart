import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../providers/building_provider.dart';
import '../../providers/unit_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../services/api_service.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Store auth data
        await _authService.setAuthData(
          token: data['token'],
          adminId: data['adminId'],
          adminData: data['adminData'],
        );

        if (mounted) {
          // Initialize all providers with the new token
          try {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading data...',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );

            // Initialize providers with the new token
            await Future.wait([
              Provider.of<BuildingProvider>(context, listen: false)
                  .fetchBuildings(),
              // Provider.of<TenantProvider>(context, listen: false)
              //     .fetchTenants(ApiService(jwtToken: data['token'])),
            ]);

            // Pop loading dialog and navigate to dashboard
            Navigator.of(context).pop();
            Navigator.pushReplacementNamed(context, '/dashboard');
          } catch (e) {
            print(e);
            // Pop loading dialog if there's an error
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading initial data')),
            );
          }
        }
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
