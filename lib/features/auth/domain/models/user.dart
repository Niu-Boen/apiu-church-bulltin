enum UserRole { admin, user }

class User {
  final String username;
  final String password; // 实际应用中应存储哈希，此处简化
  final UserRole role;

  User({
    required this.username,
    required this.password,
    this.role = UserRole.user,
  });
}
