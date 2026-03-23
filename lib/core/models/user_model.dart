import 'package:flutter/foundation.dart' show debugPrint;
import '../utils/date_parser.dart';

/// 用户数据模型
class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.role,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing UserModel from JSON: $json');

    final createdAtValue = json['created_at'] ?? json['createdAt'];
    final updatedAtValue = json['updated_at'] ?? json['updatedAt'];

    debugPrint('createdAt value: $createdAtValue (${createdAtValue.runtimeType})');
    debugPrint('updatedAt value: $updatedAtValue (${updatedAtValue.runtimeType})');

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['username'] ?? '',
      email: json['email']?.toString() ?? json['email'] ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      role: json['role']?.toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: DateParser.parse(createdAtValue),
      updatedAt: DateParser.parseNullable(updatedAtValue),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role?.toLowerCase() == 'admin';
  bool get isEditor => role?.toLowerCase() == 'editor' || isAdmin;
}
