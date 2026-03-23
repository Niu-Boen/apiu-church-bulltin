import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/bulletin/presentation/widgets/bulletin_item_model.dart';

/// 公告本地存储服务
/// 用于持久化 bulletin 数据
class BulletinStorageService {
  static const String _bulletinsKey = 'bulletin_items';

  /// 保存所有 bulletin 条目
  static Future<bool> saveBulletins(List<BulletinItem> bulletins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = bulletins.map((item) => _itemToJson(item)).toList();
      final jsonString = jsonEncode(jsonList);
      final result = await prefs.setString(_bulletinsKey, jsonString);
      debugPrint('Saved ${bulletins.length} bulletins to local storage');
      return result;
    } catch (e) {
      debugPrint('Error saving bulletins: $e');
      return false;
    }
  }

  /// 加载所有 bulletin 条目
  static Future<List<BulletinItem>> loadBulletins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_bulletinsKey);

      if (jsonString == null) {
        debugPrint('No bulletins found in local storage');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      final bulletins = jsonList
          .map((json) => _itemFromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('Loaded ${bulletins.length} bulletins from local storage');
      return bulletins;
    } catch (e) {
      debugPrint('Error loading bulletins: $e');
      return [];
    }
  }

  /// 添加单个 bulletin 条目
  static Future<bool> addBulletin(BulletinItem item) async {
    try {
      final bulletins = await loadBulletins();
      bulletins.add(item);
      return await saveBulletins(bulletins);
    } catch (e) {
      debugPrint('Error adding bulletin: $e');
      return false;
    }
  }

  /// 更新 bulletin 条目
  static Future<bool> updateBulletin(BulletinItem oldItem, BulletinItem newItem) async {
    try {
      final bulletins = await loadBulletins();
      final index = bulletins.indexWhere((item) => item.title == oldItem.title && item.time == oldItem.time);
      if (index != -1) {
        bulletins[index] = newItem;
        return await saveBulletins(bulletins);
      }
      return false;
    } catch (e) {
      debugPrint('Error updating bulletin: $e');
      return false;
    }
  }

  /// 删除 bulletin 条目
  static Future<bool> deleteBulletin(BulletinItem item) async {
    try {
      final bulletins = await loadBulletins();
      final result = bulletins.remove(item);
      if (result) {
        return await saveBulletins(bulletins);
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting bulletin: $e');
      return false;
    }
  }

  /// 清空所有 bulletins
  static Future<bool> clearBulletins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(_bulletinsKey);
      debugPrint('Cleared all bulletins from local storage');
      return result;
    } catch (e) {
      debugPrint('Error clearing bulletins: $e');
      return false;
    }
  }

  /// 将 BulletinItem 转换为 JSON
  static Map<String, dynamic> _itemToJson(BulletinItem item) {
    return {
      'title': item.title,
      'time': item.time,
      'description': item.description,
      'servicePersonnel': item.servicePersonnel,
      'iconCodepoint': item.icon.codePoint,
      'iconFontFamily': item.icon.fontFamily,
      'publishDate': item.publishDate.toIso8601String(),
      'isDraft': item.isDraft,
      'scheduledDate': item.scheduledDate?.toIso8601String(),
    };
  }

  /// 从 JSON 创建 BulletinItem
  static BulletinItem _itemFromJson(Map<String, dynamic> json) {
    return BulletinItem(
      title: json['title'] as String,
      time: json['time'] as String,
      description: json['description'] as String,
      servicePersonnel: json['servicePersonnel'] as String?,
      icon: IconData(
        json['iconCodepoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
      ),
      publishDate: DateTime.parse(json['publishDate'] as String),
      isDraft: json['isDraft'] as bool? ?? false,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
    );
  }
}
