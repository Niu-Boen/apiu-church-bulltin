import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isEditor => _currentUser?.isEditor ?? false;

  void login(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
