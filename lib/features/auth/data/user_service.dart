import '../domain/models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final List<User> _users = [
    User(username: 'admin', password: 'admin', role: UserRole.admin),
    User(username: 'user1', password: 'user1', role: UserRole.user),
  ];

  List<User> get users => List.unmodifiable(_users);

  /// 注册新用户，返回是否成功（用户名不重复）
  bool addUser(
    String username,
    String password, {
    UserRole role = UserRole.user,
  }) {
    if (_users.any((u) => u.username == username)) {
      return false;
    }
    _users.add(User(username: username, password: password, role: role));
    return true;
  }

  /// 登录验证
  User? authenticate(String username, String password) {
    try {
      return _users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (e) {
      return null;
    }
  }
}
