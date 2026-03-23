import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _guestName;

  UserModel? get currentUser => _currentUser;
  String? get guestName => _guestName;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isEditor => _currentUser?.isEditor ?? false;
  bool get isLoggedIn => _currentUser != null || _guestName != null;
  bool get isGuest => _currentUser == null && _guestName != null;

  void login(UserModel user) {
    _currentUser = user;
    _guestName = null; // 清除访客信息
    notifyListeners();
  }

  void loginAsGuest(String name) {
    _guestName = name;
    _currentUser = null; // 清除用户信息
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _guestName = null;
    notifyListeners();
  }
}
