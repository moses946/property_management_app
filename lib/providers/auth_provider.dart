import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String _jwtToken = '';

  String get jwtToken => _jwtToken;

  void setJwtToken(String token) {
    _jwtToken = token;
    notifyListeners();
  }
}
