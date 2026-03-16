import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CommonName {
  final String id;
  final String name;
  final String role;

  CommonName({required this.id, required this.name, required this.role});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role};

  factory CommonName.fromJson(Map<String, dynamic> json) => CommonName(
        id: json['id'],
        name: json['name'],
        role: json['role'],
      );
}

class CommonNamesService {
  static const String _key = 'common_names';
  List<CommonName> _names = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _names = jsonList.map((e) => CommonName.fromJson(e)).toList();
    } else {
      // 初始化默认常用姓名
      _names = [
        CommonName(id: '1', name: 'Pr. Jane Smith', role: 'Speaker'),
        CommonName(id: '2', name: 'Elder John Doe', role: 'Leader'),
        CommonName(id: '3', name: 'Sarah Johnson', role: 'Coordinator'),
        CommonName(id: '4', name: 'Mark Chen', role: 'Youth Leader'),
      ];
      await save(); // 保存默认值
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(_names.map((n) => n.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  List<CommonName> getNames() => _names;

  void addName(CommonName name) {
    _names.add(name);
    save();
  }

  void removeName(String id) {
    _names.removeWhere((n) => n.id == id);
    save();
  }
}